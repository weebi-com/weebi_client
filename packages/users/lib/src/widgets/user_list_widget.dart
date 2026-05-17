import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:users_weebi/weebi_users.dart';

/// User list widget that automatically generates UI using protobuf mirroring
class UserListWidget extends StatefulWidget {
  final Function(UserPublic, UserPermissions)? onPermissionsChanged;

  /// Current user ID to exclude from the list (prevents self-permission editing)
  final String currentUserId;

  /// When set (e.g. [GoRouter.push]), used for the FAB instead of
  /// [Navigator.pushNamed]('/users/create'), which requires [MaterialApp.routes].
  final VoidCallback? onCreateUser;

  /// Optional firm licenses (e.g. from billing) to show seat status on user detail.
  final Iterable<License>? firmLicenses;

  const UserListWidget({
    super.key,
    required this.currentUserId,
    this.onPermissionsChanged,
    this.onCreateUser,
    this.firmLicenses,
  });

  @override
  State<UserListWidget> createState() => _UserListWidgetState();
}

class _UserListWidgetState extends State<UserListWidget> {
  late TextEditingController _searchController;
  String _searchQuery = '';

  Widget _seatStatusChip(UserPublic user) {
    final licenses = widget.firmLicenses!;
    if (userHasActiveLicensedSeat(user.userId, licenses)) {
      return Chip(
        label: Text(
          EntitlementUiStrings.userListSeatBadgeActive,
          style: const TextStyle(fontSize: 11),
        ),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
        backgroundColor: Colors.green.shade50,
        side: BorderSide(color: Colors.green.shade200),
      );
    }
    if (user.hasPermissions() &&
        firmCreatorOperationalJoker(user.permissions)) {
      return Chip(
        label: Text(
          EntitlementUiStrings.userListSeatBadgeCreator,
          style: const TextStyle(fontSize: 11),
        ),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 6),
        backgroundColor: Colors.blue.shade50,
        side: BorderSide(color: Colors.blue.shade200),
      );
    }
    return Chip(
      label: Text(
        EntitlementUiStrings.userListSeatBadgeNone,
        style: const TextStyle(fontSize: 11),
      ),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 6),
      backgroundColor: Colors.orange.shade50,
      side: BorderSide(color: Colors.orange.shade200),
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    Future.microtask(() => context.read<UserProvider>().loadUsers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserPublic> _getFilteredUsers(List<UserPublic> users) {
    if (_searchQuery.isEmpty) return users;
    final query = _searchQuery.toLowerCase();
    return users.where((user) {
      return user.firstname.toLowerCase().contains(query) ||
          user.lastname.toLowerCase().contains(query) ||
          user.mail.toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: UserUiStrings.searchUsersHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SelectableText(UserUiStrings.errorPrefix('${provider.error}')),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    provider.clearError();
                    provider.loadUsers();
                  },
                  child: const Text(UserUiStrings.retry),
                ),
              ],
            ),
          );
        }

        final filteredUsers = _getFilteredUsers(provider.users);

        if (provider.users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(UserUiStrings.noUsersFound),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _showUserForm(context),
                  child: const Text(UserUiStrings.addUser),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: filteredUsers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person_search,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? UserUiStrings.noUsersFound
                                : UserUiStrings.noUsersMatchSearch,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (_searchQuery.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              UserUiStrings.tryAdjustingSearch,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            final isCurrentUser =
                                user.userId == widget.currentUserId;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              color: isCurrentUser ? Colors.blue[50] : null,
                              elevation: isCurrentUser ? 2 : 1,
                              child: ListTile(
                                leading: Stack(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: isCurrentUser
                                          ? Colors.blue[600]
                                          : _getAvatarColor(user),
                                      child: Text(
                                        user.firstname.isNotEmpty
                                            ? user.firstname[0].toUpperCase()
                                            : 'U',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (isCurrentUser)
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: Colors.blue[600],
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.white, width: 2),
                                          ),
                                          child: const Icon(
                                            Icons.person,
                                            size: 10,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${user.firstname} ${user.lastname}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: isCurrentUser
                                              ? Colors.blue[800]
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.mail,
                                      style:
                                          TextStyle(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      UserUiStrings.userListIdLine(user.userId),
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (widget.firmLicenses != null) ...[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 4),
                                        child: _seatStatusChip(user),
                                      ),
                                    ],
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () =>
                                          _showUserForm(context, user),
                                      tooltip: UserUiStrings.editUserTooltip,
                                      constraints: const BoxConstraints(
                                        minWidth: 48,
                                        minHeight: 48,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red[600],
                                        size: 20,
                                      ),
                                      onPressed: () =>
                                          user.userId == widget.currentUserId
                                              ? null
                                              : _showDeleteConfirmation(
                                                  context, user),
                                      tooltip: UserUiStrings.deleteUserTooltip,
                                      constraints: const BoxConstraints(
                                        minWidth: 48,
                                        minHeight: 48,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () => _navigateToUserDetail(
                                    context, user, provider),
                              ),
                            );
                          },
                        ),
                        Positioned(
                          bottom:
                              MediaQuery.of(context).padding.bottom + 16,
                          right: MediaQuery.of(context).padding.right + 16,
                          child: FloatingActionButton(
                            onPressed: () {
                              if (widget.onCreateUser != null) {
                                widget.onCreateUser!();
                              } else {
                                Navigator.of(context)
                                    .pushNamed('/users/create');
                              }
                            },
                            child: const Icon(Icons.person_add),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Color _getAvatarColor(UserPublic user) {
    final colors = [
      Colors.green,
      Colors.teal,
    ];
    final index = user.userId.hashCode % colors.length;
    return colors[index];
  }

  Future<void> _showUserForm(BuildContext context, [UserPublic? user]) async {
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: UserFormWidget(
            user: user,
            userProvider: context.read<UserProvider>(),
            onSaved: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, UserPublic user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(UserUiStrings.deleteUserTitle),
        content: Text(
            UserUiStrings.deleteUserConfirm(
                user.firstname, user.lastname)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(UserUiStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(UserUiStrings.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<UserProvider>().deleteUser(user.userId);
    }
  }

  void _navigateToUserDetail(
      BuildContext context, UserPublic user, UserProvider provider) {
    UserRoutes.navigateToUserDetailView(
      context,
      user,
      provider,
      currentUserId: widget.currentUserId,
      firmLicenses: widget.firmLicenses,
      onPermissionsChanged: widget.onPermissionsChanged,
      onEdit: () {
        Navigator.of(context).pop();
        _showUserForm(context, user);
      },
      onDelete: () {
        Navigator.of(context).pop();
        _showDeleteConfirmation(context, user);
      },
    );
  }
}
