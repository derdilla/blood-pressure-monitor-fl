import 'package:blood_pressure_app/l10n/app_localizations.dart';

/// Different modes for the bluetooth input field.
enum BluetoothInputMode {
  /// No bluetooth input.
  disabled,
  /// The established bluetooth input.
  oldBluetoothInput,
  /// The new bluetooth input with bluetooth_low_energy backend.
  newBluetoothInputCrossPlatform;

  /// Create a [BluetoothInputMode.deserialize]able number.
  int get serialized => switch(this) {
    BluetoothInputMode.disabled => 0,
    BluetoothInputMode.oldBluetoothInput => 1,
    BluetoothInputMode.newBluetoothInputCrossPlatform => 3,
  };

  /// Try to create an object from [serialized] form.
  static BluetoothInputMode? deserialize(int? value) => switch (value) {
    0 => BluetoothInputMode.disabled,
    1 => BluetoothInputMode.oldBluetoothInput,
    3 => BluetoothInputMode.newBluetoothInputCrossPlatform,
    _ => null,
  };

  /// Determine the matching localization.
  String localize(AppLocalizations localizations) => switch(this) {
    BluetoothInputMode.disabled => localizations.disabled,
    BluetoothInputMode.oldBluetoothInput => localizations.oldBluetoothInput,
    BluetoothInputMode.newBluetoothInputCrossPlatform => localizations.newBluetoothInputCrossPlatform,
  };
}
