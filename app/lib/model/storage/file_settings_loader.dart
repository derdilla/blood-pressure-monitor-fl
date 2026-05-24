import 'dart:collection';
import 'dart:io';

import 'package:archive/archive_io.dart';
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
///
/// If any errors occur or the object is not present, a default one will be
/// created. Changes in the object will save to the automatically.
///
/// Changes to the disk data will not propagate to the object.
class FileSettingsLoader {
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

    obj.addListener(() => f.writeAsStringSync(obj!.toJson()));
    f.writeAsStringSync(obj.toJson());
    _instances[fileName] = obj;
    return obj;
  }

  final _instances = <String, SettingsGroup>{};

  /// Contains values of every type for which a load... method was called.
  UnmodifiableListView<SettingsGroup> get initializedSettings => UnmodifiableListView(_instances.values);

  Future<CsvExportSettings> loadCsvExportSettings() async => _loadFile(
    'csv-export',
    CsvExportSettings.fromJson,
    CsvExportSettings.new,
  );

  Future<ExportColumnsManager> loadExportColumnsManager() async => _loadFile(
    'export-columns',
    ExportColumnsManager.fromJson,
    ExportColumnsManager.new,
  );

  Future<ExportSettings> loadExportSettings() async => _loadFile(
    'export',
    ExportSettings.fromJson,
    ExportSettings.new,
  );

  Future<IntervalStoreManager> loadIntervalStorageManager() async => _loadFile(
    'intervall-store',
    IntervalStoreManager.fromJson,
    IntervalStoreManager.new,
  );

  Future<PdfExportSettings> loadPdfExportSettings() async => _loadFile(
    'pdf-export',
    PdfExportSettings.fromJson,
    PdfExportSettings.new,
  );

  Future<ExcelExportSettings> loadXlsExportSettings() async => _loadFile(
    'xsl-export', // wrong spelling kept for compatability reasons
    ExcelExportSettings.fromJson,
    ExcelExportSettings.new,
  );

  Future<Settings> loadSettings() async => _loadFile(
    'general',
    Settings.fromJson,
    Settings.new,
  );

  Future<HealthConnectSettings> loadHealthConnectSettings() async => _loadFile(
    'health_connect',
    HealthConnectSettings.fromJson,
    HealthConnectSettings.new,
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
