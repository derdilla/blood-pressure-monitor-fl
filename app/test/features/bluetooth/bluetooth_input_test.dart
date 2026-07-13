import 'package:bloc_test/bloc_test.dart';
import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_backend.dart';
import 'package:blood_pressure_app/features/bluetooth/bluetooth_input.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/ble_read_cubit.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/bluetooth_cubit.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/ble_measurement_data.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/device_scan_cubit.dart';
import 'package:blood_pressure_app/features/bluetooth/ui/closed_bluetooth_input.dart';
import 'package:blood_pressure_app/features/bluetooth/ui/measurement_success.dart';
import 'package:blood_pressure_app/model/bluetooth_measurement_import_mode.dart';
import 'package:blood_pressure_app/model/storage/settings.dart';
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

class MockBluetoothManager extends Fake implements BluetoothManager {}

void main() {
  testWidgets('propagates successful read', (WidgetTester tester) async {
    final bluetoothCubit = _MockBluetoothCubit();
    whenListen(bluetoothCubit,
        Stream<BluetoothState>.fromIterable([BluetoothStateReady()]),
        initialState: BluetoothStateReady());
    final deviceScanCubit = _MockDeviceScanCubit();
    final bleReadCubit = _MockBleReadCubit();
    final devScanOk = DeviceSelected(bleReadCubit);
    whenListen(
        deviceScanCubit, Stream<DeviceScanState>.fromIterable([devScanOk]),
        initialState: devScanOk);
    final bleReadOk = BleReadSuccess(BleMeasurementData(
      systolic: 123,
      diastolic: 45,
      meanArterialPressure: 67,
      isMMHG: true,
    ));
    whenListen(
      bleReadCubit,
      Stream<BleReadState>.fromIterable([bleReadOk]),
      initialState: bleReadOk,
    );

    final List<BloodPressureRecord> reads = [];
    await tester.pumpWidget(materialApp(BluetoothInput(
      manager: MockBluetoothManager(),
      onMeasurement: reads.add,
      onAllMeasurements: (_) {},
      bluetoothCubit: () => bluetoothCubit,
      deviceScanCubit: () => deviceScanCubit,
      bleReadCubit: () => bleReadCubit,
    )));

    await tester.tap(find.byType(ClosedBluetoothInput));
    await tester.pumpAndSettle();
    expect(find.byType(ClosedBluetoothInput), findsNothing);

    expect(reads, hasLength(1));
    expect(reads.first.sys?.mmHg, 123);
    expect(reads.first.dia?.mmHg, 45);
    expect(reads.first.pul, null);
  });
  testWidgets('allows closing after successful read',
      (WidgetTester tester) async {
    final bluetoothCubit = _MockBluetoothCubit();
    whenListen(bluetoothCubit,
        Stream<BluetoothState>.fromIterable([BluetoothStateReady()]),
        initialState: BluetoothStateReady());
    final deviceScanCubit = _MockDeviceScanCubit();
    final bleReadCubit = _MockBleReadCubit();
    final devScanOk = DeviceSelected(bleReadCubit);
    whenListen(
        deviceScanCubit, Stream<DeviceScanState>.fromIterable([devScanOk]),
        initialState: devScanOk);
    final bleReadOk = BleReadSuccess(BleMeasurementData(
      systolic: 123,
      diastolic: 45,
      meanArterialPressure: 67,
      isMMHG: true,
    ));
    whenListen(
      bleReadCubit,
      Stream<BleReadState>.fromIterable([bleReadOk]),
      initialState: bleReadOk,
    );

    final List<BloodPressureRecord> reads = [];
    await tester.pumpWidget(materialApp(BluetoothInput(
      manager: MockBluetoothManager(),
      onMeasurement: reads.add,
      onAllMeasurements: (_) {},
      bluetoothCubit: () => bluetoothCubit,
      deviceScanCubit: () => deviceScanCubit,
    )));

    await tester.tap(find.byType(ClosedBluetoothInput));
    await tester.pumpAndSettle();
    expect(find.byType(ClosedBluetoothInput), findsNothing);
    expect(find.byType(MeasurementSuccess), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.byType(ClosedBluetoothInput), findsOneWidget);
  });
  testWidgets("doesn't attempt to turn on bluetooth before interaction",
      (tester) async {
    final bluetoothCubit = _MockBluetoothCubitFailingEnable();
    whenListen(bluetoothCubit,
        Stream<BluetoothState>.fromIterable([BluetoothStateDisabled()]),
        initialState: BluetoothStateReady());
    final widget = BluetoothInput(
      manager: MockBluetoothManager(),
      onMeasurement: (_) {},
      onAllMeasurements: (_) {},
      bluetoothCubit: () => bluetoothCubit,
    );
    await tester.pumpWidget(materialApp(widget));
    BluetoothInputState widgetState = tester.state(find.byWidget(widget));
    expect(tester.takeException(), isNull);
    expect(widgetState.isActive, false);
  });

  testWidgets("Auto-starts bluetooth import", (tester) async {
    final bluetoothCubit = _MockBluetoothCubitFailingEnable();
    final settings = Settings(autostartBluetoothInput: true);
    whenListen(bluetoothCubit,
        Stream<BluetoothState>.fromIterable([BluetoothStateReady()]),
        initialState: BluetoothStateReady());
    final widget = BluetoothInput(
      manager: MockBluetoothManager(),
      onMeasurement: (_) {},
      onAllMeasurements: (_) {},
      bluetoothCubit: () => bluetoothCubit,
    );
    await tester.pumpWidget(materialApp(widget, settings: settings));
    BluetoothInputState widgetState = tester.state(find.byWidget(widget));
    expect(widgetState.isActive, true);
  });

  testWidgets("Auto-imports bluetooth data", (tester) async {

    final settings =
        Settings(bluetoothImportMode: BluetoothMeasurementImportMode.all, autostartBluetoothInput: true);

    final bluetoothCubit = _MockBluetoothCubit();
    whenListen(bluetoothCubit,
        Stream<BluetoothState>.fromIterable([BluetoothStateReady()]),
        initialState: BluetoothStateReady());

    final deviceScanCubit = _MockDeviceScanCubit();
    final bleReadCubit = _MockBleReadCubit();
    final devScanOk = DeviceSelected(bleReadCubit);
    whenListen(
        deviceScanCubit, Stream<DeviceScanState>.fromIterable([devScanOk]),
        initialState: devScanOk);

    final bleReadOk = BleReadMultiple([BleMeasurementData(
      systolic: 123,
      diastolic: 45,
      meanArterialPressure: 67,
      isMMHG: true,
    )]);
    whenListen(
      bleReadCubit,
      Stream<BleReadState>.fromIterable([bleReadOk]),
      initialState: bleReadOk,
    );

    final List<BloodPressureRecord> reads = [];
    final widget = BluetoothInput(
      manager: MockBluetoothManager(),
      onMeasurement: reads.add,
      onAllMeasurements: reads.addAll,
      bluetoothCubit: () => bluetoothCubit,
      deviceScanCubit: () => deviceScanCubit
    );
    await tester.pumpWidget(materialApp(widget, settings: settings));

    BluetoothInputState widgetState = tester.state(find.byWidget(widget));
    expect(widgetState.isActive, true);
    expect(widgetState.hasImported, true);
    expect(reads.length, 1);
  });
}
