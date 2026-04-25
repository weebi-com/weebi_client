import 'package:models_weebi/models.dart';
import 'package:services_weebi/services_weebi.dart';

/// Handles device identity and cloud enrollment
/// Single Responsibility: Device management only
class DeviceManager {
  DeviceManager(this._deviceService);
  
  final DeviceServiceAbstract _deviceService;
  DeviceCloudIdentity _deviceIdentity = DeviceCloudIdentity.empty;

  // Device Properties (Read-only access) - matches original CloudHub
  String get chainId => _deviceIdentity.chainId;
  String get boutiqueId => _deviceIdentity.boutiqueId;
  String get deviceId => _deviceIdentity.deviceId;
  bool get isLinked => _deviceIdentity.isCloudLinked;
  bool get isFirstSync => _deviceIdentity.isFirstSync;
  
  /// Device firm ID (separate from permission firmId, like original CloudHub)
  String get deviceFirmId => _deviceIdentity.firmId;

  /// Gets the current device identity
  DeviceCloudIdentity get deviceIdentity => _deviceIdentity;

  /// Reads and sets the device identity from service (like original CloudHub)
  Future<DeviceCloudIdentity> loadDeviceIdentity() async {
    try {
      // ignore: void_checks
      final identity = await _deviceService.readCloudIdentityRpc.request(const []);
      _deviceIdentity = identity;
      return identity;
    } catch (e) {
      print(e); // Match original CloudHub error logging
      rethrow;
    }
  }

  /// Updates the device identity (like original CloudHub)
  Future<DeviceCloudIdentity> updateDeviceIdentity(DeviceCloudIdentity identity) async {
    try {
      final updatedIdentity = await _deviceService.upsertCloudIdentityRpc.request(identity);
      _deviceIdentity = updatedIdentity;
      return updatedIdentity;
    } catch (e) {
      print(e); // Match original CloudHub error logging
      rethrow;
    }
  }

  /// Marks first sync as complete (like original CloudHub)
  Future<DeviceCloudIdentity> markFirstSyncComplete() async {
    final temp = _deviceIdentity.copyWith(isFirstSync: false);
    try {
      final updatedIdentity = await _deviceService.upsertCloudIdentityRpc.request(temp);
      _deviceIdentity = updatedIdentity;
      return updatedIdentity;
    } catch (e) {
      print(e); // Match original CloudHub error logging
      rethrow;
    }
  }

  /// Clears device enrollment (like original CloudHub)
  Future<void> clearEnrollment() async {
    _deviceIdentity = DeviceCloudIdentity.empty;
    await _deviceService.upsertCloudIdentityRpc.request(DeviceCloudIdentity.empty);
    return;
  }
}

