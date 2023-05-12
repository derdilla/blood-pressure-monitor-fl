import 'package:blood_pressure_app/model/settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('TimeStep', () {
    test('names should match to fields', () {
      expect(TimeStep.getName(TimeStep.day), 'day');
      expect(TimeStep.getName(TimeStep.month), 'month');
      expect(TimeStep.getName(TimeStep.year), 'year');
      expect(TimeStep.getName(TimeStep.lifetime), 'lifetime');
    });
  });

  group('Settings model',() {
    // setup db path
    databaseFactory = databaseFactoryFfi;

    test('should initialize', () async {
      expect(() async { await Settings.create(dbPath: '/tmp/setting_test/should_init'); }, returnsNormally);
    });
    test('fields defaults should be set after initialization', () async {
      var s = await Settings.create(dbPath: '/tmp/setting_test/should_default');
      expect(s.graphStepSize, TimeStep.day);
      expect(s.graphStart, DateTime.fromMillisecondsSinceEpoch(-1));
      expect(s.graphEnd, DateTime.fromMillisecondsSinceEpoch(-1));
      expect(s.followSystemDarkMode, true);
      expect(s.darkMode, true);
      expect(s.accentColor.value, 0xFF009688);
      expect(s.sysColor.value, 0xFF009688);
      expect(s.diaColor.value, 0xFF4CAF50);
      expect(s.pulColor.value, 0xFFF44336);
      expect(s.allowManualTimeInput, true);
      expect(s.dateFormatString, 'yy-MM-dd H:mm');
      expect(s.useExportCompatability, false);
    });

    test('setting fields should save changes', () async {
      var s = await Settings.create(dbPath: '/tmp/setting_test/should_save');

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
      s.graphStart = DateTime.fromMillisecondsSinceEpoch(10000);
      s.graphEnd = DateTime.fromMillisecondsSinceEpoch(200000);
      s.followSystemDarkMode = false;
      s.darkMode = false;
      s.accentColor = s.createMaterialColor(0xFF942DA4);
      s.sysColor = s.createMaterialColor(0xFF942DA5);
      s.diaColor = s.createMaterialColor(0xFF942DA6);
      s.pulColor = s.createMaterialColor(0xFF942DA7);
      s.allowManualTimeInput = false;
      s.dateFormatString = 'yy:dd @ H:mm.ss';
      s.useExportCompatability = true;


      expect(s.graphStart, DateTime.fromMillisecondsSinceEpoch(10000));
      expect(s.graphEnd, DateTime.fromMillisecondsSinceEpoch(200000));
      expect(s.followSystemDarkMode, false);
      expect(s.darkMode, false);
      expect(s.accentColor.value, 0xFF942DA4);
      expect(s.sysColor.value, 0xFF942DA5);
      expect(s.diaColor.value, 0xFF942DA6);
      expect(s.pulColor.value, 0xFF942DA7);
      expect(s.allowManualTimeInput, false);
      expect(s.useExportCompatability, true);
    });

    test('setting fields should notify listeners and change values', () async {
      var s = await Settings.create(dbPath: '/tmp/setting_test/should_notify');

      int i = 0;
      s.addListener(() {
        i++;
      });

      s.graphStepSize = TimeStep.lifetime;
      s.graphStart = DateTime.fromMillisecondsSinceEpoch(10000);
      s.graphEnd = DateTime.fromMillisecondsSinceEpoch(200000);
      s.followSystemDarkMode = false;
      s.darkMode = false;
      s.accentColor = s.createMaterialColor(0xFF942DA4);
      s.sysColor = s.createMaterialColor(0xFF942DA5);
      s.diaColor = s.createMaterialColor(0xFF942DA6);
      s.pulColor = s.createMaterialColor(0xFF942DA7);
      s.allowManualTimeInput = false;
      s.dateFormatString = 'yy:dd @ H:mm.ss';
      s.useExportCompatability = true;
      
      expect(i, 12);
    });

  });
}