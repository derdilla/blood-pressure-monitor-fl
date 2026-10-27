import 'dart:typed_data';

import 'package:blood_pressure_app/logging.dart';

/// Microlife monitors (e.g. the BP3GY1-2N) don't expose the standard bluetooth
/// blood pressure service. Instead commands are written to `fff2` and responses
/// are received as notifications on `fff1`. Both directions share the same frame
/// layout:
///
/// ```
/// byte 0..1  header     (command: 0x4D 0xFF, response: 0x4D 0x3A == "M:")
/// byte 2..3  length     (big endian, payload length + checksum length)
/// byte 4..n  payload
/// byte n+1   checksum   (least significant byte of the sum of all preceding bytes)
/// ```
///
/// The protocol was reverse engineered from the Microlife Connect android app,
/// ported here from the python implementation `bpm_bt.py`
/// (https://github.com/joergmlpts/blood-pressure-monitor).
class MicrolifeProtocol {
  MicrolifeProtocol._();

  static const responseHeader = [0x4D, 0x3A];
  static const readUserVersionCommand = [0x4D, 0xFF, 0, 2, 5, 0x53];
  static const List<int> getMeasurementsCommand = [77, 255, 0, 9, 0, 0, 0, 0, 0, 0, 0, 253, 82];
  static const List<int> disconnectCommand = [77, 255, 0, 2, 4, 82];

  static int checksum(Iterable<int> bytes) =>
      bytes.fold<int>(0, (sum, b) => sum + b) % 256;

  static bool isKnown3gDevice(String? name) {
    final normalized = name?.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
    return normalized != null &&
        (normalized == 'A7' ||
            normalized.contains('A7TOUCHBT') ||
            normalized.contains('BP3GT16F'));
  }

  static List<int> buildRead3gMeasurementsCommand(DateTime time) {
    final command = [
      0x4D,
      0xFF,
      0,
      8,
      0,
      time.year % 100,
      time.month,
      time.day,
      time.hour,
      time.minute,
      time.second,
    ];
    return [...command, checksum(command)];
  }

  static List<int> buildSetTimeCommand(DateTime time) {
    final command = <int>[
      77, 255, 0, 8, 13,
      time.year - 2000,
      time.month,
      time.day,
      time.hour,
      time.minute,
      time.second,
    ];
    return [...command, checksum(command)];
  }

  /// Total length of the frame described by [buffer]
  static int? expectedFrameLength(List<int> buffer) {
    if (buffer.length < 4) return null;
    return (buffer[2] << 8) + buffer[3] + 4;
  }

  static Uint8List? parseResponsePayload(List<int> frame) {
    if (frame.length < 5) {
      log.warning('MicrolifeProtocol received frame that is too short: $frame');
      return null;
    }
    if (frame[0] != responseHeader[0]
        || (frame[1] != 0x31 && frame[1] != 0x3A)) {
      log.warning("MicrolifeProtocol didn't find response header: $frame");
      return null;
    }
    if (frame.length != expectedFrameLength(frame)) {
      log.warning('MicrolifeProtocol frame length mismatch: $frame');
      return null;
    }
    if (checksum(frame.sublist(0, frame.length - 1)) != frame.last) {
      log.warning('MicrolifeProtocol checksum mismatch: $frame');
      return null;
    }
    return Uint8List.fromList(frame.sublist(4, frame.length - 1));
  }
}

class MicrolifeResponseFrame {
  MicrolifeResponseFrame(this.marker, this.payload);

  final int marker;
  final Uint8List payload;
}

class MicrolifeFrameDecoder {
  final List<int> _buffer = [];

  void clear() => _buffer.clear();

  List<MicrolifeResponseFrame> add(List<int> bytes) {
    _buffer.addAll(bytes);
    final frames = <MicrolifeResponseFrame>[];
    while (_buffer.length >= 2) {
      if (_buffer[0] != 0x4D || (_buffer[1] != 0x31 && _buffer[1] != 0x3A)) {
        _buffer.removeAt(0);
        continue;
      }
      final length = MicrolifeProtocol.expectedFrameLength(_buffer);
      if (length == null) break;
      if (length < 6) {
        _buffer.removeAt(0);
        continue;
      }
      if (_buffer.length < length) break;
      final payload = MicrolifeProtocol.parseResponsePayload(
        _buffer.sublist(0, length),
      );
      if (payload == null) {
        _buffer.removeAt(0);
        continue;
      }
      frames.add(MicrolifeResponseFrame(_buffer[1], payload));
      _buffer.removeRange(0, length);
    }
    return frames;
  }
}
