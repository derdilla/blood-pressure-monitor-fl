import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_service.dart';
import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';

/// UUID wrapper for BluetoothLowEnergy
final class BluetoothLowEnergyUUID extends BluetoothUuid<UUID> {
  /// Create a [BluetoothLowEnergyUUID] from a [UUID]
  BluetoothLowEnergyUUID(UUID uuid): super(uuid: uuid.toString(), source: uuid);

  /// Create a [BluetoothLowEnergyUUID] from a [String]
  factory BluetoothLowEnergyUUID.fromString(String uuid) => BluetoothLowEnergyUUID(UUID.fromString(uuid));
}

/// Wrapper class with generic interface for a [GATTService]
final class BluetoothLowEnergyService
    extends BluetoothService<GATTService, BluetoothLowEnergyCharacteristic> {

   /// Create a [BluetoothLowEnergyService] from a [GATTService]
  BluetoothLowEnergyService.fromSource(GATTService service):
    super(uuid: BluetoothLowEnergyUUID(service.uuid), source: service);

  @override
  List<BluetoothLowEnergyCharacteristic> get characteristics => source.characteristics.map(BluetoothLowEnergyCharacteristic.fromSource).toList();
}

/// Wrapper class with generic interface for a [GATTCharacteristic]
final class BluetoothLowEnergyCharacteristic extends BluetoothCharacteristic<GATTCharacteristic> {
  /// Create a [BluetoothLowEnergyCharacteristic] from the backend specific source
  BluetoothLowEnergyCharacteristic.fromSource(GATTCharacteristic source):
    super(uuid: BluetoothLowEnergyUUID(source.uuid), source: source);

  @override
  bool get canRead => source.properties.contains(GATTCharacteristicProperty.read);

  @override
  bool get canWrite => source.properties.contains(GATTCharacteristicProperty.write);

  @override
  bool get canWriteWithoutResponse => source.properties.contains(GATTCharacteristicProperty.writeWithoutResponse);

  @override
  bool get canNotify => source.properties.contains(GATTCharacteristicProperty.notify);

  @override
  bool get canIndicate => source.properties.contains(GATTCharacteristicProperty.indicate);
}
