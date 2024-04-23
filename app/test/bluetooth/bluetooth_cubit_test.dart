import 'dart:async';

import 'package:blood_pressure_app/bluetooth/bluetooth_cubit.dart';
import 'package:blood_pressure_app/bluetooth/flutter_blue_plus_mockable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([MockSpec<FlutterBluePlusMockable>()])
import 'bluetooth_cubit_test.mocks.dart';

void main() {
  test('should translate adapter stream to state', () async {
    final bluePlus = MockFlutterBluePlusMockable();
    when(bluePlus.adapterState).thenAnswer((_) =>
      Stream.fromIterable([
        BluetoothAdapterState.unknown,
        BluetoothAdapterState.unavailable,
        BluetoothAdapterState.turningOff,
        BluetoothAdapterState.off,
        BluetoothAdapterState.unauthorized,
        BluetoothAdapterState.turningOn,
        BluetoothAdapterState.on,
    ]));
    final cubit = BluetoothCubit(flutterBluePlus: bluePlus);
    expect(cubit.state, isA<BluetoothInitial>());

    await expectLater(cubit.stream, emitsInOrder([
      isA<BluetoothInitial>(),
      isA<BluetoothUnfeasible>(),
      isA<BluetoothDisabled>(),
      isA<BluetoothDisabled>(),
      isA<BluetoothUnauthorized>(),
      isA<BluetoothDisabled>(),
      isA<BluetoothReady>(),
    ]));
  });
  // TODO: integration tests ?
  test('should request permissions', () async {});
  test('should enable bluetooth', () async {});
}
