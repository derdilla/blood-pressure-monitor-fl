import 'package:blood_pressure_app/components/dialoges/add_measurement_dialoge.dart';
import 'package:blood_pressure_app/components/settings/color_picker_list_tile.dart';
import 'package:blood_pressure_app/model/blood_pressure/needle_pin.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../model/export_import/record_formatter_test.dart';
import 'settings/color_picker_list_tile_test.dart';
import 'util.dart';

void main() {
  group('AddEntryDialoge', () {
    testWidgets('should show everything on initial page', (widgetTester) async {
      await widgetTester.pumpWidget(materialApp(
        AddEntryDialoge(
          settings: Settings(),
        )
      ));
      expect(widgetTester.takeException(), isNull);
      expect(find.text('SAVE'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Systolic'), findsWidgets);
      expect(find.text('Diastolic'), findsWidgets);
      expect(find.text('Pulse'), findsWidgets);
      expect(find.byType(ColorSelectionListTile), findsOneWidget);
    });
    testWidgets('should prefill initialRecord values', (widgetTester) async {
      await widgetTester.pumpWidget(materialApp(
          AddEntryDialoge(
            settings: Settings(),
            initialRecord: BloodPressureRecord(
              DateTime.now(), 123, 56, 43, 'Test note',
              needlePin: const MeasurementNeedlePin(Colors.teal)
            ),
          )
      ));
      await widgetTester.pumpAndSettle();
      expect(find.text('SAVE'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.text('Test note'), findsOneWidget);
      expect(find.text('123'), findsOneWidget);
      expect(find.text('56'), findsOneWidget);
      expect(find.text('43'), findsOneWidget);
      expect(find.byType(ColorSelectionListTile), findsOneWidget);
      expect(find.byType(ColorSelectionListTile).evaluate().first.widget, isA<ColorSelectionListTile>().
      having((p0) => p0.initialColor, 'ColorSelectionListTile should have correct initial color', Colors.teal));
    });
  });
  group('showAddEntryDialoge', () {
    testWidgets('should return null on cancel', (widgetTester) async {
      dynamic result = 'not null';
      await loadDialoge(widgetTester, (context) async
        => result = await showAddEntryDialoge(context, Settings(),
          mockRecord(sys: 123, dia: 56, pul: 43, note: 'Test note', pin: Colors.teal)));

      expect(find.byType(AddEntryDialoge), findsOneWidget);
      await widgetTester.tap(find.byIcon(Icons.close));
      await widgetTester.pumpAndSettle();
      expect(find.byType(AddEntryDialoge), findsNothing);

      expect(result, null);
    });
    testWidgets('should return values on edit cancel', (widgetTester) async {
      dynamic result = 'not null';
      final record = mockRecord(sys: 123, dia: 56, pul: 43, note: 'Test note', pin: Colors.teal);
      await loadDialoge(widgetTester, (context) async
        => result = await showAddEntryDialoge(context, Settings(), record));

      expect(find.byType(AddEntryDialoge), findsOneWidget);
      await widgetTester.tap(find.text('SAVE'));
      await widgetTester.pumpAndSettle();
      expect(find.byType(AddEntryDialoge), findsNothing);

      expect(result?.$1, isA<BloodPressureRecord>().having(
              (p0) => (p0.creationTime, p0.systolic, p0.diastolic, p0.pulse, p0.notes, p0.needlePin!.color),
          'should return initial values as they were not modified',
          (record.creationTime, record.systolic, record.diastolic, record.pulse, record.notes, record.needlePin!.color)));
    });
    testWidgets('should be able to input values', (WidgetTester widgetTester) async {
      dynamic result = 'not null';
      await loadDialoge(widgetTester, (context) async
        => result = await showAddEntryDialoge(context, Settings()));

      await widgetTester.enterText(find.ancestor(of: find.text('Systolic').first, matching: find.byType(TextFormField)), '123');
      await widgetTester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '67');
      await widgetTester.enterText(find.ancestor(of: find.text('Pulse').first, matching: find.byType(TextFormField)), '89');
      await widgetTester.enterText(find.ancestor(of: find.text('Note (optional)').first, matching: find.byType(TextFormField)), 'Test note');

      await widgetTester.tap(find.byType(ColorSelectionListTile));
      await widgetTester.pumpAndSettle();
      await widgetTester.tap(find.byElementPredicate(findColored(Colors.red)));
      await widgetTester.pumpAndSettle();

      expect(find.text('SAVE'), findsOneWidget);
      await widgetTester.tap(find.text('SAVE'));
      await widgetTester.pumpAndSettle();

      expect(result?.$1, isA<BloodPressureRecord>()
        .having((p0) => p0.systolic, 'systolic', 123)
        .having((p0) => p0.diastolic, 'diastolic', 67)
        .having((p0) => p0.pulse, 'pulse', 89)
        .having((p0) => p0.notes, 'notes', 'Test note')
        .having((p0) => p0.needlePin?.color, 'needlePin', Colors.red)
      );
    });
    testWidgets('should not allow invalid values', (widgetTester) async {
      await loadDialoge(widgetTester, (context) => showAddEntryDialoge(context, Settings()));
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));

      expect(find.byType(AddEntryDialoge), findsOneWidget);
      expect(find.text(localizations.errNaN), findsNothing);
      expect(find.text(localizations.errLt30), findsNothing);
      expect(find.text(localizations.errUnrealistic), findsNothing);
      expect(find.text(localizations.errDiaGtSys), findsNothing);

      await widgetTester.enterText(find.ancestor(of: find.text('Systolic').first, matching: find.byType(TextFormField)), '123');
      await widgetTester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '67');

      await widgetTester.tap(find.text('SAVE'));
      await widgetTester.pumpAndSettle();
      expect(find.byType(AddEntryDialoge), findsOneWidget);
      expect(find.text(localizations.errNaN), findsOneWidget);
      expect(find.text(localizations.errLt30), findsNothing);
      expect(find.text(localizations.errUnrealistic), findsNothing);
      expect(find.text(localizations.errDiaGtSys), findsNothing);

      await widgetTester.enterText(find.ancestor(of: find.text('Pulse').first, matching: find.byType(TextFormField)), '20');
      await widgetTester.tap(find.text('SAVE'));
      await widgetTester.pumpAndSettle();
      expect(find.byType(AddEntryDialoge), findsOneWidget);
      expect(find.text(localizations.errNaN), findsNothing);
      expect(find.text(localizations.errLt30), findsOneWidget);
      expect(find.text(localizations.errUnrealistic), findsNothing);
      expect(find.text(localizations.errDiaGtSys), findsNothing);

      await widgetTester.enterText(find.ancestor(of: find.text('Pulse').first, matching: find.byType(TextFormField)), '60');
      await widgetTester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '500');
      await widgetTester.tap(find.text('SAVE'));
      await widgetTester.pumpAndSettle();
      expect(find.byType(AddEntryDialoge), findsOneWidget);
      expect(find.text(localizations.errNaN), findsNothing);
      expect(find.text(localizations.errLt30), findsNothing);
      expect(find.text(localizations.errUnrealistic), findsOneWidget);
      expect(find.text(localizations.errDiaGtSys), findsNothing);

      await widgetTester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '100');
      await widgetTester.enterText(find.ancestor(of: find.text('Systolic').first, matching: find.byType(TextFormField)), '90');
      await widgetTester.tap(find.text('SAVE'));
      await widgetTester.pumpAndSettle();
      expect(find.byType(AddEntryDialoge), findsOneWidget);
      expect(find.text(localizations.errNaN), findsNothing);
      expect(find.text(localizations.errLt30), findsNothing);
      expect(find.text(localizations.errUnrealistic), findsNothing);
      expect(find.text(localizations.errDiaGtSys), findsOneWidget);


      await widgetTester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '78');
      await widgetTester.enterText(find.ancestor(of: find.text('Systolic').first, matching: find.byType(TextFormField)), '123');
      await widgetTester.tap(find.text('SAVE'));
      await widgetTester.pumpAndSettle();
      expect(find.byType(AddEntryDialoge), findsNothing);
      expect(find.text(localizations.errNaN), findsNothing);
      expect(find.text(localizations.errLt30), findsNothing);
      expect(find.text(localizations.errUnrealistic), findsNothing);
      expect(find.text(localizations.errDiaGtSys), findsNothing);
    });
    testWidgets('should allow invalid values when setting is set', (widgetTester) async {
      await loadDialoge(widgetTester, (context) =>
          showAddEntryDialoge(context, Settings(validateInputs: false, allowMissingValues: true)));

      await widgetTester.enterText(find.ancestor(of: find.text('Systolic').first, matching: find.byType(TextFormField)), '2');
      await widgetTester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '500');
      await widgetTester.tap(find.text('SAVE'));
      await widgetTester.pumpAndSettle();
      expect(find.byType(AddEntryDialoge), findsNothing);
    });
    testWidgets('should respect settings.allowManualTimeInput', (widgetTester) async {
      await loadDialoge(widgetTester, (context) =>
          showAddEntryDialoge(context, Settings(allowManualTimeInput: false)));

      expect(find.byIcon(Icons.edit), findsNothing);
    });
    testWidgets('should start with sys input focused', (widgetTester) async {
      await loadDialoge(widgetTester, (context) =>
          showAddEntryDialoge(context, Settings(), mockRecord(sys: 12)));

      final primaryFocus = FocusManager.instance.primaryFocus;
      expect(primaryFocus?.context?.widget, isNotNull);
      final focusedTextFormField = find.ancestor(
        of: find.byWidget(primaryFocus!.context!.widget),
        matching: find.byType(TextFormField),
      );
      expect(focusedTextFormField, findsOneWidget);
      expect(focusedTextFormField.evaluate().first.widget, isA<TextFormField>()
          .having((p0) => p0.initialValue, 'systolic content', '12'));
    });
    testWidgets('should focus next on input finished', (widgetTester) async {
      await loadDialoge(widgetTester, (context) =>
          showAddEntryDialoge(context, Settings(), mockRecord(sys: 12, dia: 3, pul: 4, note: 'note')));

      await widgetTester.enterText(find.ancestor(of: find.text('Systolic').first, matching: find.byType(TextFormField)), '123');

      final firstFocused = FocusManager.instance.primaryFocus;
      expect(firstFocused?.context?.widget, isNotNull);
      final focusedTextFormField = find.ancestor(
        of: find.byWidget(firstFocused!.context!.widget),
        matching: find.byType(TextFormField),
      );
      expect(focusedTextFormField, findsOneWidget);
      expect(focusedTextFormField.evaluate().first.widget, isA<TextFormField>()
          .having((p0) => p0.initialValue, 'diastolic content', '3'));

      await widgetTester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '78');

      final secondFocused = FocusManager.instance.primaryFocus;
      expect(secondFocused?.context?.widget, isNotNull);
      final secondFocusedTextFormField = find.ancestor(
        of: find.byWidget(secondFocused!.context!.widget),
        matching: find.byType(TextFormField),
      );
      expect(secondFocusedTextFormField, findsOneWidget);
      expect(secondFocusedTextFormField.evaluate().first.widget, isA<TextFormField>()
          .having((p0) => p0.initialValue, 'pulse content', '4'));

      await widgetTester.enterText(find.ancestor(of: find.text('Pulse').first, matching: find.byType(TextFormField)), '60');

      final thirdFocused = FocusManager.instance.primaryFocus;
      expect(thirdFocused?.context?.widget, isNotNull);
      final thirdFocusedTextFormField = find.ancestor(
        of: find.byWidget(thirdFocused!.context!.widget),
        matching: find.byType(TextFormField),
      );
      expect(thirdFocusedTextFormField, findsOneWidget);
      expect(thirdFocusedTextFormField.evaluate().first.widget, isA<TextFormField>()
          .having((p0) => p0.initialValue, 'note input content', 'note'));
    });

    testWidgets('should focus last input field on backspace pressed in empty input field', (widgetTester) async {
      await loadDialoge(widgetTester, (context) =>
          showAddEntryDialoge(context, Settings(), mockRecord(sys: 12, dia: 3, pul: 4, note: 'note')));


      await widgetTester.enterText(find.ancestor(of: find.text('note').first, matching: find.byType(TextFormField)), '');
      await widgetTester.sendKeyEvent(LogicalKeyboardKey.backspace);

      final firstFocused = FocusManager.instance.primaryFocus;
      expect(firstFocused?.context?.widget, isNotNull);
      final focusedTextFormField = find.ancestor(
        of: find.byWidget(firstFocused!.context!.widget),
        matching: find.byType(TextFormField),
      );
      expect(focusedTextFormField, findsOneWidget);
      expect(find.descendant(of: focusedTextFormField, matching: find.text('Note (optional)')), findsNothing);
      expect(find.descendant(of: focusedTextFormField, matching: find.text('Pulse')), findsWidgets);


      await widgetTester.enterText(find.ancestor(of: find.text('Pulse').first, matching: find.byType(TextFormField)), '');
      await widgetTester.sendKeyEvent(LogicalKeyboardKey.backspace);

      final secondFocused = FocusManager.instance.primaryFocus;
      expect(secondFocused?.context?.widget, isNotNull);
      final secondFocusedTextFormField = find.ancestor(
        of: find.byWidget(secondFocused!.context!.widget),
        matching: find.byType(TextFormField),
      );
      expect(secondFocusedTextFormField, findsOneWidget);
      expect(find.descendant(of: secondFocusedTextFormField, matching: find.text('Pulse')), findsNothing);
      expect(find.descendant(of: secondFocusedTextFormField, matching: find.text('Diastolic')), findsWidgets);


      await widgetTester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '');
      await widgetTester.sendKeyEvent(LogicalKeyboardKey.backspace);

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
      await widgetTester.enterText(find.ancestor(of: find.text('Systolic').first, matching: find.byType(TextFormField)), '');
      await widgetTester.sendKeyEvent(LogicalKeyboardKey.backspace);

      final fourthFocused = FocusManager.instance.primaryFocus;
      expect(fourthFocused?.context?.widget, isNotNull);
      final fourthFocusedTextFormField = find.ancestor(
        of: find.byWidget(fourthFocused!.context!.widget),
        matching: find.byType(TextFormField),
      );
      expect(fourthFocusedTextFormField, findsOneWidget);
      expect(find.descendant(of: fourthFocusedTextFormField, matching: find.text('Systolic')), findsWidgets);
    });
    // TODO: test medicine_intake
  });
}