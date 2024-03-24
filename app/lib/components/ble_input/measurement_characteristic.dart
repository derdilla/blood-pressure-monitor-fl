import 'dart:math';

// TODO: test all parts of the conversion and parsing.

/// Dart representation of org.bluetooth.characteristic.blood_pressure_measurement.
///
/// Reference: https://bitbucket.org/bluetooth-SIG/public/src/main/gss/org.bluetooth.characteristic.blood_pressure_measurement.yaml
class BPMeasurementCharacteristic {
  BPMeasurementCharacteristic._create(
    this.unit,
    this.sys,
    this.dia,
    this.meanArterialPressure,
    this.time,
    this.pul,
    this.userid,
    this.bodyMoved,
    this.cuffLoose,
    this.irregularPulse,
    this.measurementStatus,
    this.improperMeasurementPosition,
  );

  /// Parse from binary data in byte array format as specified in protocol.
  factory BPMeasurementCharacteristic.parse(List<int> bin) {
    // - bool flags(8 bit) bool:
    //    - 0   blood_pressure_units (mmHg or kPa)
    //    - 1   contains time stamp
    //    - 2   contains pulse
    //    - 3   contains userid
    //    - 4   contains measurement status
    // - [sys (mmHg) (16 bit) medfloat16 - IEEE 11073-20601 16-bit SFLOAT] (flags[0] == 0)
    // - [dia (mmHg) (16 bit) medfloat16] (flags[0] == 0)
    // - [Mean Arterial Pressure (mmHg) (16 bit) medfloat16] (flags[0] == 0)
    // - [sys (kPa) (16 bit) medfloat16] (flags[0] == 1)
    // - [dia (kPa) (16 bit) medfloat16] (flags[0] == 1)
    // - [Mean Arterial Pressure (kPa) (16 bit) medfloat16] (flags[0] == 1)
    // - [Timestamp (7byte) sec:org.bluetooth.characteristic.date_time] (flags[1] == 1)
    // - [pul (bpm) (16 bit) medfloat16] (flags[2] == 1)
    // - [userid (8 bit) uint8] (flags[3] == 1)
    // - [Measurement status (16 bit) bool] (flags[4] == 1)
    //    - 0   Body Movement (==1)
    //    - 1   Cuff loose (==1)
    //    - 2   Irregular pulse (==1)
    //    - 3,4 00=ok 01=toHigh 10=toLow
    //    - 5   Improper measurement position (==1)

    int currByte = 0;

    if (bin.length < 1+3*2) {
      throw ArgumentError('BloodPressureMeasurementCharacteristic has not enough bytes.');
    }
    final BPUnit unit = _checkBit(bin[currByte], 0) ? BPUnit.kPa : BPUnit.mmHg;
    final bool containsTimestamp = _checkBit(bin[currByte], 1);
    final bool containsPulse = _checkBit(bin[currByte], 2);
    final bool containsUserid = _checkBit(bin[currByte], 3);
    final bool containsMeasurementStatus = _checkBit(bin[currByte], 4);

    final int expectedByteCount = 1
        + 3*2
        + (containsTimestamp ? 7 : 0)
        + (containsPulse ? 2 : 0)
        + (containsUserid ? 1 : 0)
        + (containsMeasurementStatus ? 2 : 0);
    if (bin.length != expectedByteCount) {
      throw ArgumentError('Unexpected byte count. Flags indicate '
          '$expectedByteCount but got ${bin.length}');
    }
    currByte += 1;

    final sys = _parseMedfloat(bin[currByte], bin[currByte+1]);
    currByte += 2;
    final dia = _parseMedfloat(bin[currByte], bin[currByte+1]);
    currByte += 2;
    final meanArterialPressure = _parseMedfloat(bin[currByte], bin[currByte+1]);
    currByte += 2;
    DateTime? time;
    if (containsTimestamp) {
      time = _parseDateTime(bin.sublist(currByte, currByte + 7));
      currByte += 7;
    }
    double? pul;
    if (containsPulse) {
      pul = _parseMedfloat(bin[currByte], bin[currByte+1]);
      currByte += 2;
    }
    int? userid;
    if (containsUserid) {
      userid = bin[currByte];
      currByte += 1;
    }
    bool? bodyMoved;
    bool? cuffLoose;
    bool? irregularPulse;
    MeasurementStatus? measurementStatus;
    bool? improperMeasurementPosition;
    if (containsMeasurementStatus) {
      bodyMoved = _checkBit(bin[currByte], 0);
      cuffLoose = _checkBit(bin[currByte], 1);
      irregularPulse = _checkBit(bin[currByte], 2);
      if (!_checkBit(bin[currByte], 3) && !_checkBit(bin[currByte], 4)) {
        measurementStatus = MeasurementStatus.ok;
      } else if (!_checkBit(bin[currByte], 3) && _checkBit(bin[currByte], 4)) {
        measurementStatus = MeasurementStatus.toHigh;
      } else if (_checkBit(bin[currByte], 3) && !_checkBit(bin[currByte], 4)) {
        measurementStatus = MeasurementStatus.toLow;
      } else {
        assert(false);
        measurementStatus = MeasurementStatus.ok;
      }
      improperMeasurementPosition = _checkBit(bin[currByte], 5);
      currByte += 2;
    }

    return BPMeasurementCharacteristic._create(
      unit,
      sys,
      dia,
      meanArterialPressure,
      time,
      pul,
      userid,
      bodyMoved,
      cuffLoose,
      irregularPulse,
      measurementStatus,
      improperMeasurementPosition,
    );
  }

