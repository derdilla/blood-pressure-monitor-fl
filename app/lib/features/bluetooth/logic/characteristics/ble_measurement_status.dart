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

  factory BleMeasurementStatus.decode(int byte) => BleMeasurementStatus(
    bodyMovementDetected: isBitIntByteSet(byte, 0),
    cuffTooLose: isBitIntByteSet(byte, 1),
    irregularPulseDetected: isBitIntByteSet(byte, 2),
    // Bits 3 and 4 form the pulse rate range: 0 within, 1 above, 2 below.
    pulseRateInRange: ((byte >> 3) & 0x3) == 0,
    pulseRateExceedsUpperLimit: ((byte >> 3) & 0x3) == 1,
    pulseRateIsLessThenLowerLimit: ((byte >> 3) & 0x3) == 2,
    improperMeasurementPosition: isBitIntByteSet(byte, 5),
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
