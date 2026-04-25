import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:auth_weebi/auth_weebi.dart';
import '../providers/user_provider.dart';
import 'user_list_widget.dart';

/// Example widget showing how to integrate the user management package
/// with your existing FenceServiceClient infrastructure
/// 
/// Note: This is a simplified example. For full integration, use initCrossRoutesTestV2
/// from fence_client_provider.dart which provides the complete auth setup.
class UserManagementExample extends StatelessWidget {
  final FenceServiceClient? fenceServiceClient;

  const UserManagementExample({
    super.key,
    this.fenceServiceClient,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Simple setup - for full auth integration, use initCrossRoutesTestV2
        Provider<AccessTokenObject>(create: (_) => AccessTokenObject()),
        ChangeNotifierProxyProvider<AccessTokenObject, AccessTokenProvider>(
          create: (context) => AccessTokenProvider(context.read<AccessTokenObject>()),
          update: (context, access, accessProvider) =>
              accessProvider!..accessToken = access.value,
        ),
        if (fenceServiceClient != null)
          ChangeNotifierProvider<UserProvider>(
            create: (_) => UserProvider(fenceServiceClient!),
          ),
      ],
      child: const UserListWidget(
        currentUserId: 'demo_current_user', // In real app: use cloudHub.userId
      ),
    );
  }
}

/// Example usage in your main app
class ExampleUsage extends StatelessWidget {
  final FenceServiceClient fenceServiceClient;

  const ExampleUsage({
    super.key,
    required this.fenceServiceClient,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Management Example',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('User Management'),
        ),
        body: UserManagementExample(
          fenceServiceClient: fenceServiceClient,
        ),
      ),
    );
  }
} 