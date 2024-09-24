import 'package:blood_pressure_app/features/measurement_list/weight_list.dart';
import 'package:blood_pressure_app/model/storage/interval_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/model/weight_unit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';

import '../../util.dart';

void main() {
  testWidgets('shows all elements in time range in order', (tester) async {
    final interval = IntervalStorage();
    interval.changeStepSize(TimeStep.lifetime);

    await tester.pumpWidget(await appBaseWithData(
      weights: [
        BodyweightRecord(time: DateTime(2001), weight: Weight.kg(123.0)),
        BodyweightRecord(time: DateTime(2003), weight: Weight.kg(122.1)),
        BodyweightRecord(time: DateTime(2000), weight: Weight.kg(70.0)),
        BodyweightRecord(time: DateTime(2002), weight: Weight.kg(7000.12345)),
      ],
      intervallStoreManager: IntervalStoreManager(interval, IntervalStorage(), IntervalStorage()),
      const WeightList(rangeType: IntervalStoreManagerLocation.mainPage),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(ListTile), findsNWidgets(4));
    expect(find.text('123 kg'), findsOneWidget);
    expect(find.text('122.1 kg'), findsOneWidget);
    expect(find.text('70 kg'), findsOneWidget);
    expect(find.text('7000.12 kg'), findsOneWidget);

    expect(
      tester.getCenter(find.textContaining('2003')).dy,
      lessThan(tester.getCenter(find.textContaining('2002')).dy),
    );
    expect(
      tester.getCenter(find.textContaining('2002')).dy,
      lessThan(tester.getCenter(find.textContaining('2001')).dy),
    );
    expect(
      tester.getCenter(find.textContaining('2001')).dy,
      lessThan(tester.getCenter(find.textContaining('2000')).dy),
    );
  });
  testWidgets('deletes elements from repo', (tester) async {
    final interval = IntervalStorage();
    interval.changeStepSize(TimeStep.lifetime);
    final repo = MockBodyweightRepository();
    await repo.add(BodyweightRecord(time: DateTime(2001), weight: Weight.kg(123.0)));

    await tester.pumpWidget(appBase(
      weightRepo: repo,
      intervallStoreManager: IntervalStoreManager(interval, IntervalStorage(), IntervalStorage()),
      const WeightList(rangeType: IntervalStoreManagerLocation.mainPage),
    ));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'))!;
    await tester.pumpAndSettle();

    expect(find.text('123 kg'), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);
    expect(find.text(localizations.confirmDelete), findsNothing);
    expect(find.text(localizations.btnConfirm), findsNothing);

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(find.text(localizations.confirmDelete), findsOneWidget);
    expect(find.text(localizations.btnConfirm), findsOneWidget);

    await tester.tap(find.text(localizations.btnConfirm));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    expect(find.text('123 kg'), findsNothing);
    expect(repo.data, isEmpty);
  });
  testWidgets('respects confirm deletion setting', (tester) async {
    final interval = IntervalStorage();
    interval.changeStepSize(TimeStep.lifetime);
    final repo = MockBodyweightRepository();
    await repo.add(BodyweightRecord(time: DateTime(2001), weight: Weight.kg(123.0)));

    await tester.pumpWidget(appBase(
      weightRepo: repo,
      intervallStoreManager: IntervalStoreManager(interval, IntervalStorage(), IntervalStorage()),
      settings: Settings(confirmDeletion: false),
      const WeightList(rangeType: IntervalStoreManagerLocation.mainPage),
    ));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'))!;
    await tester.pumpAndSettle();

    expect(find.text('123 kg'), findsOneWidget);
    expect(find.text(localizations.confirmDelete), findsNothing);

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(find.text(localizations.confirmDelete), findsNothing);
    expect(find.text('123 kg'), findsNothing);
  });
  testWidgets('respects confirm weight unit setting', (tester) async {
    final interval = IntervalStorage();
    interval.changeStepSize(TimeStep.lifetime);
    final repo = MockBodyweightRepository();
    await repo.add(BodyweightRecord(time: DateTime(2001), weight: Weight.kg(123.0)));

    await tester.pumpWidget(appBase(
      weightRepo: repo,
      intervallStoreManager: IntervalStoreManager(interval, IntervalStorage(), IntervalStorage()),
      settings: Settings(weightUnit: WeightUnit.lbs),
      const WeightList(rangeType: IntervalStoreManagerLocation.mainPage),
    ));
    await tester.pumpAndSettle();

    expect(find.text('123 kg'), findsNothing);
    expect(find.text('55.79 lbs'), findsOneWidget);
  });
}
