import 'package:blood_pressure_app/logging.dart';
import 'package:blood_pressure_app/model/blood_pressure/medicine/medicine.dart';
import 'package:blood_pressure_app/model/blood_pressure/medicine/medicine_intake.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

/// Model of all medicine intakes that allows fast access of data.
///
/// Internally maintains a sorted list of intakes to allow for binary search.
///
/// Intake history does not implement database support, as operations performed
/// are
@Deprecated('use health_data_store')
class IntakeHistory extends ChangeNotifier {
  /// Create a intake history from an unsorted list of intakes.
  IntakeHistory(List<OldMedicineIntake> medicineIntakes):
    _medicineIntakes = medicineIntakes.sorted((p0, p1) => p0.compareTo(p1));

  /// Creates a intake history from a sorted list of intakes.
  IntakeHistory._sorted(this._medicineIntakes);

  /// Restores a intake history from a [serialize] generated string.
  factory IntakeHistory.deserialize(String serialized, List<Medicine> availableMedicines) =>
    IntakeHistory._sorted(
      serialized
        .split('\n')
        .map((e) {
          try {
            return OldMedicineIntake.deserialize(e, availableMedicines);
          } on FormatException {
            log.severe('OldMedicineIntake deserialization problem: "$e"');
            return null;
          }
        })
        .whereNotNull()
        .toList(),
    );

  /// List of all medicine intakes sorted in ascending order.
  ///
  /// Can contain multiple medicine intakes at the same time.
  final List<OldMedicineIntake> _medicineIntakes;

  /// Returns all intakes in a given range in ascending order.
  ///
  /// Binary searches the lower and the upper bound of stored intakes to create
  /// the list view.
  UnmodifiableListView<OldMedicineIntake> getIntakes(DateTimeRange range) {
    if (_medicineIntakes.isEmpty) return UnmodifiableListView([]);
    int start = _findLowerBound(_medicineIntakes, range.start);
    int end = _findUpperBound(_medicineIntakes, range.end);

    if (start < 0) start = 0;
    assert(end < _medicineIntakes.length);
    if (end < 0) end = _medicineIntakes.length;

    return UnmodifiableListView(_medicineIntakes.getRange(start, end));
  }

  /// Use binary search to determine the first index in [list] before which all
  /// values that are before or at the same time as [t].
  int _findUpperBound(List<OldMedicineIntake> list, DateTime t) {
    int low = 0;
    int high = list.length - 1;

    int idx = -1;
    while (low <= high) {
      final int mid = low + ((high - low) >> 1);
      assert (mid == (low + (high - low) / 2).toInt());

      if (list[mid].timestamp.isBefore(t) || list[mid].timestamp.isAtSameMomentAs(t)) {
        low = mid + 1;
      } else {
        idx = mid;
        high = mid - 1;
      }
    }

    return idx;
  }

  /// Use binary search to determine the last index in [list] after which before
  /// all values that are after or at the same time as [t].
  int _findLowerBound(List<OldMedicineIntake> list, DateTime t) {
    int low = 0;
    int high = list.length - 1;

    int idx = -1;
    while (low <= high) {
      final int mid = low + ((high - low) >> 1);
      assert (mid == (low + (high - low) / 2).toInt());

      if (list[mid].timestamp.isAfter(t) || list[mid].timestamp.isAtSameMomentAs(t) ){
        high = mid - 1;
      } else {
        idx = mid;
        low = mid + 1;
      }
    }

    return idx + 1;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntakeHistory && runtimeType == other.runtimeType &&
        (){
          for (final e in _medicineIntakes) {
            if (!other._medicineIntakes.contains(e)) return false;
          }
          return true;
        }();

  @override
  int get hashCode => _medicineIntakes.hashCode;
}
