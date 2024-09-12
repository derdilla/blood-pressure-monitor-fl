part of 'ble_manager.dart';

/// Bluetooth adapter state parser for the bluetooth_low_energy package
final class BluetoothLowEnergyStateParser extends BluetoothStateParser<BluetoothLowEnergyStateChangedEventArgs> {
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
