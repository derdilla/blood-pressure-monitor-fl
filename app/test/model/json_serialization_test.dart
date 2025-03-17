
import 'package:blood_pressure_app/model/blood_pressure/pressure_unit.dart';
import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/export_import/export_configuration.dart';
import 'package:blood_pressure_app/model/horizontal_graph_line.dart';
import 'package:blood_pressure_app/model/storage/bluetooth_input_mode.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:blood_pressure_app/model/storage/interval_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/model/weight_unit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';

void main() {
  group('IntervallStorage', () {
    test('should create json without error', () {
      final intervall = IntervalStorage(stepSize: TimeStep.year);
      final json = intervall.toJson();
      expect(json.length, greaterThan(0));
    });

    test('should load same data from json', () {
      final initialData = IntervalStorage();
      final json = initialData.toJson();
      final recreatedData = IntervalStorage.fromJson(json);

      expect(initialData.stepSize, recreatedData.stepSize);
      expect(initialData.currentRange.start.millisecondsSinceEpoch,
          recreatedData.currentRange.start.millisecondsSinceEpoch,);
      expect(initialData.currentRange.end.millisecondsSinceEpoch,
          recreatedData.currentRange.end.millisecondsSinceEpoch,);
    });

    test('should load same data from json in edge cases', () {
      final initialData = IntervalStorage(stepSize: TimeStep.month, range: DateRange(
          start: DateTime.fromMillisecondsSinceEpoch(1234),
          end: DateTime.fromMillisecondsSinceEpoch(5678),
      ),);
      final json = initialData.toJson();
      final recreatedData = IntervalStorage.fromJson(json);

      expect(initialData.stepSize, TimeStep.month);
      expect(recreatedData.currentRange.start.millisecondsSinceEpoch, 1234);
      expect(recreatedData.currentRange.end.millisecondsSinceEpoch, 5678);
    });

    test('should not crash when parsing incorrect json', () {
      IntervalStorage.fromJson('banana');
      IntervalStorage.fromJson('{"stepSize" = 1}');
      IntervalStorage.fromJson('{"stepSize": 1');
      IntervalStorage.fromJson('{stepSize: 1}');
      IntervalStorage.fromJson('green{stepSize: 1}');
    });

    test('should not crash when parsing invalid values and ignore them', () {
      final v1 = IntervalStorage.fromJson('{"stepSize": true}');
      final v2 = IntervalStorage.fromJson('{"stepSize": "month"}');
      final v3 = IntervalStorage.fromJson('{"start": "month", "end": 10.5}');
      final v4 = IntervalStorage.fromJson('{"start": 18.6, "end": 90.65}');

      expect(v1.stepSize, TimeStep.last7Days);
      expect(v2.stepSize, TimeStep.last7Days);
      expect(v3.stepSize, TimeStep.last7Days);

      // in minutes to avoid failing through performance
      expect(v2.currentRange.duration.inMinutes, v1.currentRange.duration.inMinutes);
      expect(v3.currentRange.duration.inMinutes, v1.currentRange.duration.inMinutes);
      expect(v4.currentRange.duration.inMinutes, v1.currentRange.duration.inMinutes);
    });
  });

  group('Settings', (){
    test('should be able to recreate all values from json', () {
      final initial = Settings(
        language: const Locale('en'),
        accentColor: Colors.deepOrange,
        sysColor: Colors.deepOrange,
        diaColor: Colors.deepOrange,
        pulColor: Colors.deepOrange,
        needlePinBarWidth: 123.456789,
        dateFormatString: 'Lorem Ipsum',
        graphLineThickness: 134.23123,
        animationSpeed: 78,
        sysWarn: 78,
        diaWarn: 78,
        allowManualTimeInput: false,
        confirmDeletion: false,
        themeMode: ThemeMode.light,
        validateInputs: false,
        allowMissingValues: false,
        drawRegressionLines: false,
        startWithAddMeasurementPage: false,
        useLegacyList: false,
        horizontalGraphLines: [HorizontalGraphLine(Colors.blue, 1230)],
        bottomAppBars: true,
        knownBleDev: ['a', 'b'],
        bleInput: BluetoothInputMode.newBluetoothInputCrossPlatform,
        weightInput: true,
        weightUnit: WeightUnit.st,
        preferredPressureUnit: PressureUnit.kPa,
      );
      final fromJson = Settings.fromJson(initial.toJson());

      expect(initial.language, fromJson.language);
      expect(initial.accentColor.toARGB32(), fromJson.accentColor.toARGB32());
      expect(initial.sysColor.toARGB32(), fromJson.sysColor.toARGB32());
      expect(initial.diaColor.toARGB32(), fromJson.diaColor.toARGB32());
      expect(initial.pulColor.toARGB32(), fromJson.pulColor.toARGB32());
      expect(initial.dateFormatString, fromJson.dateFormatString);
      expect(initial.graphLineThickness, fromJson.graphLineThickness);
      expect(initial.animationSpeed, fromJson.animationSpeed);
      expect(initial.sysWarn, fromJson.sysWarn);
      expect(initial.diaWarn, fromJson.diaWarn);
      expect(initial.allowManualTimeInput, fromJson.allowManualTimeInput);
      expect(initial.confirmDeletion, fromJson.confirmDeletion);
      expect(initial.themeMode, fromJson.themeMode);
      expect(initial.validateInputs, fromJson.validateInputs);
      expect(initial.allowMissingValues, fromJson.allowMissingValues);
      expect(initial.drawRegressionLines, fromJson.drawRegressionLines);
      expect(initial.startWithAddMeasurementPage, fromJson.startWithAddMeasurementPage);
      expect(initial.compactList, fromJson.compactList);
      expect(initial.horizontalGraphLines.length, fromJson.horizontalGraphLines.length);
      expect(initial.horizontalGraphLines.first.color.toARGB32(), fromJson.horizontalGraphLines.first.color.toARGB32());
      expect(initial.horizontalGraphLines.first.height, fromJson.horizontalGraphLines.first.height);
      expect(initial.needlePinBarWidth, fromJson.needlePinBarWidth);
      expect(initial.bottomAppBars, fromJson.bottomAppBars);
      expect(initial.knownBleDev, fromJson.knownBleDev);
      expect(initial.bleInput, fromJson.bleInput);
      expect(initial.weightInput, fromJson.weightInput);
      expect(initial.preferredPressureUnit, fromJson.preferredPressureUnit);
      expect(initial.weightUnit, fromJson.weightUnit);

      expect(initial.toJson(), fromJson.toJson());
    });

    test('should not crash when parsing incorrect json', () {
      Settings.fromJson('banana');
      Settings.fromJson('{"stepSize" = 1}');
      Settings.fromJson('{"stepSize": 1');
      Settings.fromJson('{stepSize: 1}');
      Settings.fromJson('green{stepSize: 1}');
    });

    test('should not crash when parsing invalid values and ignore them', () {
      final v1 = Settings.fromJson('{"pulColor": true}');
      final v2 = Settings.fromJson('{"validateInputs": "red"}');
      final v3 = Settings.fromJson('{"validateInputs": "month", "useLegacyList": 10.5}');
      Settings.fromJson('{"sysWarn": 18.6, "diaWarn": 90.65}');

      expect(v1.pulColor.toARGB32(), Settings().pulColor.toARGB32());
      expect(v2.validateInputs, Settings().validateInputs);
      expect(v3.compactList, Settings().compactList);
    });
  });

  group('ExportSettings', (){
    test('should be able to recreate all values from json', () {
      final initial = ExportSettings(
        exportFormat: ExportFormat.db,
        defaultExportDir: 'lorem ipsum',
        exportAfterEveryEntry: true,
      );
      final fromJson = ExportSettings.fromJson(initial.toJson());

      expect(initial.exportFormat, fromJson.exportFormat);
      expect(initial.defaultExportDir, fromJson.defaultExportDir);
      expect(initial.exportAfterEveryEntry, fromJson.exportAfterEveryEntry);

      expect(initial.toJson(), fromJson.toJson());
    });

    test('should not crash when parsing incorrect json', () {
      ExportSettings.fromJson('banana');
      ExportSettings.fromJson('{"defaultExportDir" = 1}');
      ExportSettings.fromJson('{"defaultExportDir": 1');
      ExportSettings.fromJson('{defaultExportDir: 1}');
      ExportSettings.fromJson('green{exportFormat: 1}');
    });

    test('should not crash when parsing invalid values and ignore them', () {
      final v1 = ExportSettings.fromJson('{"defaultExportDir": ["test"]}');
      final v2 = ExportSettings.fromJson('{"exportFormat": "red"}');
      final v3 = ExportSettings.fromJson('{"exportFormat": "month", "exportAfterEveryEntry": 15}');

      expect(v1.defaultExportDir, ExportSettings().defaultExportDir);
      expect(v2.exportFormat, ExportSettings().exportFormat);
      expect(v3.exportFormat, ExportSettings().exportFormat);
      expect(v3.exportAfterEveryEntry, ExportSettings().exportAfterEveryEntry);
    });
  });
  group('ActiveExportColumnConfiguration', () {
    test('should be able to recreate all values from json', () {
      final initial = ActiveExportColumnConfiguration(
        activePreset: ExportImportPreset.myHeart,
        userSelectedColumnIds: ['a', 'b', 'c'],
      );
      final fromJson = ActiveExportColumnConfiguration.fromJson(initial.toJson());

      expect(initial.activePreset, fromJson.activePreset);
      expect(initial.toJson(), fromJson.toJson());
    });
    test('should not crash when parsing incorrect json', () {
      ActiveExportColumnConfiguration.fromJson('banana');
      ActiveExportColumnConfiguration.fromJson('{"preset" = false}');
      ActiveExportColumnConfiguration.fromJson('{"preset": false');
      ActiveExportColumnConfiguration.fromJson('{"preset": null');
      ActiveExportColumnConfiguration.fromJson('{"columns": null');
      ActiveExportColumnConfiguration.fromJson('{"columns": [123]');
      ActiveExportColumnConfiguration.fromJson('{preset: false}');
      ActiveExportColumnConfiguration.fromJson('green{preset: false}');
    });
    test('should not crash when parsing invalid values and ignore them', () {
      final v1 = ActiveExportColumnConfiguration.fromJson('{"preset": ["test"]}');
      final v2 = ActiveExportColumnConfiguration.fromJson('{"columns": [123, 456]}');

      expect(v1.activePreset, ActiveExportColumnConfiguration().activePreset);
      expect(v2.toJson(), ActiveExportColumnConfiguration().toJson());
    });
  });

  group('CsvExportSettings', (){
    test('should be able to recreate all values from json', () {
      final initial = CsvExportSettings(
        fieldDelimiter: 'asdfghjklö',
        textDelimiter: 'asdfghjklö2',
        exportHeadline: false,
        exportFieldsConfiguration: ActiveExportColumnConfiguration(
          activePreset: ExportImportPreset.myHeart,
          userSelectedColumnIds: ['a', 'b', 'c'],
        ),
      );
      final fromJson = CsvExportSettings.fromJson(initial.toJson());

      expect(initial.fieldDelimiter, fromJson.fieldDelimiter);
      expect(initial.textDelimiter, fromJson.textDelimiter);
      expect(initial.exportHeadline, fromJson.exportHeadline);
      expect(initial.exportFieldsConfiguration.toJson(), fromJson.exportFieldsConfiguration.toJson());

      expect(initial.toJson(), fromJson.toJson());
    });

    test('should not crash when parsing incorrect json', () {
      CsvExportSettings.fromJson('banana');
      CsvExportSettings.fromJson('{"fieldDelimiter" = 1}');
      CsvExportSettings.fromJson('{"fieldDelimiter": 1');
      CsvExportSettings.fromJson('{fieldDelimiter: 1}');
      CsvExportSettings.fromJson('green{fieldDelimiter: 1}');
    });

    test('should not crash when parsing invalid values and ignore them', () {
      final v1 = CsvExportSettings.fromJson('{"fieldDelimiter": ["test"]}');
      final v2 = CsvExportSettings.fromJson('{"exportHeadline": "red"}');
      final v3 = CsvExportSettings.fromJson('{"textDelimiter": "month", "textDelimiter": {"test": 10.5}}');

      expect(v1.fieldDelimiter, CsvExportSettings().fieldDelimiter);
      expect(v2.exportHeadline, CsvExportSettings().exportHeadline);
      expect(v3.textDelimiter, CsvExportSettings().textDelimiter);
      expect(v3.exportFieldsConfiguration.toJson(), CsvExportSettings().exportFieldsConfiguration.toJson());
    });
    test('should load settings from 1.5.7 and earlier', () {
      final settings = CsvExportSettings.fromJson('{"fieldDelimiter":"A","textDelimiter":"B","exportHeadline":false,"exportCustomFields":true,"customFields":["timestampUnixMs","systolic","diastolic","pulse","notes","color"]}');
      expect(settings.fieldDelimiter, 'A');
      expect(settings.textDelimiter, 'B');
      expect(settings.exportHeadline, false);
      expect(settings.exportFieldsConfiguration.activePreset, ExportImportPreset.none);
    });
  });

  group('PdfExportSettings', (){
    test('should be able to recreate all values from json', () {
      final initial = PdfExportSettings(
        exportTitle: false,
        exportStatistics: false,
        exportData: false,
        headerHeight: 67.89,
        cellHeight: 67.89,
        headerFontSize: 67.89,
        cellFontSize: 67.89,
        exportFieldsConfiguration: ActiveExportColumnConfiguration(
          activePreset: ExportImportPreset.myHeart,
          userSelectedColumnIds: ['a', 'b', 'c'],
        ),
      );
      final fromJson = PdfExportSettings.fromJson(initial.toJson());

      expect(initial.exportTitle, fromJson.exportTitle);
      expect(initial.exportStatistics, fromJson.exportStatistics);
      expect(initial.exportData, fromJson.exportData);
      expect(initial.headerHeight, fromJson.headerHeight);
      expect(initial.cellHeight, fromJson.cellHeight);
      expect(initial.headerFontSize, fromJson.headerFontSize);
      expect(initial.cellFontSize, fromJson.cellFontSize);
      expect(initial.exportFieldsConfiguration.toJson(), fromJson.exportFieldsConfiguration.toJson());

      expect(initial.toJson(), fromJson.toJson());
    });

    test('should not crash when parsing incorrect json', () {
      PdfExportSettings.fromJson('banana');
      PdfExportSettings.fromJson('{"cellFontSize" = 1}');
      PdfExportSettings.fromJson('{"cellFontSize": 1');
      PdfExportSettings.fromJson('{cellFontSize: 1}');
      PdfExportSettings.fromJson('green{fieldDelimiter: 1}');
    });

    test('should not crash when parsing invalid values and ignore them', () {
      final v1 = PdfExportSettings.fromJson('{"cellFontSize": ["test"]}');
      final v2 = PdfExportSettings.fromJson('{"cellFontSize": "red"}');
      final v3 = PdfExportSettings.fromJson('{"headerFontSize": "month", "exportData": 15}');

      expect(v1.cellFontSize, PdfExportSettings().cellFontSize);
      expect(v2.cellFontSize, PdfExportSettings().cellFontSize);
      expect(v3.headerFontSize, PdfExportSettings().headerFontSize);
      expect(v3.exportData, PdfExportSettings().exportData);
    });
    test('should load settings from 1.5.7 and earlier', () {
      final settings = PdfExportSettings.fromJson('{"exportTitle":false,"exportStatistics":true,"exportData":false,"headerHeight":42.0,"cellHeight":42.0,"headerFontSize":42.0,"cellFontSize":42.0,"exportCustomFields":true,"customFields":["formattedTimestamp","systolic","diastolic","pulse","notes"]}');
      expect(settings.exportTitle, false);
      expect(settings.exportStatistics, true);
      expect(settings.exportData, false);
      expect(settings.headerHeight, 42);
      expect(settings.cellHeight, 42);
      expect(settings.headerFontSize, 42);
      expect(settings.cellFontSize, 42);
      expect(settings.exportFieldsConfiguration.activePreset, ExportImportPreset.none);
    });
  });

  group('ExportColumnsManager', (){
    test('should be able to recreate all values from json', () {
      final initial = ExportColumnsManager();
      final c1 = UserColumn('test', 'test', '\$SYS');
      final c2 = TimeColumn('testB', 'mmm');
      initial.addOrUpdate(c1);
      initial.addOrUpdate(c2);
      final fromJson = ExportColumnsManager.fromJson(initial.toJson());

      expect(initial.toJson(), fromJson.toJson());
    });

    test('should not crash when parsing incorrect json', () {
      ExportColumnsManager.fromJson('banana');
      ExportColumnsManager.fromJson('{"userColumns" = 1}');
      ExportColumnsManager.fromJson('{"userColumns": 1');
      ExportColumnsManager.fromJson('{userColumns: 1}');
      ExportColumnsManager.fromJson('green{userColumns: 1}');
    });

    test('should not crash when parsing invalid values and ignore them', () {
      final v1 = ExportColumnsManager.fromJson('{"userColumns": [1]}');
      final v2 = ExportColumnsManager.fromJson('{"cellFontSize": "red"}');

      expect(v1.userColumns.length, ExportColumnsManager().userColumns.length);
      expect(v2.userColumns.length, ExportColumnsManager().userColumns.length);
    });
  });
}
