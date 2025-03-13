import 'package:blood_pressure_app/features/bluetooth/bluetooth_input.dart';
import 'package:blood_pressure_app/features/input/add_entry_dialogue.dart';
import 'package:blood_pressure_app/features/input/forms/add_entry_form.dart';
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

// FIXME: most of these are already tested at add_entry_form_test. make tests more concise

void main() {
  testWidgets('respects bottomAppBars', (tester) async {
    final settings = Settings(bottomAppBars: false);
    await tester.pumpWidget(materialApp(const AddEntryDialogue(availableMeds: []),
      settings: settings
    ));
    final initialHeights = tester.getCenter(find.byType(AppBar)).dy;

    settings.bottomAppBars = true;
    await tester.pump();

    expect(tester.getCenter(find.byType(AppBar)).dy, greaterThan(initialHeights));
  });

  // TODO: update these old tests
  testWidgets('should show everything on initial page', (tester) async {
    await tester.pumpWidget(materialApp(const AddEntryDialogue(availableMeds: [])));
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
      AddEntryDialogue(
        initialRecord: mockEntryPos(
          DateTime.now(), 123, 56, 43, 'Test note', Colors.teal,
        ).asAddEntry,
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
  testWidgets('should return null on cancel', (tester) async {
    dynamic result = 'result before save';
    await loadDialoge(tester, (context) async
    => result = await showAddEntryDialogue(context,
        medRepo(),
        mockEntry(sys: 123, dia: 56, pul: 43, note: 'Test note', pin: Colors.teal).asAddEntry));
    expect(find.byType(DropdownButton<Medicine?>), findsNothing, reason: 'No medication in settings.');

    expect(find.byType(AddEntryDialogue), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.byType(AddEntryDialogue), findsNothing);

    expect(result, null);
  });
  testWidgets('should not allow invalid values', (tester) async {
    final mRep = medRepo();
    await loadDialoge(tester, (context) => showAddEntryDialogue(context, mRep));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.byType(DropdownButton<Medicine?>), findsNothing, reason: 'No medication in settings.');

    expect(find.byType(AddEntryDialogue), findsOneWidget);
    expect(find.text(localizations.errNaN), findsNothing);
    expect(find.text(localizations.errLt30), findsNothing);
    expect(find.text(localizations.errUnrealistic), findsNothing);
    expect(find.text(localizations.errDiaGtSys), findsNothing);

    await tester.enterText(find.ancestor(of: find.text('Systolic').first, matching: find.byType(TextFormField)), '123');
    await tester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '67');

    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();
    expect(find.byType(AddEntryDialogue), findsOneWidget);
    expect(find.text(localizations.errNaN), findsOneWidget);
    expect(find.text(localizations.errLt30), findsNothing);
    expect(find.text(localizations.errUnrealistic), findsNothing);
    expect(find.text(localizations.errDiaGtSys), findsNothing);

    await tester.enterText(find.ancestor(of: find.text('Pulse').first, matching: find.byType(TextFormField)), '20');
    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();
    expect(find.byType(AddEntryDialogue), findsOneWidget);
    expect(find.text(localizations.errNaN), findsNothing);
    expect(find.text(localizations.errLt30), findsOneWidget);
    expect(find.text(localizations.errUnrealistic), findsNothing);
    expect(find.text(localizations.errDiaGtSys), findsNothing);

    await tester.enterText(find.ancestor(of: find.text('Pulse').first, matching: find.byType(TextFormField)), '60');
    await tester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '500');
    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();
    expect(find.byType(AddEntryDialogue), findsOneWidget);
    expect(find.text(localizations.errNaN), findsNothing);
    expect(find.text(localizations.errLt30), findsNothing);
    expect(find.text(localizations.errUnrealistic), findsOneWidget);
    expect(find.text(localizations.errDiaGtSys), findsNothing);

    await tester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '100');
    await tester.enterText(find.ancestor(of: find.text('Systolic').first, matching: find.byType(TextFormField)), '90');
    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();
    expect(find.byType(AddEntryDialogue), findsOneWidget);
    expect(find.text(localizations.errNaN), findsNothing);
    expect(find.text(localizations.errLt30), findsNothing);
    expect(find.text(localizations.errUnrealistic), findsNothing);
    expect(find.text(localizations.errDiaGtSys), findsOneWidget);


    await tester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '78');
    await tester.enterText(find.ancestor(of: find.text('Systolic').first, matching: find.byType(TextFormField)), '123');
    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();
    expect(find.byType(AddEntryDialogue), findsNothing);
    expect(find.text(localizations.errNaN), findsNothing);
    expect(find.text(localizations.errLt30), findsNothing);
    expect(find.text(localizations.errUnrealistic), findsNothing);
    expect(find.text(localizations.errDiaGtSys), findsNothing);
  });
  testWidgets('should allow invalid values when setting is set', (tester) async {
    final mRep = medRepo();
    await loadDialoge(tester, (context) => showAddEntryDialogue(context, mRep),
      settings: Settings(validateInputs: false, allowMissingValues: true),
    );
    expect(find.byType(DropdownButton<Medicine?>), findsNothing, reason: 'No medication in settings.');

    await tester.enterText(find.ancestor(of: find.text('Systolic').first, matching: find.byType(TextFormField)), '2');
    await tester.enterText(find.ancestor(of: find.text('Diastolic').first, matching: find.byType(TextFormField)), '500');
    await tester.tap(find.text('SAVE'));
    await tester.pumpAndSettle();
    expect(find.byType(AddEntryDialogue), findsNothing);
  });
  testWidgets('should start with sys input focused', (tester) async {
    final mRep = medRepo();
    await loadDialoge(tester, (context) =>
        showAddEntryDialogue(context, mRep, mockEntry(sys: 12).asAddEntry));
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
        showAddEntryDialogue(context, mRep, mockEntry(sys: 12, dia: 3, pul: 4, note: 'note').asAddEntry),);
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
}
