import 'dart:async';

import 'package:blood_pressure_app/bluetooth/device_scan_cubit.dart';
import 'package:blood_pressure_app/bluetooth/flutter_blue_plus_mockable.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<BluetoothDevice>(),
  MockSpec<BluetoothService>(),
  MockSpec<AdvertisementData>(),
  MockSpec<FlutterBluePlusMockable>(),
  MockSpec<ScanResult>(),
])
import 'device_scan_cubit_test.mocks.dart';

void main() {
  test('finds and connects to devices', () async {
    Log.testExpectError = true;
    final StreamController<List<ScanResult>> mockResults = StreamController.broadcast();
    final settings = Settings();

    final flutterBluePlus = MockFlutterBluePlusMockable();
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
        service: Guid('1810'),
        settings: settings,
        flutterBluePlus: flutterBluePlus
    );
    expect(cubit.state, isA<DeviceListLoading>());

    final wrongRes0 = MockScanResult();
    final wrongDev0 = MockBluetoothDevice();
    final wrongRes1 = MockScanResult();
    final wrongDev1 = MockBluetoothDevice();
    when(wrongDev0.platformName).thenReturn('wrongDev0');
    when(wrongRes0.device).thenReturn(wrongDev0);
    when(wrongDev1.platformName).thenReturn('wrongDev1');
    when(wrongRes1.device).thenReturn(wrongDev1);
    mockResults.sink.add([wrongRes0]);
    await expectLater(cubit.stream, emits(isA<SingleDeviceAvailable>()));

    mockResults.sink.add([wrongRes0, wrongRes1]);
    await expectLater(cubit.stream, emits(isA<DeviceListAvailable>()));

    final dev = MockBluetoothDevice();
    when(dev.platformName).thenReturn('testDev');
    final res = MockScanResult();
    when(res.device).thenReturn(dev);

    mockResults.sink.add([res]);
    await expectLater(cubit.stream, emits(isA<SingleDeviceAvailable>()
        .having((r) => r.device.device, 'device', dev)));

    expect(settings.knownBleDev, isEmpty);
    await cubit.acceptDevice(dev);
    expect(settings.knownBleDev, contains('testDev'));
    // state should be set as we await above
    await expectLater(cubit.state, isA<DeviceSelected>()
      .having((s) => s.device, 'device', dev));
    Log.testExpectError = false;
  });
  test('recognizes devices', () async {
    Log.testExpectError = true;
    final StreamController<List<ScanResult>> mockResults = StreamController.broadcast();
    final settings = Settings(
      knownBleDev: ['testDev']
    );

    final flutterBluePlus = MockFlutterBluePlusMockable();
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
      service: Guid('1810'),
      settings: settings,
      flutterBluePlus: flutterBluePlus
    );
    expect(cubit.state, isA<DeviceListLoading>());

    final wrongRes0 = MockScanResult();
    final wrongDev0 = MockBluetoothDevice();
    when(wrongDev0.platformName).thenReturn('wrongDev0');
    when(wrongRes0.device).thenReturn(wrongDev0);
    mockResults.sink.add([wrongRes0]);
    await expectLater(cubit.stream, emits(isA<SingleDeviceAvailable>()));

    final dev = MockBluetoothDevice();
    when(dev.platformName).thenReturn('testDev');
    final res = MockScanResult();
    when(res.device).thenReturn(dev);
    mockResults.sink.add([wrongRes0, res]);
    // No prompt when finding the correct device again
    await expectLater(cubit.stream, emits(isA<DeviceSelected>()));
    Log.testExpectError = false;
  });
}
