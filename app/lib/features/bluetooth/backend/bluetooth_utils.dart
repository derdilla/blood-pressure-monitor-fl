
import 'dart:async';

import 'package:blood_pressure_app/features/bluetooth/backend/bluetooth_state.dart';
import 'package:blood_pressure_app/logging.dart';

/// Generic stream data parser base class
abstract class StreamDataParser<StreamData, ParsedData> {
  /// Method to be implemented by backend that converts the raw bluetooth adapter state to our BluetoothState
  ParsedData parse(StreamData rawState);
}

/// Generic stream data parser base class that caches the last known state returned by the stream
abstract class StreamDataParserCached<StreamData, ParsedData> extends StreamDataParser<StreamData, ParsedData> {
  /// Initial state when it's unknown, f.e. when stream didn't return any data yet
  ParsedData get initialState;
  ParsedData? _lastKnownState;

  /// The last known adapter state
  ParsedData get lastKnownState => _lastKnownState ?? initialState;

  /// Internal method to cache the last adapter state value, backends should only implement parse not this method
  ParsedData parseAndCache(StreamData rawState) {
    _lastKnownState = parse(rawState);
    return lastKnownState;
  }
}

/// Transforms the backend's bluetooth adapter state stream to emit [BluetoothAdapterState]'s
///
/// Can normally be used directly, backends should only inject a customized BluetoothStateParser
class StreamDataParserTransformer<StreamData, ParsedData, SD extends StreamDataParser<StreamData, ParsedData>>
  extends StreamDataTransformer<StreamData, ParsedData> {
  /// Create a BluetoothAdapterStateStreamTransformer
  ///
  /// [stateParser] The BluetoothStateParser that provides the backend logic to convert BackendState to BluetoothAdapterState
  StreamDataParserTransformer({ required SD stateParser, super.sync, super.cancelOnError }) {
    _stateParser = stateParser;
  }

  late SD _stateParser;

  @override
  void onData(StreamData streamData) {
    late ParsedData data;
    if (_stateParser is StreamDataParserCached) {
      data = (_stateParser as StreamDataParserCached).parseAndCache(streamData);
    } else {
      data = _stateParser.parse(streamData);
    }

    sendData(data);
  }
}


/// Generic stream transformer util that should support cancelling & pausing etc
///
/// Implementations should only need to worry about transforming the data by overriding
/// the onData method and sending the transformed data using sendData
///
/// TODO: move outside bluetooth logic
abstract class StreamDataTransformer<S,T> with TypeLogger implements StreamTransformer<S,T> {
  /// Create a BluetoothStreamTransformer
  ///
  /// - [sync] Passed to [StreamController]
  /// - [cancelOnError] Passed to [Stream]
  StreamDataTransformer({ bool sync = false, bool cancelOnError = false }) {
    _cancelOnError = cancelOnError;

    _controller = StreamController<T>(
      onListen: _onListen,
      onCancel: _onCancel,
      onPause: () => _subscription?.pause(),
      onResume: () => _subscription?.resume(),
      sync: sync,
    );
  }

  late StreamController<T> _controller;
  StreamSubscription? _subscription;
  Stream<S>? _stream;
  bool _cancelOnError = false;

  void _onListen() {
    logger.finest('_onListen');
    _subscription = _stream?.listen(
      onData,
      onError: _controller.addError,
      onDone: _controller.close,
      cancelOnError: _cancelOnError);
  }

  void _onCancel() {
    logger.finest('_onCancel');
    _subscription?.cancel();
    _subscription = null;
  }

  /// Method that actually transforms the data being passed through this stream
  void onData(S streamData);

  /// Send data to the listening stream, should f.e. be called from within the
  /// onData call to forward the transformed data
  void sendData(T data) {
    _controller.add(data);
  }

  @override
  Stream<T> bind(Stream<S> stream) {
    logger.finest('bind');
    _stream = stream;
    return _controller.stream;
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() => StreamTransformer.castFrom(this);
}
