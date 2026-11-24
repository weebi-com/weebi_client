import 'package:flutter/foundation.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_admin/environment.dart';
import 'package:web_admin/grpc/server.dart';
import 'package:web_admin/core/session/bff_session_store.dart';
import 'package:web_admin/core/auth/signup_session.dart';
import 'package:web_admin/core/phone/boutique_phone_display.dart';
import '../models/sign_in_result.dart';
import '../models/sign_up_result.dart';
import 'grpc_client_service.dart';
import '../constants/values.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

class AuthService {
  final GrpcClientService _grpcClientService = GrpcClientService();

  SignInResult _handleSignInError(e) {
    if (e is GrpcError) {
      return SignInResult(success: false, errorMessage: e.message);
    } else {
      return SignInResult(success: false, errorMessage: e.toString());
    }
  }

  SignUpResult _handleSignUpError(e) {
    if (e is GrpcError) {
      return SignUpResult(success: false, errorMessage: e.message);
    } else {
      return SignUpResult(success: false, errorMessage: e.toString());
    }
  }

  Future<void> _saveTokens(String accessToken, String refreshToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(SharePrefKeys.accessToken, accessToken);
    await prefs.setString(SharePrefKeys.refreshToken, refreshToken);
  }

  Future<void> _persistAuth(
    Tokens tokens, {
    bool persistSession = true,
  }) async {
    await _saveTokens(tokens.accessToken, tokens.refreshToken);
    if (Config.isBffMode && tokens.sessionId.isNotEmpty) {
      await BffSessionStore.setSessionId(
        tokens.sessionId,
        persist: persistSession,
      );
    }
  }

