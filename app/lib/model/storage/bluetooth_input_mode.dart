import 'package:blood_pressure_app/l10n/app_localizations.dart';

/// Different modes for the bluetooth input field.
enum BluetoothInputMode {
  /// No bluetooth input.
  disabled,
  /// The new bluetooth input with bluetooth_low_energy backend.
  newBluetoothInputCrossPlatform;

  /// Turn object into [deserialize]able number.
  int serialize() => switch(this) {
    BluetoothInputMode.disabled => 0,
    BluetoothInputMode.newBluetoothInputCrossPlatform => 3,
  };

  /// Try to create an object from [serialize]d form.
  static BluetoothInputMode? deserialize(int? value) => switch (value) {
    0 => BluetoothInputMode.disabled,
    1 | 2 | 3 => BluetoothInputMode.newBluetoothInputCrossPlatform,
    _ => null,
  };

  /// Determine the matching localization.
  String localize(AppLocalizations localizations) => switch(this) {
    BluetoothInputMode.disabled => localizations.disabled,
    // BluetoothInputMode.oldBluetoothInput => localizations.oldBluetoothInput,
    // BluetoothInputMode.newBluetoothInputOldLib => localizations.newBluetoothInputOldLib,
    BluetoothInputMode.newBluetoothInputCrossPlatform => localizations.oldBluetoothInput,
  };
}
