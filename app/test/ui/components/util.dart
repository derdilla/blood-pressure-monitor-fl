import 'package:blood_pressure_app/model/blood_pressure/medicine/intake_history.dart';
import 'package:blood_pressure_app/model/blood_pressure/model.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../ram_only_implementations.dart';

/// Create a root material widget with localizations.
Widget materialApp(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  locale: const Locale('en'),
  home: Scaffold(body:child),
);

/// Create a root material widget with localizations and all providers but
/// without a app root.
Widget appBase(Widget child, {
  Settings? settings,
  ExportSettings? exportSettings,
  CsvExportSettings? csvExportSettings,
  PdfExportSettings? pdfExportSettings,
  IntervallStoreManager? intervallStoreManager,
  IntakeHistory? intakeHistory,
  BloodPressureModel? model,
}) {
  model ??= RamBloodPressureModel();
  settings ??= Settings();
  exportSettings ??= ExportSettings();
  csvExportSettings ??= CsvExportSettings();
  pdfExportSettings ??= PdfExportSettings();
  intakeHistory ??= IntakeHistory([]);
  intervallStoreManager ??= IntervallStoreManager(IntervallStorage(), IntervallStorage(), IntervallStorage());
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => settings),
      ChangeNotifierProvider(create: (_) => exportSettings),
      ChangeNotifierProvider(create: (_) => csvExportSettings),
      ChangeNotifierProvider(create: (_) => pdfExportSettings),
      ChangeNotifierProvider(create: (_) => intakeHistory),
      ChangeNotifierProvider(create: (_) => intervallStoreManager),
      ChangeNotifierProvider<BloodPressureModel>(create: (_) => model!),
    ],
    child: materialApp(child),
  );
}

/// Open a dialoge through a button press.
///
/// Example usage:
/// ```dart
/// dynamic returnedValue = false;
/// await loadDialoge(tester, (context) async => returnedValue =
///    await showAddExportColumnDialoge(context, Settings(),
///      UserColumn('initialInternalIdentifier', 'csvTitle', 'formatPattern')
/// ));
/// ```
Future<void> loadDialoge(WidgetTester tester, void Function(BuildContext context) dialogeStarter, { String dialogeStarterText = 'X' }) async {
  await tester.pumpWidget(materialApp(Builder(builder: (context) =>
      TextButton(onPressed: () => dialogeStarter(context), child: Text(dialogeStarterText)),),),);
  await tester.tap(find.text(dialogeStarterText));
  await tester.pumpAndSettle();
}
