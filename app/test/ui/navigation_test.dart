import 'package:blood_pressure_app/components/dialoges/add_measurement_dialoge.dart';
import 'package:blood_pressure_app/components/dialoges/enter_timeformat_dialoge.dart';
import 'package:blood_pressure_app/main.dart';
import 'package:blood_pressure_app/model/blood_pressure/medicine/intake_history.dart';
import 'package:blood_pressure_app/model/blood_pressure/model.dart';
import 'package:blood_pressure_app/model/storage/db/config_dao.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/screens/settings_screen.dart';
import 'package:blood_pressure_app/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'components/util.dart';

void main() {
  group('start page', () {
    testWidgets('should navigate to add entry page', (tester) async {
      await _pumpAppRoot(tester);
      expect(find.byIcon(Icons.add), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.byType(AddEntryDialoge), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 4)),);
    testWidgets('should navigate to settings page', (tester) async {
      await _pumpAppRoot(tester);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
    });
    testWidgets('should navigate to stats page', (tester) async {
      await _pumpAppRoot(tester);
      expect(find.byIcon(Icons.insights), findsOneWidget);
      await tester.tap(find.byIcon(Icons.insights));
      await tester.pumpAndSettle();

      expect(find.byType(StatisticsScreen), findsOneWidget);
    });
  });
  group('settings page', () {
    testWidgets('open EnterTimeFormatScreen', (tester) async {
      await _pumpAppRoot(tester);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.byType(EnterTimeFormatDialoge), findsNothing);
      final localizations = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(localizations.enterTimeFormatScreen), findsOneWidget);
      await tester.tap(find.text(localizations.enterTimeFormatScreen));
      await tester.pumpAndSettle();

      expect(find.byType(EnterTimeFormatDialoge), findsOneWidget);
    });
    // TODO: ...
  });
}

/// Creates a the same App as the main method.
Future<void> _pumpAppRoot(WidgetTester tester, {
  Settings? settings,
  ExportSettings? exportSettings,
  CsvExportSettings? csvExportSettings,
  PdfExportSettings? pdfExportSettings,
  IntervallStoreManager? intervallStoreManager,
  IntakeHistory? intakeHistory,
  BloodPressureModel? model,
}) async {
  await tester.pumpWidget(await appBase(const AppRoot(),
    settings: settings,
    exportSettings: exportSettings,
    csvExportSettings: csvExportSettings,
    pdfExportSettings: pdfExportSettings,
    intervallStoreManager: intervallStoreManager,
    intakeHistory: intakeHistory,
    model: model,
  ),);
}

class MockConfigDao implements ConfigDao {
  @override
  Future<CsvExportSettings> loadCsvExportSettings(int profileID) async => CsvExportSettings();

  @override
  Future<ExportSettings> loadExportSettings(int profileID) async => ExportSettings();

  @override
  Future<IntervallStorage> loadIntervallStorage(int profileID, int storageID) async => IntervallStorage();

  @override
  Future<PdfExportSettings> loadPdfExportSettings(int profileID) async => PdfExportSettings();

  @override
  Future<Settings> loadSettings(int profileID) async => Settings();

  void reset() {}

  @override
  Future<ExportColumnsManager> loadExportColumnsManager(int profileID) async => ExportColumnsManager();
}
