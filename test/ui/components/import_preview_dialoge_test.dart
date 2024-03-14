import 'package:blood_pressure_app/components/dialoges/import_preview_dialoge.dart';
import 'package:blood_pressure_app/model/export_import/csv_converter.dart';
import 'package:blood_pressure_app/model/export_import/csv_record_parsing_actor.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:flutter/material.dart';
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
    )));

    expect(tester.takeException(), isNull);
    expect(find.byType(DropdownButton), findsNWidgets(6), reason: '6 columns');
    expect(find.text('note1'), findsOneWidget);
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
    )));

    expect(find.text('row-content'), findsNWidgets(30));
    await tester.dragFrom(Offset(10, tester.view.physicalSize.height), Offset(0, -(tester.view.physicalSize.height)));
    await tester.pumpAndSettle();
    expect(find.text('…'), findsAtLeast(1));
  });
}
