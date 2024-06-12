import 'package:blood_pressure_app/components/dialoges/add_measurement_dialoge.dart';
import 'package:blood_pressure_app/components/settings/color_picker_list_tile.dart';
import 'package:blood_pressure_app/model/blood_pressure/medicine/medicine.dart';
import 'package:blood_pressure_app/model/blood_pressure/medicine/medicine_intake.dart';
import 'package:blood_pressure_app/model/blood_pressure/needle_pin.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../model/export_import/record_formatter_test.dart';
import '../../model/medicine/medicine_test.dart';
import 'settings/color_picker_list_tile_test.dart';
import 'util.dart';

void main() {
  group('AddEntryDialoge', () {
    testWidgets('should show everything on initial page', (tester) async {
      await tester.pumpWidget(materialApp(
        AddEntryDialoge(
          settings: Settings(),
        ),
      ),);
      expect(tester.takeException(), isNull);

      expect(find.byType(DropdownButton<Medicine?>), findsNothing, reason: 'No medication in settings.');
      expect(find.text('SAVE'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Systolic'), findsWidgets);
      expect(find.text('Diastolic'), findsWidgets);
      expect(find.text('Pulse'), findsWidgets);
      expect(find.byType(ColorSelectionListTile), findsOneWidget);
    });
    testWidgets('should prefill initialRecord values', (tester) async {
      await tester.pumpWidget(materialApp(
        AddEntryDialoge(
          settings: Settings(),
          initialRecord: BloodPressureRecord(
            DateTime.now(), 123, 56, 43, 'Test note',
            needlePin: const MeasurementNeedlePin(Colors.teal),
          ),
        ),
      ),);
      await tester.pumpAndSettle();
      expect(find.byType(DropdownButton<Medicine?>), findsNothing, reason: 'No medication in settings.');
      expect(find.text('SAVE'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Test note'), findsOneWidget);
      expect(find.text('123'), findsOneWidget);
      expect(find.text('56'), findsOneWidget);
      expect(find.text('43'), findsOneWidget);
      expect(find.byType(ColorSelectionListTile), findsOneWidget);
      expect(find.byType(ColorSelectionListTile).evaluate().first.widget, isA<ColorSelectionListTile>().
      having((p0) => p0.initialColor, 'ColorSelectionListTile should have correct initial color', Colors.teal),);
    });
    testWidgets('should show medication picker when medications available', (tester) async {
      await tester.pumpWidget(materialApp(
        AddEntryDialoge(
          settings: Settings(
            medications: [mockMedicine(designation: 'testmed')],
          ),
        ),
      ),);
      await tester.pumpAndSettle();
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));

      expect(find.byType(DropdownButton<Medicine?>), findsOneWidget);
      expect(find.text(localizations.noMedication), findsOneWidget);
      expect(find.text('testmed'), findsNothing);

      await tester.tap(find.byType(DropdownButton<Medicine?>));
      await tester.pumpAndSettle();

      expect(find.text('testmed'), findsOneWidget);
    });
    testWidgets('should reveal dosis on medication selection', (tester) async {
      await tester.pumpWidget(materialApp(
        AddEntryDialoge(
          settings: Settings(
            medications: [mockMedicine(designation: 'testmed')],
          ),
        ),
      ),);
      await tester.pumpAndSettle();
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));

      expect(find.byType(DropdownButton<Medicine?>), findsOneWidget);
      expect(find.text(localizations.noMedication), findsOneWidget);
      expect(find.text('testmed'), findsNothing);

      await tester.tap(find.byType(DropdownButton<Medicine?>));
      await tester.pumpAndSettle();

      expect(find.text(localizations.dosis), findsNothing);
      expect(find.text('testmed'), findsOneWidget);
      await tester.tap(find.text('testmed'));
      await tester.pumpAndSettle();

      expect(
        find.ancestor(
          of: find.text(localizations.dosis,).first,
          matching: find.byType(TextFormField),
        ),
        findsOneWidget,
      );
    });
    testWidgets('should enter default dosis if available', (tester) async {
      await tester.pumpWidget(materialApp(
        AddEntryDialoge(
          settings: Settings(
            medications: [mockMedicine(designation: 'testmed', defaultDosis: 3.1415)],
          ),
        ),
      ),);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButton<Medicine?>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('testmed'));
      await tester.pumpAndSettle();

      expect(find.text('3.1415'), findsOneWidget);
    });
    testWidgets('should not quit when the measurement field is incorrectly filled, but a measurement is added', (tester) async {
      await tester.pumpWidget(materialApp(
        AddEntryDialoge(
          settings: Settings(
            medications: [mockMedicine(designation: 'testmed', defaultDosis: 3.1415)],
          ),
        ),
      ),);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButton<Medicine?>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('testmed'));
      await tester.pumpAndSettle();

      await tester.enterText(find.ancestor(of: find.text('Systolic').first, matching: find.byType(TextFormField)), '123');
      await tester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '900');
      await tester.enterText(find.ancestor(of: find.text('Pulse').first, matching: find.byType(TextFormField)), '89');
      await tester.pumpAndSettle();

      final localizations = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.byType(AddEntryDialoge), findsOneWidget);
      expect(find.text(localizations.errUnrealistic), findsNothing);

      await tester.tap(find.text(localizations.btnSave));
      await tester.pumpAndSettle();

      expect(find.byType(AddEntryDialoge), findsOneWidget);
      expect(find.text(localizations.errUnrealistic), findsOneWidget);
    });
  });
  group('showAddEntryDialoge', () {
    testWidgets('should return null on cancel', (tester) async {
      dynamic result = 'result before save';
      await loadDialoge(tester, (context) async
      => result = await showAddEntryDialoge(context, Settings(),
        mockRecord(sys: 123, dia: 56, pul: 43, note: 'Test note', pin: Colors.teal),),);
      expect(find.byType(DropdownButton<Medicine?>), findsNothing, reason: 'No medication in settings.');

      expect(find.byType(AddEntryDialoge), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.byType(AddEntryDialoge), findsNothing);

      expect(result, null);
    });
    testWidgets('should return values on edit cancel', (tester) async {
      dynamic result = 'result before save';
      final record = mockRecord(sys: 123, dia: 56, pul: 43, note: 'Test note', pin: Colors.teal);
      await loadDialoge(tester, (context) async
      => result = await showAddEntryDialoge(context, Settings(), record),);
      expect(find.byType(DropdownButton<Medicine?>), findsNothing, reason: 'No medication in settings.');

      expect(find.byType(AddEntryDialoge), findsOneWidget);
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();
      expect(find.byType(AddEntryDialoge), findsNothing);

      expect(result?.$2, isNull);
      expect(result?.$1, isA<BloodPressureRecord>().having(
            (p0) => (p0.creationTime, p0.systolic, p0.diastolic, p0.pulse, p0.notes, p0.needlePin!.color),
        'should return initial values as they were not modified',
        (record.creationTime, record.systolic, record.diastolic, record.pulse, record.notes, record.needlePin!.color),),);
    });
    testWidgets('should be able to input records', (WidgetTester tester) async {
      dynamic result = 'result before save';
      await loadDialoge(tester, (context) async
      => result = await showAddEntryDialoge(context, Settings()),);
      expect(find.byType(DropdownButton<Medicine?>), findsNothing, reason: 'No medication in settings.');

      await tester.enterText(find.ancestor(of: find.text('Systolic').first, matching: find.byType(TextFormField)), '123');
      await tester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '67');
      await tester.enterText(find.ancestor(of: find.text('Pulse').first, matching: find.byType(TextFormField)), '89');
      await tester.enterText(find.ancestor(of: find.text('Note (optional)').first, matching: find.byType(TextFormField)), 'Test note');

      await tester.tap(find.byType(ColorSelectionListTile));
      await tester.pumpAndSettle();
      await tester.tap(find.byElementPredicate(findColored(Colors.red)));
      await tester.pumpAndSettle();

      expect(find.text('SAVE'), findsOneWidget);
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();

      expect(result?.$2, isNull);
      expect(result?.$1, isA<BloodPressureRecord>()
          .having((p0) => p0.systolic, 'systolic', 123)
          .having((p0) => p0.diastolic, 'diastolic', 67)
          .having((p0) => p0.pulse, 'pulse', 89)
          .having((p0) => p0.notes, 'notes', 'Test note')
          .having((p0) => p0.needlePin?.color, 'needlePin', Colors.red),
      );
    });
    testWidgets('should allow value only', (WidgetTester tester) async {
      dynamic result = 'result before save';
      await loadDialoge(tester, (context) async
      => result = await showAddEntryDialoge(context, Settings()),);
      expect(find.byType(DropdownButton<Medicine?>), findsNothing, reason: 'No medication in settings.');
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));

      await tester.enterText(find.ancestor(of: find.text(localizations.sysLong).first,
        matching: find.byType(TextFormField),), '123',);
      await tester.enterText(find.ancestor(of: find.text(localizations.diaLong).first,
        matching: find.byType(TextFormField),), '67',);
      await tester.enterText(find.ancestor(of: find.text(localizations.pulLong).first,
        matching: find.byType(TextFormField),), '89',);

      expect(find.text(localizations.btnSave), findsOneWidget);
      await tester.tap(find.text(localizations.btnSave));
      await tester.pumpAndSettle();

      expect(result?.$2, isNull);
      expect(result?.$1, isA<BloodPressureRecord>()
          .having((p0) => p0.systolic, 'systolic', 123)
          .having((p0) => p0.diastolic, 'diastolic', 67)
          .having((p0) => p0.pulse, 'pulse', 89)
          .having((p0) => p0.notes, 'notes', '')
          .having((p0) => p0.needlePin?.color, 'needlePin', null),
      );
    });
    testWidgets('should allow note only', (WidgetTester tester) async {
      dynamic result = 'result before save';
      await loadDialoge(tester, (context) async
      => result = await showAddEntryDialoge(context, Settings(
        allowMissingValues: true,
        validateInputs: false,
      ),),);
      expect(find.byType(DropdownButton<Medicine?>), findsNothing, reason: 'No medication in settings.');

      final localizations = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.enterText(find.ancestor(of: find.text(localizations.addNote).first,
        matching: find.byType(TextFormField),), 'test note',);

      expect(find.text(localizations.btnSave), findsOneWidget);
      await tester.tap(find.text(localizations.btnSave));
      await tester.pumpAndSettle();

      expect(result?.$2, isNull);
      expect(result?.$1, isA<BloodPressureRecord>()
          .having((p0) => p0.systolic, 'systolic', null)
          .having((p0) => p0.diastolic, 'diastolic', null)
          .having((p0) => p0.pulse, 'pulse', null)
          .having((p0) => p0.notes, 'notes', 'test note')
          .having((p0) => p0.needlePin?.color, 'needlePin', null),
      );
    });
    testWidgets('should be able to input medicines', (WidgetTester tester) async {
      final med2 = mockMedicine(designation: 'medication2', defaultDosis: 31.415);

      dynamic result = 'result before save';
      await loadDialoge(tester, (context) async
      => result = await showAddEntryDialoge(context, Settings(
        medications: [
          mockMedicine(designation: 'medication1'),
          med2,
        ],
      ),),);
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));

      await tester.tap(find.byType(DropdownButton<Medicine?>));
      final openDialogeTimeStamp = DateTime.now();
      await tester.pumpAndSettle();

      expect(find.text('medication1'), findsOneWidget);
      expect(find.text('medication2'), findsOneWidget);
      await tester.tap(find.text('medication2'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.ancestor(
          of: find.text(localizations.dosis).first,
          matching: find.byType(TextFormField),
        ),
        '123.456',
      );

      expect(find.text(localizations.btnSave), findsOneWidget);
      await tester.tap(find.text(localizations.btnSave));
      await tester.pumpAndSettle();

      expect(result?.$1, isNull);
      expect(result?.$2, isA<MedicineIntake>()
          .having((p0) => p0.timestamp.millisecondsSinceEpoch ~/ 10000, 'timestamp', openDialogeTimeStamp.millisecondsSinceEpoch ~/ 10000)
          .having((p0) => p0.medicine, 'medicine', med2)
          .having((p0) => p0.dosis, 'dosis', 123.456),
      );
    });
    testWidgets('should not allow invalid values', (tester) async {
      await loadDialoge(tester, (context) => showAddEntryDialoge(context, Settings()));
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));

      expect(find.byType(DropdownButton<Medicine?>), findsNothing, reason: 'No medication in settings.');

      expect(find.byType(AddEntryDialoge), findsOneWidget);
      expect(find.text(localizations.errNaN), findsNothing);
      expect(find.text(localizations.errLt30), findsNothing);
      expect(find.text(localizations.errUnrealistic), findsNothing);
      expect(find.text(localizations.errDiaGtSys), findsNothing);

      await tester.enterText(find.ancestor(of: find.text('Systolic').first, matching: find.byType(TextFormField)), '123');
      await tester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '67');

      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();
      expect(find.byType(AddEntryDialoge), findsOneWidget);
      expect(find.text(localizations.errNaN), findsOneWidget);
      expect(find.text(localizations.errLt30), findsNothing);
      expect(find.text(localizations.errUnrealistic), findsNothing);
      expect(find.text(localizations.errDiaGtSys), findsNothing);

      await tester.enterText(find.ancestor(of: find.text('Pulse').first, matching: find.byType(TextFormField)), '20');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();
      expect(find.byType(AddEntryDialoge), findsOneWidget);
      expect(find.text(localizations.errNaN), findsNothing);
      expect(find.text(localizations.errLt30), findsOneWidget);
      expect(find.text(localizations.errUnrealistic), findsNothing);
      expect(find.text(localizations.errDiaGtSys), findsNothing);

      await tester.enterText(find.ancestor(of: find.text('Pulse').first, matching: find.byType(TextFormField)), '60');
      await tester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '500');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();
      expect(find.byType(AddEntryDialoge), findsOneWidget);
      expect(find.text(localizations.errNaN), findsNothing);
      expect(find.text(localizations.errLt30), findsNothing);
      expect(find.text(localizations.errUnrealistic), findsOneWidget);
      expect(find.text(localizations.errDiaGtSys), findsNothing);

      await tester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '100');
      await tester.enterText(find.ancestor(of: find.text('Systolic').first, matching: find.byType(TextFormField)), '90');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();
      expect(find.byType(AddEntryDialoge), findsOneWidget);
      expect(find.text(localizations.errNaN), findsNothing);
      expect(find.text(localizations.errLt30), findsNothing);
      expect(find.text(localizations.errUnrealistic), findsNothing);
      expect(find.text(localizations.errDiaGtSys), findsOneWidget);


      await tester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '78');
      await tester.enterText(find.ancestor(of: find.text('Systolic').first, matching: find.byType(TextFormField)), '123');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();
      expect(find.byType(AddEntryDialoge), findsNothing);
      expect(find.text(localizations.errNaN), findsNothing);
      expect(find.text(localizations.errLt30), findsNothing);
      expect(find.text(localizations.errUnrealistic), findsNothing);
      expect(find.text(localizations.errDiaGtSys), findsNothing);
    });
    testWidgets('should allow invalid values when setting is set', (tester) async {
      await loadDialoge(tester, (context) =>
          showAddEntryDialoge(context, Settings(validateInputs: false, allowMissingValues: true)),);
      expect(find.byType(DropdownButton<Medicine?>), findsNothing, reason: 'No medication in settings.');

      await tester.enterText(find.ancestor(of: find.text('Systolic').first, matching: find.byType(TextFormField)), '2');
      await tester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '500');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();
      expect(find.byType(AddEntryDialoge), findsNothing);
    });
    testWidgets('should respect settings.allowManualTimeInput', (tester) async {
      await loadDialoge(tester, (context) =>
          showAddEntryDialoge(context, Settings(allowManualTimeInput: false)),);
      expect(find.byType(DropdownButton<Medicine?>), findsNothing, reason: 'No medication in settings.');

      expect(find.byIcon(Icons.edit), findsNothing);
    });
    testWidgets('should start with sys input focused', (tester) async {
      await loadDialoge(tester, (context) =>
          showAddEntryDialoge(context, Settings(), mockRecord(sys: 12)),);
      expect(find.byType(DropdownButton<Medicine?>), findsNothing, reason: 'No medication in settings.');

      final primaryFocus = FocusManager.instance.primaryFocus;
      expect(primaryFocus?.context?.widget, isNotNull);
      final focusedTextFormField = find.ancestor(
        of: find.byWidget(primaryFocus!.context!.widget),
        matching: find.byType(TextFormField),
      );
      expect(focusedTextFormField, findsOneWidget);
      expect(focusedTextFormField.evaluate().first.widget, isA<TextFormField>()
          .having((p0) => p0.initialValue, 'systolic content', '12'),);
    });
    testWidgets('should focus next on input finished', (tester) async {
      await loadDialoge(tester, (context) =>
          showAddEntryDialoge(context, Settings(), mockRecord(sys: 12, dia: 3, pul: 4, note: 'note')),);
      expect(find.byType(DropdownButton<Medicine?>), findsNothing, reason: 'No medication in settings.');

      await tester.enterText(find.ancestor(of: find.text('Systolic').first, matching: find.byType(TextFormField)), '123');

      final firstFocused = FocusManager.instance.primaryFocus;
      expect(firstFocused?.context?.widget, isNotNull);
      final focusedTextFormField = find.ancestor(
        of: find.byWidget(firstFocused!.context!.widget),
        matching: find.byType(TextFormField),
      );
      expect(focusedTextFormField, findsOneWidget);
      expect(focusedTextFormField.evaluate().first.widget, isA<TextFormField>()
          .having((p0) => p0.initialValue, 'diastolic content', '3'),);

      await tester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '78');

      final secondFocused = FocusManager.instance.primaryFocus;
      expect(secondFocused?.context?.widget, isNotNull);
      final secondFocusedTextFormField = find.ancestor(
        of: find.byWidget(secondFocused!.context!.widget),
        matching: find.byType(TextFormField),
      );
      expect(secondFocusedTextFormField, findsOneWidget);
      expect(secondFocusedTextFormField.evaluate().first.widget, isA<TextFormField>()
          .having((p0) => p0.initialValue, 'pulse content', '4'),);

      await tester.enterText(find.ancestor(of: find.text('Pulse').first, matching: find.byType(TextFormField)), '60');

      final thirdFocused = FocusManager.instance.primaryFocus;
      expect(thirdFocused?.context?.widget, isNotNull);
      final thirdFocusedTextFormField = find.ancestor(
        of: find.byWidget(thirdFocused!.context!.widget),
        matching: find.byType(TextFormField),
      );
      expect(thirdFocusedTextFormField, findsOneWidget);
      expect(thirdFocusedTextFormField.evaluate().first.widget, isA<TextFormField>()
          .having((p0) => p0.initialValue, 'note input content', 'note'),);
    });
    testWidgets('should focus last input field on backspace pressed in empty input field', (tester) async {
      await loadDialoge(tester, (context) =>
          showAddEntryDialoge(context, Settings(), mockRecord(sys: 12, dia: 3, pul: 4, note: 'note')),);
      expect(find.byType(DropdownButton<Medicine?>), findsNothing, reason: 'No medication in settings.');

      await tester.enterText(find.ancestor(of: find.text('note').first, matching: find.byType(TextFormField)), '');
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);

      final firstFocused = FocusManager.instance.primaryFocus;
      expect(firstFocused?.context?.widget, isNotNull);
      final focusedTextFormField = find.ancestor(
        of: find.byWidget(firstFocused!.context!.widget),
        matching: find.byType(TextFormField),
      );
      expect(focusedTextFormField, findsOneWidget);
      expect(find.descendant(of: focusedTextFormField, matching: find.text('Note (optional)')), findsNothing);
      expect(find.descendant(of: focusedTextFormField, matching: find.text('Pulse')), findsWidgets);


      await tester.enterText(find.ancestor(of: find.text('Pulse').first, matching: find.byType(TextFormField)), '');
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);

      final secondFocused = FocusManager.instance.primaryFocus;
      expect(secondFocused?.context?.widget, isNotNull);
      final secondFocusedTextFormField = find.ancestor(
        of: find.byWidget(secondFocused!.context!.widget),
        matching: find.byType(TextFormField),
      );
      expect(secondFocusedTextFormField, findsOneWidget);
      expect(find.descendant(of: secondFocusedTextFormField, matching: find.text('Pulse')), findsNothing);
      expect(find.descendant(of: secondFocusedTextFormField, matching: find.text('Diastolic')), findsWidgets);


      await tester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '');
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);

      final thirdFocused = FocusManager.instance.primaryFocus;
      expect(thirdFocused?.context?.widget, isNotNull);
      final thirdFocusedTextFormField = find.ancestor(
        of: find.byWidget(thirdFocused!.context!.widget),
        matching: find.byType(TextFormField),
      );
      expect(thirdFocusedTextFormField, findsOneWidget);
      expect(find.descendant(of: thirdFocusedTextFormField, matching: find.text('Diastolic')), findsNothing);
      expect(find.descendant(of: thirdFocusedTextFormField, matching: find.text('Systolic')), findsWidgets);


      // should not go back further than systolic
      await tester.enterText(find.ancestor(of: find.text('Systolic').first, matching: find.byType(TextFormField)), '');
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);

      final fourthFocused = FocusManager.instance.primaryFocus;
      expect(fourthFocused?.context?.widget, isNotNull);
      final fourthFocusedTextFormField = find.ancestor(
        of: find.byWidget(fourthFocused!.context!.widget),
        matching: find.byType(TextFormField),
      );
      expect(fourthFocusedTextFormField, findsOneWidget);
      expect(find.descendant(of: fourthFocusedTextFormField, matching: find.text('Systolic')), findsWidgets);
    });
    testWidgets('should allow entering custom dosis', (tester) async {
      dynamic result;
      await loadDialoge(tester, (context) async =>
        result = await showAddEntryDialoge(context, Settings(
          medications: [mockMedicine(designation: 'testmed')],
        ),),
      );

      await tester.tap(find.byType(DropdownButton<Medicine?>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('testmed'));
      await tester.pumpAndSettle();

      final localizations = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.text(localizations.btnSave));
      await tester.pumpAndSettle();

      expect(find.text(localizations.errNaN), findsOneWidget);

      await tester.enterText(
        find.ancestor(
          of: find.text(localizations.dosis).first,
          matching: find.byType(TextFormField),
        ),
        '654.321',
      );
      await tester.tap(find.text(localizations.btnSave));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result?.$1, isNull);
      expect(result?.$2, isA<MedicineIntake>()
          .having((p0) => p0.dosis, 'dosis', 654.321),
      );
    });
    testWidgets('should allow modifying entered dosis', (tester) async {
      dynamic result;
      await loadDialoge(tester, (context) async =>
        result = await showAddEntryDialoge(context, Settings(
          medications: [mockMedicine(designation: 'testmed')],
        ),),
      );
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));

      await tester.tap(find.byType(DropdownButton<Medicine?>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('testmed'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.ancestor(
          of: find.text(localizations.dosis).first,
          matching: find.byType(TextFormField),
        ),
        '654.321',
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.ancestor(
          of: find.text(localizations.dosis).first,
          matching: find.byType(TextFormField),
        ),
        '654.322',
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(localizations.btnSave));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result?.$1, isNull);
      expect(result?.$2, isA<MedicineIntake>()
          .having((p0) => p0.dosis, 'dosis', 654.322),
      );
    });
    testWidgets('should not go back to last field when the current field is still filled', (tester) async {
      await loadDialoge(tester, (context) =>
          showAddEntryDialoge(context, Settings(), mockRecord(sys: 12, dia: 3, pul: 4, note: 'note')),);
      expect(find.byType(DropdownButton<Medicine?>), findsNothing, reason: 'No medication in settings.');

      await tester.enterText(find.ancestor(
          of: find.text('note').first,
          matching: find.byType(TextFormField),),
        'not empty',);
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);

      final firstFocused = FocusManager.instance.primaryFocus;
      expect(firstFocused?.context?.widget, isNotNull);
      final focusedTextFormField = find.ancestor(
        of: find.byWidget(firstFocused!.context!.widget),
        matching: find.byType(TextFormField),
      );
      expect(focusedTextFormField, findsOneWidget);
      expect(find.descendant(of: focusedTextFormField, matching: find.text('Pulse')), findsNothing);
      expect(find.descendant(of: focusedTextFormField, matching: find.text('Note (optional)')), findsWidgets);
    });
  });
}
