import 'package:blood_pressure_app/features/input/forms/weight_form.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../util.dart';

void main() {
  testWidgets('saves entered values', (WidgetTester tester) async {
    final key = GlobalKey<WeightFormState>();
    await tester.pumpWidget(materialApp(WeightForm(key: key)));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.text(localizations.weight), findsOneWidget);
    expect(find.text(Settings().weightUnit.name), findsOneWidget);
    expect(key.currentState!.validate(), true);

    await tester.enterText(find.byType(TextField), '314.15');

    expect(key.currentState!.validate(), true);
    expect(key.currentState!.save(), Settings().weightUnit.store(314.15));
  });

  testWidgets('shows errors on bad inputs', (WidgetTester tester) async {
    final key = GlobalKey<WeightFormState>();
    await tester.pumpWidget(materialApp(WeightForm(key: key)));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.text(localizations.errNaN), findsNothing);

    await tester.enterText(find.byType(TextField), '..,..');
    expect(key.currentState!.validate(), false);
    await tester.pumpAndSettle();
    expect(find.text(localizations.errNaN), findsOneWidget);
  });

  testWidgets('loads initial values', (WidgetTester tester) async {
    await tester.pumpWidget(materialApp(WeightForm(
      initialValue: Settings().weightUnit.store(123.45),
    )));
    await tester.pumpAndSettle();
    expect(find.text('123.45'), findsOneWidget);
  });

  testWidgets('saves only filled inputs', (WidgetTester tester) async {
    final key = GlobalKey<WeightFormState>();
    await tester.pumpWidget(materialApp(WeightForm(key: key)));
    expect(key.currentState!.save(), isNull);
  });
}
