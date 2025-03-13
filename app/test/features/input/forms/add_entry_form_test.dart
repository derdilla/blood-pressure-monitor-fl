import 'package:blood_pressure_app/features/bluetooth/bluetooth_input.dart';
import 'package:blood_pressure_app/features/bluetooth/logic/bluetooth_cubit.dart';
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
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:intl/intl.dart';

import '../../../model/analyzer_test.dart';
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
    await tester.pumpWidget(materialApp(AddEntryForm(key: key, meds: [])));

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
    await tester.pumpWidget(materialApp(AddEntryForm(key: key, meds: [])));

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
    await tester.pumpWidget(materialApp(AddEntryForm(key: key, meds: [])));
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
    await tester.pumpWidget(materialApp(AddEntryForm(key: key, meds: [])));
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
    await tester.pumpWidget(materialApp(AddEntryForm(key: key, meds: []),
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
      note: Note(time: intake.time, note: '123test', color: Colors.teal.value),
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
      note: Note(time: intake.time, note: '123test', color: Colors.teal.value),
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
    await tester.pumpWidget(materialApp(AddEntryForm(key: key, meds: [])));
    await tester.pumpAndSettle();
    expect(key.currentState!.validate(), true);
    expect(key.currentState!.save(), isNull);
  });

  testWidgets('focuses last input field on backspace', (tester) async {
    final key = GlobalKey<AddEntryFormState>();
    await tester.pumpWidget(materialApp(AddEntryForm(key: key, meds: [])));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '123'); // sys
    await tester.enterText(fields.at(1), '45'); // dia
    await tester.enterText(fields.at(2), '67'); // pul

    await tester.tap(find.text('67'));

    Finder focusedTextField() {
      final firstFocused = FocusManager.instance.primaryFocus;
      expect(firstFocused?.context?.widget, isNotNull);
      return find.ancestor(
        of: find.byWidget(FocusManager.instance.primaryFocus!.context!.widget),
        matching: find.byType(TextField),
      );
    }
    expect(find.descendant(of: focusedTextField(), matching: find.text(localizations.sysLong)), findsNothing);
    expect(find.descendant(of: focusedTextField(), matching: find.text(localizations.diaLong)), findsNothing);
    expect(find.descendant(of: focusedTextField(), matching: find.text(localizations.pulLong)), findsOneWidget);

    await tester.enterText(focusedTextField(), '');
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();

    expect(find.descendant(of: focusedTextField(), matching: find.text(localizations.sysLong)), findsNothing);
    expect(find.descendant(of: focusedTextField(), matching: find.text(localizations.diaLong)), findsOneWidget);
    expect(find.descendant(of: focusedTextField(), matching: find.text(localizations.pulLong)), findsNothing);

    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();

    expect(find.descendant(of: focusedTextField(), matching: find.text(localizations.sysLong)), findsOneWidget);
    expect(find.descendant(of: focusedTextField(), matching: find.text(localizations.diaLong)), findsNothing);
    expect(find.descendant(of: focusedTextField(), matching: find.text(localizations.pulLong)), findsNothing);

    // doesn't focus last input on backspace if the current is still filled
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.pump();

    expect(find.descendant(of: focusedTextField(), matching: find.text(localizations.sysLong)), findsOneWidget);
    expect(find.descendant(of: focusedTextField(), matching: find.text(localizations.diaLong)), findsNothing);
    expect(find.descendant(of: focusedTextField(), matching: find.text(localizations.pulLong)), findsNothing);
  });

  //testWidgets('description', (tester) async {fail('TODO');});
}

class _MockBluetoothCubit extends Fake implements BluetoothCubit {
  @override
  Future<void> close() async {}

  @override
  BluetoothState get state => BluetoothStateDisabled();

  @override
  Stream<BluetoothState> get stream => Stream.empty();
}
