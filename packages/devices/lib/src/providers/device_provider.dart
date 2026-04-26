import 'package:flutter/foundation.dart';
import 'package:protos_weebi/protos_weebi_io.dart';

/// Provider for managing device CRUD operations
/// All operations require appropriate ChainRights permissions
class DeviceProvider extends ChangeNotifier {
  final FenceServiceClient _fenceServiceClient;
  final bool useServerPermissions;

  List<Device> _devices = [];
  bool _isLoading = false;
  String? _error;
  UserPermissions? _userPermissions;

  DeviceProvider(
    this._fenceServiceClient, {
    this.useServerPermissions = false,
  });

  // Getters
  List<Device> get devices => _devices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  UserPermissions? get userPermissions => _userPermissions;

  /// Set user permissions (usually from auth token)
  void setUserPermissions(UserPermissions permissions) {
    _userPermissions = permissions;
    notifyListeners();
  }

  /// Check if user can perform device operations
  bool get canCreateDevice => _hasChainRight(Right.create);
  bool get canReadDevices => _hasChainRight(Right.read);
  bool get canUpdateDevice => _hasChainRight(Right.update);
  bool get canDeleteDevice => _hasChainRight(Right.delete);

  bool _hasChainRight(Right right) {
    if (useServerPermissions) return true;
    return _userPermissions?.hasChainRights() == true &&
        _userPermissions!.chainRights.rights.contains(right);
  }

  /// Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // ===== DEVICE CRUD OPERATIONS =====

  /// CREATE: Generate pairing code for device chaining
  /// Requires ChainRight.create
  Future<String?> generatePairingCode(String chainId, String boutiqueId) async {
    if (!canCreateDevice) {
      _error = 'Insufficient permissions: ChainRight.create required';
      notifyListeners();
      return null;
    }

    _setLoading(true);
    _clearError();

    try {
      final request = ChainIdAndboutiqueId()
        ..chainId = chainId
        ..boutiqueId = boutiqueId;

      final response =
          await _fenceServiceClient.generateCodeForPairingDevice(request);
      return response.code.toString().padLeft(6, '0');
    } catch (e) {
      _setError('Failed to generate pairing code: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// CREATE: Chain device using pairing code
  /// No specific permission required (code validates authorization)
  Future<CreateDeviceResponse?> chainDevice(
      int code, HardwareInfo hardwareInfo) async {
    _setLoading(true);
    _clearError();

    try {
      final request = PendingDeviceRequest()
        ..code = code
        ..hardwareInfo = hardwareInfo;

      final response = await _fenceServiceClient.createDevice(request);

      if (response.statusResponse.type == StatusResponse_Type.CREATED) {
        // Reload devices to show the new one
        await loadDevices(response.chainId);
        return response;
      } else {
        _setError('Failed to chain device: ${response.statusResponse.message}');
        return null;
      }
    } catch (e) {
      _setError('Failed to chain device: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// READ: Load devices for a specific chain
  /// Requires ChainRight.read
  Future<void> loadDevices(String chainId) async {
    if (!canReadDevices) {
      _error = 'Insufficient permissions: ChainRight.read required';
      notifyListeners();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final request = ReadDevicesRequest()..chainId = chainId;
      final response = await _fenceServiceClient.readDevices(request);
      _devices = response.devices;
    } catch (e) {
      _setError('Failed to load devices: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// UPDATE: Update device password
  /// Requires ChainRight.update
  Future<bool> updateDevicePassword(Device device, String newPassword) async {
    if (!canUpdateDevice) {
      _error = 'Insufficient permissions: ChainRight.update required';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final updatedDevice = Device()
        ..mergeFromMessage(device)
        ..password = newPassword;

      final request = UpdateDevicePasswordRequest()
        ..chainId = device.chainId
        ..device = updatedDevice;

      final response = await _fenceServiceClient.updateDevicePassword(request);

      if (response.type == StatusResponse_Type.UPDATED) {
        // Update local device list
        final index = _devices.indexWhere((d) => d.deviceId == device.deviceId);
        if (index != -1) {
          _devices[index] = updatedDevice;
          notifyListeners();
        }
        return true;
      } else {
        _setError('Failed to update device: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Failed to update device: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// UPDATE: Move device to different boutique
  /// This would require a new gRPC endpoint or using updateDevice
  Future<bool> moveDeviceToBoutique(
      String deviceId, String newBoutiqueId) async {
    if (!canUpdateDevice) {
      _error = 'Insufficient permissions: ChainRight.update required';
      notifyListeners();
      return false;
    }

    // TODO: Implement when moveDevice endpoint is available
    // For now, this would require updating the device's boutiqueId
    _setError('Move device functionality not yet implemented');
    notifyListeners();
    return false;
  }

  /// UPDATE: Enable/disable device
  /// This would require updating device.status
  Future<bool> setDeviceStatus(String deviceId, bool enabled) async {
    if (!canUpdateDevice) {
      _error = 'Insufficient permissions: ChainRight.update required';
      notifyListeners();
      return false;
    }

    // TODO: Implement when updateDevice endpoint is available
    _setError('Device enable/disable functionality not yet implemented');
    notifyListeners();
    return false;
  }

  /// DELETE: Remove device from system
  /// Requires ChainRight.delete
  Future<bool> deleteDevice(Device device) async {
    if (!canDeleteDevice) {
      _error = 'Insufficient permissions: ChainRight.delete required';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final request = DeleteDeviceRequest()
        ..chainId = device.chainId
        ..device = device;

      final response = await _fenceServiceClient.deleteOneDevice(request);

      if (response.type == StatusResponse_Type.DELETED) {
        // Remove from local list
        _devices.removeWhere((d) => d.deviceId == device.deviceId);
        notifyListeners();
        return true;
      } else {
        _setError('Failed to delete device: ${response.message}');
        return false;
      }
    } catch (e) {
      _setError('Failed to delete device: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ===== UTILITY METHODS =====

  /// Get devices for a specific boutique
  List<Device> getDevicesForBoutique(String boutiqueId) {
    return _devices.where((d) => d.boutiqueId == boutiqueId).toList();
  }

  /// Get active devices only
  List<Device> get activeDevices {
    return _devices.where((d) => d.status).toList();
  }

  /// Search devices by hardware info or device ID
  List<Device> searchDevices(String query) {
    if (query.isEmpty) return _devices;

    final lowercaseQuery = query.toLowerCase();
    return _devices
        .where((device) =>
            device.deviceId.toLowerCase().contains(lowercaseQuery) ||
            device.hardwareInfo.name.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  // Private helpers
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
