import 'package:blood_pressure_app/features/input/forms/blood_pressure_form.dart';
import 'package:flutter/material.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../util.dart';

void main() {
  testWidgets('saves entered values', (WidgetTester tester) async {
    final key = GlobalKey<BloodPressureFormState>();
    await tester.pumpWidget(materialApp(BloodPressureForm(key: key)));
    await tester.pumpAndSettle();
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.text(localizations.sysLong), findsOneWidget);
    expect(find.text(localizations.diaLong), findsOneWidget);
    expect(find.text(localizations.pulLong), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
    expect(key.currentState?.validate(), true);

    await tester.enterText(find.ancestor(of: find.text(localizations.sysLong), matching: find.byType(TextField)), '123');
    await tester.enterText(find.ancestor(of: find.text(localizations.diaLong), matching: find.byType(TextField)), '67');
    await tester.enterText(find.ancestor(of: find.text(localizations.pulLong), matching: find.byType(TextField)), '89');

    expect(key.currentState?.validate(), true);
    expect(key.currentState?.save(), (sys: 123, dia: 67, pul: 89));
  });

  testWidgets('shows errors on bad inputs', (WidgetTester tester) async {
    final key = GlobalKey<BloodPressureFormState>();
    await tester.pumpWidget(materialApp(BloodPressureForm(key: key)));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.text(localizations.errNaN), findsNothing);

    await tester.enterText(find.byType(TextField).first, '..,..');
    await tester.pump();
    expect(find.text('..,..'), findsNothing);

    expect(find.text(localizations.errNaN), findsNothing);
    expect(find.text(localizations.errLt30), findsNothing);

    await tester.enterText(find.byType(TextField).first, '13');
    await tester.pump();
    expect(key.currentState!.validate(), isFalse);
    await tester.pumpAndSettle();

    expect(find.text(localizations.errLt30), findsOneWidget);
    expect(find.text(localizations.errUnrealistic), findsNothing);

    await tester.enterText(find.byType(TextField).first, '500');
    await tester.pump();
    expect(key.currentState!.validate(), isFalse);
    await tester.pumpAndSettle();

    expect(find.text(localizations.errLt30), findsNothing);
    expect(find.text(localizations.errUnrealistic), findsOneWidget);

    await tester.enterText(find.ancestor(of: find.text(localizations.sysLong), matching: find.byType(TextField)), '123');
    await tester.enterText(find.ancestor(of: find.text(localizations.diaLong), matching: find.byType(TextField)), '67');
    await tester.enterText(find.ancestor(of: find.text(localizations.pulLong), matching: find.byType(TextField)), '');
    await tester.pump();
    expect(key.currentState!.validate(), isFalse);
    await tester.pumpAndSettle();

    expect(find.text(localizations.errUnrealistic), findsNothing);
    expect(find.text(localizations.errNaN), findsOneWidget, reason: 'pul is null');

    await tester.enterText(find.ancestor(of: find.text(localizations.sysLong), matching: find.byType(TextField)), '90');
    await tester.enterText(find.ancestor(of: find.text(localizations.diaLong), matching: find.byType(TextField)), '130');
    await tester.enterText(find.ancestor(of: find.text(localizations.pulLong), matching: find.byType(TextField)), '89');
    await tester.pump();
    expect(key.currentState!.validate(), isFalse);
    await tester.pumpAndSettle();

    expect(find.text(localizations.errUnrealistic), findsNothing);
    expect(find.text(localizations.errDiaGtSys), findsOneWidget);
  });

  testWidgets('loads initial values', (WidgetTester tester) async {
    await tester.pumpWidget(materialApp(BloodPressureForm(
      initialValue: (sys: 123, dia: 67, pul: 89),
    )));
    await tester.pumpAndSettle();
    expect(find.text('123'), findsOneWidget);
    expect(find.text('67'), findsOneWidget);
    expect(find.text('89'), findsOneWidget);
  });
}
