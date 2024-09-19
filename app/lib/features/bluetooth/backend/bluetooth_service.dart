
import 'package:collection/collection.dart';

/// Generic BluetoothUuid representation
abstract class BluetoothUuid<BackendUuid> {
  /// constructor
  BluetoothUuid({ required BackendUuid uuid}) {
    _uuid = uuid;
  }

  /// Create a BluetoothUuid from a string
  BluetoothUuid.fromString(String uuid);

  late BackendUuid _uuid;

  /// The backend specific uuid
  BackendUuid get uuid => _uuid;

  @override
  String toString() => _uuid.toString();

  @override
  bool operator == (Object other) {
    if (other is BluetoothUuid) {
      return toString() == other.toString();
    }

    if (other is BluetoothService) {
      return toString() == other.uuid.toString();
    }

    if (other is BluetoothCharacteristic) {
      return toString() == other.uuid.toString();
    }

    return false;
  }

  @override
  int get hashCode => super.hashCode * 17;
}

/// Generic BluetoothService representation
abstract class BluetoothService<BackendService, BC extends BluetoothCharacteristic> {
  /// Initialize bluetooth service wrapper class
  BluetoothService({ required this.uuid, required this.source });

  /// UUID of the service
  final BluetoothUuid uuid;
  /// Backend source for the service
  final BackendService source;

  /// Get all characteristics for this service
  List<BC> get characteristics;

  /// Returns the characteristic with requested [uuid], returns null if
  /// requested [uuid] was not found
  Future<BC?> getCharacteristicByUuid(BluetoothUuid uuid) async => characteristics.firstWhereOrNull((service) => service.uuid == uuid);

  @override
  String toString() => 'BluetoothService{uuid: $uuid, source: $source}';

  @override
  bool operator == (Object other) {
    if (other is BluetoothService) {
      return toString() == other.toString();
    }

    return false;
  }

  @override
  int get hashCode => super.hashCode * 17;
}

/// Characteristic representation
abstract class BluetoothCharacteristic<BackendCharacteristic> {
  /// Initialize bluetooth characteristic wrapper class
  BluetoothCharacteristic({ required this.uuid, required this.source });

  /// UUID of the characteristic
  final BluetoothUuid uuid;
  /// Backend source for the characteristic
  final BackendCharacteristic source;

  /// Whether the characteristic can be read
  bool get canRead;

  /// Whether the characteristic can be written to
  bool get canWrite;

  /// Whether the characteristic can be written to without a response
  bool get canWriteWithoutResponse;

  /// Whether the characteristic permits notifications for it's value, without a response to indicate receipt of the notification.
  bool get canNotify;

  /// Whether the characteristic permits notifications for it's value, with a response to indicate receipt of the notification
  bool get canIndicate;

  @override
  String toString() => 'BluetoothCharacteristic{uuid: $uuid, source: $source, '
    'canRead: $canRead, canWrite: $canWrite, canWriteWithoutResponse: $canWriteWithoutResponse, '
    'canNotify: $canNotify, canIndicate: $canIndicate}';

  @override
  bool operator == (Object other) {
    if (other is BluetoothCharacteristic) {
      return toString() == other.toString();
    }

    return false;
  }

  @override
  int get hashCode => super.hashCode * 17;
}
