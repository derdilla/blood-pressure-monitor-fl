import 'dart:convert';

import 'package:blood_pressure_app/model/blood_pressure/warn_values.dart';
import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/export_import/export_configuration.dart';
import 'package:blood_pressure_app/model/horizontal_graph_line.dart';
import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:blood_pressure_app/model/storage/db/config_db.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:blood_pressure_app/model/storage/interval_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'db/config_dao.dart';

/// Function for upgrading shared preferences from pre 1.5.4 (Oct 23) versions.
Future<void> migrateSharedPreferences(Settings settings, ExportSettings exportSettings, CsvExportSettings csvExportSettings,
    PdfExportSettings pdfExportSettings, IntervalStoreManager intervallStoreManager,) async {
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  final List<Future> futures = [];

  final keys = sharedPreferences.getKeys();
  for (final key in keys) { // remove these first
    switch (key) {
      case 'age':
        final age = sharedPreferences.getInt('age') ?? 30;
        settings.sysWarn = BloodPressureWarnValues.getUpperSysWarnValue(age);
        settings.diaWarn = BloodPressureWarnValues.getUpperDiaWarnValue(age);
        await sharedPreferences.remove(key);
        break;
      case 'overrideWarnValues':
      case 'exportLimitDataRange':
      case 'exportDataRangeStartEpochMs':
      case 'exportDataRangeEndEpochMs':
      case 'exportAddableItems':
      case 'iconSize':
      case 'titlesCount':
        await sharedPreferences.remove(key);
        break;
      case 'exportCustomEntries':
        csvExportSettings.exportFieldsConfiguration.activePreset =
          sharedPreferences.getBool(key)! ? ExportImportPreset.none : ExportImportPreset.bloodPressureApp;
        await sharedPreferences.remove(key);
        break;
      case 'exportItems':
        // can't be migrated as internalIdentifier changed
        await sharedPreferences.remove(key);
        break;
      case 'darkMode':
        settings.themeMode = sharedPreferences.getBool(key)! ? ThemeMode.dark : ThemeMode.light;
        await sharedPreferences.remove(key);
        break;
    }
  }
  for (final key in keys) {
    switch (key) {
      case 'graphStepSize':
        intervallStoreManager.mainPage.changeStepSize(TimeStep.deserialize(sharedPreferences.getInt(key)!));
        intervallStoreManager.statsPage.changeStepSize(TimeStep.deserialize(sharedPreferences.getInt(key)!));
        intervallStoreManager.exportPage.changeStepSize(TimeStep.deserialize(sharedPreferences.getInt(key)!));
        break;
      case 'followSystemDarkMode':
        if (sharedPreferences.getBool(key)!) settings.themeMode = ThemeMode.system;
        break;
      case 'accentColor':
        settings.accentColor = ConvertUtil.parseColor(sharedPreferences.getInt(key)!)!;
        break;
      case 'diaColor':
        settings.diaColor = ConvertUtil.parseColor(sharedPreferences.getInt(key)!)!;
        break;
      case 'sysColor':
        settings.sysColor = ConvertUtil.parseColor(sharedPreferences.getInt(key)!)!;
        break;
      case 'pulColor':
        settings.pulColor = ConvertUtil.parseColor(sharedPreferences.getInt(key)!)!;
        break;
      case 'allowManualTimeInput':
        settings.allowManualTimeInput = sharedPreferences.getBool(key)!;
        break;
      case 'dateFormatString':
        settings.dateFormatString = sharedPreferences.getString(key)!;
        break;
      case 'sysWarn':
        settings.sysWarn = sharedPreferences.getInt(key)!;
        break;
      case 'diaWarn':
        settings.diaWarn = sharedPreferences.getInt(key)!;
        break;
      case 'validateInputs':
        settings.validateInputs = sharedPreferences.getBool(key)!;
        break;
      case 'allowMissingValues':
        settings.allowMissingValues = sharedPreferences.getBool(key)!;
        break;
      case 'graphLineThickness':
        settings.graphLineThickness = sharedPreferences.getDouble(key)!;
        break;
      case 'animationSpeed':
        settings.animationSpeed = sharedPreferences.getInt(key)!;
        break;
      case 'confirmDeletion':
        settings.confirmDeletion = sharedPreferences.getBool(key)!;
        break;
      case 'exportFormat':
        exportSettings.exportFormat = ExportFormat.deserialize(sharedPreferences.getInt(key)!);
        break;
      case 'csvFieldDelimiter':
        csvExportSettings.fieldDelimiter = sharedPreferences.getString(key)!;
        break;
      case 'csvTextDelimiter':
        csvExportSettings.textDelimiter = sharedPreferences.getString(key)!;
        break;
      case 'exportMimeType':
        break;
      case 'exportCustomEntriesCsv':
        csvExportSettings.exportFieldsConfiguration.activePreset =
          sharedPreferences.getBool(key)! ? ExportImportPreset.none : ExportImportPreset.bloodPressureApp;
        break;
      case 'exportItemsCsv':
        // can't be migrated as internalIdentifier changed
        break;
      case 'exportCsvHeadline':
        csvExportSettings.exportHeadline = sharedPreferences.getBool(key)!;
        break;
      case 'defaultExportDir':
        exportSettings.defaultExportDir = sharedPreferences.getString(key)!;
        break;
      case 'exportAfterEveryEntry':
        exportSettings.exportAfterEveryEntry = sharedPreferences.getBool(key)!;
        break;
      case 'language':
        final value = sharedPreferences.getString(key);
        if (value?.isEmpty ?? true) {
          settings.language = null;
        } else {
          settings.language = Locale(value!);
        }
        break;
      case 'drawRegressionLines':
        settings.drawRegressionLines = sharedPreferences.getBool(key)!;
        break;
      case 'exportPdfHeaderHeight':
        pdfExportSettings.headerHeight = sharedPreferences.getDouble(key)!;
        break;
      case 'exportPdfCellHeight':
        pdfExportSettings.cellHeight = sharedPreferences.getDouble(key)!;
        break;
      case 'exportPdfHeaderFontSize':
        pdfExportSettings.headerFontSize = sharedPreferences.getDouble(key)!;
        break;
      case 'exportPdfCellFontSize':
        pdfExportSettings.cellFontSize = sharedPreferences.getDouble(key)!;
        break;
      case 'exportPdfExportTitle':
        pdfExportSettings.exportTitle = sharedPreferences.getBool(key)!;
        break;
      case 'exportPdfExportStatistics':
        pdfExportSettings.exportStatistics = sharedPreferences.getBool(key)!;
        break;
      case 'exportPdfExportData':
        pdfExportSettings.exportData = sharedPreferences.getBool(key)!;
        break;
      case 'startWithAddMeasurementPage':
        settings.startWithAddMeasurementPage = sharedPreferences.getBool(key)!;
        break;
      case 'exportCustomEntriesPdf':
        pdfExportSettings.exportFieldsConfiguration.activePreset =
            sharedPreferences.getBool(key)!
              ? ExportImportPreset.none : ExportImportPreset.bloodPressureApp;
        break;
      case 'exportItemsPdf':
        // can't be migrated as internalIdentifier changed
        break;
      case 'horizontalGraphLines':
        settings.horizontalGraphLines = sharedPreferences.getStringList(key)!.map((e) =>
            HorizontalGraphLine.fromJson(jsonDecode(e)),).toList();
        break;
      case 'useLegacyList':
        settings.compactList = sharedPreferences.getBool(key)!;
        break;
      case 'lastAppVersion':
        break;
      default:
        assert(false, 'Unexpected property saved: $key with value ${sharedPreferences.get(key)}');
        break;
    }
    futures.add(sharedPreferences.remove(key));
  }
  for (final f in futures) {
    await f;
  }
}

