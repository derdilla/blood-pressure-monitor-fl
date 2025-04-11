import 'package:blood_pressure_app/features/input/forms/medicine_intake_form.dart';
import 'package:flutter/material.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';

import '../../../util.dart';

void main() {
  testWidgets('shows input list on single med', (WidgetTester tester) async {
    final mockMed = mockMedicine(designation: 'monozernorditrocin');
    await tester.pumpWidget(materialApp(MedicineIntakeForm(meds: [mockMed])));
    final localizations = await AppLocalizations.delegate.load(Locale('en'));

    expect(find.byType(TextField), findsNothing);
    expect(find.text('monozernorditrocin'), findsOneWidget);
    expect(find.text(localizations.tapToSelect), findsOneWidget);
  });

  testWidgets('shows input list on multiple meds', (WidgetTester tester) async {
    final med1 = mockMedicine(designation: 'tetraebraphthyme');
    final med2 = mockMedicine(designation: 'hypovonyhensas');
    await tester.pumpWidget(materialApp(MedicineIntakeForm(meds: [med1,med2])));
    final localizations = await AppLocalizations.delegate.load(Locale('en'));

    expect(find.text('tetraebraphthyme'), findsOneWidget);
    expect(find.text('hypovonyhensas'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byIcon(Icons.close), findsNothing);
    expect(find.text(localizations.tapToSelect), findsNothing);

    await tester.tap(find.text('hypovonyhensas'));
    await tester.pumpAndSettle();

    expect(find.text('tetraebraphthyme'), findsNothing);
    expect(find.text('hypovonyhensas'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.text('tetraebraphthyme'), findsOneWidget);
    expect(find.text('hypovonyhensas'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byIcon(Icons.close), findsNothing);

    await tester.tap(find.text('tetraebraphthyme'));
    await tester.pumpAndSettle();

    expect(find.text('tetraebraphthyme'), findsOneWidget);
    expect(find.text('hypovonyhensas'), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('returns entered values', (WidgetTester tester) async {
    final med1 = mockMedicine(designation: 'tetraebraphthyme');
    final med2 = mockMedicine(designation: 'hypovonyhensas');
    final key = GlobalKey<MedicineIntakeFormState>();

    await tester.pumpWidget(materialApp(MedicineIntakeForm(
      meds: [med1,med2],
      key: key,
    )));

    expect(key.currentState!.validate(), isTrue);
    expect(key.currentState!.save(), isNull);

    await tester.tap(find.text(med1.designation));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), ',..,');

    expect(key.currentState!.validate(), isFalse);
    expect(key.currentState!.save(), isNull);

    await tester.enterText(find.byType(TextField), '3.14');
    expect(key.currentState!.validate(), isTrue);
    expect(key.currentState!.save(), (med1, Weight.mg(3.14)));
  });

  testWidgets('prefills values when selecting med', (WidgetTester tester) async {
    final med1 = mockMedicine(designation: 'tetraebraphthyme', defaultDosis: 3.141);
    final med2 = mockMedicine(designation: 'hypovonyhensas');
    await tester.pumpWidget(materialApp(MedicineIntakeForm(meds: [med1,med2])));

    await tester.tap(find.text(med1.designation));
    await tester.pumpAndSettle();

    expect(find.text(med1.dosis!.mg.toString()), findsOneWidget);
  });

  testWidgets('returns passed values on edit', (WidgetTester tester) async {
    final med1 = mockMedicine(designation: 'tetraebraphthyme');
    final med2 = mockMedicine(designation: 'hypovonyhensas');
    final key = GlobalKey<MedicineIntakeFormState>();

    await tester.pumpWidget(materialApp(MedicineIntakeForm(
      meds: [med1,med2],
      key: key,
      initialValue: (med2, Weight.mg(3.141)),
    )));
    await tester.pumpAndSettle();

    expect(find.text(med2.designation), findsOneWidget);
    expect(find.text('3.141'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);

    expect(key.currentState!.validate(), isTrue);
    expect(key.currentState!.save(), (med2, Weight.mg(3.141)));
  });

}
