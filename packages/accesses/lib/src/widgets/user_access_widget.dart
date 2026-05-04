import 'package:accesses_weebi/accesses_weebi.dart' show AccessProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/grpc.dart';
import 'package:users_weebi/weebi_users.dart'
    show AccessTokenProvider, LicenseSeatStatusCard, LicenseUiStrings,
        userHasActiveLicensedSeat;
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/access_ui_strings.dart';
import 'change_password_dialog.dart';

/// Widget for managing a specific user's access to boutiques and chains
class UserAccessWidget extends StatefulWidget {
  final UserPublic user;
  final String? currentUserId;

  /// Explains that operational use needs a license seat; sign-in does not.
  final bool showOperationalLicenseNotice;

  /// When set (e.g. from [readLicenses]), shows seat status for this user.
  final Iterable<License>? firmLicenses;

  const UserAccessWidget({
    super.key,
    required this.user,
    this.currentUserId,
    this.showOperationalLicenseNotice = true,
    this.firmLicenses,
  });

  @override
  State<UserAccessWidget> createState() => _UserAccessWidgetState();
}

class _UserAccessWidgetState extends State<UserAccessWidget> {
  UserPermissions? _userPermissions;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;

  // Track selected access
  bool _hasFullAccess = false;
  final Set<String> _selectedChainIds = {};
  final Set<String> _selectedBoutiqueIds = {};

  @override
  void initState() {
    super.initState();
    _loadUserPermissions();
  }

  Future<void> _loadUserPermissions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final accessProvider = context.read<AccessProvider>();
      final permissions = await accessProvider.getUserPermissions(
        widget.user.userId,
        forceRefresh: true,
      );

