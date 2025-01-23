import 'package:blood_pressure_app/features/bluetooth/bluetooth_input.dart';
import 'package:blood_pressure_app/features/input/add_bodyweight_dialoge.dart';
import 'package:blood_pressure_app/features/input/add_measurement_dialoge.dart';
import 'package:blood_pressure_app/features/settings/tiles/color_picker_list_tile.dart';
import 'package:blood_pressure_app/model/storage/bluetooth_input_mode.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';

import '../../model/export_import/record_formatter_test.dart';
import '../../util.dart';
import '../settings/tiles/color_picker_list_tile_test.dart';

void main() {
  group('AddEntryDialoge', () {
    testWidgets('should show everything on initial page', (tester) async {
      await tester.pumpWidget(materialApp(const AddEntryDialoge(availableMeds: [])));
      expect(tester.takeException(), isNull);

      expect(find.byType(DropdownButton<Medicine?>), findsNothing, reason: 'No medication in settings.');
      expect(find.text('SAVE'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Systolic'), findsWidgets);
      expect(find.text('Diastolic'), findsWidgets);
      expect(find.text('Pulse'), findsWidgets);
      expect(find.byType(ColorSelectionListTile), findsOneWidget);
    },);
    testWidgets('should prefill initialRecord values', (tester) async {
      await tester.pumpWidget(materialApp(
        AddEntryDialoge(
          initialRecord: mockEntryPos(
            DateTime.now(), 123, 56, 43, 'Test note', Colors.teal,
          ),
          availableMeds: const [],
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
      tester.widget<ColorSelectionListTile>(find.byType(ColorSelectionListTile)).initialColor == Colors.teal;
    });
    testWidgets('should show medication picker when medications available', (tester) async {
      await tester.pumpWidget(materialApp(
        AddEntryDialoge(
          availableMeds: [ mockMedicine(designation: 'testmed') ],
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
          availableMeds: [ mockMedicine(designation: 'testmed') ],
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
          availableMeds: [ mockMedicine(designation: 'testmed', defaultDosis: 3.1415) ],
        ),
      ),);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(DropdownButton<Medicine?>));
      await tester.pumpAndSettle();

      await tester.tap(find.text('testmed'));
      await tester.pumpAndSettle();

      expect(find.text('3.1415'), findsOneWidget);
    });
    testWidgets('should not quit when the measurement field is incorrectly filled, but a intake is added', (tester) async {
      await tester.pumpWidget(materialApp(
        AddEntryDialoge(
          availableMeds: [ mockMedicine(designation: 'testmed', defaultDosis: 3.1415) ],
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
    testWidgets('respects settings about showing bluetooth input', (tester) async {
      final settings = Settings(
        bleInput: BluetoothInputMode.newBluetoothInputCrossPlatform,
      );
      await tester.pumpWidget(materialApp(
        const AddEntryDialoge(
          availableMeds: [],
        ),
        settings: settings,
      ),);
      await tester.pumpAndSettle();
      expect(find.byType(BluetoothInput, skipOffstage: false), findsOneWidget);

      settings.bleInput = BluetoothInputMode.disabled;
      await tester.pumpAndSettle();
      expect(find.byType(BluetoothInput), findsNothing);
    });
  }, skip: true);
  group('showAddEntryDialoge', () {
    testWidgets('should return null on cancel', (tester) async {
      dynamic result = 'result before save';
      await loadDialoge(tester, (context) async
      => result = await showAddEntryDialoge(context,
        medRepo(),
        mockEntry(sys: 123, dia: 56, pul: 43, note: 'Test note', pin: Colors.teal),),);
      expect(find.byType(DropdownButton<Medicine?>), findsNothing, reason: 'No medication in settings.');

      expect(find.byType(AddEntryDialoge), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.byType(AddEntryDialoge), findsNothing);

      expect(result, null);
    });
    testWidgets('should return values on edit cancel', (tester) async {
      dynamic result = 'result before save';
      final record = mockEntry(sys: 123, dia: 56, pul: 43, note: 'Test note', pin: Colors.teal);
      await loadDialoge(tester, (context) async {
        result = await showAddEntryDialoge(context, medRepo(), record);
      },);
      expect(find.byType(DropdownButton<Medicine?>), findsNothing, reason: 'No medication in settings.');

      expect(find.byType(AddEntryDialoge), findsOneWidget);
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();
      expect(find.byType(AddEntryDialoge), findsNothing);
      
      expect(result, isA<FullEntry>());
      final FullEntry res = result;
      expect(res.time, record.time);
      expect(res.sys, record.sys);
      expect(res.dia, record.dia);
      expect(res.pul, record.pul);
      expect(res.note, record.note);
      expect(res.color, record.color);
    });
    testWidgets('should be able to input records', (WidgetTester tester) async {
      dynamic result = 'result before save';
      await loadDialoge(tester, (context) async {
        result = await showAddEntryDialoge(context, medRepo(),);
      });
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

      expect(result, isA<FullEntry>());
      final FullEntry res = result;
      expect(res.sys?.mmHg, 123);
      expect(res.dia?.mmHg, 67);
      expect(res.pul, 89);
      expect(res.note, 'Test note');
      expect(res.color, Colors.red.value);
    });
    testWidgets('should allow value only', (WidgetTester tester) async {
      dynamic result = 'result before save';
      await loadDialoge(tester, (context) async
      => result = await showAddEntryDialoge(context, medRepo(),),);
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

      expect(result, isA<FullEntry>());
      final FullEntry res = result;
      expect(res.sys?.mmHg, 123);
      expect(res.dia?.mmHg, 67);
      expect(res.pul, 89);
      expect(res.note, null);
      expect(res.color, null);
    });
    testWidgets('should allow note only', (WidgetTester tester) async {
      dynamic result = 'result before save';
      await loadDialoge(tester, (context) async
      => result = await showAddEntryDialoge(context, medRepo(),),);
      expect(find.byType(DropdownButton<Medicine?>), findsNothing, reason: 'No medication in settings.');

      final localizations = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.enterText(find.ancestor(of: find.text(localizations.addNote).first,
        matching: find.byType(TextFormField),), 'test note',);

      expect(find.text(localizations.btnSave), findsOneWidget);
      await tester.tap(find.text(localizations.btnSave));
      await tester.pumpAndSettle();

      expect(result, isA<FullEntry>()
        .having((p0) => p0.sys, 'systolic', null)
        .having((p0) => p0.dia, 'diastolic', null)
        .having((p0) => p0.pul, 'pulse', null)
        .having((p0) => p0.note, 'note', 'test note')
        .having((p0) => p0.color, 'needlePin', null),
      );
    });
    testWidgets('should be able to input medicines', (WidgetTester tester) async {
      final med2 = mockMedicine(designation: 'medication2', defaultDosis: 31.415);

      dynamic result = 'result before save';
      await loadDialoge(tester, (context) async
      => result = await showAddEntryDialoge(context, medRepo([
        mockMedicine(designation: 'medication1'),
        med2,
      ],),),);
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

      expect(result, isA<FullEntry>());
      final FullEntry res = result;
      expect(res.time.millisecondsSinceEpoch, inInclusiveRange(
        openDialogeTimeStamp.millisecondsSinceEpoch - 2000,
        openDialogeTimeStamp.millisecondsSinceEpoch + 2000)
      );
      expect(res.sys, null);
      expect(res.dia, null);
      expect(res.pul, null);
      expect(res.note, null);
      expect(res.color, null);
      expect(res.intakes, hasLength(1));
      expect(res.intakes.first.medicine, med2);
      expect(res.intakes.first.dosis.mg, 123.456);
    });
    testWidgets('should not allow invalid values', (tester) async {
      final mRep = medRepo();
      await loadDialoge(tester, (context) => showAddEntryDialoge(context, mRep));
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
      final mRep = medRepo();
      await loadDialoge(tester, (context) => showAddEntryDialoge(context, mRep),
        settings: Settings(validateInputs: false, allowMissingValues: true),
      );
      expect(find.byType(DropdownButton<Medicine?>), findsNothing, reason: 'No medication in settings.');

      await tester.enterText(find.ancestor(of: find.text('Systolic').first, matching: find.byType(TextFormField)), '2');
      await tester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '500');
      await tester.tap(find.text('SAVE'));
      await tester.pumpAndSettle();
      expect(find.byType(AddEntryDialoge), findsNothing);
    });
    testWidgets('should respect settings.allowManualTimeInput', (tester) async {
      final mRep = medRepo();
      await loadDialoge(tester, (context) => showAddEntryDialoge(context, mRep),
        settings: Settings(allowManualTimeInput: false),
      );
      expect(find.byType(DropdownButton<Medicine?>), findsNothing, reason: 'No medication in settings.');

      expect(find.byIcon(Icons.edit), findsNothing);
    });
    testWidgets('should start with sys input focused', (tester) async {
      final mRep = medRepo();
      await loadDialoge(tester, (context) =>
          showAddEntryDialoge(context, mRep, mockEntry(sys: 12)),);
      expect(find.byType(DropdownButton<Medicine?>), findsNothing, reason: 'No medication in settings.');

      final primaryFocus = FocusManager.instance.primaryFocus;
      expect(primaryFocus?.context?.widget, isNotNull);
      final focusedTextFormField = find.ancestor(
        of: find.byWidget(primaryFocus!.context!.widget),
        matching: find.byType(TextFormField),
      );
      expect(focusedTextFormField, findsOneWidget);
      final field = tester.widget<TextFormField>(focusedTextFormField);
      expect(field.initialValue, '12');
    });
    testWidgets('should focus next on input finished', (tester) async {
      final mRep = medRepo();
      await loadDialoge(tester, (context) =>
          showAddEntryDialoge(context, mRep, mockEntry(sys: 12, dia: 3, pul: 4, note: 'note')),);
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
      final mRep = medRepo();
      await loadDialoge(tester, (context) =>
          showAddEntryDialoge(context, mRep, mockEntry(sys: 12, dia: 3, pul: 4, note: 'note')),);
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
      final mRep = medRepo([mockMedicine(designation: 'testmed')]);
      dynamic result;
      await loadDialoge(tester, (context) async =>
        result = await showAddEntryDialoge(context, mRep),
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
      
      expect(result, isA<FullEntry>());
      final FullEntry res = result; 
      expect(res.sys, null);
      expect(res.dia, null);
      expect(res.pul, null);
      expect(res.note, null);
      expect(res.color, null);
      
      expect(res.intakes, hasLength(1));
      expect(res.intakes.first.dosis.mg, 654.321);
    });
    testWidgets('should allow modifying entered dosis', (tester) async {
      final mRep = medRepo([mockMedicine(designation: 'testmed')]);
      dynamic result;
      await loadDialoge(tester, (context) async =>
        result = await showAddEntryDialoge(context, mRep),
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

      expect(result, isA<FullEntry>());
      final FullEntry res = result;
      expect(res.sys, null);
      expect(res.dia, null);
      expect(res.pul, null);
      expect(res.note, null);
      expect(res.color, null);

      expect(res.intakes, hasLength(1));
      expect(res.intakes.first.dosis.mg, 654.322);
    });
    testWidgets('should not go back to last field when the current field is still filled', (tester) async {
      final mRep = medRepo([mockMedicine(designation: 'testmed')]);
      await loadDialoge(tester, (context) =>
          showAddEntryDialoge(context, mRep, mockEntry(sys: 12, dia: 3, pul: 4, note: 'note')),);
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
    testWidgets('opens weight input if necessary', (tester) async {
      final repo = MockBodyweightRepository();
      await tester.pumpWidget(appBase(Builder(
        builder: (context) => TextButton(onPressed: () => showAddEntryDialoge(context, MockMedRepo([])), child: const Text('X'))
      ), settings: Settings(weightInput: true), weightRepo: repo));
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));
      await tester.tap(find.text('X'));
      await tester.pumpAndSettle();

      expect(find.text(localizations.enterWeight), findsOneWidget);
      expect(find.byIcon(Icons.scale), findsOneWidget);
      await tester.tap(find.text(localizations.enterWeight));
      await tester.pumpAndSettle();
      
      expect(repo.data, isEmpty);
      await tester.enterText(find.descendant(
        of: find.byType(AddBodyweightDialoge),
        matching: find.byType(TextFormField)
      ), '123.45');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(repo.data, hasLength(1));
      expect(repo.data[0].weight, Weight.kg(123.45));
    });
  });
}
