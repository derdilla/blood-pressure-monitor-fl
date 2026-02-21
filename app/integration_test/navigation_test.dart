
import 'package:blood_pressure_app/app.dart';
import 'package:blood_pressure_app/features/export_import/add_export_column_dialoge.dart';
import 'package:blood_pressure_app/features/export_import/export_column_management_screen.dart';
import 'package:blood_pressure_app/features/settings/add_medication_dialoge.dart';
import 'package:blood_pressure_app/features/settings/delete_data_screen.dart';
import 'package:blood_pressure_app/features/settings/enter_timeformat_dialoge.dart';
import 'package:blood_pressure_app/features/settings/export_import_screen.dart';
import 'package:blood_pressure_app/features/settings/graph_markings_screen.dart';
import 'package:blood_pressure_app/features/settings/medicine_manager_screen.dart';
import 'package:blood_pressure_app/features/settings/warn_about_screen.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/screens/home_screen.dart';
import 'package:blood_pressure_app/screens/settings_screen.dart';
import 'package:blood_pressure_app/screens/statistics_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'util.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Can visit all screens and dialoges', (WidgetTester tester) async {
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    const double settingsScrollAmount = 200.0;

    await tester.pumpWidget(App());
    await tester.pumpAndSettle();
    await tester.pumpUntil(() => find.byType(AppHome).hasFound);
    // home

    expect(find.byType(AppHome), findsOneWidget);
    expect(find.byType(SettingsPage), findsNothing);
    expect(find.byIcon(Icons.settings), findsOneWidget);
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsPage), findsOneWidget);
    // settings

    expect(find.byType(EnterTimeFormatDialoge), findsNothing);
    expect(find.text(localizations.timeFormat), findsOneWidget);
    await tester.tap(find.text(localizations.timeFormat));
    await tester.pumpAndSettle();
    expect(find.byType(EnterTimeFormatDialoge), findsOneWidget);
    // time format
    expect(find.text(localizations.btnSave), findsOneWidget);
    await tester.tap(find.text(localizations.btnSave));
    await tester.pumpAndSettle();
    expect(find.byType(EnterTimeFormatDialoge), findsNothing);
    // settings

    expect(find.byType(MedicineManagerScreen), findsNothing);
    await tester.scrollUntilVisible(find.text(localizations.medications), settingsScrollAmount);
    await tester.tap(find.text(localizations.medications));
    await tester.pumpAndSettle();
    expect(find.byType(MedicineManagerScreen), findsOneWidget);
    // medication manager
    expect(find.byType(AddMedicationDialoge), findsNothing);
    await tester.tap(find.text(localizations.addMedication));
    await tester.pumpAndSettle();
    expect(find.byType(AddMedicationDialoge), findsOneWidget);
    // add medication
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.byType(AddMedicationDialoge), findsNothing);
    // medication manager
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(MedicineManagerScreen), findsNothing);
    // settings

    expect(find.byType(AboutWarnValuesScreen), findsNothing);
    await tester.scrollUntilVisible(find.text(localizations.aboutWarnValuesScreenDesc), settingsScrollAmount);
    await tester.tap(find.text(localizations.aboutWarnValuesScreenDesc));
    await tester.pumpAndSettle();
    expect(find.byType(AboutWarnValuesScreen), findsOneWidget);
    // warn values info
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(AboutWarnValuesScreen), findsNothing);
    // settings

    expect(find.byType(GraphMarkingsScreen), findsNothing);
    await tester.scrollUntilVisible(find.text(localizations.customGraphMarkings), settingsScrollAmount);
    await tester.tap(find.text(localizations.customGraphMarkings));
    await tester.pumpAndSettle();
    expect(find.byType(GraphMarkingsScreen), findsOneWidget);
    // markings
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(GraphMarkingsScreen), findsNothing);
    // settings

    expect(find.byType(ExportImportScreen), findsNothing);
    await tester.scrollUntilVisible(find.text(localizations.exportImport), settingsScrollAmount);
    await tester.tap(find.text(localizations.exportImport));
    await tester.pumpAndSettle();
    expect(find.byType(ExportImportScreen), findsOneWidget);
    // export / import
    expect(find.byType(ExportColumnsManagementScreen), findsNothing);
    await tester.scrollUntilVisible(find.text(localizations.manageExportColumns), settingsScrollAmount);
    await tester.tap(find.text(localizations.manageExportColumns));
    await tester.pumpAndSettle();
    expect(find.byType(ExportColumnsManagementScreen), findsOneWidget);
    // export column manager
    expect(find.byType(AddExportColumnDialoge), findsNothing);
    await tester.tap(find.text(localizations.addExportformat));
    await tester.pumpAndSettle();
    expect(find.byType(AddExportColumnDialoge), findsOneWidget);
    // add export column
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.byType(AddExportColumnDialoge), findsNothing);
    // export column manager
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(ExportColumnsManagementScreen), findsNothing);
    // export / import
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(ExportImportScreen), findsNothing);
    // settings

    expect(find.byType(DeleteDataScreen), findsNothing);
    await tester.scrollUntilVisible(find.text(localizations.delete), settingsScrollAmount);
    await tester.tap(find.text(localizations.delete));
    await tester.pumpAndSettle();
    expect(find.byType(DeleteDataScreen), findsOneWidget);
    // delete data
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(DeleteDataScreen), findsNothing);
    // settings

    expect(find.byType(LicensePage), findsNothing);
    await tester.scrollUntilVisible(find.text(localizations.licenses, skipOffstage: false), settingsScrollAmount);
    await tester.tap(find.text(localizations.licenses));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsOneWidget);
    // delete data
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(LicensePage), findsNothing);
    // settings

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsPage), findsNothing);
    expect(find.byType(AppHome), findsOneWidget);
    // home


    expect(find.byType(StatisticsScreen), findsNothing);
    await tester.tap(find.byIcon(Icons.insights));
    await tester.pumpAndSettle();
    expect(find.byType(StatisticsScreen), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.byType(StatisticsScreen), findsNothing);
    expect(find.byType(AppHome), findsOneWidget);
  });
}
