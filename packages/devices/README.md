# Devices Weebi

Comprehensive device management package for Weebi POS system with CRUD operations based on ChainRights permissions.

## Overview

This package provides complete device management functionality for the Weebi ecosystem, including:

- **Device Chaining**: Link new POS devices to boutiques during initial setup
- **Device Management**: Full CRUD operations for existing devices
- **Permission-based Access**: All operations respect ChainRights permissions
- **Intuitive UI**: Ready-to-use widgets with modern Material Design

## Features

### 🔗 Device Chaining
- Generate pairing codes for new device enrollment
- Select from accessible boutiques (server-filtered)
- Support for multi-chain organizations
- Real-time code generation with copy-to-clipboard

### 📱 Device Management
- List all devices across accessible chains
- Search and filter devices by name or hardware info
- Update device passwords
- Delete devices with confirmation
- Group devices by boutique for better organization

### 🔐 Permission System
Based on ChainRights with granular control:
- **Create** (`Right.create`): Generate pairing codes
- **Read** (`Right.read`): View device lists
- **Update** (`Right.update`): Modify device settings
- **Delete** (`Right.delete`): Remove devices

### 🎨 UI Components
- `DeviceChainingWidget`: Standalone device chaining interface
- `DeviceManagementWidget`: Complete device management with tabs
- Responsive design with search, filtering, and grouping
- Error handling and loading states

## Quick Start

### 1. Add to your app

```yaml
dependencies:
  devices_weebi:
    path: ../packages/devices
```

### 2. Setup providers

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AccessTokenProvider()),
    ChangeNotifierProvider(create: (_) => BoutiqueProvider(fenceServiceClient)),
    ChangeNotifierProvider(create: (_) => DeviceProvider(fenceServiceClient)),
  ],
  child: MyApp(),
)
```

### 3. Use the widgets

#### Device Chaining (for new device setup)
```dart
DeviceChainingWidget(
  onDeviceChained: (boutique, code) {
    // Handle successful chaining
    print('Device chained to ${boutique.displayName} with code: $code');
  },
  onCancel: () => Navigator.pop(context),
)
```

#### Full Device Management
```dart
DeviceManagementWidget() // That's it! Handles everything automatically
```

## Architecture

### DeviceProvider
Central state management for all device operations:

```dart
// Permission checks
bool get canCreateDevice;
bool get canReadDevices;
bool get canUpdateDevice;
bool get canDeleteDevice;

// CRUD operations
Future<String?> generatePairingCode(String chainId, String boutiqueId);
Future<void> loadDevices(String chainId);
Future<bool> updateDevicePassword(Device device, String password);
Future<bool> deleteDevice(Device device);

// Utility methods
List<Device> searchDevices(String query);
List<Device> getDevicesForBoutique(String boutiqueId);
List<Device> get activeDevices;
```

### Permission Requirements

| Operation | Required Permission | Description |
|-----------|-------------------|-------------|
| Generate pairing code | `ChainRight.create` | Create new device enrollment codes |
| View devices | `ChainRight.read` | List and search existing devices |
| Update password | `ChainRight.update` | Modify device settings |
| Delete device | `ChainRight.delete` | Permanently remove devices |

## Backend Integration

The package integrates with these gRPC endpoints:

- `generateCodeForPairingDevice` - Create pairing codes
- `createDevice` - Complete device enrollment
- `readDevices` - List devices for a chain
- `updateDevicePassword` - Update device credentials
- `deleteOneDevice` - Remove devices

## Examples

See `example/device_management_example.dart` for complete implementation examples including:

- Full app setup with providers
- Standalone device chaining
- Direct DeviceProvider usage
- Permission handling

## Dependencies

- `flutter`: UI framework
- `provider`: State management
- `protos_weebi`: gRPC protocol definitions
- `auth_weebi`: Authentication and permissions
- `boutiques_weebi`: Boutique and chain data

## Notes

### Future Enhancements
- **Device Movement**: Transfer devices between boutiques (currently shows "contact support")
- **Device Status Toggle**: Enable/disable devices (currently shows "contact support")
- **Batch Operations**: Select and operate on multiple devices
- **Device Analytics**: Usage statistics and health monitoring

### Security
- All operations require appropriate ChainRights
- Server validates permissions on every request
- Sensitive operations (delete) require confirmation
- Pairing codes expire automatically

## Support

For issues or questions:
1. Check the example implementation
2. Verify your ChainRights permissions
3. Ensure proper provider setup
4. Contact the Weebi development team
