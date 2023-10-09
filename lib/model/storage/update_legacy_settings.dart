import 'dart:convert';

import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/horizontal_graph_line.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> updateLegacySettings(Settings settings, ExportSettings exportSettings, CsvExportSettings csvExportSettings,
    PdfExportSettings pdfExportSettings, IntervallStoreManager intervallStoreManager) async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  List<Future> futures = [];

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
        csvExportSettings.exportCustomFields = sharedPreferences.getBool(key)!;
        await sharedPreferences.remove(key);
        break;
      case 'exportItems':
        csvExportSettings.customFields = sharedPreferences.getStringList(key)!;
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
        settings.followSystemDarkMode = sharedPreferences.getBool(key)!;
        break;
      case 'darkMode':
        settings.darkMode = sharedPreferences.getBool(key)!;
        break;
      case 'accentColor':
        settings.accentColor = createMaterialColor(sharedPreferences.getInt(key)!);
        break;
      case 'diaColor':
        settings.diaColor = createMaterialColor(sharedPreferences.getInt(key)!);
        break;
      case 'sysColor':
        settings.sysColor = createMaterialColor(sharedPreferences.getInt(key)!);
        break;
      case 'pulColor':
        settings.pulColor = createMaterialColor(sharedPreferences.getInt(key)!);
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
        csvExportSettings.exportCustomFields = sharedPreferences.getBool(key)!;
        break;
      case 'exportItemsCsv':
        csvExportSettings.customFields = sharedPreferences.getStringList(key)!;
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
        pdfExportSettings.exportCustomFields = sharedPreferences.getBool(key)!;
        break;
      case 'exportItemsPdf':
        pdfExportSettings.customFields = sharedPreferences.getStringList(key)!;
        break;
      case 'horizontalGraphLines':
        settings.horizontalGraphLines = sharedPreferences.getStringList(key)!.map((e) =>
            HorizontalGraphLine.fromJson(jsonDecode(e))).toList();
        break;
      case 'useLegacyList':
        settings.useLegacyList = sharedPreferences.getBool(key)!;
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