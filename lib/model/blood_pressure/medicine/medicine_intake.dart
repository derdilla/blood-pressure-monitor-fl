
import 'package:blood_pressure_app/model/blood_pressure/medicine/medicine.dart';

/// Instance of a medicine intake.
class MedicineIntake implements Comparable<Object> {
  /// Create a instance of a medicine intake.
  const MedicineIntake({
    required this.medicine,
    required this.dosis,
    required this.timestamp
  });

  /// Kind of medicine taken.
  final Medicine medicine;

  /// Amount in mg of medicine taken.
  final double dosis;

  /// Time when the medicine was taken.
  final DateTime timestamp;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineIntake &&
          runtimeType == other.runtimeType &&
          medicine == other.medicine &&
          dosis == other.dosis &&
          timestamp == other.timestamp;

  @override
  int get hashCode => medicine.hashCode ^ dosis.hashCode ^ timestamp.hashCode;

  @override
  int compareTo(other) {
    assert(other is MedicineIntake);
    if (other is! MedicineIntake) return 0;

    final timeCompare = timestamp.compareTo(other.timestamp);
    if (timeCompare != 0) return timeCompare;

    return dosis.compareTo(other.dosis);
  }
}