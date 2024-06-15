
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


  final bool bodyMovementDetected;
  final bool cuffTooLose;
  final bool irregularPulseDetected;
  final bool pulseRateInRange;
  final bool pulseRateExceedsUpperLimit;
  final bool pulseRateIsLessThenLowerLimit;
  final bool improperMeasurementPosition;
}
