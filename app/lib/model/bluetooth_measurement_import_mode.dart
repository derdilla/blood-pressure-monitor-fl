import 'package:blood_pressure_app/l10n/app_localizations.dart';

/// How measurements a bluetooth device returns are imported.
enum BluetoothMeasurementImportMode {
  /// Don't import automatically and let the user review measurements.
  disabled,
  /// Only import the most recent measurement.
  last,
  /// Import every measurement the device returned.
  all;

  bool get isAutomatic => this != BluetoothMeasurementImportMode.disabled;

  int get serialized => switch(this) {
    BluetoothMeasurementImportMode.disabled => 0,
    BluetoothMeasurementImportMode.last => 1,
    BluetoothMeasurementImportMode.all => 2,
  };

  static BluetoothMeasurementImportMode? deserialize(int? value) => switch (value) {
    0 => BluetoothMeasurementImportMode.disabled,
    1 => BluetoothMeasurementImportMode.last,
    2 => BluetoothMeasurementImportMode.all,
    _ => null,
  };

  String localize(AppLocalizations localizations) => switch(this) {
    BluetoothMeasurementImportMode.disabled => localizations.bluetoothImportModeDisabled,
    BluetoothMeasurementImportMode.last => localizations.bluetoothImportModeLast,
    BluetoothMeasurementImportMode.all => localizations.bluetoothImportModeAll,
  };
}
