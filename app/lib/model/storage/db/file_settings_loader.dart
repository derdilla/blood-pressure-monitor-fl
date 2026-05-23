import 'dart:collection';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:blood_pressure_app/model/storage/db/settings_loader.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings.dart';
import 'package:blood_pressure_app/model/storage/export_settings.dart';
import 'package:blood_pressure_app/model/storage/export_xls_settings.dart';
import 'package:blood_pressure_app/model/storage/health_connect_settings.dart';
import 'package:blood_pressure_app/model/storage/interval_store_manager.dart';
import 'package:blood_pressure_app/model/storage/settings.dart';
import 'package:path/path.dart';
import 'package:settings_annotation/settings_annotation.dart';
import 'package:sqflite/sqflite.dart';

/// Store settings in a directory format on disk.
class FileSettingsLoader implements SettingsLoader {
  FileSettingsLoader._create(this._path);

  /// Creates setting loader from relative directory [path] or the default
  /// settings path.
  static Future<FileSettingsLoader> load([String? path]) async {
    path ??= join(await getDatabasesPath(), 'settings');
    Directory(path).createSync(recursive: true);
    return FileSettingsLoader._create(path);
  }

  final String _path;

  /// Instantiates a settings file relative to [_path] and writes changes.
  ///
  /// If the is read successfully [build] is called else [createNew] is called.
  T _loadFile<T extends SettingsGroup>(
    String fileName,
    T Function(String) build,
    T Function() createNew,
    String Function(T) serialize,
  ) {
    if (_instances.containsKey(fileName)) return _instances[fileName] as T;
    final f = File(join(_path, fileName));
    T? obj;
    try {
      obj = build(f.readAsStringSync());
    } on FileSystemException {
      // obj stays null
    }
    obj ??= createNew();

    obj.addListener(() => f.writeAsStringSync(serialize(obj!)));
    f.writeAsStringSync(serialize(obj));
    _instances[fileName] = obj;
    return obj;
  }

  final _instances = <String, SettingsGroup>{};

  UnmodifiableListView<SettingsGroup> get initializedSettings => UnmodifiableListView(_instances.values);

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
    IntervalStoreManager.fromJson,
    IntervalStoreManager.new,
    (e) => e.toJson(),
  );

  @override
  Future<PdfExportSettings> loadPdfExportSettings() async => _loadFile(
    'pdf-export',
    PdfExportSettings.fromJson,
    PdfExportSettings.new,
    (e) => e.toJson(),
  );

  @override
  Future<ExcelExportSettings> loadXlsExportSettings() async => _loadFile(
    'xsl-export', // wrong spelling kept for compatability reasons
    ExcelExportSettings.fromJson,
    ExcelExportSettings.new,
    (e) => e.toJson(),
  );

  @override
  Future<Settings> loadSettings() async => _loadFile(
    'general',
    Settings.fromJson,
    Settings.new,
    (e) => e.toJson(),
  );

  @override
  Future<HealthConnectSettings> loadHealthConnectSettings() async => _loadFile(
    'health_connect',
    HealthConnectSettings.fromJson,
    HealthConnectSettings.new,
    (e) => e.toJson(),
  );

  /// Attempt to backup all stored data to archive.
  Archive? createArchive() {
    try {
      final archive = Archive();
      _backupFile(archive, 'general');
      _backupFile(archive, 'export');
      _backupFile(archive, 'csv-export');
      _backupFile(archive, 'pdf-export');
      _backupFile(archive, 'export-columns');
      _backupFile(archive, 'intervall-store');
      return archive;
    } on FileSystemException {
      return null;
    }
  }

  void _backupFile(Archive archive, String fileName) {
    final data = File(join(_path, fileName)).readAsStringSync();
    archive.addFile(ArchiveFile.string(fileName, data));
  }
}
