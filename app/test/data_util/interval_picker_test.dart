import 'package:blood_pressure_app/data_util/interval_picker.dart';
import 'package:blood_pressure_app/model/storage/interval_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:provider/provider.dart';

import '../util.dart';

void main() {
  testWidgets('shows controls and dropdown', (tester) async {
    await tester.pumpWidget(materialApp(ChangeNotifierProvider(
      create: (_) => IntervalStoreManager(IntervalStorage(),IntervalStorage(),IntervalStorage()),
      child: const IntervalPicker(type: IntervalStoreManagerLocation.mainPage)
    )));
    expect(find.byType(DropdownButton<TimeStep>), findsOneWidget);
    expect(find.byType(MaterialButton), findsNWidgets(2));
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    expect(
      tester.getCenter(find.byIcon(Icons.chevron_left)).dx,
      lessThan(tester.getCenter(find.byIcon(Icons.chevron_right)).dx),
    );
  });
  testWidgets('shows custom intervall start and end', (tester) async {
    final s = IntervalStoreManager(IntervalStorage(),IntervalStorage(),IntervalStorage());
    s.mainPage.changeStepSize(TimeStep.custom);
    s.mainPage.currentRange = DateRange(start: DateTime(2000), end: DateTime(2001));

    await tester.pumpWidget(materialApp(ChangeNotifierProvider.value(
      value: s,
      child: const IntervalPicker(type: IntervalStoreManagerLocation.mainPage)
    )));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.text('Jan 1, 2000 - Jan 1, 2001'), findsOneWidget);
    expect(find.text(localizations.custom), findsOneWidget);
  });
  testWidgets('allows switching interval', (tester) async {
    final s = IntervalStoreManager(IntervalStorage(),IntervalStorage(),IntervalStorage());
    s.mainPage.changeStepSize(TimeStep.last7Days);

    await tester.pumpWidget(materialApp(ChangeNotifierProvider.value(
      value: s,
      child: const IntervalPicker(type: IntervalStoreManagerLocation.mainPage),
    )));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    expect(s.mainPage.stepSize, TimeStep.last7Days);
    await tester.tap(find.text(localizations.last7Days));
    await tester.pumpAndSettle();
    await tester.tap(find.text(localizations.month));
    await tester.pumpAndSettle();

    expect(s.mainPage.stepSize, TimeStep.month);
    await tester.tap(find.text(localizations.month));
    await tester.pumpAndSettle();
    expect(find.byType(DateRangePickerDialog), findsNothing);
    await tester.tap(find.text(localizations.custom));
    await tester.pumpAndSettle();
    expect(find.byType(DateRangePickerDialog), findsOneWidget);
  });
  testWidgets('steps date stepper by one', (tester) async {
    final s = IntervalStoreManager(IntervalStorage(),IntervalStorage(),IntervalStorage());
    s.mainPage.changeStepSize(TimeStep.year);
    final year = s.mainPage.currentRange.start
      .add(s.mainPage.currentRange.duration ~/ 2)
      .year;

    await tester.pumpWidget(materialApp(ChangeNotifierProvider.value(
      value: s,
      child: const IntervalPicker(type: IntervalStoreManagerLocation.mainPage),
    )));

    expect(find.text('$year'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(find.text('${year - 1}'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.text('${year + 1}'), findsOneWidget);
  });
}
