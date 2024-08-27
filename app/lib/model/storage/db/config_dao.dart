import 'package:blood_pressure_app/model/storage/db/config_db.dart';
import 'package:blood_pressure_app/model/storage/db/settings_loader.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:blood_pressure_app/model/storage/interval_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';

/// Class for loading data from the database.
///
/// The user of this class needs to pay attention to dispose all old instances
/// of objects created by the instance methods in order to ensure there are no
/// concurrent writes to the database. Having multiple instances will cause data
/// loss because states are not synced again after one changes.
///
/// The load... methods have to schedule a initial save to db in case an
/// migration / update of fields occurred.
@deprecated
class ConfigDao implements SettingsLoader {
  /// Create a serializer to initialize data from a database.
  ConfigDao(this._configDB);

  final ConfigDB _configDB;

  final Map<int, Settings> _settingsInstances = {};
  @override
  Future<Settings> loadSettings() async {
    if (_settingsInstances.containsKey(0)) return _settingsInstances[0]!;
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
    _settingsInstances[0] = settings;
    return settings;
  }

  final Map<int, ExportSettings> _exportSettingsInstances = {};
  @override
  Future<ExportSettings> loadExportSettings() async {
    if (_exportSettingsInstances.containsKey(0)) return _exportSettingsInstances[0]!;
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
    _exportSettingsInstances[0] = exportSettings;
    return exportSettings;
  }

  final Map<int, CsvExportSettings> _csvExportSettingsInstances = {};
  @override
  Future<CsvExportSettings> loadCsvExportSettings() async {
    if (_csvExportSettingsInstances.containsKey(0)) return _csvExportSettingsInstances[0]!;
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
    _csvExportSettingsInstances[0] = exportSettings;
    return exportSettings;
  }

  final Map<int, PdfExportSettings> _pdfExportSettingsInstances = {};
  @override
  Future<PdfExportSettings> loadPdfExportSettings() async {
    if (_pdfExportSettingsInstances.containsKey(0)) return _pdfExportSettingsInstances[0]!;
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
    _pdfExportSettingsInstances[0] = exportSettings;
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

  final Map<int, ExportColumnsManager> _exportColumnsManagerInstances = {};
  @override
  Future<ExportColumnsManager> loadExportColumnsManager() async {
    if (_exportColumnsManagerInstances.containsKey(0)) return _exportColumnsManagerInstances[0]!;
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
    _exportColumnsManagerInstances[0] = columnsManager;
    return columnsManager;
  }
}
