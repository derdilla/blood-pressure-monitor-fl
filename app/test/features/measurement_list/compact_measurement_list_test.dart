import 'package:blood_pressure_app/features/measurement_list/compact_measurement_list.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../model/export_import/record_formatter_test.dart';
import '../../util.dart';

void main() {
  testWidgets('shows header and no data when empty', (WidgetTester tester) async {
    await tester.pumpWidget(materialApp(const CompactMeasurementList(data: [])));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.text(localizations.time), findsOneWidget);
    expect(find.text(localizations.sysShort), findsOneWidget);
    expect(find.text(localizations.diaShort), findsOneWidget);
    expect(find.text(localizations.pulShort), findsOneWidget);
    expect(find.text(localizations.notes), findsOneWidget);

    expect(find.text(localizations.errNoData), findsOneWidget);
  });

  testWidgets('shows passed tiles', (WidgetTester tester) async {
    await tester.pumpWidget(materialApp(CompactMeasurementList(data: [
      mockEntry(sys: 123, dia: 45, pul: 67, note: 'testnote'),
    ])));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.text(localizations.time), findsOneWidget);
    expect(find.text(localizations.sysShort), findsOneWidget);
    expect(find.text(localizations.diaShort), findsOneWidget);
    expect(find.text(localizations.pulShort), findsOneWidget);
    expect(find.text(localizations.notes), findsOneWidget);

    expect(find.text(localizations.errNoData), findsNothing);
    expect(find.byType(Dismissible), findsOneWidget);
    expect(find.text('123'), findsOneWidget);
    expect(find.text('45'), findsOneWidget);
    expect(find.text('67'), findsOneWidget);
    expect(find.text('testnote'), findsOneWidget);
  });

  // TODO: test delete once storage logic is mockable (extract add and delete to
  // object in context)
  /*testWidgets('initializes deletion when swiping from right to left', (WidgetTester tester) async {
    await tester.pumpWidget(materialApp(CompactMeasurementList(data: [
      mockEntry(sys: 123, dia: 45, pul: 67, note: 'testnote'),
    ])));

    expect(find.byType(AddEntryDialoge), findsNothing);
    expect(find.byIcon(Icons.delete), findsNothing);

    await tester.drag(find.text('45'), const Offset(-500.0, 0));
    await tester.pumpAndSettle();
    expect(find.text('Confirm deletion'), findsOneWidget);
  });*/
  // TODO: opens edit when swiping from left to right
}
