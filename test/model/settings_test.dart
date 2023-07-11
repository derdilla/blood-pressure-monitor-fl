import 'package:blood_pressure_app/model/ram_only_implementations.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Settings model', () {
    // setup db path
    databaseFactory = databaseFactoryFfi;

    test('should initialize', () async {
      expect(() async {
        await Settings.create();
      }, returnsNormally);
    });

    test('fields defaults should be set after initialization', () async {
      var s = await Settings.create();
      expect(s.graphStepSize, TimeStep.day);
      expect(s.followSystemDarkMode, true);
      expect(s.darkMode, true);
      expect(s.accentColor.value, 0xFF009688);
      expect(s.sysColor.value, 0xFF009688);
      expect(s.diaColor.value, 0xFF4CAF50);
      expect(s.pulColor.value, 0xFFF44336);
      expect(s.allowManualTimeInput, true);
      expect(s.dateFormatString, 'yyyy-MM-dd  HH:mm');
      expect(s.iconSize, 30);
      expect(s.sysWarn, 120);
      expect(s.diaWarn, 80);
      expect(s.validateInputs, true);
      expect(s.graphLineThickness, 3);
      expect(s.animationSpeed, 150);
      expect(s.confirmDeletion, true);
      expect(s.graphTitlesCount, 5);
      expect(s.csvFieldDelimiter, ',');
      expect(s.csvTextDelimiter, '"');
      expect(s.exportItems, ['timestampUnixMs', 'systolic', 'diastolic', 'pulse', 'notes']);
      expect(s.exportAddableItems, ['isoUTCTime']);
      expect(s.exportCsvHeadline, true);
      expect(s.exportDataRange.start.millisecondsSinceEpoch, 0);
      expect(s.exportLimitDataRange, false);
      expect(s.exportMimeType, MimeType.csv);
      expect(s.defaultExportDir.isEmpty, true);
      expect(s.exportAfterEveryEntry, false);
    });

    test('setting fields should save changes', () async {
      var s = await Settings.create();

      int i = 0;
      s.addListener(() {
        i++;
        if (i >= 1) {
          expect(s.graphStepSize, TimeStep.lifetime);
        }
        if (i >= 11) {
          expect(s.dateFormatString, 'yy:dd @ H:mm.ss');
        }
      });

      s.graphStepSize = TimeStep.lifetime;
      s.displayDataStart = DateTime.fromMillisecondsSinceEpoch(10000);
      s.displayDataEnd = DateTime.fromMillisecondsSinceEpoch(200000);
      s.followSystemDarkMode = false;
      s.darkMode = false;
      s.accentColor = createMaterialColor(0xFF942DA4);
      s.sysColor = createMaterialColor(0xFF942DA5);
      s.diaColor = createMaterialColor(0xFF942DA6);
      s.pulColor = createMaterialColor(0xFF942DA7);
      s.allowManualTimeInput = false;
      s.dateFormatString = 'yy:dd @ H:mm.ss';
      s.iconSize = 50;
      s.sysWarn = 314;
      s.diaWarn = 159;
      s.validateInputs = false;
      s.graphLineThickness = 5;
      s.animationSpeed = 100;
      s.confirmDeletion = false;
      s.graphTitlesCount = 7;
      s.csvFieldDelimiter = '|';
      s.csvTextDelimiter = '\'';
      s.exportAddableItems = ['timestampUnixMs'];
      s.exportItems = ['systolic', 'diastolic', 'pulse', 'notes', 'isoUTCTime'];
      s.exportCsvHeadline = false;
      s.exportLimitDataRange = true;
      s.exportMimeType = MimeType.pdf;
      s.defaultExportDir = '/storage/emulated/0/Android/data/com.derdilla.bloodPressureApp/files/file.csv';
      s.exportAfterEveryEntry = true;

      expect(s.displayDataStart, DateTime.fromMillisecondsSinceEpoch(10000));
      expect(s.displayDataEnd, DateTime.fromMillisecondsSinceEpoch(200000));
      expect(s.followSystemDarkMode, false);
      expect(s.darkMode, false);
      expect(s.accentColor.value, 0xFF942DA4);
      expect(s.sysColor.value, 0xFF942DA5);
      expect(s.diaColor.value, 0xFF942DA6);
      expect(s.pulColor.value, 0xFF942DA7);
      expect(s.allowManualTimeInput, false);
      expect(s.iconSize, 50);
      expect(s.sysWarn, 314);
      expect(s.diaWarn, 159);
      expect(s.validateInputs, false);
      expect(s.graphLineThickness, 5);
      expect(s.animationSpeed, 100);
      expect(s.confirmDeletion, false);
      expect(s.graphTitlesCount, 7);
      expect(s.csvFieldDelimiter, '|');
      expect(s.csvTextDelimiter, '\'');
      expect(s.exportItems, ['systolic', 'diastolic', 'pulse', 'notes', 'isoUTCTime']);
      expect(s.exportAddableItems, ['timestampUnixMs']);
      expect(s.exportCsvHeadline, false);
      expect(s.exportLimitDataRange, true);
      expect(s.exportMimeType, MimeType.pdf);
      expect(s.defaultExportDir, '/storage/emulated/0/Android/data/com.derdilla.bloodPressureApp/files/file.csv');
      expect(s.exportAfterEveryEntry, true);
    });

    test('setting fields should notify listeners and change values', () async {
      var s = await Settings.create();

      int i = 0;
      s.addListener(() {
        i++;
      });

      s.graphStepSize = TimeStep.lifetime;
      s.displayDataStart = DateTime.fromMillisecondsSinceEpoch(10000);
      s.displayDataEnd = DateTime.fromMillisecondsSinceEpoch(200000);
      s.followSystemDarkMode = false;
      s.darkMode = false;
      s.accentColor = createMaterialColor(0xFF942DA4);
      s.sysColor = createMaterialColor(0xFF942DA5);
      s.diaColor = createMaterialColor(0xFF942DA6);
      s.pulColor = createMaterialColor(0xFF942DA7);
      s.allowManualTimeInput = false;
      s.dateFormatString = 'yy:dd @ H:mm.ss';
      s.iconSize = 10;
      s.sysWarn = 314;
      s.diaWarn = 159;
      s.validateInputs = false;
      s.graphLineThickness = 5;
      s.animationSpeed = 100;
      s.confirmDeletion = true;
      s.graphTitlesCount = 2;
      s.csvFieldDelimiter = '|';
      s.csvTextDelimiter = '\'';
      s.exportAddableItems = ['timestampUnixMs'];
      s.exportItems = ['systolic', 'diastolic', 'pulse', 'notes', 'isoUTCTime'];
      s.exportCsvHeadline = false;
      s.exportDataRange = DateTimeRange(start: DateTime.fromMillisecondsSinceEpoch(20), end: DateTime.now());
      s.exportLimitDataRange = true;
      s.exportMimeType = MimeType.pdf;
      s.defaultExportDir = '/storage/emulated/0/Android/data/com.derdilla.bloodPressureApp/files/file.csv';
      s.exportAfterEveryEntry = true;

      expect(i, 29);
    });
  });

  group('RamSettings model', () {
    // setup db path
    databaseFactory = databaseFactoryFfi;

    test('should initialize', () async {
      expect(() async {
        RamSettings();
      }, returnsNormally);
    });

    test('fields defaults should be set after initialization', () async {
      var s = RamSettings();
      expect(s.graphStepSize, TimeStep.day);
      expect(s.followSystemDarkMode, true);
      expect(s.darkMode, true);
      expect(s.accentColor.value, 0xFF009688);
      expect(s.sysColor.value, 0xFF009688);
      expect(s.diaColor.value, 0xFF4CAF50);
      expect(s.pulColor.value, 0xFFF44336);
      expect(s.allowManualTimeInput, true);
      expect(s.dateFormatString, 'yyyy-MM-dd  HH:mm');
      expect(s.iconSize, 30);
      expect(s.sysWarn, 120);
      expect(s.diaWarn, 80);
      expect(s.validateInputs, true);
      expect(s.graphLineThickness, 3);
      expect(s.animationSpeed, 150);
      expect(s.confirmDeletion, true);
      expect(s.graphTitlesCount, 5);
      expect(s.csvFieldDelimiter, ',');
      expect(s.csvTextDelimiter, '"');
      expect(s.exportItems, ['timestampUnixMs', 'systolic', 'diastolic', 'pulse', 'notes']);
      expect(s.exportAddableItems, ['isoUTCTime']);
      expect(s.exportCsvHeadline, true);
      expect(s.exportDataRange.start.millisecondsSinceEpoch, 0);
      expect(s.exportLimitDataRange, false);
      expect(s.exportMimeType, MimeType.csv);
      expect(s.defaultExportDir.isEmpty, true);
      expect(s.exportAfterEveryEntry, false);
    });

    test('setting fields should save changes', () async {
      var s = RamSettings();

      int i = 0;
      s.addListener(() {
        i++;
        if (i >= 1) {
          expect(s.graphStepSize, TimeStep.lifetime);
        }
        if (i >= 11) {
          expect(s.dateFormatString, 'yy:dd @ H:mm.ss');
        }
      });

      s.graphStepSize = TimeStep.lifetime;
      s.displayDataStart = DateTime.fromMillisecondsSinceEpoch(10000);
      s.displayDataEnd = DateTime.fromMillisecondsSinceEpoch(200000);
      s.followSystemDarkMode = false;
      s.darkMode = false;
      s.accentColor = createMaterialColor(0xFF942DA4);
      s.sysColor = createMaterialColor(0xFF942DA5);
      s.diaColor = createMaterialColor(0xFF942DA6);
      s.pulColor = createMaterialColor(0xFF942DA7);
      s.allowManualTimeInput = false;
      s.dateFormatString = 'yy:dd @ H:mm.ss';
      s.iconSize = 50;
      s.sysWarn = 314;
      s.diaWarn = 159;
      s.validateInputs = false;
      s.graphLineThickness = 5;
      s.animationSpeed = 100;
      s.confirmDeletion = false;
      s.graphTitlesCount = 7;
      s.csvFieldDelimiter = '|';
      s.csvTextDelimiter = '\'';
      s.exportAddableItems = ['timestampUnixMs'];
      s.exportItems = ['systolic', 'diastolic', 'pulse', 'notes', 'isoUTCTime'];
      s.exportCsvHeadline = false;
      s.exportLimitDataRange = true;
      s.exportMimeType = MimeType.pdf;
      s.defaultExportDir = '/storage/emulated/0/Android/data/com.derdilla.bloodPressureApp/files/file.csv';
      s.exportAfterEveryEntry = true;


      expect(s.displayDataStart, DateTime.fromMillisecondsSinceEpoch(10000));
      expect(s.displayDataEnd, DateTime.fromMillisecondsSinceEpoch(200000));
      expect(s.followSystemDarkMode, false);
      expect(s.darkMode, false);
      expect(s.accentColor.value, 0xFF942DA4);
      expect(s.sysColor.value, 0xFF942DA5);
      expect(s.diaColor.value, 0xFF942DA6);
      expect(s.pulColor.value, 0xFF942DA7);
      expect(s.allowManualTimeInput, false);
      expect(s.iconSize, 50);
      expect(s.sysWarn, 314);
      expect(s.diaWarn, 159);
      expect(s.validateInputs, false);
      expect(s.graphLineThickness, 5);
      expect(s.animationSpeed, 100);
      expect(s.confirmDeletion, false);
      expect(s.graphTitlesCount, 7);
      expect(s.csvFieldDelimiter, '|');
      expect(s.csvTextDelimiter, '\'');
      expect(s.exportItems, ['systolic', 'diastolic', 'pulse', 'notes', 'isoUTCTime']);
      expect(s.exportAddableItems, ['timestampUnixMs']);
      expect(s.exportCsvHeadline, false);
      expect(s.exportLimitDataRange, true);
      expect(s.exportMimeType, MimeType.pdf);
      expect(s.defaultExportDir, '/storage/emulated/0/Android/data/com.derdilla.bloodPressureApp/files/file.csv');
      expect(s.exportAfterEveryEntry, true);
    });

    test('setting fields should notify listeners and change values', () async {
      var s = RamSettings();

      int i = 0;
      s.addListener(() {
        i++;
      });

      s.graphStepSize = TimeStep.lifetime;
      s.displayDataStart = DateTime.fromMillisecondsSinceEpoch(10000);
      s.displayDataEnd = DateTime.fromMillisecondsSinceEpoch(200000);
      s.followSystemDarkMode = false;
      s.darkMode = false;
      s.accentColor = createMaterialColor(0xFF942DA4);
      s.sysColor = createMaterialColor(0xFF942DA5);
      s.diaColor = createMaterialColor(0xFF942DA6);
      s.pulColor = createMaterialColor(0xFF942DA7);
      s.allowManualTimeInput = false;
      s.dateFormatString = 'yy:dd @ H:mm.ss';
      s.iconSize = 10;
      s.sysWarn = 314;
      s.diaWarn = 159;
      s.validateInputs = false;
      s.graphLineThickness = 5;
      s.animationSpeed = 100;
      s.confirmDeletion = true;
      s.graphTitlesCount = 2;
      s.csvFieldDelimiter = '|';
      s.csvTextDelimiter = '\'';
      s.exportAddableItems = ['timestampUnixMs'];
      s.exportItems = ['systolic', 'diastolic', 'pulse', 'notes', 'isoUTCTime'];
      s.exportCsvHeadline = false;
      s.exportDataRange = DateTimeRange(start: DateTime.fromMillisecondsSinceEpoch(20), end: DateTime.now());
      s.exportLimitDataRange = true;
      s.exportMimeType = MimeType.pdf;
      s.defaultExportDir = '/storage/emulated/0/Android/data/com.derdilla.bloodPressureApp/files/file.csv';
      s.exportAfterEveryEntry = true;

      expect(i, 29);
    });
  });
}
