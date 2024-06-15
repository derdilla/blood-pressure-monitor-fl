import 'ble_measurement_status.dart';

class BleMeasurementData {
  BleMeasurementData({
    required this.systolic,
    required this.diastolic,
    required this.meanArterialPressure,
    required this.isMMHG,
    required this.pulseRate,
    required this.userID,
    required this.status,
    required this.timestamp,
  });

  final double systolic;
  final double diastolic;
  final double meanArterialPressure;
  final bool isMMHG; // mmhg or kpa
  final double? pulseRate;
  final int? userID;
  final BleMeasurementStatus status;
  final DateTime? timestamp;
}
