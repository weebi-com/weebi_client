import 'package:auth_weebi/auth_weebi.dart';
import 'package:models_weebi/models.dart'
    show DeviceCloudIdentity, SessionContext;
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:services_weebi/services_weebi.dart' show DeviceServiceAbstract;

import 'services/device_manager.dart';
import 'services/user_session.dart';
import 'services/mail_manager.dart';

/// Gatekeeper - The complete session coordination system
/// Guards access to the app through device enrollment, user authentication, and permissions
///
/// Integrates:
/// - Device enrollment and identity
/// - User session management
/// - Token coordination (access + refresh)
/// - Permission management (from JWT tokens)
/// - Mail management
class Gatekeeper<P extends DeviceServiceAbstract, A extends AuthServiceAbstract>
    implements SessionContext {
  Gatekeeper(
    P deviceService,
    this._accessTokenProvider,
    this._persistedTokenProvider, {
    UserPermissions? defaultPermissions,
  })  : device = DeviceManager(deviceService),
        session = UserSession(),
        mailManager = MailManager(deviceService),
        permissionProvider = PermissionProvider(
          _accessTokenProvider,
          defaultPermissions: defaultPermissions,
        );

  final AccessTokenProvider _accessTokenProvider;
  final PersistedTokenProvider<A> _persistedTokenProvider;

  /// Focused service managers
  final DeviceManager device;
  final UserSession session;
  final PermissionProvider permissionProvider;
  final MailManager mailManager;

  // === Backward Compatibility Layer ===
  // Delegates to appropriate services to maintain existing API

  // === SessionContext Implementation ===
  // These properties satisfy the SessionContext interface

  @override
  String get firmId => permissionProvider.firmId;

  @override
  String get chainId => device.chainId;

  @override
  String get boutiqueId => device.boutiqueId;

  @override
  String get deviceId => device.deviceId;

  @override
  bool get isLinked => device.isLinked;

  @override
  String get userId => permissionProvider.userId;

  // === Additional Properties (beyond SessionContext) ===

  bool get isFirstSync => device.isFirstSync;

  /// Device firm ID (separate from permission firmId)
  String get deviceFirmId => device.deviceFirmId;

  // User Properties (delegate to UserSession)
  String get firstName => session.firstName;
  String get lastName => session.lastName;
  String get username => session.fullName;
  String get mail => session.mail;
  Phone get phone => session.phone;

  // Permission Properties (delegate to PermissionProvider from token)
  bool get canCreateArticle => permissionProvider.canCreateArticle;
  bool get canReadArticle => permissionProvider.canReadArticle;
  bool get canUpdateArticle => permissionProvider.canUpdateArticle;
  bool get canDeleteArticle => permissionProvider.canDeleteArticle;
  bool get canCreateBoutique => permissionProvider.canCreateBoutique;
  bool get canReadBoutique => permissionProvider.canReadBoutique;
  bool get canUpdateBoutique => permissionProvider.canUpdateBoutique;
  bool get canDeleteBoutique => permissionProvider.canDeleteBoutique;
  bool get canCreateContact => permissionProvider.canCreateContact;
  bool get canReadContact => permissionProvider.canReadContact;
  bool get canUpdateContact => permissionProvider.canUpdateContact;
  bool get canDeleteContact => permissionProvider.canDeleteContact;
  bool get canCreateTicket => permissionProvider.canCreateTicket;
  bool get canReadTicket => permissionProvider.canReadTicket;
  bool get canUpdateTicket => permissionProvider.canUpdateTicket;
  bool get canDeleteTicket => permissionProvider.canDeleteTicket;
  bool get canDeleteFirm => permissionProvider.canDeleteFirm;
  //
  UserPermissions get userPermissions => permissionProvider.userPermissions;
  bool get canUpdateContactBalanceOffline =>
      permissionProvider.canUpdateContactBalanceOffline;
  bool get canSeeStats => permissionProvider.canSeeStats;
  bool get canGiveDiscount => permissionProvider.canGiveDiscount;
  bool get canExportData => permissionProvider.canExportData;
  bool get canSetPromo => permissionProvider.canSetPromo;
  // to be carried on...

  BoutiqueRights get boutiqueRights =>
      permissionProvider.userPermissions.boutiqueRights;

  // Mail Properties (delegate to MailManager)
  List<String> get userMails => mailManager.userMails;
  List<String> get userMailsFiltered => mailManager.userMailsFiltered;
  String get queryString => mailManager.queryString;
  set queryString(String val) => mailManager.queryString = val;

  // === Token Management ===

  /// Set both access and refresh tokens after login
  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessTokenProvider.accessToken = accessToken;
    await _persistedTokenProvider.setAndUpsertAccessToken(accessToken);
    await _persistedTokenProvider.setAndUpsertRefreshToken(refreshToken);
  }

  /// Clear all tokens (access + refresh) from storage and memory
  Future<void> clearAllTokens() async {
    await _persistedTokenProvider.clearAccessToken();
    await _persistedTokenProvider.clearRefreshToken();
    _accessTokenProvider.clearAccessToken();
  }

  /// Restore tokens from secure storage on app startup
  Future<void> restoreAllTokens() async {
    final accessToken = await _persistedTokenProvider.readAccessToken();
    if (accessToken.isNotEmpty) {
      _accessTokenProvider.accessToken = accessToken;
    }
    await _persistedTokenProvider.readAndSetRefreshToken();
  }

  /// Get the current refresh token
  /// Reads from secure storage and returns it
  Future<String> getRefreshToken() async {
    return await _persistedTokenProvider.readAndSetRefreshToken();
  }

  /// Get the current access token from memory
  String get accessToken => _accessTokenProvider.accessToken;

  // === High-Level Operations ===

  /// Gets current user permissions (from token)
  UserPermissions get permission => permissionProvider.userPermissions;

  /// Sets user information from UserPublic
  void setUserInfo(UserPublic user) {
    session.setUserInfo(user);
  }

  /// Clears the entire session (user info + tokens)
  /// This is the main logout method
  Future<void> clearSession() async {
    session.clearSession();
    await clearAllTokens();
  }

  /// Clears user info only (keeps tokens)
  void clearUserInfo() {
    session.clearSession();
  }

  /// Gets device cloud identity
  DeviceCloudIdentity get deviceCloudIdentity => device.deviceIdentity;

  /// Sets device cloud identity
  set deviceCloudIdentity(DeviceCloudIdentity identity) {
    device.updateDeviceIdentity(identity);
  }

  // === Composite Operations (combining multiple services) ===

  /// Reads and sets cloud identity and user mails
  Future<DeviceCloudIdentity> readAndSetCloudIdentityAndReadUserMail() async {
    try {
      final cloudIdentity = await device.loadDeviceIdentity();
      await mailManager.loadUserMails();
      return cloudIdentity;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  /// Updates cloud identity
  Future<DeviceCloudIdentity> upsertCloudIdentity(
      DeviceCloudIdentity deviceCloudIdentity) async {
    return await device.updateDeviceIdentity(deviceCloudIdentity);
  }

  /// Marks first sync as complete
  Future<DeviceCloudIdentity> updateCloudIdentityIsFirstSyncToFalse() async {
    return await device.markFirstSyncComplete();
  }

  /// Clears enrollment and all data
  Future<void> clearEnrollment() async {
    await device.clearEnrollment();
    session.clearSession();
    await clearAllTokens();
    mailManager.clearLocalMails();
  }

  /// Reads user mails
  Future<List<String>> readUserMails() async {
    return await mailManager.loadUserMails();
  }

  /// Adds a user mail
  Future<String> addUserMail(String data) async {
    return await mailManager.addUserMail(data);
  }

  /// Deletes all user mails
  Future<void> deleteAllUserMails() async {
    await mailManager.deleteAllUserMails();
  }

  // === Additional Helper Methods ===

  /// Creates a Counterfoil with current context
  Counterfoil get counterfoil => Counterfoil.create()
    ..firmId = firmId
    ..chainId = chainId
    ..boutiqueId = boutiqueId
    ..deviceId = deviceId
    ..userId = userId
    ..userName = username;

  /// Gets firm name (cached, not from token)
  String firmName = '';

  /// Gets chain name (cached, not from token)
  String chainName = '';

  /// Checks if user has an active session
  bool get hasActiveUserSession => session.hasActiveSession;

  /// Alias for isLinked
  bool get isProUser => isLinked;

  /// Check if firmIds match (for validation)
  bool get firmIdsMatch => deviceFirmId == firmId;

  /// Gets a summary of current state for debugging
  Map<String, dynamic> get statusSummary => {
        'device': {
          'isLinked': isLinked,
          'deviceFirmId': deviceFirmId,
          'deviceId': deviceId,
        },
        'session': {
          'hasUser': hasActiveUserSession,
          'userName': username,
          'userMail': mail,
        },
        'permissions': {
          'firmId': firmId,
          'userId': userId,
          'hasToken': permissionProvider.hasToken,
          'summary': permissionProvider.permissionSummary,
        },
        'mail': {
          'count': mailManager.mailCount,
          'filtered': mailManager.filteredMailCount,
        },
        'firmIdsMatch': firmIdsMatch,
      };
}
