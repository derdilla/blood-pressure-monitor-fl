import 'package:blood_pressure_app/components/dialoges/add_measurement_dialoge.dart';
import 'package:blood_pressure_app/components/measurement_list/measurement_list_entry.dart';
import 'package:blood_pressure_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  final IntegrationTestWidgetsFlutterBinding binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Can enter value only measurements', (WidgetTester tester) async {
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    app.main();
    await tester.pumpAndSettle();
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

    // Gets up to 5s to load from fs.
    int retries = 10;
    while(find.text(localizations.loading).hasFound && retries >= 0) {
      retries--;
      await tester.pump(Duration(milliseconds: 500));
    }
    await tester.pump();

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
}
