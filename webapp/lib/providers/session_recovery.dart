import 'dart:async';

import 'package:auth_weebi/auth_weebi.dart'
    show AccessTokenProvider, AuthServiceAbstract, PersistedTokenProvider;
import 'package:boutiques_weebi/boutiques_weebi.dart' show BoutiqueProvider;
import 'package:flutter/foundation.dart';
import 'package:grpc/grpc.dart' as grpc;
import 'package:web_admin/core/services/auth_service.dart';
import 'package:web_admin/environment.dart';
import 'package:web_admin/providers/current_user_provider.dart';
import 'package:web_admin/providers/operational_license_gate.dart';
import 'package:web_admin/providers/tickets_boutique_cache.dart';
import 'package:web_admin/providers/user_data_provider.dart';

/// Static hook so gRPC interceptors can recover the session without a
/// [BuildContext].
class SessionRecoveryBinding {
  SessionRecoveryBinding._();
  static final instance = SessionRecoveryBinding._();

  SessionRecoveryCoordinator? _coordinator;

  void attach(SessionRecoveryCoordinator coordinator) {
    _coordinator = coordinator;
  }

  void noteIfUnauthenticated(Object error) {
    if (error is! grpc.GrpcError ||
        error.code != grpc.StatusCode.unauthenticated) {
      return;
    }

    unawaited(_coordinator?.recoverFromUnauthenticated());
  }

  Future<void> ensureSessionForRequest(
    Map<String, String> metadata,
    String uri,
  ) async {
    await _coordinator?.ensureSessionForRequest(metadata);
  }
}

class SessionRecoveryCoordinator {
  SessionRecoveryCoordinator({
    required this.userDataProvider,
    required this.accessTokenProvider,
    required this.persistedTokenProvider,
    required this.currentUserProvider,
    required this.boutiqueProvider,
    required this.ticketsBoutiqueCache,
    AuthService? authService,
  }) : _authService = authService ?? AuthService();

  final UserDataProvider userDataProvider;
  final AccessTokenProvider accessTokenProvider;
  final PersistedTokenProvider<AuthServiceAbstract> persistedTokenProvider;
  final CurrentUserProvider currentUserProvider;
  final BoutiqueProvider boutiqueProvider;
  final TicketsBoutiqueCache ticketsBoutiqueCache;
  final AuthService _authService;

  Future<void>? _recovery;
  bool _loggingOut = false;

  Future<void> recoverFromUnauthenticated() {
    final activeRecovery = _recovery;
    if (activeRecovery != null) return activeRecovery;

    final recovery = _recover();
    _recovery = recovery;
    recovery.whenComplete(() => _recovery = null);
    return recovery;
  }

  Future<void> ensureSessionForRequest(Map<String, String> metadata) async {
    if (Config.isBffMode && accessTokenProvider.accessToken.isEmpty) {
      return;
    }

    if (!_isAccessTokenExpired()) {
      _syncAuthorizationMetadata(metadata);
      return;
    }

    if (await _refreshTokens()) {
      _syncAuthorizationMetadata(metadata);
      return;
    }

    await forceLogout();
  }

  Future<void> _recover() async {
    if (await _refreshTokens()) {
      return;
    }

    await forceLogout();
  }

  Future<bool> _refreshTokens() async {
    try {
      final tokens = await _authService.authenticateWithRefreshToken();
      if (tokens.accessToken.isEmpty) return false;

      accessTokenProvider.accessToken = tokens.accessToken;
      await persistedTokenProvider.setAndUpsertAccessToken(tokens.accessToken);
      await userDataProvider.setUserDataAsync(
        accessToken: tokens.accessToken,
        refreshToken:
            tokens.refreshToken.isNotEmpty ? tokens.refreshToken : null,
      );

      if (tokens.refreshToken.isNotEmpty) {
        await persistedTokenProvider.setAndUpsertRefreshToken(
          tokens.refreshToken,
        );
      }

      currentUserProvider.clear();
      return true;
    } catch (e) {
      debugPrint('Session refresh failed after UNAUTHENTICATED: $e');
      return false;
    }
  }

  Future<void> forceLogout() async {
    if (_loggingOut) return;
    _loggingOut = true;

    try {
      await userDataProvider.clearSessionDataAsync();
      accessTokenProvider.clearAccessToken();
      await persistedTokenProvider.clearAccessToken();
      await persistedTokenProvider.clearRefreshToken();

      currentUserProvider.clear();
      boutiqueProvider.clearSession();
      ticketsBoutiqueCache.clear();
      OperationalLicenseGateBinding.instance.clear();
    } finally {
      _loggingOut = false;
    }
  }

  bool _isAccessTokenExpired() {
    try {
      return accessTokenProvider.isEmptyOrExpired;
    } catch (_) {
      return true;
    }
  }

  void _syncAuthorizationMetadata(Map<String, String> metadata) {
    if (Config.isBffMode) return;

    final accessToken = accessTokenProvider.accessToken;
    if (accessToken.isNotEmpty) {
      metadata['authorization'] = accessToken;
    }
  }
}
