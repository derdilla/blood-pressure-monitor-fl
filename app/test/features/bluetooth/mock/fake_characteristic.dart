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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}