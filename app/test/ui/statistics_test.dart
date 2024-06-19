import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';

import '../model/export_import/record_formatter_test.dart';
import 'components/util.dart';

void main() {
  testWidgets('should load page', (tester) async {
    await _initStatsPage(tester, []);
    expect(tester.takeException(), isNull);

    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(localizations.statistics), findsAtLeast(1));
    expect(find.text(localizations.valueDistribution), findsOneWidget);
    expect(find.text(localizations.timeResolvedMetrics, skipOffstage: false),
        findsOneWidget,);
  });
  testWidgets('should report measurement count', (tester) async {
    await _initStatsPage(tester, [
      for (int i = 1; i<51; i++) // can't safe entries at or before epoch
        mockEntry(time: DateTime.fromMillisecondsSinceEpoch(1582991592 + i),
          sys: i, dia: 60+i, pul: 110+i,),
    ], intervallStoreManager: IntervallStoreManager(IntervallStorage(),
        IntervallStorage(), IntervallStorage(stepSize: TimeStep.lifetime,),),);
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    expect(find.text(localizations.measurementCount), findsOneWidget);

    final measurementCountWidget = find.ancestor(
      of: find.text(localizations.measurementCount),
      matching: find.byType(ListTile),
    );
    expect(measurementCountWidget, findsOneWidget);
    expect(find.descendant(
        of: measurementCountWidget,
        matching: find.text('49'),
    ), findsNothing,);
    expect(find.descendant(
      of: measurementCountWidget,
      matching: find.text('51'),
    ), findsNothing,);
    expect(find.descendant(
      of: measurementCountWidget,
      matching: find.text('50'),
    ), findsOneWidget,);
  });
  testWidgets("should not display 'null' or -1", (tester) async {
    await _initStatsPage(tester, [
      mockEntry(time: DateTime.fromMillisecondsSinceEpoch(1), sys: 40, dia: 60),
      mockEntry(time: DateTime.fromMillisecondsSinceEpoch(2),),
    ], intervallStoreManager: IntervallStoreManager(IntervallStorage(),
        IntervallStorage(), IntervallStorage(stepSize: TimeStep.lifetime),),);
    expect(find.textContaining('-1'), findsNothing);
    expect(find.textContaining('null'), findsNothing);
  });

  testWidgets("should not display 'null' when empty", (tester) async {
    await _initStatsPage(tester, [],
        intervallStoreManager: IntervallStoreManager(
          IntervallStorage(), IntervallStorage(),
          IntervallStorage(stepSize: TimeStep.lifetime,),),);
    expect(find.textContaining('-1'), findsNothing);
    expect(find.textContaining('null'), findsNothing);
  });
}

Future<void> _initStatsPage(WidgetTester tester, List<BloodPressureRecord> records, {
  Settings? settings,
  ExportSettings? exportSettings,
  CsvExportSettings? csvExportSettings,
  PdfExportSettings? pdfExportSettings,
  IntervallStoreManager? intervallStoreManager,
}) async {
  await tester.pumpWidget(await appBaseWithData(const StatisticsScreen(),
    records: records,
    settings: settings,
    exportSettings: exportSettings,
    csvExportSettings: csvExportSettings,
    pdfExportSettings: pdfExportSettings,
    intervallStoreManager: intervallStoreManager,
  ));
  await tester.pumpAndSettle();
}
