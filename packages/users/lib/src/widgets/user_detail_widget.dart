import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:auth_weebi/auth_weebi.dart';
import 'package:provider/provider.dart';
import '../l10n/user_ui_strings.dart';
import '../providers/user_provider.dart';
import 'elegant_permissions_widget.dart';
import 'detail_view_components.dart';
import 'license_seat_status_card.dart';
import 'user_permissions_persist.dart';

bool _coerceTruthyBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.toLowerCase();
    return s == 'true' || s == '1';
  }
  return false;
}

/// JWTs may nest permissions under `permissions` or mirror flags in `boolRights`.
bool _jwtPayloadGrantsCanUpdateUserPassword(Map<String, dynamic> root) {
  bool fromUm(dynamic raw) {
    if (raw is! Map) return false;
    final m = Map<String, dynamic>.from(raw);
    return _coerceTruthyBool(m['canUpdateUserPassword']) ||
        _coerceTruthyBool(m['can_update_user_password']);
  }

  if (fromUm(root['userManagementRights'])) return true;

  final permissions = root['permissions'];
  if (permissions is Map<String, dynamic>) {
    if (fromUm(permissions['userManagementRights'])) return true;
    final br = permissions['boolRights'];
    if (br is Map<String, dynamic> &&
        _coerceTruthyBool(br['canUpdateUserPassword'])) {
      return true;
    }
  }

  final boolRights = root['boolRights'];
  if (boolRights is Map<String, dynamic> &&
      _coerceTruthyBool(boolRights['canUpdateUserPassword'])) {
    return true;
  }

  return false;
}

void _applyJwtCanUpdateUserPasswordFallback(
  BuildContext context,
  UserPermissions target,
) {
  try {
    final token =
        context.read<AccessTokenProvider>().accessToken;
    if (token.isEmpty) return;
    final payload = JsonWebToken.parse(token).payload;
    if (_jwtPayloadGrantsCanUpdateUserPassword(payload)) {
      target.ensureUserManagementRights().canUpdateUserPassword = true;
    }
  } catch (_) {}
}

/// True when the JWT carries `isFirmCreator` (works before [UserPermissions] exposes the field).
bool accessTokenMarksFirmCreator(AccessTokenProvider access) {
  final token = access.accessToken;
  if (token.isEmpty) return false;
  try {
    final jwt = JsonWebToken.parse(token);
    final p = jwt.payload;
    final root = p['isFirmCreator'] == true || p['is_firm_creator'] == true;
    if (root) return true;
    final perm = p['permissions'];
    if (perm is Map<String, dynamic>) {
      return perm['isFirmCreator'] == true || perm['is_firm_creator'] == true;
    }
  } catch (_) {}
  return false;
}

/// Widget to display user details (buttons are handled by parent scaffold)
class UserDetailWidget extends StatelessWidget {
  final UserPublic user;
  final UserProvider userProvider;
  final String? currentUserId;
  final void Function(UserPublic, UserPermissions)? onPermissionsChanged;

  /// When set (e.g. firm licenses from billing), shows whether this user has an
  /// active seat. Omit when your app does not load license data.
  final Iterable<License>? firmLicenses;

  const UserDetailWidget({
    super.key,
    required this.user,
    required this.userProvider,
    this.currentUserId,
    this.onPermissionsChanged,
    this.firmLicenses,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = currentUserId != null && user.userId == currentUserId;

    return Column(
      children: [
        DetailViewComponents.buildSummaryCard(
          title: '${user.firstname} ${user.lastname}',
          subtitle: user.mail,
          icon: Icons.person,
          avatar: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              Icons.person,
              size: 28,
              color: Colors.blue[600],
            ),
          ),
          additionalInfo: [
            if (user.phone.hasNumber())
              DetailViewComponents.buildInfoRow(
                icon: Icons.phone,
                label: UserUiStrings.labelPhone,
                value: user.phone.hasCountryCode()
                    ? '+${user.phone.countryCode} ${user.phone.number}'
                    : user.phone.number,
              ),
            DetailViewComponents.buildInfoRow(
              icon: Icons.fingerprint,
              label: UserUiStrings.labelId,
              value: user.userId,
            ),
            if (user.hasLastSignIn())
              DetailViewComponents.buildInfoRow(
                icon: Icons.schedule,
                label: UserUiStrings.labelLastSignIn,
                value: _formatTimestamp(user.lastSignIn),
              ),
          ],
        ),
        if (firmLicenses != null && user.userId.isNotEmpty) ...[
          const SizedBox(height: 16),
          LicenseSeatStatusCard(
            userId: user.userId,
            licenses: firmLicenses!,
            subjectIsFirmCreator:
                user.hasPermissions() && user.permissions.isFirmCreator,
          ),
        ],
        const SizedBox(height: 16),
        _buildPermissionsSection(isCurrentUser),
      ],
    );
  }

  Widget _buildPermissionsSection(bool isCurrentUser) {
    return _UserDetailEditablePermissions(
      user: user,
      userProvider: userProvider,
      onPermissionsChanged: onPermissionsChanged,
      userManagementReadOnly: isCurrentUser,
      userManagementSectionHint: isCurrentUser
          ? UserUiStrings.selfPermissionsReadOnlyHint
          : null,
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date =
        DateTime.fromMillisecondsSinceEpoch(timestamp.seconds.toInt() * 1000);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(date);
  }
}

