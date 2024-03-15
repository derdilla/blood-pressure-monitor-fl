import 'package:blood_pressure_app/components/custom_banner.dart';
import 'package:blood_pressure_app/components/dialoges/import_preview_dialoge.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:blood_pressure_app/model/export_import/csv_converter.dart';
import 'package:blood_pressure_app/model/export_import/csv_record_parsing_actor.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'util.dart';

void main() {
  testWidgets('should open', (tester) async {
    await tester.pumpWidget(materialApp(ImportPreviewDialoge(
      bottomAppBar: false,
      initialActor: CsvRecordParsingActor(
        CsvConverter(
          CsvExportSettings(),
          ExportColumnsManager(),
        ),
        'timestampUnixMs,systolic,diastolic,pulse,notes,needlePin\n1703175193324'
        ',123,45,67,note1,"{""color"":4285132974}"\n1703147206000,114,71,56,,null',
      ),
      columnsManager: ExportColumnsManager(),
    ),),);

    expect(tester.takeException(), isNull);
    expect(find.byType(DropdownButton), findsNWidgets(6), reason: '6 columns');
    expect(find.text('note1'), findsOneWidget);
    expect(find.byType(CustomBanner), findsNothing, reason: 'no error');

  });
  testWidgets('should limit rows', (tester) async {
    var csvTxt = 'timestampUnixMs,systolic,diastolic,pulse,notes,needlePin';
    for (int i = 0; i < 40; i++) {
      csvTxt += '\n${1703147206000 + i},1,1,1,row-content,null';
    }

    await tester.pumpWidget(materialApp(ImportPreviewDialoge(
      bottomAppBar: false,
      initialActor: CsvRecordParsingActor(
        CsvConverter(
          CsvExportSettings(),
          ExportColumnsManager(),
        ),
        csvTxt,
      ),
      columnsManager: ExportColumnsManager(),
    ),),);

    expect(find.text('row-content'), findsNWidgets(30));
    await tester.dragFrom(Offset(10, tester.view.physicalSize.height), Offset(0, -(tester.view.physicalSize.height)));
    await tester.pumpAndSettle();
    expect(find.text('…'), findsAtLeast(1));
  });
  testWidgets('should show error banner', (tester) async {
    await tester.pumpWidget(materialApp(ImportPreviewDialoge(
      bottomAppBar: false,
      initialActor: CsvRecordParsingActor(
        CsvConverter(
          CsvExportSettings(),
          ExportColumnsManager(),
        ),
        'systolic,diastolic,pulse,notes,needlePin\n123,45,67,note1,'
            '"{""color"":4285132974}"\n114,71,56,,null',
      ),
      columnsManager: ExportColumnsManager(),
    ),),);
    await tester.pumpAndSettle();

    expect(find.byType(CustomBanner), findsOneWidget);
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(localizations.errParseTimeNotRestoreable), findsOneWidget);
  });
  testWidgets('should have multiple lines', (tester) async {
    await tester.pumpWidget(materialApp(ImportPreviewDialoge(
      bottomAppBar: false,
      initialActor: CsvRecordParsingActor(
        CsvConverter(
          CsvExportSettings(),
          ExportColumnsManager(),
        ),
        'line1\nline2\nline3',
      ),
      columnsManager: ExportColumnsManager(),
    ),),);

    expect(find.byType(CheckboxMenuButton), findsOneWidget);
    expect(tester.getSemantics(find.byType(Checkbox)), containsSemantics(
      isChecked: true,
    ),);
    expect(find.text('line1'), findsNothing);
    expect(find.text('line2'), findsOneWidget);
    expect(find.text('line3'), findsOneWidget);

    await tester.tap(find.byType(CheckboxMenuButton));
    await tester.pumpAndSettle();
    expect(tester.getSemantics(find.byType(Checkbox)), containsSemantics(
      isChecked: false,
    ),);
    expect(find.text('line1'), findsOneWidget);
    expect(find.text('line2'), findsOneWidget);
    expect(find.text('line3'), findsOneWidget);
  });
  testWidgets('should parse data as expected', (tester) async {
    dynamic data = 1;

    await loadDialoge(tester, (context) async {
      data = await showImportPreview(
        context,
        CsvRecordParsingActor(
          CsvConverter(
            CsvExportSettings(),
            ExportColumnsManager(),
          ),
          'timestampUnixMs,systolic,diastolic,pulse,notes,needlePin\n1703175193324'
              ',123,45,67,note1,"{""color"":4285132974}"\n1703147206000,114,71,56,,null',
        ),
        ExportColumnsManager(),
        false,
      );
    },);

    expect(find.byType(ImportPreviewDialoge), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(find.byType(DropdownButton), findsNWidgets(6), reason: '6 columns');
    expect(find.text('note1'), findsOneWidget);
    expect(find.byType(CustomBanner), findsNothing, reason: 'no error');

    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    expect(find.text(localizations.import), findsOneWidget);
    await tester.tap(find.text(localizations.import));
    await tester.pumpAndSettle();
    expect(find.byType(ImportPreviewDialoge), findsNothing);

    expect(data, isA<List<BloodPressureRecord>>()
        .having((p0) => p0.length, 'rows', 2)
        .having((p0) => p0[0].needlePin?.color.value, 'first color', 4285132974)
        .having((p0) => p0[1].creationTime.millisecondsSinceEpoch, '2nd time', 1703147206000)
        .having((p0) => p0[1].diastolic, '2nd dia', 71),
    );
  });
}
