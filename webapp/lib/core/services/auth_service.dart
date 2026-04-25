import 'dart:async';
import 'package:protos_weebi/grpc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_admin/environment.dart';
import 'package:web_admin/grpc/server.dart';
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

  Future<SignInResult> signIn({
    required String mail,
    required String password,
  }) async {
    final stub = FenceServiceClient(_grpcClientService.channel,
        options: callOptions);

    try {
      final response = await stub.authenticateWithCredentials(
        Credentials(
          mail: mail,
          password: password,
          isWebApp: true,  // Enable BFF mode - store session server-side
        ),
      );

      await _saveTokens(response.accessToken, response.refreshToken);

      return SignInResult(
        success: true,
        message: "",
        accessToken: response.accessToken,
      );
    } catch (e) {
      return _handleSignInError(e);
    }
  }

  Future<SignUpResult> signUp({
    required String firmName,
    required String firstName,
    required String lastName,
    required String mail,
    required String password,
  }) async {
    final stub = FenceServiceClient(_grpcClientService.channel);

    try {
      final response = await stub.signUp(
        SignUpRequest(
          firstname: firstName,
          lastname: lastName,
          mail: mail,
          password: password,
        ),
      );
      final responseTokens = await stub.authenticateWithCredentials(
        Credentials(
          mail: mail,
          password: password,
          isWebApp: true,  // Enable BFF mode - store session server-side
        ),
      );

      final stub2 = FenceServiceClient(_grpcClientService.channel,
          options: CallOptions(
              metadata: {'authorization': responseTokens.accessToken}));

      /// user will not be able to create the firm
      /// we exfiltrated it from signup lobby, now we also avoid them this trap
      if (response.statusResponse.type != StatusResponse_Type.UPDATED) {
        try {
          final statusResponse =
              await stub2.createFirm(CreateFirmRequest(name: firmName));
          if (statusResponse.statusResponse.type !=
              StatusResponse_Type.CREATED) {
            throw statusResponse.toString();
          }
        } on FormatException catch (e) {
          print('createFirmServer $e');
        } on GrpcError catch (e) {
          print('createFirmServer $e');
        }
      }

          final responseTokens2 =
              response.statusResponse.type == StatusResponse_Type.UPDATED
                  ? responseTokens
                  : await stub2.authenticateWithCredentials(
                      Credentials(
                        mail: mail,
                        password: password,
                        isWebApp: true,  // Enable BFF mode - store session server-side
                      ),
                    );
      if (responseTokens2.accessToken.isEmpty) {
        return _handleSignUpError('error responseTokens2.accessToken.isEmpty');
      }

      return SignUpResult(success: true, userId: response.userId);
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

  Future<Tokens> authenticateWithRefreshToken() async {
    if (Config.isBffMode) {
      // In BFF mode, we don't manually refresh. Envoy handles it or we re-login.
      return Tokens();
    }
    final stub = FenceServiceClient(_grpcClientService.channel);

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(SharePrefKeys.accessToken);
      final refreshToken = prefs.getString(SharePrefKeys.refreshToken);

      final options = CallOptions(metadata: {'authorization': '$accessToken'});

      final response = await stub.authenticateWithRefreshToken(
        RefreshToken(refreshToken: refreshToken),
        options: options,
      );

      return response;
    } catch (e) {
      print('Erreur lors de authenticateWithRefreshToken: $e');
      rethrow;
    }
  }
}
