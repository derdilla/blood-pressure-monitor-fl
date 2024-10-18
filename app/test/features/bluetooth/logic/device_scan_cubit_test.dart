import 'dart:async';

import 'package:blood_pressure_app/features/bluetooth/backend/flutter_blue_plus/fbp_device.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/flutter_blue_plus/fbp_manager.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/flutter_blue_plus/flutter_blue_plus_mockable.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/device_scan_cubit.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<BluetoothDevice>(),
  MockSpec<BluetoothService>(),
  MockSpec<FlutterBluePlusMockable>(),
  MockSpec<ScanResult>(),
])
import 'device_scan_cubit_test.mocks.dart';

/// Helper util to create a [MockScanResult] & [MockBluetoothDevice]
(MockScanResult, MockBluetoothDevice) createScanResultMock(String name) {
  final scanResult = MockScanResult();
  final btDevice = MockBluetoothDevice();
  when(btDevice.platformName).thenReturn(name);
  when(btDevice.remoteId).thenReturn(DeviceIdentifier(name));
  when(scanResult.device).thenReturn(btDevice);
  return (scanResult, btDevice);
}

void main() {
  test('finds and connects to devices', () async {
    final StreamController<List<ScanResult>> mockResults = StreamController.broadcast();
    final settings = Settings();

    final flutterBluePlus = MockFlutterBluePlusMockable();
    final manager = FlutterBluePlusManager(flutterBluePlus);
    expect(flutterBluePlus, manager.backend);

    when(flutterBluePlus.startScan(
        withServices: [Guid('1810')]
    )).thenAnswer((_) async {
      when(flutterBluePlus.isScanningNow).thenReturn(true);
    });
    when(flutterBluePlus.stopScan()).thenAnswer((_) async {
      when(flutterBluePlus.isScanningNow).thenReturn(false);
    });
    when(flutterBluePlus.scanResults).thenAnswer((_) => mockResults.stream);

    final cubit = DeviceScanCubit(
        service: '1810',
        settings: settings,
        manager: manager
    );
    expect(cubit.state, isA<DeviceListLoading>());

    final (wrongRes0, wrongDev0) = createScanResultMock('wrongDev0');
    final (wrongRes1, wrongDev1) = createScanResultMock('wrongDev1');

    mockResults.sink.add([wrongRes0]);
    await expectLater(cubit.stream, emits(isA<SingleDeviceAvailable>()));

    mockResults.sink.add([wrongRes0, wrongRes1]);
    await expectLater(cubit.stream, emits(isA<DeviceListAvailable>()));

    final (res, dev) = createScanResultMock('testDev');
    mockResults.sink.add([res]);
    await expectLater(cubit.stream, emits(isA<DeviceListAvailable>()
        .having((r) => r.devices.last.source, 'device', res)));

    expect(settings.knownBleDev, isEmpty);
    await cubit.acceptDevice(FlutterBluePlusDevice(manager, res));
    expect(settings.knownBleDev, contains('testDev'));
    // state should be set as we await above
    await expectLater(cubit.state, isA<DeviceSelected>()
      .having((s) => s.device.source, 'device', res));
  });

  test('recognizes devices', () async {
    final StreamController<List<ScanResult>> mockResults = StreamController.broadcast();
    final settings = Settings(
      knownBleDev: ['testDev']
    );

    final flutterBluePlus = MockFlutterBluePlusMockable();
    final manager = FlutterBluePlusManager(flutterBluePlus);
    when(flutterBluePlus.startScan(
      withServices: [Guid('1810')]
    )).thenAnswer((_) async {
      when(flutterBluePlus.isScanningNow).thenReturn(true);
    });
    when(flutterBluePlus.stopScan()).thenAnswer((_) async {
      when(flutterBluePlus.isScanningNow).thenReturn(false);
    });
    when(flutterBluePlus.scanResults).thenAnswer((_) => mockResults.stream);
    final cubit = DeviceScanCubit(
      service: '1810',
      settings: settings,
      manager: manager
    );
    expect(cubit.state, isA<DeviceListLoading>());

    final (wrongRes0, wrongDev0) = createScanResultMock('wrongDev0');
    mockResults.sink.add([wrongRes0]);

    await expectLater(cubit.stream, emits(isA<SingleDeviceAvailable>()));

    final (res, dev) = createScanResultMock('testDev');
    mockResults.sink.add([wrongRes0, res]);

    // No prompt when finding the correct device again
    await expectLater(cubit.stream, emits(isA<DeviceSelected>()));
  });
}
