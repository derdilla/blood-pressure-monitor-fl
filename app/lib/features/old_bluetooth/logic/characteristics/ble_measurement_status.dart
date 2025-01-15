import 'package:blood_pressure_app/features/old_bluetooth/logic/characteristics/decoding_util.dart';

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
    bodyMovementDetected: isBitIntByteSet(byte, 1),
    cuffTooLose: isBitIntByteSet(byte, 2),
    irregularPulseDetected: isBitIntByteSet(byte, 3),
    pulseRateInRange: (byte & (1 << 4) >> 3) == 0,
    pulseRateExceedsUpperLimit: (byte & (1 << 4) >> 3) == 1,
    pulseRateIsLessThenLowerLimit: (byte & (1 << 4) >> 3) == 2,
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
