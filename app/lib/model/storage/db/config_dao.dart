import 'package:blood_pressure_app/model/storage/db/config_db.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:blood_pressure_app/model/storage/interval_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:sqflite/sqflite.dart';

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
class ConfigDao {
  /// Create a serializer to initialize data from a database.
  ConfigDao(this._configDB);

  final ConfigDB _configDB;

  final Map<int, Settings> _settingsInstances = {};
  /// Loads the profiles [Settings] object from the database.
  ///
  /// If any errors occur or the object is not present, a default one will be
  /// created. Changes in the object will save to the database automatically (a
  /// listener gets attached).
  ///
  /// Changes to the database will not propagate to the object.
  Future<Settings> loadSettings(int profileID) async {
    if (_settingsInstances.containsKey(profileID)) return _settingsInstances[profileID]!;
    final dbEntry = await _configDB.database.query(
        ConfigDB.settingsTable,
        columns: ['settings_json'],
        where: 'profile_id = ?',
        whereArgs: [profileID],
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
    await _updateSettings(profileID, settings);
    settings.addListener(() {
      _updateSettings(profileID, settings);
    });
    _settingsInstances[profileID] = settings;
    return settings;
  }

  /// Update settings for a profile in the database.
  ///
  /// Adds an entry if no settings where saved for this profile.
  Future<void> _updateSettings(int profileID, Settings settings) async {
    if (!_configDB.database.isOpen) return;
    await _configDB.database.insert(
      ConfigDB.settingsTable,
      {
        'profile_id': profileID,
        'settings_json': settings.toJson(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  final Map<int, ExportSettings> _exportSettingsInstances = {};
  /// Loads the profiles [ExportSettings] object from the database.
  ///
  /// If any errors occur or the object is not present, a default one will be created. Changes in the object
  /// will save to the database automatically (a listener gets attached).
  ///
  /// Changes to the database will not propagate to the object.
  Future<ExportSettings> loadExportSettings(int profileID) async {
    if (_exportSettingsInstances.containsKey(profileID)) return _exportSettingsInstances[profileID]!;
    final dbEntry = await _configDB.database.query(
        ConfigDB.exportSettingsTable,
        columns: ['json'],
        where: 'profile_id = ?',
        whereArgs: [profileID],
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
    _updateExportSettings(profileID, exportSettings);
    exportSettings.addListener(() {
      _updateExportSettings(profileID, exportSettings);
    });
    _exportSettingsInstances[profileID] = exportSettings;
    return exportSettings;
  }

  /// Update [ExportSettings] for a profile in the database.
  ///
  /// Adds an entry if necessary.
  Future<void> _updateExportSettings(int profileID, ExportSettings settings) async {
    if (!_configDB.database.isOpen) return;
    await _configDB.database.insert(
        ConfigDB.exportSettingsTable,
        {
          'profile_id': profileID,
          'json': settings.toJson(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  final Map<int, CsvExportSettings> _csvExportSettingsInstances = {};

  /// Loads the profiles [CsvExportSettings] object from the database.
  ///
  /// If any errors occur or the object is not present, a default one will be created. Changes in the object
  /// will save to the database automatically (a listener gets attached).
  ///
  /// Changes to the database will not propagate to the object.
  Future<CsvExportSettings> loadCsvExportSettings(int profileID) async {
    if (_csvExportSettingsInstances.containsKey(profileID)) return _csvExportSettingsInstances[profileID]!;
    final dbEntry = await _configDB.database.query(
        ConfigDB.exportCsvSettingsTable,
        columns: ['json'],
        where: 'profile_id = ?',
        whereArgs: [profileID],
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
    _updateCsvExportSettings(profileID, exportSettings);
    exportSettings.addListener(() {
      _updateCsvExportSettings(profileID, exportSettings);
    });
    _csvExportSettingsInstances[profileID] = exportSettings;
    return exportSettings;
  }

  /// Update [CsvExportSettings] for a profile in the database.
  ///
  /// Adds an entry if necessary.
  Future<void> _updateCsvExportSettings(int profileID, CsvExportSettings settings) async {
    if (!_configDB.database.isOpen) return;
    await _configDB.database.insert(
        ConfigDB.exportCsvSettingsTable,
        {
          'profile_id': profileID,
          'json': settings.toJson(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  final Map<int, PdfExportSettings> _pdfExportSettingsInstances = {};

  /// Loads the profiles [PdfExportSettings] object from the database.
  ///
  /// If any errors occur or the object is not present, a default one will be created. Changes in the object
  /// will save to the database automatically (a listener gets attached).
  ///
  /// Changes to the database will not propagate to the object.
  Future<PdfExportSettings> loadPdfExportSettings(int profileID) async {
    if (_pdfExportSettingsInstances.containsKey(profileID)) return _pdfExportSettingsInstances[profileID]!;
    final dbEntry = await _configDB.database.query(
        ConfigDB.exportPdfSettingsTable,
        columns: ['json'],
        where: 'profile_id = ?',
        whereArgs: [profileID],
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
    _updatePdfExportSettings(profileID, exportSettings);
    exportSettings.addListener(() {
      _updatePdfExportSettings(profileID, exportSettings);
    });
    _pdfExportSettingsInstances[profileID] = exportSettings;
    return exportSettings;
  }

  /// Update [PdfExportSettings] for a profile in the database.
  ///
  /// Adds an entry if necessary.
  Future<void> _updatePdfExportSettings(int profileID, PdfExportSettings settings) async {
    if (!_configDB.database.isOpen) return;
    await _configDB.database.insert(
        ConfigDB.exportPdfSettingsTable,
        {
          'profile_id': profileID,
          'json': settings.toJson(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  final Map<(int, int), IntervalStorage> _intervallStorageInstances = {};

  /// Loads a [IntervalStorage] object of a [profileID] from the database.
  ///
  /// The [storageID] allows for associating multiple intervalls with one profile.
  ///
  /// If any errors occur or the object is not present, a default one will be created. Changes in the object
  /// will save to the database automatically (a listener gets attached).
  ///
  /// Changes to the database will not propagate to the object.
  ///
  /// This should not be invoked directly in order to centralise [storageID] allocation. Currently this is done by
  /// the [IntervalStoreManager] class.
  Future<IntervalStorage> loadIntervalStorage(int profileID, int storageID) async {
    if (_intervallStorageInstances.containsKey((profileID, storageID))) return _intervallStorageInstances[(profileID, storageID)]!;
    final dbEntry = await _configDB.database.query(
        ConfigDB.selectedIntervalStorageTable,
        columns: ['stepSize', 'start', 'end'],
        where: 'profile_id = ? AND storage_id = ?',
        whereArgs: [profileID, storageID],
    );
    late final IntervalStorage intervallStorage;
    if (dbEntry.isEmpty) {
      intervallStorage = IntervalStorage();
    } else {
      assert(dbEntry.length == 1, 'Keys should ensure only one entry is possible.');
      intervallStorage = IntervalStorage.fromMap(dbEntry.first);
    }

    _updateIntervallStorage(profileID, storageID, intervallStorage);
    intervallStorage.addListener(() {
      _updateIntervallStorage(profileID, storageID, intervallStorage);
    });
    _intervallStorageInstances[(profileID, storageID)] = intervallStorage;
    return intervallStorage;
  }

  /// Update specific [IntervalStorage] for a profile in the database.
  ///
  /// Adds an entry if necessary.
  Future<void> _updateIntervallStorage(int profileID, int storageID, IntervalStorage intervallStorage) async {
    if (!_configDB.database.isOpen) return;
    final Map<String, dynamic> columnValueMap = {
      'profile_id': profileID,
      'storage_id': storageID,
    };
    columnValueMap.addAll(intervallStorage.toMap());
    await _configDB.database.insert(
        ConfigDB.selectedIntervalStorageTable,
        columnValueMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  final Map<int, ExportColumnsManager> _exportColumnsManagerInstances = {};

  /// Loads the profiles [ExportColumnsManager] object from the database.
  ///
  /// If any errors occur or the object is not present, a default one will be created. Changes in the object
  /// will save to the database automatically (a listener gets attached).
  ///
  /// Changes to the database will not propagate to the object.
  Future<ExportColumnsManager> loadExportColumnsManager(int profileID) async {
    if (_exportColumnsManagerInstances.containsKey(profileID)) return _exportColumnsManagerInstances[profileID]!;
    final dbEntry = await _configDB.database.query(
        ConfigDB.exportColumnsTable,
        columns: ['json'],
        where: 'profile_id = ?',
        whereArgs: [profileID],
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
    _updateExportColumnsManager(profileID, columnsManager);
    columnsManager.addListener(() {
      _updateExportColumnsManager(profileID, columnsManager);
    });
    _exportColumnsManagerInstances[profileID] = columnsManager;
    return columnsManager;
  }

  /// Update [ExportColumnsManager] for a profile in the database.
  ///
  /// Adds an entry if necessary.
  Future<void> _updateExportColumnsManager(int profileID, ExportColumnsManager manager) async {
    if (!_configDB.database.isOpen) return;
    await _configDB.database.insert(
        ConfigDB.exportColumnsTable,
        {
          'profile_id': profileID,
          'json': manager.toJson(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
