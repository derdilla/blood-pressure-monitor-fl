/// Persistently stored information that is not a measurement.
///
/// To store new information use one of the existing classes in the storage directory or in case there is no fitting
/// class, add a table to config_db and create a new class. For streamlined import it should be reexported here.
///
/// Steps for expanding a storage class:
/// - Add private variable with default value
/// - Add getter and setter, where setter calls `notifyListeners()`
/// - Add as nullable to constructor definition and if != null assign it to the private variable in the body
/// - Reset the value to default in a `reset` method
/// - Add parsable representation (string, boolean or integer) to the .toMap
/// - Parse it in the .fromMap factory method
/// - Make sure edge cases are handled in .fromMap (does not exist (update), not parsable (user))
/// - To verify everything was done correctly, tests should be expanded with the newly added fields (json_serialization_test.dart)
///
/// Keeping data modular reduces the amount of data saved to the database and makes the purpose of a setting more clear.
library;

export 'common_settings_interfaces.dart';
export 'db/config_dao.dart';
export 'export_csv_settings_store.dart';
export 'export_pdf_settings_store.dart';
export 'export_settings_store.dart';
export 'interval_store.dart';
export 'settings_store.dart';
export 'update_legacy_settings.dart';
