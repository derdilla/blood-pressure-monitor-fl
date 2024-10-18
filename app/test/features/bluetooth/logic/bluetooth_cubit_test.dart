import 'dart:async';

import 'package:blood_pressure_app/features/bluetooth/backend/flutter_blue_plus/fbp_manager.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/flutter_blue_plus/flutter_blue_plus_mockable.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/bluetooth_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateNiceMocks([
  MockSpec<FlutterBluePlusMockable>(),
])
import 'bluetooth_cubit_test.mocks.dart';

void main() {
  test('should translate adapter stream to state', () async {
    WidgetsFlutterBinding.ensureInitialized();
    final flutterBluePlus = MockFlutterBluePlusMockable();
    when(flutterBluePlus.adapterState).thenAnswer((_) =>
      Stream.fromIterable([
        fbp.BluetoothAdapterState.unknown,
        fbp.BluetoothAdapterState.unavailable,
        fbp.BluetoothAdapterState.turningOff,
        fbp.BluetoothAdapterState.off,
        fbp.BluetoothAdapterState.unauthorized,
        fbp.BluetoothAdapterState.turningOn,
        fbp.BluetoothAdapterState.on,
    ]));
    final manager = FlutterBluePlusManager(flutterBluePlus);
    final cubit = BluetoothCubit(manager: manager);
    expect(cubit.state, isA<BluetoothStateInitial>());

    await expectLater(cubit.stream, emitsInOrder([
      isA<BluetoothStateInitial>(),
      isA<BluetoothStateUnfeasible>(),
      isA<BluetoothStateDisabled>(),
      isA<BluetoothStateDisabled>(),
      isA<BluetoothStateUnauthorized>(),
      isA<BluetoothStateDisabled>(),
      isA<BluetoothStateReady>(),
    ]));
  });
}
