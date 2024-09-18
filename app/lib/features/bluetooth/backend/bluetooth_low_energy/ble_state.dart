import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_state.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';

/// Bluetooth adapter state parser for the 'bluetooth_low_energy' package
final class BluetoothLowEnergyStateParser extends BluetoothAdapterStateParser<BluetoothLowEnergyStateChangedEventArgs> {
  @override
  BluetoothAdapterState parse(BluetoothLowEnergyStateChangedEventArgs rawState) {
    switch (rawState.state) {
      case BluetoothLowEnergyState.unsupported:
        return BluetoothAdapterState.unfeasible;
      case BluetoothLowEnergyState.unauthorized:
        // Bluetooth permissions should always be granted on normal android
        // devices. Users on non-standard android devices will know how to
        // enable them. If this is not the case there will be bug reports.
        return BluetoothAdapterState.unauthorized;
      case BluetoothLowEnergyState.poweredOn:
        return BluetoothAdapterState.ready;
      case BluetoothLowEnergyState.poweredOff:
        return BluetoothAdapterState.disabled;
      case BluetoothLowEnergyState.unknown:
        return BluetoothAdapterState.initial;
    }
  }
}