/// Function for upgrading pre 1.5.8 columns and settings to new structures.
/// 
/// - Adds columns from old db table to [manager].
Future<void> _updateLegacyExport(ConfigDB database, ExportColumnsManager manager) async {
  if (await _tableExists(database.database, ConfigDB.exportStringsTable)) {
    final existingDbEntries = await database.database.query(
        ConfigDB.exportStringsTable,
        columns: ['internalColumnName', 'columnTitle', 'formatPattern'],
    );
    for (final e in existingDbEntries) {
      final column = UserColumn(
          e['internalColumnName'].toString(),
          e['columnTitle'].toString(),
          e['formatPattern'].toString(),
      );
      if (column.formatPattern?.contains(r'$FORMAT') ?? false) {
        await Fluttertoast.showToast(
          msg: r'The export $FORMAT pattern got replaced. Your export columns broke.',
        );
      }
      manager.addOrUpdate(column);
    }

    await database.database.execute('DROP TABLE IF EXISTS ${ConfigDB.exportStringsTable};');
  }
}

Future<bool> _tableExists(Database database, String tableName) async => (await database.rawQuery(
  "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName';",)).isNotEmpty;

/// Migrate to file based settings format from db in pre 1.7.4 (Jul 24).
Future<void> migrateDatabaseSettings(
  Settings settings,
  ExportSettings exportSettings,
  CsvExportSettings csvExportSettings,
  PdfExportSettings pdfExportSettings,
  IntervalStoreManager intervallStoreManager,
  ExportColumnsManager manager,
  MedicineRepository medRepo,
) async {
  final configDB = await ConfigDB.open();
  if(configDB == null) return; // not upgradable

  await _updateLegacyExport(configDB, manager);
  final configDao = ConfigDao(configDB!);

  final oldSettings = await configDao.loadSettings();
  settings.copyFrom(oldSettings);
  final oldMeds = settings.medications.map((e) => Medicine(
    designation: e.designation,
    color: e.color.value,
    dosis: e.defaultDosis == null ? null : Weight.mg(e.defaultDosis!),
  ));
  await Future.forEach(oldMeds, medRepo.add);

  final oldExportSettings = await configDao.loadExportSettings();
  exportSettings.copyFrom(oldExportSettings);

  final oldCsvExportSettings = await configDao.loadCsvExportSettings();
  csvExportSettings.copyFrom(oldCsvExportSettings);

  final oldPdfExportSettings = await configDao.loadPdfExportSettings();
  pdfExportSettings.copyFrom(oldPdfExportSettings);

  final oldIntervalStorageManager = await configDao.loadIntervalStorageManager();
  intervallStoreManager.copyFrom(oldIntervalStorageManager);

  final oldExportColumnsManager = await configDao.loadExportColumnsManager();
  manager.copyFrom(oldExportColumnsManager);
}
