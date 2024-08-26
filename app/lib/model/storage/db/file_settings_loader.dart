import 'dart:convert';
import 'dart:io';

import 'package:blood_pressure_app/model/storage/db/settings_loader.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:blood_pressure_app/model/storage/interval_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Store settings in a directory format on disk.
class FileSettingsLoader implements SettingsLoader {
  FileSettingsLoader._create(this._path);

  /// Creates setting loader from relative directory [path].
  static Future<FileSettingsLoader> load([String path = 'settings']) async {
    path = join(await getDatabasesPath(), path);
    Directory(path).createSync();
    return FileSettingsLoader._create(path);
  }

  final String _path;

  /// Instantiates a settings file relative to [_path] and writes changes.
  ///
  /// If the is read successfully [build] is called else [createNew] is called.
  T _loadFile<T extends ChangeNotifier>(
    String fileName,
    T Function(String) build,
    T Function() createNew,
    String Function(T) serialize,
  ) {
    final f = File(join(_path, fileName));
    T? obj;
    try {
      obj = build(f.readAsStringSync());
    } on FileSystemException {}
    obj ??= createNew();

    obj.addListener(() => f.writeAsStringSync(serialize(obj!)));
    return obj;
  }

  @override
  Future<CsvExportSettings> loadCsvExportSettings() async => _loadFile(
    'csv-export',
    CsvExportSettings.fromJson,
    CsvExportSettings.new,
    (e) => e.toJson(),
  );

  @override
  Future<ExportColumnsManager> loadExportColumnsManager() async => _loadFile(
    'export-columns',
    ExportColumnsManager.fromJson,
    ExportColumnsManager.new,
    (e) => e.toJson(),
  );

  @override
  Future<ExportSettings> loadExportSettings() async => _loadFile(
    'export',
    ExportSettings.fromJson,
    ExportSettings.new,
        (e) => e.toJson(),
  );

  @override
  Future<IntervalStoreManager> loadIntervalStorageManager() async => _loadFile(
    'intervall-store',
    (String jsonStr) {
      final json = jsonDecode(jsonStr);
      if (json is Map<String, String?>) {
        return IntervalStoreManager(
          json['main'] == null ? IntervalStorage() : IntervalStorage.fromJson(json['main']!),
          json['export'] == null ? IntervalStorage() : IntervalStorage.fromJson(json['export']!),
          json['stats'] == null ? IntervalStorage() : IntervalStorage.fromJson(json['stats']!),
        );
      }
      return IntervalStoreManager(IntervalStorage(), IntervalStorage(), IntervalStorage());
    },
    () => IntervalStoreManager(IntervalStorage(), IntervalStorage(), IntervalStorage()),
    (e) => jsonEncode({
      'main': e.mainPage.toJson(),
      'export': e.exportPage.toJson(),
      'stats': e.statsPage.toJson(),
    }),
  );

  @override
  Future<PdfExportSettings> loadPdfExportSettings() async => _loadFile(
    'pdf-export',
    PdfExportSettings.fromJson,
    PdfExportSettings.new,
        (e) => e.toJson(),
  );

  @override
  Future<Settings> loadSettings() async => _loadFile(
    'general',
    Settings.fromJson,
    Settings.new,
    (e) => e.toJson(),
  );
}
