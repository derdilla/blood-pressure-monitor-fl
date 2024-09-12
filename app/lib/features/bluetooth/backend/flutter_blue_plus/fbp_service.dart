part of 'fbp_manager.dart';

/// UUID wrapper for FlutterBluePlus
final class FlutterBluePlusUUID extends BluetoothUUID<Guid> {
  /// Create a BluetoothUUID from a Guid
  FlutterBluePlusUUID(Guid uuid): super(uuid: uuid);
  /// Create a BluetoothUUID from a string
  FlutterBluePlusUUID.fromString(String uuid): super(uuid: Guid(uuid));
}

/// Wrapper class with generic interface for a fbp.BluetoothService
final class FlutterBluePlusService extends BluetoothService<fbp.BluetoothService, FlutterBluePlusCharacteristic> {
  /// constructor
  /// @see BluetoothService
  FlutterBluePlusService({ required super.uuid, required super.source });

  /// Create a FlutterBlueService from a fbp.BluetoothService
  factory FlutterBluePlusService.fromSource(fbp.BluetoothService service) {
    final uuid = FlutterBluePlusUUID(service.serviceUuid);
    return FlutterBluePlusService(uuid: uuid, source: service);
  }

  @override
  List<FlutterBluePlusCharacteristic> get characteristics => source.characteristics.map(FlutterBluePlusCharacteristic.fromSource).toList();
}

/// Wrapper class with generic interface for a fbp.BluetoothCharacteristic
final class FlutterBluePlusCharacteristic extends BluetoothCharacteristic<fbp.BluetoothCharacteristic> {
  /// Create a BluetoothCharacteristic from the backend specific source
  FlutterBluePlusCharacteristic.fromSource(fbp.BluetoothCharacteristic source): super(uuid: FlutterBluePlusUUID(source.serviceUuid), source: source);
  
  @override
  bool get canRead => source.properties.read;
  
  @override
  bool get canWrite => source.properties.write;
  
  @override
  bool get canWriteWithoutResponse => source.properties.writeWithoutResponse;
  
  @override
  bool get canNotify => source.properties.notify;
  
  @override
  bool get canIndicate => source.properties.indicate;
}
