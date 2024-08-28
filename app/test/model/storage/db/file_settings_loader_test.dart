import 'dart:convert';
import 'dart:io';

import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/storage/db/file_settings_loader.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:blood_pressure_app/model/storage/interval_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('constructs new objects', () async {
    await _loader((loader) async {
      await expectLater(loader.loadSettings, returnsNormally);
      await expectLater(loader.loadExportSettings, returnsNormally);
      await expectLater(loader.loadCsvExportSettings, returnsNormally);
      await expectLater(loader.loadPdfExportSettings, returnsNormally);
      await expectLater(loader.loadIntervalStorageManager, returnsNormally);
      await expectLater(loader.loadExportColumnsManager, returnsNormally);
    });

  });

  test('persists changes', () async {
    await _loader((loader1) async {
      final loader2 = await FileSettingsLoader.load('tmp');

      final settings1 = await loader1.loadSettings();
      settings1.sysColor = Colors.blueGrey;
      final settings2 = await loader2.loadSettings();
      expect(settings2.sysColor.value, settings1.sysColor.value);

      final exportSettings1 = await loader1.loadExportSettings();
      exportSettings1.exportFormat = ExportFormat.db;
      final exportSettings2 = await loader2.loadExportSettings();
      expect(exportSettings2.exportFormat, exportSettings1.exportFormat);

      final csvExportSettings1 = await loader1.loadCsvExportSettings();
      csvExportSettings1.fieldDelimiter = 'asdsf.",';
      final csvExportSettings2 = await loader2.loadCsvExportSettings();
      expect(csvExportSettings2.fieldDelimiter, csvExportSettings1.fieldDelimiter);

      final pdfExportSettings1 = await loader1.loadPdfExportSettings();
      pdfExportSettings1.cellHeight = 3.1415926;
      final pdfExportSettings2 = await loader2.loadPdfExportSettings();
      expect(pdfExportSettings2.cellHeight, pdfExportSettings1.cellHeight);

      final intervalStorageManager1 = await loader1.loadIntervalStorageManager();
      intervalStorageManager1.mainPage.changeStepSize(TimeStep.lifetime);
      final intervalStorageManager2 = await loader2.loadIntervalStorageManager();
      expect(intervalStorageManager2.mainPage.stepSize, intervalStorageManager1.mainPage.stepSize);

      final exportColumnsManager1 = await loader1.loadExportColumnsManager();
      exportColumnsManager1.addOrUpdate(TimeColumn('tsttime', 'tst-YYYY'));
      final exportColumnsManager2 = await loader2.loadExportColumnsManager();
      expect(exportColumnsManager2.userColumns.keys, exportColumnsManager1.userColumns.keys);
    });
  });
}

Future<void> _loader(void Function(FileSettingsLoader) body) async {
  final files = {};
  return IOOverrides.runZoned(
    () async => body(await FileSettingsLoader.load('tmp')),
    createDirectory: (path) => _MockDir(),
    createFile: (path) {
      if (files[path] == null) files[path] = _MockFile();
      return files[path];
    },
  );
}

class _MockDir implements Directory {
  bool _exists = false;

  @override
  void createSync({bool recursive = false}) => _exists = true;

  @override
  Future<bool> exists() async => _exists;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockFile implements File {
  String? _content;

  @override
  String readAsStringSync({Encoding encoding = utf8}) {
    if (_content == null) throw FileSystemException();
    return _content!;
  }

  @override
  void writeAsStringSync(String contents, {
    FileMode mode = FileMode.write,
    Encoding encoding = utf8,
    bool flush = false,
  }) {
    _content = contents;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
