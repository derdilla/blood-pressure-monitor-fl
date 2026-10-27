import 'dart:typed_data';

import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/ble_measurement_data.dart';

abstract final class Microlife3gMeasurementData {
  static const _historyOffset = 29;
  static const _recordLength = 7;

  static List<BleMeasurementData> decodeMeasurements(Uint8List payload) {
    final history = decodeHistory(payload);
    if (history.rejectedRecords.isNotEmpty) {
      throw history.rejectedRecords.first;
    }
    return history.measurements;
  }

  static Microlife3gHistory decodeHistory(Uint8List payload) {
    if (payload.length < _historyOffset) {
      throw const FormatException('3G Microlife history metadata is truncated');
    }
    if (payload[0] != 0x00) {
      throw const FormatException('Expected a 3G Microlife history response');
    }

    final historyCount = payload[3];
    final expectedLength = _historyOffset + historyCount * _recordLength;
    if (payload.length != expectedLength) {
      throw FormatException(
        '3G Microlife history declares $historyCount stored slots '
        '($expectedLength bytes), received ${payload.length} bytes',
      );
    }

    final userId = payload[4];
    final measurements = <BleMeasurementData>[];
    final rejectedRecords = <FormatException>[];
    for (var recordIndex = 0; recordIndex < historyCount; recordIndex++) {
      final offset = _historyOffset + recordIndex * _recordLength;
      final record = Uint8List.sublistView(
        payload,
        offset,
        offset + _recordLength,
      );
      if (record.every((value) => value == 0)) continue;

      final systolic = record[0];
      final diastolic = record[1];
      final pulse = record[2];
      final day = record[3] & 0x3f;
      final hour = record[4] & 0x3f;
      final month = ((record[4] & 0xc0) >> 4) | ((record[3] & 0xc0) >> 6);
      final minute = record[5];
      final year = 2000 + (record[6] & 0x3f);

      FormatException recordFailure(String reason) => FormatException(reason);

      if (systolic == 0 || diastolic == 0 || pulse == 0) {
        rejectedRecords.add(
          recordFailure(
            '3G Microlife stored record $recordIndex has a zero pressure or pulse',
          ),
        );
        continue;
      }

      if (month < 1 ||
          month > 12 ||
          day < 1 ||
          day > 31 ||
          hour > 23 ||
          minute > 59) {
        rejectedRecords.add(
          recordFailure(
            '3G Microlife stored record $recordIndex has invalid date/time fields',
          ),
        );
        continue;
      }

      final timestamp = DateTime(year, month, day, hour, minute);
      if (timestamp.year != year ||
          timestamp.month != month ||
          timestamp.day != day ||
          timestamp.hour != hour ||
          timestamp.minute != minute) {
        rejectedRecords.add(
          recordFailure(
            '3G Microlife stored record $recordIndex has an invalid calendar date',
          ),
        );
        continue;
      }

      measurements.add(
        BleMeasurementData(
          systolic: systolic.toDouble(),
          diastolic: diastolic.toDouble(),
          pulse: pulse.toDouble(),
          meanArterialPressure: (systolic + 2 * diastolic) / 3,
          isMMHG: true,
          timestamp: timestamp,
          userID: userId,
        ),
      );
    }
    return Microlife3gHistory(
      measurements: measurements,
      rejectedRecords: rejectedRecords,
    );
  }


}

final class Microlife3gHistory {
  Microlife3gHistory({
    required List<BleMeasurementData> measurements,
    required List<FormatException> rejectedRecords,
  }) : measurements = List<BleMeasurementData>.unmodifiable(measurements),
       rejectedRecords = List<FormatException>.unmodifiable(rejectedRecords);

  final List<BleMeasurementData> measurements;

  final List<FormatException> rejectedRecords;
}
