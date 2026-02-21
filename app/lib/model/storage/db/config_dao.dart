import 'package:blood_pressure_app/model/storage/db/config_db.dart';
import 'package:blood_pressure_app/model/storage/db/settings_loader.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_xsl_settings_store.dart';
import 'package:blood_pressure_app/model/storage/interval_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';

/// Class for loading data from the database.
///
/// The user of this class needs to pay attention to dispose all old instance
/// of objects created by the instance methods in order to ensure there are no
/// concurrent writes to the database. Having multiple instance will cause data
/// loss because states are not synced again after one changes.
///
/// The load... methods have to schedule a initial save to db in case an
/// migration / update of fields occurred.
@deprecated
class ConfigDao implements SettingsLoader {
  /// Create a serializer to initialize data from a database.
  ConfigDao(this._configDB);

  final ConfigDB _configDB;

  Settings? _settingsInstance;
  @override
  Future<Settings> loadSettings() async {
    if (_settingsInstance != null) return _settingsInstance!;
    final dbEntry = await _configDB.database.query(
        ConfigDB.settingsTable,
        columns: ['settings_json'],
        where: 'profile_id = ?',
        whereArgs: [0],
    );

    late final Settings settings;
    if (dbEntry.isEmpty) {
      settings = Settings();
    } else {
      assert(dbEntry.length == 1, 'The profile_id should be unique.');
      final settingsJson = dbEntry.first['settings_json'];
      if (settingsJson == null) {
        settings = Settings();
      } else {
        settings = Settings.fromJson(settingsJson.toString());
      }
    }
    _settingsInstance = settings;
    return settings;
  }

  ExportSettings? _exportSettingsInstance;
  @override
  Future<ExportSettings> loadExportSettings() async {
    if (_exportSettingsInstance != null) return _exportSettingsInstance!;
    final dbEntry = await _configDB.database.query(
        ConfigDB.exportSettingsTable,
        columns: ['json'],
        where: 'profile_id = ?',
        whereArgs: [0],
    );

    late final ExportSettings exportSettings;
    if (dbEntry.isEmpty) {
      exportSettings = ExportSettings();
    } else {
      assert(dbEntry.length == 1, 'The profile_id should be unique.');
      final settingsJson = dbEntry.first['json'];
      if (settingsJson == null) {
        exportSettings = ExportSettings();
      } else {
        exportSettings = ExportSettings.fromJson(settingsJson.toString());
      }
    }
    _exportSettingsInstance = exportSettings;
    return exportSettings;
  }

  CsvExportSettings? _csvExportSettingsInstance;
  @override
  Future<CsvExportSettings> loadCsvExportSettings() async {
    if (_csvExportSettingsInstance != null) return _csvExportSettingsInstance!;
    final dbEntry = await _configDB.database.query(
        ConfigDB.exportCsvSettingsTable,
        columns: ['json'],
        where: 'profile_id = ?',
        whereArgs: [0],
    );

    late final CsvExportSettings exportSettings;
    if (dbEntry.isEmpty) {
      exportSettings = CsvExportSettings();
    } else {
      assert(dbEntry.length == 1, 'The profile_id should be unique.');
      final settingsJson = dbEntry.first['json'];
      if (settingsJson == null) {
        exportSettings = CsvExportSettings();
      } else {
        exportSettings = CsvExportSettings.fromJson(settingsJson.toString());
      }
    }
    _csvExportSettingsInstance = exportSettings;
    return exportSettings;
  }

  PdfExportSettings? _pdfExportSettingsInstance;
  @override
  Future<PdfExportSettings> loadPdfExportSettings() async {
    if (_pdfExportSettingsInstance != null) return _pdfExportSettingsInstance!;
    final dbEntry = await _configDB.database.query(
        ConfigDB.exportPdfSettingsTable,
        columns: ['json'],
        where: 'profile_id = ?',
        whereArgs: [0],
    );

    late final PdfExportSettings exportSettings;
    if (dbEntry.isEmpty) {
      exportSettings = PdfExportSettings();
    } else {
      assert(dbEntry.length == 1, 'The profile_id should be unique.');
      final settingsJson = dbEntry.first['json'];
      if (settingsJson == null) {
        exportSettings = PdfExportSettings();
      } else {
        exportSettings = PdfExportSettings.fromJson(settingsJson.toString());
      }
    }
    _pdfExportSettingsInstance = exportSettings;
    return exportSettings;
  }

  IntervalStoreManager? _intervallStorageInstance;
  @override
  Future<IntervalStoreManager> loadIntervalStorageManager() async {
    _intervallStorageInstance ??= IntervalStoreManager(
      await _loadStore(0),
      await _loadStore(1),
      await _loadStore(2),
    );
    return _intervallStorageInstance!;
  }

  Future<IntervalStorage> _loadStore(int storageID) async {
    final dbEntry = await _configDB.database.query(
      ConfigDB.selectedIntervalStorageTable,
      columns: ['stepSize', 'start', 'end'],
      where: 'profile_id = ? AND storage_id = ?',
      whereArgs: [0, storageID],
    );
    late final IntervalStorage intervallStorage;
    if (dbEntry.isEmpty) {
      intervallStorage = IntervalStorage();
    } else {
      assert(dbEntry.length == 1, 'Keys should ensure only one entry is possible.');
      intervallStorage = IntervalStorage.fromMap(dbEntry.first);
    }
    return intervallStorage;
  }

  ExportColumnsManager? _exportColumnsManagerInstance;
  @override
  Future<ExportColumnsManager> loadExportColumnsManager() async {
    if (_exportColumnsManagerInstance != null) return _exportColumnsManagerInstance!;
    final dbEntry = await _configDB.database.query(
        ConfigDB.exportColumnsTable,
        columns: ['json'],
        where: 'profile_id = ?',
        whereArgs: [0],
    );

    late final ExportColumnsManager columnsManager;
    if (dbEntry.isEmpty) {
      columnsManager = ExportColumnsManager();
    } else {
      assert(dbEntry.length == 1, 'The profile_id should be unique.');
      final json = dbEntry.first['json'];
      if (json == null) {
        columnsManager = ExportColumnsManager();
      } else {
        columnsManager = ExportColumnsManager.fromJson(json.toString());
      }
    }
    _exportColumnsManagerInstance = columnsManager;
    return columnsManager;
  }

  @override
  Future<ExcelExportSettings> loadXslExportSettings() async =>
      ExcelExportSettings(); // This was added after file settings
}
