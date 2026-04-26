import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:devices_weebi/devices_weebi.dart';
import 'package:boutiques_weebi/boutiques_weebi.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

/// Example demonstrating comprehensive device management with CRUD operations
/// 
/// This example shows:
/// - Device listing with search and filtering
/// - Device chaining (creating new devices)
/// - Device password updates
/// - Device deletion
/// - Permission-based UI (ChainRights)
/// 
/// Usage:
/// - Ensure user has appropriate ChainRights (create, read, update, delete)
/// - Initialize with BoutiqueProvider, DeviceProvider, and AccessTokenProvider
void main() {
  runApp(const DeviceManagementExampleApp());
}

class DeviceManagementExampleApp extends StatelessWidget {
  const DeviceManagementExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Management Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: MultiProvider(
        providers: [
          // Auth provider - manages JWT tokens and user permissions
          ChangeNotifierProvider(
            create: (context) => AccessTokenProvider(AccessTokenObject()),
          ),
          
          // Boutique provider - manages chains and boutiques
          ChangeNotifierProvider(
            create: (context) => BoutiqueProvider(
              // You would inject your actual FenceServiceClient here
               _createMockFenceServiceClient(),
            ),
          ),
          
          // Device provider - manages device CRUD operations
          ChangeNotifierProvider(
            create: (context) => DeviceProvider(
              // You would inject your actual FenceServiceClient here
              _createMockFenceServiceClient(),
            ),
          ),
        ],
        child: const DeviceManagementExampleHome(),
      ),
    );
  }

  /// In a real app, you would inject your configured FenceServiceClient
  /// This is just a placeholder for the example
  static FenceServiceClient _createMockFenceServiceClient() {
    // This would be your actual gRPC client configuration
    throw UnimplementedError('Configure your FenceServiceClient here');
  }
}

class DeviceManagementExampleHome extends StatefulWidget {
  const DeviceManagementExampleHome({super.key});

  @override
  State<DeviceManagementExampleHome> createState() => _DeviceManagementExampleHomeState();
}

class _DeviceManagementExampleHomeState extends State<DeviceManagementExampleHome> {
  @override
  void initState() {
    super.initState();
    _initializeExampleData();
  }

  void _initializeExampleData() {
    // In a real app, you would authenticate and get a real token
    // This is just example setup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AccessTokenProvider>();
      
      // Set mock user permissions for demonstration
      // In practice, this comes from your JWT token after authentication
      _setMockUserPermissions(authProvider);
    });
  }

  void _setMockUserPermissions(AccessTokenProvider authProvider) {
    // This is just for demonstration - in real usage, permissions come from JWT
    final mockPermissions = UserPermissions()
      ..userId = 'example-user-123'
      ..firmId = 'example-firm-456'
      ..chainRights = (ChainRights()
        ..rights.addAll([
          Right.create,  // Can generate pairing codes
          Right.read,    // Can view devices
          Right.update,  // Can update device passwords
          Right.delete,  // Can delete devices
        ]));
    
    // In a real app, you would set the actual JWT token
    // authProvider.setToken('your-jwt-token-here');
    
    // For this example, we're directly setting mock permissions
    // You would never do this in production!
    print('Mock permissions set for example: ${mockPermissions.toString()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Management Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.devices, size: 100, color: Colors.blue),
            SizedBox(height: 24),
            Text(
              'Device Management Example',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'This example demonstrates comprehensive device CRUD operations\n'
              'with proper ChainRights permission handling.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 32),
            _LaunchDeviceManagementButton(),
          ],
        ),
      ),
    );
  }
}

class _LaunchDeviceManagementButton extends StatelessWidget {
  const _LaunchDeviceManagementButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const DeviceManagementWidget(),
          ),
        );
      },
      icon: const Icon(Icons.launch),
      label: const Text('Launch Device Management'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontSize: 18),
      ),
    );
  }
}

/// Example of using just the device chaining widget standalone
class DeviceChainingExamplePage extends StatelessWidget {
  const DeviceChainingExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DeviceChainingWidget(
      onDeviceChained: (boutique, code) {
        // Handle successful device chaining
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Device chained to ${boutique.displayName} with code: $code',
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back or to next step
        Navigator.of(context).pop();
      },
      onCancel: () {
        Navigator.of(context).pop();
      },
    );
  }
}

/// Example showing how to use the DeviceProvider directly
class DirectDeviceProviderExample extends StatefulWidget {
  const DirectDeviceProviderExample({super.key});

  @override
  State<DirectDeviceProviderExample> createState() => _DirectDeviceProviderExampleState();
}

class _DirectDeviceProviderExampleState extends State<DirectDeviceProviderExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Direct DeviceProvider Usage')),
      body: Consumer<DeviceProvider>(
        builder: (context, deviceProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Device Provider Status',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                // Permission status
                Text('Permissions:', style: Theme.of(context).textTheme.titleMedium),
                Text('Can Create: ${deviceProvider.canCreateDevice}'),
                Text('Can Read: ${deviceProvider.canReadDevices}'),
                Text('Can Update: ${deviceProvider.canUpdateDevice}'),
                Text('Can Delete: ${deviceProvider.canDeleteDevice}'),
                
                const SizedBox(height: 16),
                
                // Device count
                Text('Devices Loaded: ${deviceProvider.devices.length}'),
                Text('Active Devices: ${deviceProvider.activeDevices.length}'),
                
                const SizedBox(height: 16),
                
                // Loading/error state
                if (deviceProvider.isLoading)
                  const CircularProgressIndicator()
                else if (deviceProvider.error != null)
                  Text(
                    'Error: ${deviceProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                
                const SizedBox(height: 16),
                
                // Action buttons
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: deviceProvider.canReadDevices
                          ? () => deviceProvider.loadDevices('example-chain-id')
                          : null,
                      child: const Text('Load Devices'),
                    ),
                    ElevatedButton(
                      onPressed: deviceProvider.canCreateDevice
                          ? () => _generatePairingCode(deviceProvider)
                          : null,
                      child: const Text('Generate Pairing Code'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _generatePairingCode(DeviceProvider deviceProvider) async {
    final code = await deviceProvider.generatePairingCode(
      'example-chain-id',
      'example-boutique-id',
    );
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            code != null 
                ? 'Pairing code generated: $code'
                : 'Failed to generate pairing code: ${deviceProvider.error}',
          ),
          backgroundColor: code != null ? Colors.green : Colors.red,
        ),
      );
    }
  }
}
