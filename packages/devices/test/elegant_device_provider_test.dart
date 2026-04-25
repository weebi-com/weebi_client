import 'package:flutter_test/flutter_test.dart';
import 'package:protos_weebi/protos_weebi_io.dart';
import 'package:protos_weebi/fixnum.dart'; 

void main() {
  group('Device Extensions Tests', () {
    late Device testDevice;
    late HardwareInfo testHardwareInfo;
    late UserPermissions testPermissions;

    setUp(() {
      testHardwareInfo = HardwareInfo()
        ..name = 'iPhone 15 Pro'
        ..serialNumber = 'ABC123456789'
        ..baseOS = 'iOS 17.0'
        ..brand = 'Apple';

      testDevice = Device()
        ..deviceId = 'device_123'
        ..chainId = 'chain_1'
        ..boutiqueId = 'boutique_1'
        ..status = true
        ..password = 'encrypted_password'
        ..hardwareInfo = testHardwareInfo
        ..timestamp = (Timestamp()
          ..seconds = Int64(1640995200) // 2022-01-01
          ..nanos = 0);

      testPermissions = UserPermissions()
        ..userId = 'test_user'
        ..firmId = 'test_firm'
        ..chainRights = (ChainRights()
          ..rights.addAll([Right.create, Right.read, Right.update, Right.delete]));
    });

    group('Device Properties Tests', () {
      test('should access device properties correctly', () {
        expect(testDevice.deviceId, equals('device_123'));
        expect(testDevice.chainId, equals('chain_1'));
        expect(testDevice.boutiqueId, equals('boutique_1'));
        expect(testDevice.status, isTrue);
        expect(testDevice.password, equals('encrypted_password'));
      });

      test('should access hardware info correctly', () {
        expect(testDevice.hardwareInfo.name, equals('iPhone 15 Pro'));
        expect(testDevice.hardwareInfo.serialNumber, equals('ABC123456789'));
        expect(testDevice.hardwareInfo.baseOS, equals('iOS 17.0'));
        expect(testDevice.hardwareInfo.brand, equals('Apple'));
      });

      test('should handle device status correctly', () {
        expect(testDevice.status, isTrue);
        
        // Test inactive device
        final inactiveDevice = Device()..status = false;
        expect(inactiveDevice.status, isFalse);
      });

      test('should handle timestamp correctly', () {
        expect(testDevice.hasTimestamp(), isTrue);
        expect(testDevice.timestamp.seconds, equals(Int64(1640995200)));
        
        // Test device without timestamp
        final deviceWithoutTimestamp = Device();
        expect(deviceWithoutTimestamp.hasTimestamp(), isFalse);
      });
    });

    group('HardwareInfo Tests', () {
      test('should create hardware info with all fields', () {
        final hardwareInfo = HardwareInfo()
          ..name = 'Samsung Galaxy S23'
          ..serialNumber = 'XYZ987654321'
          ..baseOS = 'Android 13'
          ..brand = 'Samsung';

        expect(hardwareInfo.name, equals('Samsung Galaxy S23'));
        expect(hardwareInfo.serialNumber, equals('XYZ987654321'));
        expect(hardwareInfo.baseOS, equals('Android 13'));
        expect(hardwareInfo.brand, equals('Samsung'));
      });

      test('should handle empty hardware info', () {
        final emptyHardware = HardwareInfo();
        
        expect(emptyHardware.name, equals(''));
        expect(emptyHardware.serialNumber, equals(''));
        expect(emptyHardware.baseOS, equals(''));
        expect(emptyHardware.brand, equals(''));
      });

      test('should handle partial hardware info', () {
        final partialHardware = HardwareInfo()
          ..name = 'iPad Pro'
          ..brand = 'Apple';
        
        expect(partialHardware.name, equals('iPad Pro'));
        expect(partialHardware.brand, equals('Apple'));
        expect(partialHardware.serialNumber, equals(''));
        expect(partialHardware.baseOS, equals(''));
      });
    });

    group('Permission System Tests', () {
      test('should validate chain rights correctly', () {
        // Full permissions
        expect(testPermissions.hasChainRights(), isTrue);
        expect(testPermissions.chainRights.rights.contains(Right.create), isTrue);
        expect(testPermissions.chainRights.rights.contains(Right.read), isTrue);
        expect(testPermissions.chainRights.rights.contains(Right.update), isTrue);
        expect(testPermissions.chainRights.rights.contains(Right.delete), isTrue);

        // Read-only permissions
        final readOnlyPermissions = UserPermissions()
          ..userId = 'test_user'
          ..chainRights = (ChainRights()..rights.add(Right.read));
        
        expect(readOnlyPermissions.hasChainRights(), isTrue);
        expect(readOnlyPermissions.chainRights.rights.contains(Right.read), isTrue);
        expect(readOnlyPermissions.chainRights.rights.contains(Right.create), isFalse);
        expect(readOnlyPermissions.chainRights.rights.contains(Right.update), isFalse);
        expect(readOnlyPermissions.chainRights.rights.contains(Right.delete), isFalse);

        // No permissions
        final noPermissions = UserPermissions()..userId = 'test_user';
        expect(noPermissions.hasChainRights(), isFalse);
      });

      test('should validate specific device operations', () {
        bool hasCreateRight = testPermissions.chainRights.rights.contains(Right.create);
        bool hasReadRight = testPermissions.chainRights.rights.contains(Right.read);
        bool hasUpdateRight = testPermissions.chainRights.rights.contains(Right.update);
        bool hasDeleteRight = testPermissions.chainRights.rights.contains(Right.delete);

        expect(hasCreateRight, isTrue);
        expect(hasReadRight, isTrue);
        expect(hasUpdateRight, isTrue);
        expect(hasDeleteRight, isTrue);
      });
    });

    group('Device Collection Tests', () {
      test('should handle list of devices', () {
        final devices = <Device>[
          Device()
            ..deviceId = 'device_1'
            ..status = true
            ..hardwareInfo = (HardwareInfo()..name = 'Device 1'),
          Device()
            ..deviceId = 'device_2'
            ..status = false
            ..hardwareInfo = (HardwareInfo()..name = 'Device 2'),
          Device()
            ..deviceId = 'device_3'
            ..status = true
            ..hardwareInfo = (HardwareInfo()..name = 'Device 3'),
        ];

        expect(devices.length, equals(3));
        
        // Filter active devices
        final activeDevices = devices.where((d) => d.status).toList();
        expect(activeDevices.length, equals(2));
        expect(activeDevices.every((d) => d.status), isTrue);
        
        // Filter inactive devices
        final inactiveDevices = devices.where((d) => !d.status).toList();
        expect(inactiveDevices.length, equals(1));
        expect(inactiveDevices.first.deviceId, equals('device_2'));
      });

      test('should filter devices by boutique', () {
        final devices = <Device>[
          Device()
            ..deviceId = 'device_1'
            ..boutiqueId = 'boutique_A',
          Device()
            ..deviceId = 'device_2'
            ..boutiqueId = 'boutique_B',
          Device()
            ..deviceId = 'device_3'
            ..boutiqueId = 'boutique_A',
        ];

        final boutiqueADevices = devices.where((d) => d.boutiqueId == 'boutique_A').toList();
        expect(boutiqueADevices.length, equals(2));
        expect(boutiqueADevices.every((d) => d.boutiqueId == 'boutique_A'), isTrue);
      });

      test('should search devices by name and ID', () {
        final devices = <Device>[
          Device()
            ..deviceId = 'iphone_device_1'
            ..hardwareInfo = (HardwareInfo()..name = 'iPhone 15 Pro'),
          Device()
            ..deviceId = 'samsung_device_2'
            ..hardwareInfo = (HardwareInfo()..name = 'Samsung Galaxy S23'),
          Device()
            ..deviceId = 'ipad_device_3'
            ..hardwareInfo = (HardwareInfo()..name = 'iPad Pro'),
        ];

        // Search by device name
        final iPhoneDevices = devices.where((d) => 
          d.hardwareInfo.name.toLowerCase().contains('iphone')).toList();
        expect(iPhoneDevices.length, equals(1));
        expect(iPhoneDevices.first.hardwareInfo.name, contains('iPhone'));

        // Search by device ID
        final samsungDevices = devices.where((d) => 
          d.deviceId.toLowerCase().contains('samsung')).toList();
        expect(samsungDevices.length, equals(1));
        expect(samsungDevices.first.deviceId, contains('samsung'));

        // Search by partial name
        final appleDevices = devices.where((d) => 
          d.hardwareInfo.name.toLowerCase().contains('pro')).toList();
        expect(appleDevices.length, equals(2)); // iPhone Pro and iPad Pro
      });
    });

    group('Request/Response Objects Tests', () {
      test('should create ReadDevicesRequest correctly', () {
        final request = ReadDevicesRequest()..chainId = 'test_chain';
        
        expect(request.chainId, equals('test_chain'));
      });

      test('should create ChainIdAndboutiqueId correctly', () {
        final request = ChainIdAndboutiqueId()
          ..chainId = 'test_chain'
          ..boutiqueId = 'test_boutique';
        
        expect(request.chainId, equals('test_chain'));
        expect(request.boutiqueId, equals('test_boutique'));
      });

      test('should create CodeForPairingDevice correctly', () {
        final code = CodeForPairingDevice()
          ..firmId = 'test_firm'
          ..chainId = 'test_chain'
          ..boutiqueId = 'test_boutique'
          ..userId = 'test_user'
          ..code = 123456
          ..timestampUTC = (Timestamp()
            ..seconds = Int64(1640995200)
            ..nanos = 0);
        
        expect(code.firmId, equals('test_firm'));
        expect(code.chainId, equals('test_chain'));
        expect(code.boutiqueId, equals('test_boutique'));
        expect(code.userId, equals('test_user'));
        expect(code.code, equals(123456));
        expect(code.hasTimestampUTC(), isTrue);
      });

      test('should create DeleteDeviceRequest correctly', () {
        final request = DeleteDeviceRequest()
          ..chainId = 'test_chain'
          ..device = testDevice;
        
        expect(request.chainId, equals('test_chain'));
        expect(request.device.deviceId, equals('device_123'));
      });
    });

    group('Edge Cases Tests', () {
      test('should handle devices with missing hardware info', () {
        final deviceWithoutHardware = Device()
          ..deviceId = 'minimal_device'
          ..status = true;
        
        expect(deviceWithoutHardware.deviceId, equals('minimal_device'));
        expect(deviceWithoutHardware.status, isTrue);
        expect(deviceWithoutHardware.hasHardwareInfo(), isFalse);
      });

      test('should handle empty device collections', () {
        final emptyDevices = <Device>[];
        
        expect(emptyDevices.isEmpty, isTrue);
        expect(emptyDevices.length, equals(0));
        
        final filteredEmpty = emptyDevices.where((d) => d.status).toList();
        expect(filteredEmpty.isEmpty, isTrue);
      });

      test('should handle devices with special characters', () {
        final specialDevice = Device()
          ..deviceId = 'device-with-special_chars.123'
          ..hardwareInfo = (HardwareInfo()
            ..name = 'Device with Special Characters & Symbols!'
            ..serialNumber = 'SN-123/456@789');
        
        expect(specialDevice.deviceId, equals('device-with-special_chars.123'));
        expect(specialDevice.hardwareInfo.name, equals('Device with Special Characters & Symbols!'));
        expect(specialDevice.hardwareInfo.serialNumber, equals('SN-123/456@789'));
      });
    });

    group('Data Integrity Tests', () {
      test('should maintain device data integrity', () {
        final originalDevice = Device()
          ..deviceId = 'original'
          ..status = true
          ..hardwareInfo = (HardwareInfo()..name = 'Original Device');
        
        // Create a copy by setting properties
        final copiedDevice = Device()
          ..deviceId = originalDevice.deviceId
          ..status = originalDevice.status
          ..hardwareInfo = (HardwareInfo()..name = originalDevice.hardwareInfo.name);
        
        expect(copiedDevice.deviceId, equals(originalDevice.deviceId));
        expect(copiedDevice.status, equals(originalDevice.status));
        expect(copiedDevice.hardwareInfo.name, equals(originalDevice.hardwareInfo.name));
        
        // Modify copy shouldn't affect original
        copiedDevice.status = false;
        expect(originalDevice.status, isTrue);
        expect(copiedDevice.status, isFalse);
      });

      test('should handle complex device scenarios', () {
        final complexDevice = Device()
          ..deviceId = 'complex_device_001'
          ..chainId = 'retail_chain_main'
          ..boutiqueId = 'flagship_store_nyc'
          ..status = true
          ..password = 'hashed_password_string'
          ..hardwareInfo = (HardwareInfo()
            ..name = 'iPad Pro 12.9" (6th generation)'
            ..serialNumber = 'DMQK2LL/A'
            ..baseOS = 'iPadOS 16.1'
            ..brand = 'Apple Inc.')
          ..timestamp = (Timestamp()
            ..seconds = Int64(1672531200) // 2023-01-01
            ..nanos = 500000000); // 0.5 seconds
        
        expect(complexDevice.deviceId.length, greaterThan(10));
        expect(complexDevice.hardwareInfo.name.contains('iPad'), isTrue);
        expect(complexDevice.timestamp.nanos, equals(500000000));
        expect(complexDevice.status, isTrue);
      });
    });
  });
}
