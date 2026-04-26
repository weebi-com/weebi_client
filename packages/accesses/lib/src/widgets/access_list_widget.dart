import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:users_weebi/weebi_users.dart';

import '../l10n/access_ui_strings.dart';
import '../providers/access_provider.dart';
import '../routes/access_routes.dart';

/// Widget that displays a list of users for access management
/// Allows admins to select users and manage their boutique/chain access
class AccessListWidget extends StatefulWidget {
  final String currentUserId;
  final String? searchQuery;
  final VoidCallback? onRefresh;

  /// When set (e.g. from billing), list rows show seat status and detail gets
  /// license-aware notices.
  final Iterable<License>? firmLicenses;

  const AccessListWidget({
    super.key,
    required this.currentUserId,
    this.searchQuery,
    this.onRefresh,
    this.firmLicenses,
  });

  @override
  State<AccessListWidget> createState() => _AccessListWidgetState();
}

class _AccessListWidgetState extends State<AccessListWidget> {
  late TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery ?? '');
    _searchQuery = widget.searchQuery ?? '';
    
    // Initialize data loading after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    final accessProvider = context.read<AccessProvider>();
    await accessProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccessProvider>(
      builder: (context, accessProvider, child) {
        if (accessProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (accessProvider.error != null) {
          return _buildErrorWidget(accessProvider.error!);
        }

        final filteredUsers = _getFilteredUsers(accessProvider.users);

        return Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                child: filteredUsers.isEmpty
                    ? _buildEmptyState()
                    : _buildUserList(filteredUsers, accessProvider),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: AccessUiStrings.searchUsersHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildUserList(List<UserPublic> users, AccessProvider accessProvider) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isCurrentUser = user.userId == widget.currentUserId;
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isCurrentUser ? Colors.blue : Colors.grey,
              child: Text(
                '${user.firstname.isNotEmpty ? user.firstname[0] : ''}${user.lastname.isNotEmpty ? user.lastname[0] : ''}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text('${user.firstname} ${user.lastname}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.mail),
                if (isCurrentUser)
                  const Text(
                    AccessUiStrings.currentUser,
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),                
                const SizedBox(height: 4),
                if (widget.firmLicenses != null) ...[
                  _buildSeatBadge(user),
                  const SizedBox(height: 4),
                ],
                _buildUserAccessGlimpse(user, accessProvider),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _navigateToUserAccess(context, user),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            AccessUiStrings.errorLoadingUsers,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _handleRefresh,
            child: const Text(AccessUiStrings.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            AccessUiStrings.noUsersFound,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? AccessUiStrings.noUsersAdjustSearch
                : AccessUiStrings.noUsersForAccess,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  List<UserPublic> _getFilteredUsers(List<UserPublic> users) {
    if (_searchQuery.isEmpty) {
      return users;
    }

    final query = _searchQuery.toLowerCase();
    return users.where((user) {
      return user.firstname.toLowerCase().contains(query) ||
             user.lastname.toLowerCase().contains(query) ||
             user.mail.toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildSeatBadge(UserPublic user) {
    final licenses = widget.firmLicenses!;
    if (userHasActiveLicensedSeat(user.userId, licenses)) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Chip(
          label: Text(
            LicenseUiStrings.userListSeatBadgeActive,
            style: const TextStyle(fontSize: 11),
          ),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 6),
          backgroundColor: Colors.green.shade50,
          side: BorderSide(color: Colors.green.shade200),
        ),
      );
    }
    if (user.hasPermissions() &&
        firmCreatorOperationalJoker(user.permissions)) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Chip(
          label: Text(
            LicenseUiStrings.userListSeatBadgeCreator,
            style: const TextStyle(fontSize: 11),
          ),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          labelPadding: const EdgeInsets.symmetric(horizontal: 6),
          backgroundColor: Colors.blue.shade50,
          side: BorderSide(color: Colors.blue.shade200),
        ),
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        label: Text(
          LicenseUiStrings.userListSeatBadgeNone,
          style: const TextStyle(fontSize: 11),
        ),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
        backgroundColor: Colors.orange.shade50,
        side: BorderSide(color: Colors.orange.shade200),
      ),
    );
  }

  void _navigateToUserAccess(BuildContext context, UserPublic user) {
    AccessRoutes.navigateToUserAccess(
      context,
      user,
      currentUserId: widget.currentUserId,
      firmLicenses: widget.firmLicenses,
    );
  }

  Future<void> _handleRefresh() async {
    final accessProvider = context.read<AccessProvider>();
    await accessProvider.initialize();
    
    if (widget.onRefresh != null) {
      widget.onRefresh!();
    }
  }

  /// Builds a compact access glimpse widget for a user
  Widget _buildUserAccessGlimpse(UserPublic user, AccessProvider accessProvider) {
    return FutureBuilder<UserPermissions?>(
      future: accessProvider.getUserPermissions(user.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              AccessUiStrings.accessUnknown,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          );
        }

        final permissions = snapshot.data!;
        final hasFullAccess = permissions.hasFullAccess() && permissions.fullAccess.hasFullAccess;
        
        if (hasFullAccess) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.shade700,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade900),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                const Text(
                  AccessUiStrings.fullAccess,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        } else if (permissions.hasLimitedAccess()) {
          final chainCount = permissions.limitedAccess.chainIds.ids.length;
          final boutiqueCount = permissions.limitedAccess.boutiqueIds.ids.length;
          
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade900),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  AccessUiStrings.limitedAccessSummary(
                      chainCount, boutiqueCount),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.block, size: 14, color: Colors.red.shade700),
                const SizedBox(width: 4),
                Text(
                  AccessUiStrings.noAccess,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