      setState(() {
        _userPermissions = permissions ?? UserPermissions.create();
        _initializeSelections();
        _isLoading = false;
      });
    } on GrpcError catch (e) {
      setState(() {
        _error = AccessUiStrings.failedLoadPermissionsGrpc(
            e.code, e.message ?? '');
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = AccessUiStrings.failedLoadPermissionsGeneric(e);
        _isLoading = false;
      });
    }
  }

  void _initializeSelections() {
    if (_userPermissions == null) return;

    // Check if user has full access
    if (_userPermissions!.hasFullAccess()) {
      _hasFullAccess = _userPermissions!.fullAccess.hasFullAccess;
    }

    // Load limited access selections
    if (_userPermissions!.hasLimitedAccess()) {
      _selectedChainIds.clear();
      _selectedChainIds.addAll(_userPermissions!.limitedAccess.chainIds.ids);

      _selectedBoutiqueIds.clear();
      _selectedBoutiqueIds
          .addAll(_userPermissions!.limitedAccess.boutiqueIds.ids);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = widget.currentUserId != null &&
        widget.user.userId == widget.currentUserId;
    return Consumer<AccessProvider>(
      builder: (context, accessProvider, child) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_error != null) {
          return _buildErrorWidget();
        }

        return Scaffold(
          body: Column(
            children: [
              _buildUserHeader(),
              if (widget.showOperationalLicenseNotice) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: _OperationalLicenseNotice(
                    userId: widget.user.userId,
                    licenses: widget.firmLicenses,
                    isSubjectFirmCreator: _userPermissions!.isFirmCreator,
                  ),
                ),
              ],
              if (widget.firmLicenses != null &&
                  widget.user.userId.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: LicenseSeatStatusCard(
                    userId: widget.user.userId,
                    licenses: widget.firmLicenses!,
                    subjectIsFirmCreator: _userPermissions!.isFirmCreator,
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.lock_reset),
                    label: Text(isCurrentUser
                        ? AccessUiStrings.changeMyPassword
                        : AccessUiStrings.updateUserPassword),
                    onPressed:
                        isCurrentUser || _canCurrentUserUpdatePasswords(context)
                            ? () => _showChangePasswordDialog(
                                isSelfService: isCurrentUser)
                            : null,
                  ),
                ),
              ),
              if (isCurrentUser)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.grey[700]),
                            const SizedBox(width: 8),
                            Text(
                              AccessUiStrings.readOnlyCurrentUser,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              _buildAccessSummary(accessProvider),
              const Divider(),
              Expanded(
                child: _buildAccessControls(accessProvider,
                    isReadOnly: isCurrentUser),
              ),
            ],
          ),
          floatingActionButton:
              isCurrentUser ? null : _buildSaveFloatingActionButton(),
        );
      },
    );
  }

  bool _canCurrentUserUpdatePasswords(BuildContext context) {
    try {
      final permissions = context.read<AccessTokenProvider>().permissions;
      final map = permissions.toProto3Json() as Map<String, dynamic>;
      final um = map['userManagementRights'] as Map<String, dynamic>?;
      final dynamic raw = um?['canUpdateUserPassword'];
      if (raw is bool) return raw;
      // Fallback: check boolRights in case server places it there
      final br = map['boolRights'] as Map<String, dynamic>?;
      final dynamic alt = br?['canUpdateUserPassword'];
      return alt is bool ? alt : false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _showChangePasswordDialog({bool isSelfService = false}) async {
    if (_userPermissions == null) return;
    await showDialog<bool>(
      context: context,
      builder: (ctx) => ChangePasswordDialog(
        selectedUserId: widget.user.userId,
        firmId: _userPermissions!.firmId,
        isSelfService: isSelfService,
        onPasswordChanged: () {
          // optionally refresh anything if needed
        },
      ),
    );
  }

  Widget _buildUserHeader() {
    final isCurrentUser = widget.currentUserId != null &&
        widget.user.userId == widget.currentUserId;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isCurrentUser ? Colors.blue : Colors.grey,
            radius: 24,
            child: Text(
              '${widget.user.firstname.isNotEmpty ? widget.user.firstname[0] : ''}${widget.user.lastname.isNotEmpty ? widget.user.lastname[0] : ''}',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.user.firstname} ${widget.user.lastname}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  widget.user.mail,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessSummary(AccessProvider accessProvider) {
    final chainCount = _hasFullAccess
        ? accessProvider.chains.length
        : _selectedChainIds.length;
    final boutiqueCount = _hasFullAccess
        ? accessProvider.allBoutiques.length
        : _selectedBoutiqueIds.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            icon: Icons.account_tree,
            label: AccessUiStrings.summaryChains,
            count: chainCount,
          ),
          _buildSummaryItem(
            icon: Icons.store,
            label: AccessUiStrings.summaryBoutiques,
            count: boutiqueCount,
          ),
          _buildSummaryItem(
            icon: Icons.fence,
            label: AccessUiStrings.accessLevel,
            value: _hasFullAccess
                ? AccessUiStrings.accessFull
                : AccessUiStrings.accessLimited,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    int? count,
    String? value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          count != null ? count.toString() : value ?? '',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAccessControls(AccessProvider accessProvider,
      {bool isReadOnly = false}) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFullAccessToggle(isReadOnly: isReadOnly),
          if (!_hasFullAccess) ...[
            const SizedBox(height: 16),
            _buildChainsList(accessProvider, isReadOnly: isReadOnly),
          ],
        ],
      ),
    );
  }

  Widget _buildFullAccessToggle({bool isReadOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SwitchListTile(
        title: const Text(AccessUiStrings.fullAccessToggleTitle),
        subtitle: const Text(AccessUiStrings.fullAccessToggleSubtitle),
        value: _hasFullAccess,
        onChanged: isReadOnly
            ? null
            : (value) {
                setState(() {
                  _hasFullAccess = value;
                  if (value) {
                    // Clear limited selections when granting full access
                    _selectedChainIds.clear();
                    _selectedBoutiqueIds.clear();
                  }
                });
              },
      ),
    );
  }

  Widget _buildChainsList(AccessProvider accessProvider,
      {bool isReadOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            AccessUiStrings.chainBoutiqueSectionTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        ...accessProvider.chains.map((chain) =>
            _buildChainTile(chain, accessProvider, isReadOnly: isReadOnly)),
      ],
    );
  }

  Widget _buildChainTile(Chain chain, AccessProvider accessProvider,
      {bool isReadOnly = false}) {
    final boutiques = accessProvider.getBoutiquesForChain(chain.chainId);
    final isChainSelected = _selectedChainIds.contains(chain.chainId);
    final selectedBoutiquesInChain = boutiques
        .where((b) => _selectedBoutiqueIds.contains(b.boutiqueId))
        .length;

    return ExpansionTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_tree,
            color: isChainSelected ? Colors.blue : Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 8),
          Checkbox(
            value: isChainSelected,
            onChanged: isReadOnly
                ? null
                : (value) {
                    setState(() {
                      if (value == true) {
                        _selectedChainIds.add(chain.chainId);
                        // Auto-select all boutiques in this chain
                        for (final boutique in boutiques) {
                          _selectedBoutiqueIds.add(boutique.boutiqueId);
                        }
                      } else {
                        _selectedChainIds.remove(chain.chainId);
                        // Auto-deselect all boutiques in this chain
                        for (final boutique in boutiques) {
                          _selectedBoutiqueIds.remove(boutique.boutiqueId);
                        }
                      }
                    });
                  },
          ),
        ],
      ),
      title: Text(chain.name),
      subtitle: Text(AccessUiStrings.boutiquesSelectedInChain(
          selectedBoutiquesInChain, boutiques.length)),
      children: boutiques
          .map((boutique) =>
              _buildBoutiqueTile(boutique, chain, isReadOnly: isReadOnly))
          .toList(),
    );
  }

  Widget _buildBoutiqueTile(BoutiqueMongo boutique, Chain chain,
      {bool isReadOnly = false}) {
    final isSelected = _selectedBoutiqueIds.contains(boutique.boutiqueId);

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 56.0, right: 16.0),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.store,
            color: isSelected ? Colors.blue : Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 8),
          Checkbox(
            value: isSelected,
            onChanged: isReadOnly
                ? null
                : (value) {
                    setState(() {
                      if (value == true) {
                        _selectedBoutiqueIds.add(boutique.boutiqueId);

                        // Check if all boutiques in this chain are now selected
                        final boutiquesInChain = context
                            .read<AccessProvider>()
                            .getBoutiquesForChain(chain.chainId);
                        final allSelected = boutiquesInChain.every(
                            (b) => _selectedBoutiqueIds.contains(b.boutiqueId));
                        if (allSelected) {
                          _selectedChainIds.add(chain.chainId);
                        }
                      } else {
                        _selectedBoutiqueIds.remove(boutique.boutiqueId);
                        // Uncheck the chain if a boutique is deselected
                        _selectedChainIds.remove(chain.chainId);
                      }
                    });
                  },
          ),
        ],
      ),
      title: Text(boutique.name),
      subtitle: Text(AccessUiStrings.boutiqueIdLine(boutique.boutiqueId)),
    );
  }

  Widget _buildSaveFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _isSaving ? null : _saveUserPermissions,
      icon: _isSaving
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.save),
      label: Text(_isSaving
          ? AccessUiStrings.savingAccess
          : AccessUiStrings.saveAccess),
      backgroundColor: _isSaving ? Colors.grey : Colors.blue,
      tooltip: AccessUiStrings.saveAccessTooltip,
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            AccessUiStrings.errorLoadingUserAccess,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? AccessUiStrings.unknownError,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUserPermissions,
            child: const Text(AccessUiStrings.retry),
          ),
        ],
      ),
    );
  }

  Future<void> _saveUserPermissions() async {
    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final accessProvider = context.read<AccessProvider>();

      // Create new UserPermissions based on selections
      final newPermissions = UserPermissions.create();
      newPermissions.userId = widget.user.userId;

      if (_hasFullAccess) {
        // Set full access
        final fullAccess = AccessFull.create();
        fullAccess.hasFullAccess = true;
        newPermissions.fullAccess = fullAccess;
      } else {
        // Set limited access
        final limitedAccess = AccessLimited.create();
        limitedAccess.chainIds = ChainIds.create();
        limitedAccess.chainIds.ids.addAll(_selectedChainIds);
        limitedAccess.boutiqueIds = BoutiqueIds.create();
        limitedAccess.boutiqueIds.ids.addAll(_selectedBoutiqueIds);

        newPermissions.limitedAccess = limitedAccess;
      }

      final success = await accessProvider.updateUserPermissions(
          widget.user.userId, newPermissions);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AccessUiStrings.accessUpdatedFor(
                  widget.user.firstname, widget.user.lastname)),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        setState(() {
          _error = AccessUiStrings.failedSavePermissions;
        });
      }
    } on GrpcError catch (e) {
      setState(() {
        _error = AccessUiStrings.errorSavingPermissionsGrpc(
            e.code, e.message ?? '');
      });
    } catch (e) {
      setState(() {
        _error = AccessUiStrings.errorSavingPermissionsGeneric(e);
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }
}

enum _OperationalLicenseNoticeKind {
  unknown,
  hasSeat,
  firmCreatorJokerNoSeat,
  noSeat,
}

class _OperationalLicenseNotice extends StatelessWidget {
  const _OperationalLicenseNotice({
    required this.userId,
    this.licenses,
    this.isSubjectFirmCreator = false,
  });

  final String userId;
  final Iterable<License>? licenses;

  /// [UserPermissions.isFirmCreator] for the user this screen is about.
  final bool isSubjectFirmCreator;

  _OperationalLicenseNoticeKind get _kind {
    if (licenses == null) return _OperationalLicenseNoticeKind.unknown;
    final hasSeat = userId.trim().isNotEmpty &&
        userHasActiveLicensedSeat(userId, licenses!);
    if (hasSeat) return _OperationalLicenseNoticeKind.hasSeat;
    if (isSubjectFirmCreator) {
      return _OperationalLicenseNoticeKind.firmCreatorJokerNoSeat;
    }
    return _OperationalLicenseNoticeKind.noSeat;
  }

  Future<void> _openBillingPortal(BuildContext context) async {
    final uri = Uri.parse(LicenseUiStrings.cloudLicensesPortalUrl);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: SelectableText(
              LicenseUiStrings.cloudLicensesPortalUrl,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: SelectableText(
              LicenseUiStrings.cloudLicensesPortalUrl,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final kind = _kind;
    late final String body;
    late final Color bg;
    late final Color border;
    late final Color iconColor;
    late final IconData icon;
    late final Color accent;

    switch (kind) {
      case _OperationalLicenseNoticeKind.unknown:
        body = LicenseUiStrings.accessOperationalLicenseNotice;
        bg = Colors.blue[50]!;
        border = Colors.blue[200]!;
        icon = Icons.info_outline;
        iconColor = Colors.blue[800]!;
        accent = Colors.blue[900]!;
        break;
      case _OperationalLicenseNoticeKind.hasSeat:
        body = LicenseUiStrings.accessOperationalLicenseNoticeHasSeat;
        bg = Colors.green[50]!;
        border = Colors.green[200]!;
        icon = Icons.verified_user_outlined;
        iconColor = Colors.green[800]!;
        accent = Colors.green[900]!;
        break;
      case _OperationalLicenseNoticeKind.firmCreatorJokerNoSeat:
        body = LicenseUiStrings.accessOperationalLicenseNoticeFirmCreatorJoker;
        bg = Colors.blue[50]!;
        border = Colors.blue[200]!;
        icon = Icons.business_center_outlined;
        iconColor = Colors.blue[800]!;
        accent = Colors.blue[900]!;
        break;
      case _OperationalLicenseNoticeKind.noSeat:
        body = LicenseUiStrings.accessOperationalLicenseNoticeNoSeat;
        bg = Colors.orange[50]!;
        border = Colors.orange[200]!;
        icon = Icons.warning_amber_rounded;
        iconColor = Colors.orange[900]!;
        accent = Colors.orange[900]!;
        break;
    }

    final textStyle = TextStyle(
      color: accent,
      height: 1.35,
      fontSize: 13,
    );

    return Card(
      margin: EdgeInsets.zero,
      color: bg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    body,
                    style: textStyle,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: accent,
                    ),
                    onPressed: () => _openBillingPortal(context),
                    child: Text(
                      LicenseUiStrings.accessOperationalLicenseOpenBilling,
                      style: textStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
