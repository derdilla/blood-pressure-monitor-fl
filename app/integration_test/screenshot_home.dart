
import 'package:blood_pressure_app/app.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'util.dart';

void main() {
  testWidgets('Screenshot home page', (WidgetTester tester) async {
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    await tester.pumpUntil(() => find.byType(AppHome).hasFound);
    
    await tester.tap(find.text(localizations.last7Days));
    await tester.pumpAndSettle();
    await tester.tap(find.text(localizations.day));
    await tester.pumpAndSettle();

    await tester.enterMeasurement(sys: 119, dia: 75, pul: 65);
    await tester.enterMeasurement(sys: 114, dia: 83, pul: 70, color: Colors.red);
    await tester.enterMeasurement(sys: 107, dia: 73, pul: 64);
    await tester.enterMeasurement(sys: 116, dia: 71, pul: 61, note: 'Add notes and colors!', color: Colors.lightBlue);
    await tester.enterMeasurement(sys: 105, dia: 74, pul: 60);
    await tester.pumpUntil(() => find.text('116').hasFound);
    
    await tester.tap(find.text('116'));
    await tester.pumpAndSettle();

    await tester.takeScreenshot('02-example_home');
  });
}

extension on WidgetTester {
  Future<void> enterMeasurement({
    int? sys,
    int? dia,
    int? pul,
    String? note,
    Color? color,
    bool save = true,
  }) async {
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    await tap(find.byIcon(Icons.add));
    await pumpAndSettle();
    if (sys != null) await enterText(find.byType(TextFormField).at(0), '$sys');
    if (dia != null) await enterText(find.byType(TextFormField).at(1), '$dia');
    if (pul != null) await enterText(find.byType(TextFormField).at(2), '$pul');
    if (note != null) await enterText(find.byType(TextFormField).at(3), note);
    if (color != null) {
      await tap(find.text(localizations.color));
      await pumpAndSettle();
      await tap(find.byElementPredicate(_colored(color)));
      await pumpAndSettle();
    }

    if (save) {
      await tap(find.text(localizations.btnSave));
      await pumpAndSettle();
    }
  }
}

bool Function(Element e) _colored(Color color) => (e) =>
  e.widget is Container &&
    (e.widget as Container).decoration is BoxDecoration &&
      ((e.widget as Container).decoration as BoxDecoration).color == color;