  Future<bool> _shouldPersistBffSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(SharePrefKeys.stayConnected) ?? true;
  }

  Phone? _accountPhone({int? countryCode, String nationalNumber = ''}) {
    final number = nationalNumber.trim();
    if (countryCode == null || countryCode <= 0 || number.isEmpty) return null;
    return Phone(countryCode: countryCode, number: number);
  }

  bool _tokensProveAuth(Tokens tokens) => signupAuthSucceeded(
        isBffMode: Config.isBffMode,
        accessToken: tokens.accessToken,
        sessionId: tokens.sessionId,
      );

  CallOptions _authenticatedOptions(Tokens tokens) {
    if (Config.isBffMode) return securedCallOptions;
    return CallOptions(metadata: {'authorization': tokens.accessToken});
  }

  Future<SignInResult> signIn({
    required String mail,
    required String password,
    bool stayConnected = true,
  }) async {
    final stub = FenceServiceClient(_grpcClientService.channel,
        options: callOptions);

    try {
      final response = await stub.authenticateWithCredentials(
        Credentials(
          mail: mail,
          password: password,
          isWebApp: Config.isBffMode,
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(SharePrefKeys.stayConnected, stayConnected);
      await _persistAuth(response, persistSession: stayConnected);

      return SignInResult(
        success: true,
        message: "",
        accessToken: response.accessToken,
        sessionId: response.sessionId,
        mustChangePassword: response.mustChangePassword,
      );
    } catch (e) {
      return _handleSignInError(e);
    }
  }

  /// Boss path: signUp → authent → createFirm → refresh (firmId in session).
  /// Invited path (`UPDATED`): signUp → authent, skip createFirm.
  ///
  /// [phoneCountryCode] and [phoneNationalNumber] are the account phone.
  /// They are stored on the user and stamped on the default boutique.
  Future<SignUpResult> signUp({
    required String firmName,
    required String firstName,
    required String lastName,
    required String mail,
    required String password,
    int? phoneCountryCode,
    String phoneNationalNumber = '',
  }) async {
    final stub = FenceServiceClient(
      _grpcClientService.channel,
      options: callOptions,
    );

    try {
      final response = await stub.signUp(
        SignUpRequest(
          firstname: firstName,
          lastname: lastName,
          mail: mail,
          password: password,
          phone: _accountPhone(
            countryCode: phoneCountryCode,
            nationalNumber: phoneNationalNumber,
          ),
        ),
      );

      final statusType = response.statusResponse.type;
      if (statusType != StatusResponse_Type.CREATED &&
          statusType != StatusResponse_Type.UPDATED) {
        return SignUpResult(
          success: false,
          errorMessage: response.statusResponse.message.isNotEmpty
              ? response.statusResponse.message
              : 'Signup failed',
        );
      }

      final tokens = await stub.authenticateWithCredentials(
        Credentials(
          mail: mail,
          password: password,
          isWebApp: Config.isBffMode,
        ),
      );

      if (!_tokensProveAuth(tokens)) {
        return _handleSignUpError('authentication failed after signup');
      }
      await _persistAuth(tokens);

      final isPendingJoin = statusType == StatusResponse_Type.UPDATED;
      if (isPendingJoin) {
        return SignUpResult(
          success: true,
          userId: response.userId,
          firmCreated: false,
          accessToken: tokens.accessToken,
          sessionId: tokens.sessionId,
        );
      }

      final firmRequest = CreateFirmRequest(name: firmName);
      if (mail.trim().isNotEmpty) {
        firmRequest.boutiqueMail = mail.trim();
      }
      final boutiquePhone = formatBoutiquePhone(
        countryCode: phoneCountryCode ?? 0,
        number: phoneNationalNumber,
      );
      if (boutiquePhone.isNotEmpty) {
        firmRequest.boutiquePhone = boutiquePhone;
      }
      final firmResponse = await stub.createFirm(
        firmRequest,
        options: _authenticatedOptions(tokens),
      );
      if (firmResponse.statusResponse.type != StatusResponse_Type.CREATED) {
        return SignUpResult(
          success: false,
          userId: response.userId,
          errorMessage: firmResponse.statusResponse.message.isNotEmpty
              ? firmResponse.statusResponse.message
              : 'firm could not be created',
        );
      }

      await installFirmCredential(firmResponse);

      return SignUpResult(
        success: true,
        userId: response.userId,
        firmCreated: true,
        accessToken: firmResponse.accessToken,
        sessionId: firmResponse.sessionId.isNotEmpty
            ? firmResponse.sessionId
            : tokens.sessionId,
      );
    } catch (e) {
      return _handleSignUpError(e);
    }
  }

  /// Requests a password reset email for the given address.
  /// Returns (success, errorMessage).
  Future<(bool success, String? errorMessage)> requestPasswordReset({
    required String mail,
  }) async {
    final stub = FenceServiceClient(_grpcClientService.channel);

    try {
      final response = await stub.requestPasswordReset(
        PasswordResetRequest(mail: mail),
      );
      final ok = response.type == StatusResponse_Type.SUCCESS ||
          response.type == StatusResponse_Type.UPDATED;
      return (ok, ok ? null : response.message);
    } on GrpcError catch (e) {
      return (false, e.message);
    } catch (e) {
      return (false, e.toString());
    }
  }

  /// Stores the credential [createFirm] just minted. No second login.
  /// In BFF mode the server already rewrote the current session.
  Future<void> installFirmCredential(CreateFirmResponse response) async {
    if (Config.isBffMode) {
      if (response.sessionId.isNotEmpty) {
        await BffSessionStore.setSessionId(
          response.sessionId,
          persist: await _shouldPersistBffSession(),
        );
      }
      return;
    }
    if (response.accessToken.isEmpty) {
      throw StateError('firm credential missing');
    }
    await _saveTokens(response.accessToken, response.refreshToken);
  }

  /// Public RPC: exchanges a one-time App->Web bridge token for a BFF session.
  /// Envoy sets `weebi_session_id` from [Tokens.sessionId] on the response.
  Future<Tokens> exchangeWebBridgeToken(String token) async {
    final stub = FenceServiceClient(
      _grpcClientService.channel,
      options: callOptions,
    );
    final response = await stub.exchangeWebBridgeToken(
      ExchangeWebBridgeTokenRequest(token: token),
    );
    if (Config.isBffMode && response.sessionId.isNotEmpty) {
      await BffSessionStore.setSessionId(response.sessionId);
    }
    return response;
  }

  Future<Tokens> authenticateWithRefreshToken() async {
    final stub = FenceServiceClient(_grpcClientService.channel);

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(SharePrefKeys.accessToken);
      final refreshToken = prefs.getString(SharePrefKeys.refreshToken) ?? '';

      final options = Config.isBffMode
          ? securedCallOptions
          : accessToken == null || accessToken.isEmpty
              ? callOptions
              : securedCallOptions.mergedWith(
                  CallOptions(metadata: {'authorization': accessToken}),
                );

      final response = await stub.authenticateWithRefreshToken(
        RefreshToken(
          refreshToken: refreshToken,
          isWebApp: Config.isBffMode,
        ),
        options: options,
      );

      if (Config.isBffMode && response.sessionId.isNotEmpty) {
        await BffSessionStore.setSessionId(
          response.sessionId,
          persist: await _shouldPersistBffSession(),
        );
      }

      return response;
    } catch (e) {
      debugPrint('Erreur lors de authenticateWithRefreshToken: $e');
      rethrow;
    }
  }

  /// Invalidates the server BFF session. Envoy clears the cookie on this path.
  /// Failures are swallowed so local logout still proceeds.
  Future<void> logout() async {
    try {
      final stub = FenceServiceClient(
        _grpcClientService.channel,
        options: securedCallOptions,
      );
      await stub.logout(Empty());
    } catch (e) {
      debugPrint('FenceService.logout failed: $e');
    }
  }
}
