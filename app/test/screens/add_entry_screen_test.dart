import 'package:blood_pressure_app/features/input/forms/add_entry_form.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/screens/add_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';

import '../util.dart';

void main() {
  testWidgets('Stores entered measurements', (tester) async {
    final db = MockHealthDataSore();
    final bpRepo = db.bpRepo;

    await tester.pumpWidget(appBase(
      const AddEntryScreen(),
      bpRepo: bpRepo,
    ));
    await tester.pumpAndSettle();

    expect(find.byType(AddEntryForm), findsOneWidget);
    final oldMeasurements = await bpRepo.get(DateRange.all());
    expect(oldMeasurements, isEmpty);

    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    await tester.enterText(find.ancestor(of: find.text(localizations.sysLong).first, matching: find.byType(TextField)), '123');
    await tester.enterText(find.ancestor(of: find.text(localizations.diaLong).first, matching: find.byType(TextField)), '45');
    await tester.enterText(find.ancestor(of: find.text(localizations.pulLong).first, matching: find.byType(TextField)), '67');

    await tester.tap(find.text(localizations.btnSave));
    await tester.pumpAndSettle();
    expect(find.byType(AddEntryForm), findsNothing);

    final newMeasurements = await bpRepo.get(DateRange.all());
    expect(newMeasurements, hasLength(1));
    expect(newMeasurements.first.dia, Pressure.mmHg(45));
  });
  testWidgets('Updates on new med', (tester) async {
    final medRepo = MockMedRepo([]);

    await tester.pumpWidget(appBase(
      const AddEntryScreen(),
      medRepo: medRepo,
    ));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.monitor_heart_outlined), findsNothing);
    await medRepo.add(mockMedicine());
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.monitor_heart_outlined), findsOneWidget);
  });
}
