import 'package:blood_pressure_app/features/bluetooth/bluetooth_input.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/ble_read_cubit.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/bluetooth_cubit.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/device_scan_cubit.dart';
import 'package:blood_pressure_app/features/input/forms/add_entry_form.dart';
import 'package:blood_pressure_app/features/input/forms/blood_pressure_form.dart';
import 'package:blood_pressure_app/features/input/forms/date_time_form.dart';
import 'package:blood_pressure_app/features/input/forms/medicine_intake_form.dart';
import 'package:blood_pressure_app/features/input/forms/note_form.dart';
import 'package:blood_pressure_app/features/input/forms/weight_form.dart';
import 'package:blood_pressure_app/features/old_bluetooth/bluetooth_input.dart';
import 'package:blood_pressure_app/model/storage/bluetooth_input_mode.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../util.dart';

void main() {
  group('shows sub-forms depending on settings', () {
    // always show NoteForm, BloodPressureForm
    
    testWidgets('show TimeForm if and only if setting is set (default true)', (tester) async {
      final settings = Settings();
      await tester.pumpWidget(materialApp(AddEntryForm(meds: []), settings: settings));

      expect(find.byType(TabBar, skipOffstage: false), findsNothing);
      expect(find.byType(NoteForm, skipOffstage: false), findsOneWidget);
      expect(find.byType(BloodPressureForm, skipOffstage: false), findsOneWidget);
      expect(find.byType(DateTimeForm, skipOffstage: false), findsOneWidget);
      expect(find.byType(WeightForm, skipOffstage: false), findsNothing);
      expect(find.byType(MedicineIntakeForm, skipOffstage: false), findsNothing);
      expect(find.byType(OldBluetoothInput, skipOffstage: false), findsNothing);
      expect(find.byType(BluetoothInput, skipOffstage: false), findsNothing);
      
      settings.allowManualTimeInput = false;
      await tester.pumpAndSettle();

      expect(find.byType(DateTimeForm, skipOffstage: false), findsNothing);
    });
    
    testWidgets('show WeightForm if and only if setting is set', (tester) async {
      final settings = Settings(weightInput: true);
      await tester.pumpWidget(materialApp(AddEntryForm(meds: []), settings: settings));

      expect(find.byType(TabBar, skipOffstage: false), findsOneWidget);
      expect(find.byType(NoteForm, skipOffstage: false), findsOneWidget);
      expect(find.byType(BloodPressureForm, skipOffstage: false), findsOneWidget);
      expect(find.byType(DateTimeForm, skipOffstage: false), findsOneWidget);
      expect(find.byType(WeightForm, skipOffstage: false), findsOneWidget);
      expect(find.byType(MedicineIntakeForm, skipOffstage: false), findsNothing);
      expect(find.byType(OldBluetoothInput, skipOffstage: false), findsNothing);
      expect(find.byType(BluetoothInput, skipOffstage: false), findsNothing);

      settings.weightInput = false;
      await tester.pumpAndSettle();

      expect(find.byType(WeightForm, skipOffstage: false), findsNothing);
    });

    testWidgets('show MedicineIntakeForm if medicines are available', (tester) async {
      await tester.pumpWidget(materialApp(AddEntryForm(meds: [mockMedicine()])));

      expect(find.byType(TabBar, skipOffstage: false), findsOneWidget);
      expect(find.byType(NoteForm, skipOffstage: false), findsOneWidget);
      expect(find.byType(BloodPressureForm, skipOffstage: false), findsOneWidget);
      expect(find.byType(DateTimeForm, skipOffstage: false), findsOneWidget);
      expect(find.byType(WeightForm, skipOffstage: false), findsNothing);
      expect(find.byType(MedicineIntakeForm, skipOffstage: false), findsOneWidget);
      expect(find.byType(OldBluetoothInput, skipOffstage: false), findsNothing);
      expect(find.byType(BluetoothInput, skipOffstage: false), findsNothing);
    });

    testWidgets('show the BluetoothInput specified by setting', (tester) async {
      final settings = Settings(bleInput: BluetoothInputMode.disabled);
      await tester.pumpWidget(materialApp(AddEntryForm(
          meds: [],
          bluetoothCubit: _MockBluetoothCubit.new
      ), settings: settings));

      expect(find.byType(TabBar, skipOffstage: false), findsNothing);
      expect(find.byType(NoteForm, skipOffstage: false), findsOneWidget);
      expect(find.byType(BloodPressureForm, skipOffstage: false), findsOneWidget);
      expect(find.byType(DateTimeForm, skipOffstage: false), findsOneWidget);
      expect(find.byType(WeightForm, skipOffstage: false), findsNothing);
      expect(find.byType(MedicineIntakeForm, skipOffstage: false), findsNothing);
      expect(find.byType(OldBluetoothInput, skipOffstage: false), findsNothing);
      expect(find.byType(BluetoothInput, skipOffstage: false), findsNothing);

      settings.bleInput = BluetoothInputMode.newBluetoothInputOldLib;
      await tester.pumpAndSettle();

      expect(find.byType(OldBluetoothInput, skipOffstage: false), findsNothing);
      expect(find.byType(BluetoothInput, skipOffstage: false), findsOneWidget);

      settings.bleInput = BluetoothInputMode.disabled;
      await tester.pumpAndSettle();

      expect(find.byType(OldBluetoothInput, skipOffstage: false), findsNothing);
      expect(find.byType(BluetoothInput, skipOffstage: false), findsNothing);
    });
  });

  testWidgets('saves all entered values', (tester) {fail('TODO');});

  testWidgets('saves partially entered values (blood pressure)', (tester) {fail('TODO');});

  testWidgets('saves partially entered values (intake)', (tester) {fail('TODO');});

  testWidgets('saves partially entered values (note)', (tester) {fail('TODO');});

  testWidgets('initializes timestamp correctly', (tester) {fail('TODO');});

  testWidgets('validates time form', (tester) {fail('TODO');});

  testWidgets('validates bp form', (tester) {fail('TODO');});

  testWidgets('validates weight form', (tester) {fail('TODO');});

  testWidgets('validates intake form', (tester) {fail('TODO');});

  testWidgets('loads initial values', (tester) {fail('TODO');});

  testWidgets('saves prefilled values as is', (tester) {fail('TODO');});

  testWidgets("doesn't save empty forms", (tester) {fail('TODO');});

  testWidgets('loads values through method call', (tester) {fail('TODO');});

  testWidgets('only shows bluetooth input when requested', (tester) {fail('TODO');});

  // TODO: reevaluate this. Can other code change?
  testWidgets('returns values on edit cancel', (tester) {fail('TODO');});

  testWidgets('focuses last input field on backspace', (tester) {fail('TODO');});

  testWidgets("doesn't focus last input on backspace if the current is still filled", (tester) {fail('TODO');});

  //testWidgets('description', (tester) {fail('TODO');});
}

class _MockBluetoothCubit extends Fake implements BluetoothCubit {
  @override
  Future<void> close() async {}

  @override
  BluetoothState get state => BluetoothStateDisabled();

  @override
  // TODO: implement stream
  Stream<BluetoothState> get stream => Stream.empty();
}
class _MockDeviceScanCubit extends Fake implements DeviceScanCubit {}
class _MockBleReadCubit extends Fake implements BleReadCubit {}
