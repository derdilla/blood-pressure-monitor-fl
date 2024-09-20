import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_state.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';

/// Bluetooth adapter state parser for the 'bluetooth_low_energy' package
final class BluetoothLowEnergyStateParser extends BluetoothAdapterStateParser<BluetoothLowEnergyStateChangedEventArgs> {
  @override
  BluetoothAdapterState parse(BluetoothLowEnergyStateChangedEventArgs rawState) => switch (rawState.state) {
    BluetoothLowEnergyState.unsupported => BluetoothAdapterState.unfeasible,
    // Bluetooth permissions should always be granted on normal android
    // devices. Users on non-standard android devices will know how to
    // enable them. If this is not the case there will be bug reports.
    BluetoothLowEnergyState.unauthorized => BluetoothAdapterState.unauthorized,
    BluetoothLowEnergyState.poweredOn => BluetoothAdapterState.ready,
    BluetoothLowEnergyState.poweredOff => BluetoothAdapterState.disabled,
    BluetoothLowEnergyState.unknown => BluetoothAdapterState.initial,
  };
}
