import 'package:blood_pressure_app/data_util/full_entry_builder.dart';
import 'package:blood_pressure_app/model/storage/interval_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';

import '../features/measurement_list/measurement_list_entry_test.dart';
import '../model/analyzer_test.dart';
import '../util.dart';

void main() {
  testWidgets('loads expected data', (tester) async {
    final records = [mockRecord(sys: 123)];
    final notes = [Note(time: DateTime(2000), note: 'test1'), Note(time: DateTime(2001), note: 'test2')];
    final intakes = [mockIntake(mockMedicine()), mockIntake(mockMedicine()), mockIntake(mockMedicine())];

    final mainIntervalls = IntervalStorage();
    mainIntervalls.changeStepSize(TimeStep.lifetime);

    await tester.pumpWidget(await appBaseWithData(FullEntryBuilder(
      rangeType: IntervalStoreManagerLocation.mainPage,
      onData: (context, foundRecords, foundIntakes, foundNotes) {
        expect(foundRecords, records);
        expect(foundIntakes, intakes);
        expect(foundNotes, notes);
        return const Text('ok');
      },
    ), records: records, intakes: intakes, notes: notes, intervallStoreManager: IntervalStoreManager(mainIntervalls, IntervalStorage(), IntervalStorage())));

    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(localizations.loading), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('ok'), findsOneWidget);
  });
  testWidgets('loads sorted entries', (tester) async {
    final notes = [Note(time: DateTime(2003), note: 'test0'), Note(time: DateTime(2000), note: 'test1'), Note(time: DateTime(2001), note: 'test2')];

    final exportPageIntervalls = IntervalStorage();
    exportPageIntervalls.changeStepSize(TimeStep.lifetime);

    await tester.pumpWidget(await appBaseWithData(FullEntryBuilder(
      rangeType: IntervalStoreManagerLocation.exportPage,
      onEntries: (context, entries) {
        expect(entries, hasLength(3));
        expect(entries[0].time.year, 2003);
        expect(entries[1].time.year, 2001);
        expect(entries[2].time.year, 2000);
        return const Text('ok');
      },
    ), notes: notes, intervallStoreManager: IntervalStoreManager(exportPageIntervalls, IntervalStorage(), IntervalStorage())));

    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(localizations.loading), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('ok'), findsOneWidget);
  });
}
