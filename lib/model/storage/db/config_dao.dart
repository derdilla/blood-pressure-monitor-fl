import 'package:blood_pressure_app/model/storage/db/config_db.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:sqflite/sqflite.dart';

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
}