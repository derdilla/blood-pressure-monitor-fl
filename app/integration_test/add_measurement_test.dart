import 'package:blood_pressure_app/app.dart';
import 'package:blood_pressure_app/features/input/add_measurement_dialoge.dart';
import 'package:blood_pressure_app/features/measurement_list/measurement_list_entry.dart';
import 'package:blood_pressure_app/features/settings/tiles/color_picker_list_tile.dart';
import 'package:blood_pressure_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:integration_test/integration_test.dart';

import '../test/ui/components/settings/color_picker_list_tile_test.dart';
import 'util.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Can enter value only measurements', (WidgetTester tester) async {
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(App(forceClearAppDataOnLaunch: true));
    await tester.pumpAndSettle();
    await tester.pumpUntil(() => find.byType(AppHome).hasFound);
    expect(find.byType(AppHome), findsOneWidget);
    expect(find.byType(AddEntryDialoge), findsNothing);
    expect(find.byType(MeasurementListRow), findsNothing);

    expect(find.byIcon(Icons.add), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.byType(AddEntryDialoge), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), '123'); // sys
    await tester.enterText(find.byType(TextFormField).at(1), '67'); // dia
    await tester.enterText(find.byType(TextFormField).at(2), '56'); // pul

    await tester.tap(find.text(localizations.btnSave));
    await tester.pumpAndSettle();
    expect(find.byType(AddEntryDialoge), findsNothing);

    await tester.pumpUntil(() => !find.text(localizations.loading).hasFound);
    expect(find.text(localizations.loading), findsNothing);

    expect(find.byType(MeasurementListRow), findsOneWidget);
    expect(find.descendant(
      of: find.byType(MeasurementListRow),
      matching: find.text('123'),
    ), findsOneWidget,);
    expect(find.descendant(
      of: find.byType(MeasurementListRow),
      matching: find.text('67'),
    ), findsOneWidget,);
    expect(find.descendant(
      of: find.byType(MeasurementListRow),
      matching: find.text('56'),
    ), findsOneWidget,);

  });

  testWidgets('Can enter complex measurements', (WidgetTester tester) async {
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.pumpWidget(App(forceClearAppDataOnLaunch: true,));
    await tester.pumpAndSettle();
    await tester.pumpUntil(() => find.byType(AppHome).hasFound);
    expect(find.byType(AppHome), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.byType(AddEntryDialoge), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), '123'); // sys
    await tester.enterText(find.byType(TextFormField).at(1), '67'); // dia
    await tester.enterText(find.byType(TextFormField).at(2), '56'); // pul
    await tester.enterText(find.byType(TextFormField).at(3), 'some test sample note'); // note
    await tester.tap(find.byType(ColorSelectionListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.byElementPredicate(findColored(Colors.red)));
    await tester.pumpAndSettle();

    await tester.tap(find.text(localizations.btnSave));
    await tester.pumpAndSettle();
    expect(find.byType(AddEntryDialoge), findsNothing);

    await tester.pumpUntil(() => !find.text(localizations.loading).hasFound);
    expect(find.text(localizations.loading), findsNothing);

    expect(find.byType(MeasurementListRow), findsOneWidget);
    final submittedRecord = tester.widget<MeasurementListRow>(find.byType(MeasurementListRow)).data;
    expect(submittedRecord.sys?.mmHg, 123);
    expect(submittedRecord.dia?.mmHg, 67);
    expect(submittedRecord.pul, 56);
    expect(submittedRecord.color, Colors.red.value);
    expect(submittedRecord.note, 'some test sample note');

    expect(find.text('some test sample note'), findsNothing);
    await tester.tap(find.byType(MeasurementListRow));
    await tester.pumpAndSettle();
    expect(find.text('some test sample note'), findsOneWidget);
  });
}
