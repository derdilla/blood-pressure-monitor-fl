import 'package:bloc_test/bloc_test.dart';
import 'package:blood_pressure_app/bluetooth/ble_read_cubit.dart';
import 'package:blood_pressure_app/bluetooth/bluetooth_cubit.dart';
import 'package:blood_pressure_app/bluetooth/characteristics/ble_measurement_data.dart';
import 'package:blood_pressure_app/bluetooth/device_scan_cubit.dart';
import 'package:blood_pressure_app/components/bluetooth_input.dart';
import 'package:blood_pressure_app/components/bluetooth_input/closed_bluetooth_input.dart';
import 'package:blood_pressure_app/components/bluetooth_input/measurement_success.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothState;
import 'package:flutter_test/flutter_test.dart';

import 'util.dart';

class _MockBluetoothCubit extends MockCubit<BluetoothState>
    implements BluetoothCubit {}
class _MockDeviceScanCubit extends MockCubit<DeviceScanState>
    implements DeviceScanCubit {}
class _MockBleReadCubit extends MockCubit<BleReadState>
    implements BleReadCubit {}

void main() {
  testWidgets('propagates successful read', (WidgetTester tester) async {
    final bluetoothCubit = _MockBluetoothCubit();
    whenListen(bluetoothCubit, Stream<BluetoothState>.fromIterable([BluetoothReady()]),
      initialState: BluetoothReady());
    final deviceScanCubit = _MockDeviceScanCubit();
    final devScanOk = DeviceSelected(BluetoothDevice(remoteId: DeviceIdentifier('tstDev')));
    whenListen(deviceScanCubit, Stream<DeviceScanState>.fromIterable([devScanOk]),
      initialState: devScanOk);
    final bleReadCubit = _MockBleReadCubit();
    final bleReadOk = BleReadSuccess(BleMeasurementData(
      systolic: 123,
      diastolic: 45,
      meanArterialPressure: 67,
      isMMHG: true,
      pulse: null,
      userID: null,
      status: null,
      timestamp: null,
    ));
    whenListen(bleReadCubit, Stream<BleReadState>.fromIterable([bleReadOk]),
      initialState: bleReadOk,
    );

    final List<BloodPressureRecord> reads = [];
    await tester.pumpWidget(materialApp(BluetoothInput(
      settings: Settings(),
      onMeasurement: reads.add,
      bluetoothCubit: () => bluetoothCubit,
      deviceScanCubit: () => deviceScanCubit,
      bleReadCubit: () => bleReadCubit,
    )));

    await tester.tap(find.byType(ClosedBluetoothInput));
    await tester.pumpAndSettle();
    expect(find.byType(ClosedBluetoothInput), findsNothing);

    expect(reads, hasLength(1));
    expect(reads, contains(isA<BloodPressureRecord>()
      .having((p) => p.systolic, 'sys', 123)
      .having((p) => p.diastolic, 'dia', 45)
      .having((p) => p.pulse, 'pul', isNull),
    ));
  });

  testWidgets('allows closing after successful read', (WidgetTester tester) async {
    final bluetoothCubit = _MockBluetoothCubit();
    whenListen(bluetoothCubit, Stream<BluetoothState>.fromIterable([BluetoothReady()]),
      initialState: BluetoothReady());
    final deviceScanCubit = _MockDeviceScanCubit();
    final devScanOk = DeviceSelected(BluetoothDevice(remoteId: DeviceIdentifier('tstDev')));
    whenListen(deviceScanCubit, Stream<DeviceScanState>.fromIterable([devScanOk]),
      initialState: devScanOk);
    final bleReadCubit = _MockBleReadCubit();
    final bleReadOk = BleReadSuccess(BleMeasurementData(
      systolic: 123,
      diastolic: 45,
      meanArterialPressure: 67,
      isMMHG: true,
      pulse: null,
      userID: null,
      status: null,
      timestamp: null,
    ));
    whenListen(bleReadCubit, Stream<BleReadState>.fromIterable([bleReadOk]),
      initialState: bleReadOk,
    );

    final List<BloodPressureRecord> reads = [];
    await tester.pumpWidget(materialApp(BluetoothInput(
      settings: Settings(),
      onMeasurement: reads.add,
      bluetoothCubit: () => bluetoothCubit,
      deviceScanCubit: () => deviceScanCubit,
      bleReadCubit: () => bleReadCubit,
    )));

    await tester.tap(find.byType(ClosedBluetoothInput));
    await tester.pumpAndSettle();
    expect(find.byType(ClosedBluetoothInput), findsNothing);
    expect(find.byType(MeasurementSuccess), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.byType(ClosedBluetoothInput), findsOneWidget);
  });
}
