import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/microlife_protocol.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('computes checksum as least significant byte of sum', () {
    expect(MicrolifeProtocol.checksum([77, 255, 0, 9, 0, 0, 0, 0, 0, 0, 0, 253]), 82);
    expect(MicrolifeProtocol.checksum([]), 0);
  });

  test('predefined commands carry a valid checksum', () {
    final getMeasurements = MicrolifeProtocol.getMeasurementsCommand;
    expect(
      MicrolifeProtocol.checksum(getMeasurements.sublist(0, getMeasurements.length - 1)),
      getMeasurements.last,
    );

    final disconnect = MicrolifeProtocol.disconnectCommand;
    expect(
      MicrolifeProtocol.checksum(disconnect.sublist(0, disconnect.length - 1)),
      disconnect.last,
    );
  });

  test('builds a valid set time command', () {
    final command = MicrolifeProtocol.buildSetTimeCommand(DateTime(2024, 6, 15, 14, 30, 45));

    expect(command, [77, 255, 0, 8, 13, 24, 6, 15, 14, 30, 45, 231]);
    expect(
      MicrolifeProtocol.checksum(command.sublist(0, command.length - 1)),
      command.last,
    );
  });

  test('determines expected frame length once header is available', () {
    expect(MicrolifeProtocol.expectedFrameLength([77, 58]), isNull);
    expect(MicrolifeProtocol.expectedFrameLength([77, 58, 0, 2]), 6);
    expect(MicrolifeProtocol.expectedFrameLength([77, 58, 1, 0]), 260);
  });

  test('parses a valid response payload', () {
    // ack frame: header "M:", length 2, payload [129], checksum
    final payload = MicrolifeProtocol.parseResponsePayload([77, 58, 0, 2, 129, 10]);
    expect(payload, [129]);
  });

  test('rejects a frame with a bad header', () {
    expect(MicrolifeProtocol.parseResponsePayload([77, 255, 0, 2, 129, 207]), isNull);
  });

  test('rejects a frame with a bad checksum', () {
    expect(MicrolifeProtocol.parseResponsePayload([77, 58, 0, 2, 129, 11]), isNull);
  });

  test('rejects a frame with a mismatched length', () {
    expect(MicrolifeProtocol.parseResponsePayload([77, 58, 0, 5, 129, 10]), isNull);
  });
}
