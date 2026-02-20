import 'package:blood_pressure_app/features/bluetooth/bluetooth_input.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/bluetooth_cubit.dart';
import 'package:blood_pressure_app/features/input/forms/add_entry_form.dart';
import 'package:blood_pressure_app/features/input/forms/blood_pressure_form.dart';
import 'package:blood_pressure_app/features/input/forms/date_time_form.dart';
import 'package:blood_pressure_app/features/input/forms/medicine_intake_form.dart';
import 'package:blood_pressure_app/features/input/forms/note_form.dart';
import 'package:blood_pressure_app/features/input/forms/weight_form.dart';
import 'package:blood_pressure_app/features/old_bluetooth/bluetooth_input.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/storage/bluetooth_input_mode.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:intl/intl.dart';

import '../../../model/analyzer_test.dart';
import '../../../model/export_import/record_formatter_test.dart';
import '../../../util.dart';
import '../../measurement_list/measurement_list_entry_test.dart';

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
        bluetoothCubit: _MockBoringBluetoothCubit.new
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

  testWidgets('saves all entered values', (tester) async {
    final med1 = mockMedicine(color: Colors.blue, designation: 'med123', defaultDosis: 3.14);
    final key = GlobalKey<AddEntryFormState>();
    await tester.pumpWidget(materialApp(AddEntryForm(key: key, meds: [med1]),
      settings: Settings(weightInput: true)
    ));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '123'); // sys
    await tester.enterText(fields.at(1), '45'); // dia
    await tester.enterText(fields.at(2), '67'); // pul

    await tester.tap(find.byIcon(Icons.medication_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text(med1.designation)); // med
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.scale));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '65.4'); // weight

    await tester.enterText(find.descendant(
        of: find.byType(NoteForm),
        matching: find.byType(TextField),
    ), 'some note'); // note text
    await tester.pumpAndSettle();

    expect(key.currentState!.validate(), true);
    final res = key.currentState!.save();
    expect(res?.record?.sys?.mmHg, 123);
    expect(res?.record?.dia?.mmHg, 45);
    expect(res?.record?.pul, 67);
    expect(res?.intake?.medicine, med1);
    expect(res?.intake?.dosis, med1.dosis);
    expect(res?.weight?.weight.kg, 65.4);
    expect(res?.note?.note, 'some note');
    expect(res?.note?.color, isNull);
  });

  testWidgets('saves partially entered values (blood pressure)', (tester) async {
    final key = GlobalKey<AddEntryFormState>();
    await tester.pumpWidget(materialApp(AddEntryForm(key: key)));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '123'); // sys
    await tester.enterText(fields.at(1), '45'); // dia
    await tester.enterText(fields.at(2), '67'); // pul

    expect(key.currentState!.validate(), true);
    final res = key.currentState!.save();
    expect(res?.record?.sys?.mmHg, 123);
    expect(res?.record?.dia?.mmHg, 45);
    expect(res?.record?.pul, 67);
    expect(res?.intake, isNull);
    expect(res?.note, isNull);
  });

  testWidgets('saves partially entered values (note)', (tester) async {
    final key = GlobalKey<AddEntryFormState>();
    await tester.pumpWidget(materialApp(AddEntryForm(key: key)));

    await tester.enterText(find.descendant(
      of: find.byType(NoteForm),
      matching: find.byType(TextField),
    ), 'some note'); // note text
    await tester.pumpAndSettle();

    expect(key.currentState!.validate(), true);
    final res = key.currentState!.save();
    expect(res?.record, isNull);
    expect(res?.intake, isNull);
    expect(res?.weight, isNull);
    expect(res?.note?.note, 'some note');
  });

  testWidgets('saves partially entered values (intake)', (tester) async {
    final med1 = mockMedicine(color: Colors.blue, designation: 'med123', defaultDosis: 3.14);
    final key = GlobalKey<AddEntryFormState>();
    await tester.pumpWidget(materialApp(AddEntryForm(key: key, meds: [med1])));

    await tester.tap(find.byIcon(Icons.medication_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text(med1.designation)); // med
    await tester.pumpAndSettle();

    expect(key.currentState!.validate(), true);
    final res = key.currentState!.save();
    expect(res?.record, isNull);
    expect(res?.weight, isNull);
    expect(res?.note, isNull);
    expect(res?.intake?.medicine, med1);
    expect(res?.intake?.dosis, med1.dosis);
  });

  testWidgets('initializes timestamp correctly', (tester) async {
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final timeFormatter = DateFormat('HH:mm');

    final start = DateTime.now();
    await tester.pumpWidget(materialApp(AddEntryForm(meds: [])));

    expect(find.text(dateFormatter.format(start)), findsOneWidget);
    final allowedTimes = anyOf(timeFormatter.format(start), timeFormatter.format(start.add(Duration(minutes: 1))));
    expect(find.byWidgetPredicate(
            (w) => w is Text && allowedTimes.matches(w.data, {})),
        findsOneWidget);
  });

  testWidgets('validates time form', (tester) async {
    final key = GlobalKey<AddEntryFormState>();
    final time = DateTime.now();
    await tester.pumpWidget(materialApp(AddEntryForm(key: key)));
    expect(key.currentState?.validate(), true);

    key.currentState!.fillForm((
      timestamp: time.add(Duration(hours: 1)),
      intake: null, note: null, record: null, weight: null,
    ));
    await tester.pump();
    expect(key.currentState?.validate(), false);
  });

  testWidgets('validates bp form', (tester) async {
    final key = GlobalKey<AddEntryFormState>();
    await tester.pumpWidget(materialApp(AddEntryForm(key: key)));
    expect(key.currentState?.validate(), true);

    key.currentState!.fillForm((
      timestamp: DateTime.now(),
      record: mockRecord(sys: 123123),
      note: null, intake: null, weight: null,
    ));
    await tester.pump();
    expect(key.currentState?.validate(), false);
  });

  testWidgets('validates weight form', (tester) async {
    final key = GlobalKey<AddEntryFormState>();
    await tester.pumpWidget(materialApp(AddEntryForm(key: key),
      settings: Settings(weightInput: true),
    ));
    expect(key.currentState?.validate(), true);

    await tester.tap(find.byIcon(Icons.scale));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, ',.,');
    await tester.pump();
    expect(key.currentState?.validate(), false);
  });

  testWidgets('validates intake form', (tester) async {
    final key = GlobalKey<AddEntryFormState>();
    final med = mockMedicine(designation: 'testmed');
    await tester.pumpWidget(materialApp(AddEntryForm(key: key, meds: [med])));
    expect(key.currentState?.validate(), true);

    await tester.tap(find.byIcon(Icons.medication_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text(med.designation));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, ',.,');
    await tester.pump();
    expect(key.currentState?.validate(), false);
  });

  testWidgets('saves initial values as is', (tester) async {
    final key = GlobalKey<AddEntryFormState>();
    final med = mockMedicine(designation: 'somemed123');
    final intake = mockIntake(med);
    final value = (
      timestamp: intake.time,
      intake: intake,
      note: Note(time: intake.time, note: '123test', color: Colors.teal.toARGB32()),
      record: mockRecord(time: intake.time, sys: 123, dia: 45, pul: 67),
      weight: BodyweightRecord(time: intake.time, weight: Weight.kg(123.45))
    );
    await tester.pumpWidget(materialApp(AddEntryForm(
      key: key,
      meds: [med],
      initialValue: value,
    )));
    await tester.pumpAndSettle();

    expect(key.currentState?.validate(), true);
    expect(key.currentState?.save(), isA<AddEntryFormValue>()
      .having((e) => e.timestamp, 'timestamp', value.timestamp)
      .having((e) => e.intake, 'intake', value.intake)
      .having((e) => e.record, 'record', value.record)
      .having((e) => e.weight, 'weight', value.weight)
      .having((e) => e.note, 'note', value.note));
  });

  testWidgets('saves loaded values as is', (tester) async {
    final key = GlobalKey<AddEntryFormState>();
    final med = mockMedicine(designation: 'somemed123');
    final intake = mockIntake(med);
    final value = (
      timestamp: intake.time,
      intake: intake,
      note: Note(time: intake.time, note: '123test', color: Colors.teal.toARGB32()),
      record: mockRecord(time: intake.time, sys: 123, dia: 45, pul: 67),
      weight: BodyweightRecord(time: intake.time, weight: Weight.kg(123.45))
    );
    await tester.pumpWidget(materialApp(AddEntryForm(
      key: key,
      meds: [med],
    )));
    await tester.pumpAndSettle();
    key.currentState!.fillForm(value);
    await tester.pumpAndSettle();

    expect(key.currentState?.validate(), true);
    expect(key.currentState?.save(), isA<AddEntryFormValue>()
        .having((e) => e.timestamp, 'timestamp', value.timestamp)
        .having((e) => e.intake, 'intake', value.intake)
        .having((e) => e.record, 'record', value.record)
        .having((e) => e.weight, 'weight', value.weight)
        .having((e) => e.note, 'note', value.note));
  });

  testWidgets("doesn't save empty forms", (tester) async {
    final key = GlobalKey<AddEntryFormState>();
    await tester.pumpWidget(materialApp(AddEntryForm(key: key)));
    await tester.pumpAndSettle();
    expect(key.currentState!.validate(), true);
    expect(key.currentState!.save(), isNull);
  });

  testWidgets('focuses last input field on backspace', (tester) async {
    final key = GlobalKey<AddEntryFormState>();
    await tester.pumpWidget(materialApp(AddEntryForm(key: key)));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '123'); // sys
    await tester.enterText(fields.at(1), '45'); // dia
    await tester.enterText(fields.at(2), '67'); // pul

    await tester.showKeyboard(find.ancestor(of: find.text('67'), matching: find.byType(TextField)));
    Future<void> backspace(int n) async {
      for (int i = 0; i < n; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
        await tester.pump();
      }
    }

    expect(find.descendant(of: _focusedTextField(), matching: find.text(localizations.sysLong)), findsNothing);
    expect(find.descendant(of: _focusedTextField(), matching: find.text(localizations.diaLong)), findsNothing);
    expect(find.descendant(of: _focusedTextField(), matching: find.text(localizations.pulLong)), findsOneWidget);

    await backspace(3);
    await tester.idle();
    await tester.pumpAndSettle();

    expect(find.descendant(of: _focusedTextField(), matching: find.text(localizations.sysLong)), findsNothing);
    expect(find.descendant(of: _focusedTextField(), matching: find.text(localizations.diaLong)), findsOneWidget);
    expect(find.descendant(of: _focusedTextField(), matching: find.text(localizations.pulLong)), findsNothing);

    await backspace(3);
    await tester.idle();
    await tester.pumpAndSettle();

    expect(find.descendant(of: _focusedTextField(), matching: find.text(localizations.sysLong)), findsOneWidget);
    expect(find.descendant(of: _focusedTextField(), matching: find.text(localizations.diaLong)), findsNothing);
    expect(find.descendant(of: _focusedTextField(), matching: find.text(localizations.pulLong)), findsNothing);

    // doesn't focus last input on backspace if the current is still filled
    await backspace(6);
    await tester.pumpAndSettle();

    expect(find.descendant(of: _focusedTextField(), matching: find.text(localizations.sysLong)), findsOneWidget);
    expect(find.descendant(of: _focusedTextField(), matching: find.text(localizations.diaLong)), findsNothing);
    expect(find.descendant(of: _focusedTextField(), matching: find.text(localizations.pulLong)), findsNothing);
  });

  testWidgets('should allow invalid values when setting is set', (tester) async {
    final key = GlobalKey<AddEntryFormState>();
    await tester.pumpWidget(materialApp(AddEntryForm(key: key),
      settings: Settings(validateInputs: false)),
    );

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '12'); // sys
    await tester.enterText(fields.at(1), '450'); // dia
    await tester.enterText(fields.at(2), '67123'); // pul

    expect(key.currentState!.validate(), true);
    final res = key.currentState!.save();
    expect(res?.record?.sys?.mmHg, 12);
    expect(res?.record?.dia?.mmHg, 450);
    expect(res?.record?.pul, 67123);
  });

  testWidgets('starts with sys input focused', (tester) async {
    final key = GlobalKey<AddEntryFormState>();
    await tester.pumpWidget(materialApp(AddEntryForm(key: key)));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    await tester.pump();
    expect(find.descendant(
      of: find.ancestor(
        of: find.byWidget(FocusManager.instance.primaryFocus!.context!.widget),
        matching: find.byType(TextField)
      ),
      matching: find.text(localizations.sysLong)
    ), findsOneWidget);
  });

  testWidgets('opens correct tab on edit', (tester) async {
    final key = GlobalKey<AddEntryFormState>();
    await tester.pumpWidget(materialApp(AddEntryForm(key: key,
      initialValue: (
        timestamp: DateTime.now(),
        weight: BodyweightRecord(time:  DateTime.now(), weight: Weight.kg(123.0)),
        record: null,
        note: null,
        intake: null,
      ),
    ),
      settings: Settings(weightInput: true),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(BloodPressureForm), findsNothing);
    expect(find.byType(WeightForm), findsOneWidget);
  });

  test('correctly creates AddEntryFormValue from note only FullEntry', () {
    final FullEntry entry = mockEntry(note: 'Test');
    expect(entry.asAddEntry.note?.note, 'Test');
  });

  testWidgets("doesn't update time from ble if setting isn't set", (tester) async {
    final key = GlobalKey<AddEntryFormState>();
    final initialTime = DateTime.now();

    await tester.pumpWidget(materialApp(AddEntryForm(key: key,
      initialValue: (
        timestamp: initialTime,
        weight: null,
        record: null,
        note: null,
        intake: null,
      ),
      mockBleInput: (callback) => ListTile(
        onTap: () => callback(mockRecord(time: DateTime(2000))),
        title: Text('mockBleInput'),
      ),
    ),
      settings: Settings(
        bleInput: BluetoothInputMode.disabled,
        trustBLETime: false,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('mockBleInput'));
    final returnedEntry = key.currentState!.save();
    expect(returnedEntry!.timestamp.isAfter(DateTime(2000)), isTrue);
    expect(returnedEntry.timestamp, initialTime);

    // also check if the hint dialog isn't incorrectly displayed
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('updates time from ble if setting is set', (tester) async {
    final key = GlobalKey<AddEntryFormState>();
    final initialTime = DateTime.now();

    await tester.pumpWidget(materialApp(AddEntryForm(key: key,
      initialValue: (
        timestamp: initialTime,
        weight: null,
        record: null,
        note: null,
        intake: null,
      ),
      mockBleInput: (callback) => ListTile(
        onTap: () => callback(mockRecord(time: DateTime(2000))),
        title: Text('mockBleInput'),
      ),
    ),
      settings: Settings(
        bleInput: BluetoothInputMode.disabled,
        trustBLETime: true,
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('mockBleInput'));
    final returnedEntry = key.currentState!.save();
    expect(returnedEntry!.timestamp, equals(DateTime(2000)));
  });

  testWidgets('shows warning if time from ble is too old', (tester) async {
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(materialApp(AddEntryForm(
      mockBleInput: (callback) => ListTile(
        onTap: () => callback(mockRecord(time: DateTime(2000))),
        title: Text('mockBleInput'),
      ),
    ),
      settings: Settings(
        bleInput: BluetoothInputMode.disabled,
        trustBLETime: true,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    await tester.tap(find.text('mockBleInput'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('The bluetooth device reported a time off by'), findsOneWidget);
    expect(find.text(localizations.btnConfirm), findsOneWidget);

    await tester.tap(find.text(localizations.btnConfirm));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);

    // reopens the next time
    await tester.tap(find.text('mockBleInput'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('allows disabling warning if time from ble is too old', (tester) async {
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(materialApp(AddEntryForm(
      mockBleInput: (callback) => ListTile(
        onTap: () => callback(mockRecord(time: DateTime(2000))),
        title: Text('mockBleInput'),
      ),
    ),
      settings: Settings(
        bleInput: BluetoothInputMode.disabled,
        trustBLETime: true,
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    await tester.tap(find.text('mockBleInput'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('The bluetooth device reported a time off by'), findsOneWidget);
    expect(find.text(localizations.dontShowAgain), findsOneWidget);

    await tester.tap(find.text(localizations.dontShowAgain));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    await tester.tap(find.text('mockBleInput'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('saves measurement when time input is hidden', (tester) async {
    final key = GlobalKey<AddEntryFormState>();
    await tester.pumpWidget(materialApp(AddEntryForm(key: key),
        settings: Settings(allowManualTimeInput: false),
    ));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '123'); // sys
    await tester.enterText(fields.at(1), '45'); // dia
    await tester.enterText(fields.at(2), '67'); // pul

    expect(key.currentState!.validate(), true);
    final res = key.currentState!.save();
    expect(res, isNotNull);
    expect(res?.record, isNotNull);
    expect(res?.record?.sys?.mmHg, 123);
    expect(res?.record?.dia?.mmHg, 45);
    expect(res?.record?.pul, 67);
    expect(res?.record?.time
        .difference(DateTime.now())
        .inMinutes
        .abs(), lessThan(5));
  });

  testWidgets("Doesn't focus back without sending extra event", (WidgetTester tester) async {
    await tester.pumpWidget(materialApp(AddEntryForm()));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpAndSettle();
    await tester.enterText(find.ancestor(of: find.text(localizations.sysLong), matching: find.byType(TextField)), '123');
    await tester.enterText(find.ancestor(of: find.text(localizations.diaLong), matching: find.byType(TextField)), '67');
    await tester.enterText(find.ancestor(of: find.text(localizations.pulLong), matching: find.byType(TextField)), '8');

    await tester.showKeyboard(find.ancestor(of: find.text(localizations.pulLong), matching: find.byType(TextField)));
    await tester.pumpAndSettle();
    expect(find.descendant(of: _focusedTextField(), matching: find.text(localizations.pulLong)), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pumpAndSettle();
    // Doesn't focus back without sending extra event
    expect(find.descendant(of: _focusedTextField(), matching: find.text(localizations.diaLong)), findsNothing);
    expect(find.descendant(of: _focusedTextField(), matching: find.text(localizations.pulLong)), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pumpAndSettle();
    expect(find.descendant(
      of: _focusedTextField(),
      matching: find.text(localizations.diaLong),
    ), findsOneWidget);
  });
}

Finder _focusedTextField() {
  final firstFocused = FocusManager.instance.primaryFocus;
  expect(firstFocused?.context?.widget, isNotNull);
  return find.ancestor(
    of: find.byWidget(FocusManager.instance.primaryFocus!.context!.widget),
    matching: find.byType(TextField),
  );
}

/// A mock ble cubit that never does anything.
class _MockBoringBluetoothCubit extends Fake implements BluetoothCubit {
  @override
  Future<void> close() async {}

  @override
  BluetoothState get state => BluetoothStateDisabled();

  @override
  Stream<BluetoothState> get stream => Stream.empty();
}
