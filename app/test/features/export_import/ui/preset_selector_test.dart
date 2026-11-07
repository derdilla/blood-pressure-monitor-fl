import 'dart:ui';

import 'package:blood_pressure_app/features/export_import/model/export_preset.dart';
import 'package:blood_pressure_app/features/export_import/ui/columns_config/preset_selector.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:blood_pressure_app/model/storage/types/export_format_setting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../util.dart';

void main() {
  testWidgets('Changes presets as expected', (tester) async {
    final exportSettings = ExportSettings(exportFormat: ExportFormat.csv);
    final csvSettings = CsvExportSettings(activePreset: ExportPreset.appDefault.id);
    final pdfSettings = PdfExportSettings(activePreset: ExportPreset.appDefault.id);
    final xlsSettings = ExcelExportSettings(activePreset: ExportPreset.appDefault.id);
    await tester.pumpWidget(materialApp(PresetSelector(),
      exportSettings: exportSettings,
      csvExportSettings: csvSettings,
      pdfExportSettings: pdfSettings,
      excelExportSettings: xlsSettings,
    ));
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));

    await tester.pumpAndSettle();
    expect(find.text(ExportPreset.appDefault.localize(localizations)), findsOneWidget);

    expect(csvSettings.activePreset, ExportPreset.appDefault.id);
    await tester.tap(find.text(ExportPreset.appDefault.localize(localizations)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ExportPreset.myHeart.localize(localizations)));
    await tester.pumpAndSettle();
    expect(csvSettings.activePreset, ExportPreset.myHeart.id);

    exportSettings.exportFormat = ExportFormat.pdf;
    await tester.pumpAndSettle();
    expect(pdfSettings.activePreset, ExportPreset.appDefault.id);
    await tester.tap(find.text(ExportPreset.appDefault.localize(localizations)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ExportPreset.myHeart.localize(localizations)));
    await tester.pumpAndSettle();
    expect(pdfSettings.activePreset, ExportPreset.myHeart.id);

    exportSettings.exportFormat = ExportFormat.xls;
    await tester.pumpAndSettle();
    expect(xlsSettings.activePreset, ExportPreset.appDefault.id);
    await tester.tap(find.text(ExportPreset.appDefault.localize(localizations)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ExportPreset.myHeart.localize(localizations)));
    await tester.pumpAndSettle();
    expect(xlsSettings.activePreset, ExportPreset.myHeart.id);

    await tester.tap(find.text(ExportPreset.myHeart.localize(localizations)));
    await tester.pumpAndSettle();
    await tester.tap(find.text(ExportPreset.appPdf.localize(localizations)));
    await tester.pumpAndSettle();
    expect(xlsSettings.activePreset, ExportPreset.appPdf.id);


  });
}
