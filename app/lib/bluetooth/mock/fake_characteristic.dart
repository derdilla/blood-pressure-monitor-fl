import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class FakeBleBpCharacteristic implements BluetoothCharacteristic {
  final StreamController<List<int>> _valueReceivedController = StreamController.broadcast();

  @override
  Guid get characteristicUuid => Guid('2A35');
  @override
  Guid get uuid => characteristicUuid;

  @override
  Stream<List<int>> get onValueReceived => _valueReceivedController.stream;

  @override
  Future<bool> setNotifyValue(bool notify, {int timeout = 15, bool forceIndications = false}) async{
    if (notify) {
      _valueReceivedController.add([22, 124, 0, 86, 0, 97, 0, 232, 7, 6, 15, 17, 17, 27, 51, 0, 0, 0]);
    }
    return true;
  }

  @override
  // TODO: implement descriptors
  List<BluetoothDescriptor> get descriptors => throw UnimplementedError();

  @override
  // TODO: implement device
  BluetoothDevice get device => throw UnimplementedError();

  @override
  // TODO: implement deviceId
  DeviceIdentifier get deviceId => throw UnimplementedError();

  @override
  // TODO: implement isNotifying
  bool get isNotifying => throw UnimplementedError();

  @override
  // TODO: implement lastValue
  List<int> get lastValue => throw UnimplementedError();

  @override
  // TODO: implement lastValueStream
  Stream<List<int>> get lastValueStream => throw UnimplementedError();

  @override
  // TODO: implement onValueChangedStream
  Stream<List<int>> get onValueChangedStream => throw UnimplementedError();

  @override
  // TODO: implement properties
  CharacteristicProperties get properties => throw UnimplementedError();

  @override
  Future<List<int>> read({int timeout = 15}) {
    // TODO: implement read
    throw UnimplementedError();
  }

  @override
  // TODO: implement remoteId
  DeviceIdentifier get remoteId => throw UnimplementedError();

  @override
  // TODO: implement secondaryServiceUuid
  Guid? get secondaryServiceUuid => throw UnimplementedError();

  @override
  // TODO: implement serviceUuid
  Guid get serviceUuid => throw UnimplementedError();

  @override
  // TODO: implement value
  Stream<List<int>> get value => throw UnimplementedError();

  @override
  Future<void> write(List<int> value, {bool withoutResponse = false, bool allowLongWrite = false, int timeout = 15}) {
    // TODO: implement write
    throw UnimplementedError();
  }

}