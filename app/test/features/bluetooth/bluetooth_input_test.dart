import 'package:bloc_test/bloc_test.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/mock/mock_manager.dart';
import 'package:blood_pressure_app/features/bluetooth/bluetooth_input.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/ble_read_cubit.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/bluetooth_cubit.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/ble_measurement_data.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/device_scan_cubit.dart';
import 'package:blood_pressure_app/features/bluetooth/ui/closed_bluetooth_input.dart';
import 'package:blood_pressure_app/features/bluetooth/ui/measurement_success.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';

import '../../util.dart';

class _MockBluetoothCubit extends MockCubit<BluetoothState>
    implements BluetoothCubit {}
class _MockDeviceScanCubit extends MockCubit<DeviceScanState>
    implements DeviceScanCubit {}
class _MockBleReadCubit extends MockCubit<BleReadState>
    implements BleReadCubit {}
class _MockBluetoothCubitFailingEnable extends MockCubit<BluetoothState>
    implements BluetoothCubit {
  @override
  Future<bool> enableBluetooth() async {
    throw 'enableBluetooth called';
  }
}

void main() {
  testWidgets('propagates successful read', (WidgetTester tester) async {
    final bluetoothCubit = _MockBluetoothCubit();
    whenListen(bluetoothCubit, Stream<BluetoothState>.fromIterable([BluetoothStateReady()]),
      initialState: BluetoothStateReady());
    final deviceScanCubit = _MockDeviceScanCubit();
    final devScanOk = DeviceSelected(MockBluetoothDevice(MockBluetoothManager(), 'tstDev'));
    whenListen(deviceScanCubit, Stream<DeviceScanState>.fromIterable([devScanOk]),
      initialState: devScanOk);
    final bleReadCubit = _MockBleReadCubit();
    final bleReadOk = BleReadSuccess(BleMeasurementData(
      systolic: 123,
      diastolic: 45,
      meanArterialPressure: 67,
      isMMHG: true,
    ));
    whenListen(bleReadCubit, Stream<BleReadState>.fromIterable([bleReadOk]),
      initialState: bleReadOk,
    );

    final List<BloodPressureRecord> reads = [];
    await tester.pumpWidget(materialApp(BluetoothInput(
      manager: MockBluetoothManager(),
      onMeasurement: reads.add,
      bluetoothCubit: () => bluetoothCubit,
      deviceScanCubit: () => deviceScanCubit,
      bleReadCubit: (device) => bleReadCubit,
    )));

    await tester.tap(find.byType(ClosedBluetoothInput));
    await tester.pumpAndSettle();
    expect(find.byType(ClosedBluetoothInput), findsNothing);

    expect(reads, hasLength(1));
    expect(reads.first.sys?.mmHg, 123);
    expect(reads.first.dia?.mmHg, 45);
    expect(reads.first.pul, null);
  });
  testWidgets('allows closing after successful read', (WidgetTester tester) async {
    final bluetoothCubit = _MockBluetoothCubit();
    whenListen(bluetoothCubit, Stream<BluetoothState>.fromIterable([BluetoothStateReady()]),
      initialState: BluetoothStateReady());
    final deviceScanCubit = _MockDeviceScanCubit();
    final devScanOk = DeviceSelected(MockBluetoothDevice(MockBluetoothManager(), 'tstDev'));
    whenListen(deviceScanCubit, Stream<DeviceScanState>.fromIterable([devScanOk]),
      initialState: devScanOk);
    final bleReadCubit = _MockBleReadCubit();
    final bleReadOk = BleReadSuccess(BleMeasurementData(
      systolic: 123,
      diastolic: 45,
      meanArterialPressure: 67,
      isMMHG: true,
    ));
    whenListen(bleReadCubit, Stream<BleReadState>.fromIterable([bleReadOk]),
      initialState: bleReadOk,
    );

    final List<BloodPressureRecord> reads = [];
    await tester.pumpWidget(materialApp(BluetoothInput(
      manager: MockBluetoothManager(),
      onMeasurement: reads.add,
      bluetoothCubit: () => bluetoothCubit,
      deviceScanCubit: () => deviceScanCubit,
      bleReadCubit: (device) => bleReadCubit,
    )));

    await tester.tap(find.byType(ClosedBluetoothInput));
    await tester.pumpAndSettle();
    expect(find.byType(ClosedBluetoothInput), findsNothing);
    expect(find.byType(MeasurementSuccess), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.byType(ClosedBluetoothInput), findsOneWidget);
  });
  testWidgets("doesn't attempt to turn on bluetooth before interaction", (tester) async {
    final bluetoothCubit = _MockBluetoothCubitFailingEnable();
    whenListen(bluetoothCubit, Stream<BluetoothState>.fromIterable([BluetoothStateDisabled()]),
      initialState: BluetoothStateReady());
    await tester.pumpWidget(materialApp(BluetoothInput(
      manager: MockBluetoothManager(),
      onMeasurement: (_) {},
      bluetoothCubit: () => bluetoothCubit,
    )));
    expect(tester.takeException(), isNull);
  });
}
