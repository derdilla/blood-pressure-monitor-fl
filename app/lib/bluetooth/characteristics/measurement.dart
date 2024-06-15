/// Blood pressure measurement according to default GATT.
///
/// https://developer.nordicsemi.com/nRF51_SDK/nRF51_SDK_v4.x.x/doc/html/structble__bps__meas__s.html
/// https://github.com/NordicSemiconductor/Kotlin-BLE-Library/blob/6b565e59de21dfa53ef80ff8351ac4a4550e8d58/profile/src/main/java/no/nordicsemi/android/kotlin/ble/profile/bps/BloodPressureMeasurementParser.kt
class MeasurementCharacteristic {
  /// Create a blood pressure measurement with default GATT fields.
  const MeasurementCharacteristic({
    required this.bloodPressureUnitsInKPa,
    required this.sys,
    required this.dia,
    required this.meanArterialPressure,
    required this.time,
    required this.pul,
    required this.userid,
    required this.bodyMoved,
    required this.cuffLoose,
    required this.irregularPulse,
    required this.measurementStatus,
    required this.improperMeasurementPosition,
  });

  /// Whether the unit is kPa (true) or mmHg (false).
  final bool bloodPressureUnitsInKPa;

  /// Systolic value in [unit].
  final double sys;

  /// Diatolic value in [unit].
  final double dia;

  /// Mean arterial pressure in [unit].
  final double meanArterialPressure;

  /// Time stamp of the measurement.
  final DateTime? time;

  /// Pulse rate in beats per minute.
  final double? pul;

  /// User id of the person that took the measurement.
  ///
  /// This could be used to get more information about that person. Refer to:
  /// https://www.bluetooth.com/specifications/blp-1-1-1/
  final int? userid;

  /// Whether body movement was detected during measurement.
  final bool? bodyMoved;

  /// Whether the cuff was too loose during measurement.
  final bool? cuffLoose;

  /// Whether irregular pulse was detected.
  final bool? irregularPulse;

  /// The range the pulse rate was in.
  final MeasurementStatus? measurementStatus;

  /// Whether the measurement was taken at an improper position.
  final bool? improperMeasurementPosition;
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