class _UserDetailEditablePermissions extends StatefulWidget {
  final UserPublic user;
  final UserProvider userProvider;
  final void Function(UserPublic, UserPermissions)? onPermissionsChanged;
  final bool userManagementReadOnly;
  final String? userManagementSectionHint;

  const _UserDetailEditablePermissions({
    required this.user,
    required this.userProvider,
    this.onPermissionsChanged,
    this.userManagementReadOnly = false,
    this.userManagementSectionHint,
  });

  @override
  State<_UserDetailEditablePermissions> createState() =>
      _UserDetailEditablePermissionsState();
}

class _UserDetailEditablePermissionsState
    extends State<_UserDetailEditablePermissions> {
  UserPermissions? _permissions;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_UserDetailEditablePermissions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.userId != widget.user.userId) {
      _loading = true;
      _permissions = null;
      _load();
    }
  }

  Future<void> _load() async {
    final fetched = await widget.userProvider.getUserPermissions(
      widget.user.userId,
      forceRefresh: true,
    );

    late final UserPermissions resolved;
    if (fetched != null) {
      resolved = UserPermissions.create()..mergeFromMessage(fetched);
    } else if (widget.user.hasPermissions()) {
      resolved = UserPermissions.create()
        ..mergeFromMessage(widget.user.permissions);
    } else {
      resolved = _minimalPermissions(widget.user.userId);
    }

    if (!mounted) return;

    if (widget.userManagementReadOnly &&
        !resolved.userManagementRights.canUpdateUserPassword) {
      _applyJwtCanUpdateUserPasswordFallback(context, resolved);
    }

    setState(() {
      _permissions = resolved;
      _loading = false;
    });
  }

  UserPermissions _minimalPermissions(String userId) {
    return UserPermissions.create()
      ..userId = userId
      ..firmId = 'unknown_firm'
      ..articleRights = ArticleRights(rights: [Right.read])
      ..contactRights = ContactRights(rights: [Right.read])
      ..ticketRights = TicketRights(rights: [Right.read])
      ..boutiqueRights = BoutiqueRights.create()
      ..boolRights = BoolRights.create();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _permissions == null) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final p = _permissions!;
    final permissionsWidget = ElegantPermissionsWidget(
      key: ValueKey<String>(widget.user.userId),
      permissions: p,
      isEditable: true,
      userManagementReadOnly: widget.userManagementReadOnly,
      userManagementSectionHint: widget.userManagementSectionHint,
      showHeader: !widget.userManagementReadOnly,
      title: UserUiStrings.permissionsTitleForUser(widget.user.firstname),
      onPermissionsChanged: (updated) async {
        await persistUserPermissionsWithFeedback(
          context,
          widget.user,
          updated,
          widget.userProvider,
        );
        widget.onPermissionsChanged?.call(widget.user, updated);
        if (mounted) {
          setState(() {
            _permissions = UserPermissions.create()
              ..mergeFromMessage(updated);
          });
        }
      },
    );

    if (widget.userManagementReadOnly) {
      return Card(
        margin: const EdgeInsets.all(16),
        elevation: 2,
        key: ValueKey<String>('self_card_${widget.user.userId}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.admin_panel_settings, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      UserUiStrings.yourPermissions,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              permissionsWidget,
            ],
          ),
        ),
      );
    }

    return permissionsWidget;
  }
}
