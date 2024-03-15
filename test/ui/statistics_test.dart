import 'package:blood_pressure_app/model/blood_pressure/model.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../model/export_import/record_formatter_test.dart';
import '../ram_only_implementations.dart';

void main() {
  testWidgets('should load page', (widgetTester) async {
    await _initStatsPage(widgetTester, []);
    expect(widgetTester.takeException(), isNull);

    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(localizations.statistics), findsAtLeast(1));
    expect(find.text(localizations.valueDistribution), findsOneWidget);
    expect(find.text(localizations.timeResolvedMetrics, skipOffstage: false),
        findsOneWidget,);
  });
  testWidgets('should report measurement count', (widgetTester) async {
    await _initStatsPage(widgetTester, [
      for (int i = 1; i<51; i++) // can't safe entries at or before epoch
        mockRecord(time: DateTime.fromMillisecondsSinceEpoch(1582991592 + i),
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
  testWidgets("should not display 'null' or -1", (widgetTester) async {
    await _initStatsPage(widgetTester, [
      mockRecord(time: DateTime.fromMillisecondsSinceEpoch(1), sys: 40, dia: 60),
      mockRecord(time: DateTime.fromMillisecondsSinceEpoch(2),),
    ], intervallStoreManager: IntervallStoreManager(IntervallStorage(),
        IntervallStorage(), IntervallStorage(stepSize: TimeStep.lifetime),),);
    expect(find.textContaining('-1'), findsNothing);
    expect(find.textContaining('null'), findsNothing);
  });

  testWidgets("should not display 'null' when empty", (widgetTester) async {
    await _initStatsPage(widgetTester, [],
        intervallStoreManager: IntervallStoreManager(
            IntervallStorage(), IntervallStorage(),
            IntervallStorage(stepSize: TimeStep.lifetime,),),);
    expect(find.textContaining('-1'), findsNothing);
    expect(find.textContaining('null'), findsNothing);
  });
}

Future<void> _initStatsPage(WidgetTester widgetTester, List<BloodPressureRecord> records, {
  Settings? settings,
  ExportSettings? exportSettings,
  CsvExportSettings? csvExportSettings,
  PdfExportSettings? pdfExportSettings,
  IntervallStoreManager? intervallStoreManager,
}) async {
  final model = RamBloodPressureModel();
  settings ??= Settings();
  exportSettings ??= ExportSettings();
  csvExportSettings ??= CsvExportSettings();
  pdfExportSettings ??= PdfExportSettings();
  intervallStoreManager ??= IntervallStoreManager(IntervallStorage(), IntervallStorage(), IntervallStorage());

  for (final r in records) {
    model.add(r);
  }

  await widgetTester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => settings),
        ChangeNotifierProvider(create: (_) => exportSettings),
        ChangeNotifierProvider(create: (_) => csvExportSettings),
        ChangeNotifierProvider(create: (_) => pdfExportSettings),
        ChangeNotifierProvider(create: (_) => intervallStoreManager),
        ChangeNotifierProvider<BloodPressureModel>(create: (_) => model),
      ],
      child: Localizations(
        delegates: AppLocalizations.localizationsDelegates,
        locale: const Locale('en'),
        child: const StatisticsScreen(),
      ),
  ),);
  await widgetTester.pumpAndSettle();
}
