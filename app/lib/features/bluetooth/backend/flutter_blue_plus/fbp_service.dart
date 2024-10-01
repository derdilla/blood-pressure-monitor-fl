import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:flutter_blue_plus/flutter_blue_plus.dart' show Guid;

/// UUID wrapper for FlutterBluePlus
final class FlutterBluePlusUUID extends BluetoothUuid<Guid> {
  /// Create a [FlutterBluePlusUUID] from a [Guid]
  FlutterBluePlusUUID(Guid uuid): super(uuid: uuid.str128, source: uuid);

  /// Create a [FlutterBluePlusUUID] from a [String]
  factory FlutterBluePlusUUID.fromString(String uuid) => FlutterBluePlusUUID(Guid(uuid));
}

/// [BluetoothService] implementation wrapping [fbp.BluetoothService]
final class FlutterBluePlusService extends BluetoothService<fbp.BluetoothService, FlutterBluePlusCharacteristic> {
  /// Create [BluetoothService] implementation wrapping [fbp.BluetoothService]
  FlutterBluePlusService({ required super.uuid, required super.source });

  /// Create a [FlutterBluePlusService] from a [fbp.BluetoothService]
  factory FlutterBluePlusService.fromSource(fbp.BluetoothService service) {
    final uuid = FlutterBluePlusUUID(service.serviceUuid);
    return FlutterBluePlusService(uuid: uuid, source: service);
  }

  @override
  List<FlutterBluePlusCharacteristic> get characteristics => source.characteristics
    .map(FlutterBluePlusCharacteristic.fromSource).toList();
}

/// Wrapper class with generic interface for a [fbp.BluetoothCharacteristic]
final class FlutterBluePlusCharacteristic extends BluetoothCharacteristic<fbp.BluetoothCharacteristic> {
  /// Initialize a [FlutterBluePlusCharacteristic] from the backend specific source
  FlutterBluePlusCharacteristic.fromSource(fbp.BluetoothCharacteristic source):
    super(uuid: FlutterBluePlusUUID(source.characteristicUuid), source: source);

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