  /// Pressure unit for [sys], [dia] and [meanArterialPressure].
  BPUnit unit;

  /// Systolic value in [unit].
  double sys;

  /// Diatolic value in [unit].
  double dia;

  /// Mean arterial pressure in [unit].
  double meanArterialPressure;

  /// Time stamp of the measurement.
  DateTime? time;

  /// Pulse rate in beats per minute.
  double? pul;

  /// User id of the person that took the measurement.
  ///
  /// This could be used to get more information about that person. Refer to:
  /// https://www.bluetooth.com/specifications/blp-1-1-1/
  int? userid;

  /// Whether body movement was detected during measurement.
  bool? bodyMoved;

  /// Whether the cuff was too loose during measurement.
  bool? cuffLoose;

  /// Whether irregular pulse was detected.
  bool? irregularPulse;

  /// The range the pulse rate was in.
  MeasurementStatus? measurementStatus;

  /// Whether the measurement was taken at an improper position.
  bool? improperMeasurementPosition;

  /// Whether a the bit at [bit] in [value] is 1.
  static bool _checkBit(int value, int bit) => (value & (1 << bit)) != 0;

  /// Parse a medfloat to double.
  ///
  /// Format: 4 bits exponent, 12 bits mantissa
  /// https://www.bluetooth.com/wp-content/uploads/2019/03/PHD_Transcoding_WP_v16.pdf
  static double _parseMedfloat(int firstByte, int secondByte) {
    final exponent = firstByte & 0xF0;
    final mantissa = ((firstByte & 0x0F) << 4) + secondByte;
    if (exponent == 0) {
      if (mantissa == 0x07FF) {
        return double.nan;
      } else if (mantissa == 0x0800) {
        return double.nan;
      } else if (mantissa == 0x07FE) {
        return double.infinity;
      } else if (mantissa == 0x0802) {
        return double.negativeInfinity;
      } else if (mantissa == 0x0801) {
        assert(false, 'unimplemented, reserved');
        return double.nan;
      }
    }

    return (mantissa * pow(10, exponent)).toDouble();
  }

  static DateTime _parseDateTime(List<int> data) {
    assert(data.length == 7);
    return DateTime(
      (data[0] << 8) + data[1], // year
      data[2], // month
      data[3], // day
      data[4], // hour
      data[5], // minute
      data[6], // seconds
    );
  }

}

/// Pressure unit for blood pressure values.
enum BPUnit {
  /// Millimeters of mercury.
  mmHg,
  /// Kilopascal.
  kPa
}

/// Whether pulse rate was in an measurable range.
///
/// https://bitbucket.org/bluetooth-SIG/public/src/995423d6e1136111c1759a3d7270c15213ee5b9a/gss/org.bluetooth.characteristic.blood_pressure_measurement.yaml#lines-166:172
enum MeasurementStatus {
  /// Pulse rate is within the range.
  ok,
  /// Pulse rate exceeds upper limit.
  toHigh,
  /// Pulse rate is less than lower limit.
  toLow,
}
