import 'package:blood_pressure_app/model/export_options.dart';
import 'package:blood_pressure_app/model/storage/db/config_db.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:sqflite/sqflite.dart';

/// Class for loading data from the database.
///
/// The user of this class needs to pay attention not to dispose all old instances of objects in order to ensure there
/// are no concurrent writes to the database. Having multiple instances will cause data loss.
class ConfigDao {
  ConfigDao(this._configDB);
  
  final ConfigDB _configDB;

  /// Loads the profiles [Settings] object from the database.
  ///
  /// If any errors occur or the object is not present, a default one will be created. Changes in the object
  /// will save to the database automatically (a listener gets attached).
  Future<Settings> loadSettings(int profileID) async {
    final dbEntry = await _configDB.database.query(
      ConfigDB.settingsTable,
      columns: ['settings_json'],
      where: 'profile_id = ?',
      whereArgs: [profileID]
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
    settings.addListener(() {
      _updateSettings(profileID, settings);
    });
    return settings;
  }

  /// Update settings for a profile in the database.
  ///
  /// Adds an entry if necessary.
  Future<void> _updateSettings(int profileID, Settings settings) async {
    await _configDB.database.insert(
      ConfigDB.settingsTable,
      {
        'profile_id': profileID,
        'settings_json': settings.toJson()
      },
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  /// Loads the profiles [ExportSettings] object from the database.
  ///
  /// If any errors occur or the object is not present, a default one will be created. Changes in the object
  /// will save to the database automatically (a listener gets attached).
  Future<ExportSettings> loadExportSettings(int profileID) async {
    final dbEntry = await _configDB.database.query(
        ConfigDB.exportSettingsTable,
        columns: ['json'],
        where: 'profile_id = ?',
        whereArgs: [profileID]
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
    exportSettings.addListener(() {
      _updateExportSettings(profileID, exportSettings);
    });
    return exportSettings;
  }

  /// Update [ExportSettings] for a profile in the database.
  ///
  /// Adds an entry if necessary.
  Future<void> _updateExportSettings(int profileID, ExportSettings settings) async {
    await _configDB.database.insert(
        ConfigDB.exportSettingsTable,
        {
          'profile_id': profileID,
          'json': settings.toJson()
        },
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  /// Loads the profiles [CsvExportSettings] object from the database.
  ///
  /// If any errors occur or the object is not present, a default one will be created. Changes in the object
  /// will save to the database automatically (a listener gets attached).
  Future<CsvExportSettings> loadCsvExportSettings(int profileID) async {
    final dbEntry = await _configDB.database.query(
        ConfigDB.exportCsvSettingsTable,
        columns: ['json'],
        where: 'profile_id = ?',
        whereArgs: [profileID]
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
    exportSettings.addListener(() {
      _updateCsvExportSettings(profileID, exportSettings);
    });
    return exportSettings;
  }

  /// Update [CsvExportSettings] for a profile in the database.
  ///
  /// Adds an entry if necessary.
  Future<void> _updateCsvExportSettings(int profileID, CsvExportSettings settings) async {
    await _configDB.database.insert(
        ConfigDB.exportCsvSettingsTable,
        {
          'profile_id': profileID,
          'json': settings.toJson()
        },
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  /// Loads the profiles [PdfExportSettings] object from the database.
  ///
  /// If any errors occur or the object is not present, a default one will be created. Changes in the object
  /// will save to the database automatically (a listener gets attached).
  Future<PdfExportSettings> loadPdfExportSettings(int profileID) async {
    final dbEntry = await _configDB.database.query(
        ConfigDB.exportPdfSettingsTable,
        columns: ['json'],
        where: 'profile_id = ?',
        whereArgs: [profileID]
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
    exportSettings.addListener(() {
      _updatePdfExportSettings(profileID, exportSettings);
    });
    return exportSettings;
  }

  Future<IntervallStorage> loadIntervallStorage(int profileID, int storageID) async {
    final dbEntry = await _configDB.database.query(
        ConfigDB.selectedIntervallStorageTable,
        columns: ['stepSize', 'start', 'end'],
        where: 'profile_id = ? AND storage_id = ?',
        whereArgs: [profileID, storageID]
    );
    late final IntervallStorage intervallStorage;
    if (dbEntry.isEmpty) {
      intervallStorage = IntervallStorage();
    } else {
      assert(dbEntry.length == 1, 'Keys should ensure only one entry is possible.');
      intervallStorage = IntervallStorage.fromMap(dbEntry.first);
    }

    intervallStorage.addListener(() {
      _updateIntervallStorage(profileID, storageID, intervallStorage);
    });
    return intervallStorage;
  }

  /// Update specific [IntervallStorage] for a profile in the database.
  ///
  /// Adds an entry if necessary.
  Future<void> _updateIntervallStorage(int profileID, int storageID, IntervallStorage intervallStorage) async {
    final Map<String, dynamic> columnValueMap = {
      'profile_id': profileID,
      'storage_id': storageID,
    };
    columnValueMap.addAll(intervallStorage.toMap());
    await _configDB.database.insert(
        ConfigDB.selectedIntervallStorageTable,
        columnValueMap,
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  /// Update [PdfExportSettings] for a profile in the database.
  ///
  /// Adds an entry if necessary.
  Future<void> _updatePdfExportSettings(int profileID, PdfExportSettings settings) async {
    await _configDB.database.insert(
        ConfigDB.exportPdfSettingsTable,
        {
          'profile_id': profileID,
          'json': settings.toJson()
        },
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  // TODO: test if custom export columns still work
  Future<List<ExportColumn>> loadExportColumns() async {
    final existingDbEntries = await _configDB.database.query(
      ConfigDB.exportStringsTable,
      columns: ['internalColumnName', 'columnTitle', 'formatPattern']
    );
    return [
      for (final e in existingDbEntries)
        ExportColumn(
            internalName: e['internalColumnName'].toString(),
            columnTitle: e['columnTitle'].toString(),
            formatPattern: e['formatPattern'].toString()
        ),
    ];
  }

  Future<void> updateExportColumn(ExportColumn exportColumn) async {
    await _configDB.database.insert(
        ConfigDB.exportStringsTable,
        {
          'internalColumnName': exportColumn.internalName,
          'columnTitle': exportColumn.columnTitle,
          'formatPattern': exportColumn.formatPattern
        },
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<void> deleteExportColumn(String internalName) async {
    await _configDB.database.delete('exportStrings', where: 'internalColumnName = ?', whereArgs: [internalName]);
  }


  // TODO: ExportConfigurationModel
}