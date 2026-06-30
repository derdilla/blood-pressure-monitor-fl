import 'package:blood_pressure_app/components/custom_banner.dart';
import 'package:blood_pressure_app/features/export_import/model/export_preset.dart';
import 'package:blood_pressure_app/features/export_import/ui/export_warn_banner.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings.dart';
import 'package:blood_pressure_app/model/storage/export_settings.dart';
import 'package:blood_pressure_app/model/storage/types/export_format_setting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../util.dart';

void main() {
  testWidgets('Shows warn banner during dangerous configurations', (tester) async {
    final exportSettings = ExportSettings(exportFormat: ExportFormat.csv);
    final csvSettings = CsvExportSettings(activePreset: ExportPreset.appDefault.id);
    await tester.pumpWidget(materialApp(ExportWarnBanner(),
      exportSettings: exportSettings,
      csvExportSettings: csvSettings,
    ));

    await tester.pumpAndSettle();
    expect(find.byType(CustomBanner), findsNothing);

    csvSettings.activePreset = ExportPreset.myHeart.id;
    await tester.pumpAndSettle();
    expect(find.byType(CustomBanner), findsOneWidget);

    csvSettings.activePreset = ExportPreset.appDefault.id;
    await tester.pumpAndSettle();
    expect(find.byType(CustomBanner), findsNothing);

    exportSettings.exportFormat = ExportFormat.pdf;
    await tester.pumpAndSettle();
    expect(find.byType(CustomBanner), findsOneWidget);

    exportSettings.exportFormat = ExportFormat.db;
    await tester.pumpAndSettle();
    expect(find.byType(CustomBanner), findsNothing);
  });
}
