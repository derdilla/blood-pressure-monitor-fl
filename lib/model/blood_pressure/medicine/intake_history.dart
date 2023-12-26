import 'package:blood_pressure_app/model/blood_pressure/medicine/medicine_intake.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

/// Model of all medicine intakes that allows fast access of data.
///
/// Internally maintains a sorted list of intakes to allow for binary search.
class IntakeHistory {

  IntakeHistory(List<MedicineIntake> medicineIntakes):
    _medicineIntakes = medicineIntakes.sorted((p0, p1) => p0.compareTo(p1));

  /// List of all medicine intakes sorted in ascending order.
  ///
  /// Can contain multiple medicine intakes at the same time.
  final List<MedicineIntake> _medicineIntakes;


  /// Returns all intakes in a given range in ascending order.
  ///
  /// Binary searches the lower and the upper bound of stored intakes to create
  /// the list view.
  UnmodifiableListView<MedicineIntake> getIntakes(DateTimeRange range) {
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
  int _findUpperBound(List<MedicineIntake> list, DateTime t) {
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
  int _findLowerBound(List<MedicineIntake> list, DateTime t) {
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

  /// Save a medicine intake.
  ///
  /// Inserts the intake at the upper bound of intakes that are bigger or equal.
  /// When no smaller bigger intake is available insert to the end of the list.
  ///
  /// Uses binary search to determine the bound.
  void addIntake(MedicineIntake intake) {
    int index = _findUpperBound(_medicineIntakes, intake.timestamp);

    if (index == -1) {
      _medicineIntakes.add(intake);
    } else {
      _medicineIntakes.insert(index, intake);
    }
  }

  /// Attempts to delete a medicine intake.
  ///
  /// When finding multiple intakes with the same timestamp, medicine
  /// and dosis all instances will get deleted.
  void deleteIntake(MedicineIntake intake) {
    int idx = binarySearch(_medicineIntakes, intake);
    while (idx >= 0) {
      _medicineIntakes.removeAt(idx);
      idx = binarySearch(_medicineIntakes, intake);
    }
  }
}