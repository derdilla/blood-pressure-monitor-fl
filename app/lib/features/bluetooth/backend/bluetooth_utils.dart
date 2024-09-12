part of 'bluetooth_backend.dart';

/// Generic stream transformer util that should support cancelling & pausing etc
/// so implementations only need to worry about transforming the data by overriding
/// the onData method and sending the transformed data using sendData
/// TODO: move to generic data_util not just bluetooth?
abstract class BluetoothStreamTransformer<S,T> with TypeLogger implements StreamTransformer<S,T> {
  /// constructor
  BluetoothStreamTransformer({ bool sync = false, bool cancelOnError = false }) {
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
  void onData(S data);

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
