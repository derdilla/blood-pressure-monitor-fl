import 'package:blood_pressure_app/bluetooth/ble_read_cubit.dart';
import 'package:blood_pressure_app/bluetooth/logging.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<BluetoothDevice>(),
  MockSpec<BluetoothService>(),
  MockSpec<BluetoothCharacteristic>()
])
import 'ble_read_cubit_test.mocks.dart';

void main() {
  test('success path works', () async {
    final characteristic = MockBluetoothCharacteristic();
    when(characteristic.uuid).thenReturn(Guid('2A35'));
    when(characteristic.read()).thenAnswer((_) async => [1,2,3]); // TODO

    final service = MockBluetoothService();
    when(service.uuid).thenReturn(Guid('1810'));
    when(service.characteristics).thenReturn([characteristic]);

    final BluetoothDevice device = MockBluetoothDevice();
    when(device.discoverServices()).thenAnswer((_) async => [service]);

    final cubit = BleReadCubit(device);
    expect(cubit.state, isA<BleReadInProgress>());
    await expectLater(cubit.stream, emits(isA<BleReadSuccess>()));
  });
  test('should fail when device not connected', () async {
    final BluetoothDevice device = MockBluetoothDevice();
    when(device.discoverServices()).thenThrow(FlutterBluePlusException(
        ErrorPlatform.fbp, 'discoverServices', FbpErrorCode.deviceIsDisconnected.index, 'device is not connected'
    ));

    Log.testExpectError = true;
    final cubit = BleReadCubit(device);
    expect(cubit.state, isA<BleReadFailure>(), reason: 'fails fast. Having a '
        'BleReadInProgress first would also be fine.');
    Log.testExpectError = false;
  });
  test('should fail without matching service', () async {
    final service = MockBluetoothService();
    when(service.uuid).thenReturn(Guid('1811'));

    final BluetoothDevice device = MockBluetoothDevice();
    when(device.discoverServices()).thenAnswer((_) async => [service]);

    Log.testExpectError = true;
    final cubit = BleReadCubit(device);
    expect(cubit.state, isA<BleReadInProgress>());
    await expectLater(cubit.stream, emits(isA<BleReadFailure>()));
    Log.testExpectError = false;
  });
  test('fails without matching characteristic', () async {
    final characteristic = MockBluetoothCharacteristic();
    when(characteristic.uuid).thenReturn(Guid('2A34'));

    final service = MockBluetoothService();
    when(service.uuid).thenReturn(Guid('1810'));
    when(service.characteristics).thenReturn([characteristic]);

    final BluetoothDevice device = MockBluetoothDevice();
    when(device.discoverServices()).thenAnswer((_) async => [service]);

    Log.testExpectError = true;
    final cubit = BleReadCubit(device);
    expect(cubit.state, isA<BleReadInProgress>());
    await expectLater(cubit.stream, emits(isA<BleReadFailure>()));
    Log.testExpectError = false;
  });
  test('fails when not able to read data', () async {
    final characteristic = MockBluetoothCharacteristic();
    when(characteristic.uuid).thenReturn(Guid('2A35'));
    when(characteristic.read()).thenThrow(FlutterBluePlusException(
        ErrorPlatform.fbp, 'discoverServices', FbpErrorCode.deviceIsDisconnected.index, 'device is not connected'
    ));

    final service = MockBluetoothService();
    when(service.uuid).thenReturn(Guid('1810'));
    when(service.characteristics).thenReturn([characteristic]);

    final BluetoothDevice device = MockBluetoothDevice();
    when(device.discoverServices()).thenAnswer((_) async => [service]);

    Log.testExpectError = true;
    final cubit = BleReadCubit(device);
    expect(cubit.state, isA<BleReadInProgress>());
    await expectLater(cubit.stream, emits(isA<BleReadFailure>()));
    Log.testExpectError = false;
  });
}
