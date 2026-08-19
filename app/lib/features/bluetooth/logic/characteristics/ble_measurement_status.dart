import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/decoding_util.dart';

class BleMeasurementStatus {
  BleMeasurementStatus({
    required this.bodyMovementDetected,
    required this.cuffTooLose,
    required this.irregularPulseDetected,
    required this.pulseRateInRange,
    required this.pulseRateExceedsUpperLimit,
    required this.pulseRateIsLessThenLowerLimit,
    required this.improperMeasurementPosition,
  });

  /// Decode the 16 bit measurement status field into a [BleMeasurementStatus].
  ///
  /// [value] is the whole uint16 field, not just its low byte. The spec only
  /// assigns bits 0 to 5; bits 6 to 15 are reserved for future use and are
  /// ignored here. Callers are responsible for reading [value] in the byte
  /// order the device uses.
  factory BleMeasurementStatus.decode(int value) => BleMeasurementStatus(
    bodyMovementDetected: isBitIntByteSet(value, 0),
    cuffTooLose: isBitIntByteSet(value, 1),
    irregularPulseDetected: isBitIntByteSet(value, 2),
    // Bits 3 and 4 form the pulse rate range: 0 within, 1 above, 2 below.
    pulseRateInRange: ((value >> 3) & 0x3) == 0,
    pulseRateExceedsUpperLimit: ((value >> 3) & 0x3) == 1,
    pulseRateIsLessThenLowerLimit: ((value >> 3) & 0x3) == 2,
    improperMeasurementPosition: isBitIntByteSet(value, 5),
  );

  final bool bodyMovementDetected;
  final bool cuffTooLose;
  final bool irregularPulseDetected;
  final bool pulseRateInRange;
  final bool pulseRateExceedsUpperLimit;
  final bool pulseRateIsLessThenLowerLimit;
  final bool improperMeasurementPosition;

  @override
  String toString() => 'BleMeasurementStatus{bodyMovementDetected: $bodyMovementDetected, cuffTooLose: $cuffTooLose, irregularPulseDetected: $irregularPulseDetected, pulseRateInRange: $pulseRateInRange, pulseRateExceedsUpperLimit: $pulseRateExceedsUpperLimit, pulseRateIsLessThenLowerLimit: $pulseRateIsLessThenLowerLimit, improperMeasurementPosition: $improperMeasurementPosition}';
}
