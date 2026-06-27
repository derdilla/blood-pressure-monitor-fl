import 'package:blood_pressure_app/features/export_import/ui/columns_config/active_column_customizer.dart';
import 'package:blood_pressure_app/features/settings/export_import_screen.dart';
import 'package:blood_pressure_app/model/storage/export_settings.dart';
import 'package:blood_pressure_app/model/storage/types/export_format_setting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../util.dart';

void main() {
  testWidgets('Shows field customizer when relevant', (tester) async {
    final settings = ExportSettings(exportFormat: ExportFormat.csv);
    await tester.pumpWidget(materialApp(ExportImportScreen(), 
        exportSettings: settings));

    await tester.pumpAndSettle();
    expect(find.byType(ActiveColumnCustomizer), findsOneWidget);

    settings.exportFormat = ExportFormat.db;
    await tester.pumpAndSettle();
    expect(find.byType(ActiveColumnCustomizer), findsNothing);

    settings.exportFormat = ExportFormat.pdf;
    await tester.pumpAndSettle();
    expect(find.byType(ActiveColumnCustomizer), findsOneWidget);

    settings.exportFormat = ExportFormat.xls;
    await tester.pumpAndSettle();
    expect(find.byType(ActiveColumnCustomizer), findsOneWidget);
  });
}
