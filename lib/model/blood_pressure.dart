import 'dart:collection';

import 'package:flutter/foundation.dart';

class BloodPressureModel extends ChangeNotifier {
  final List<BloodPressureRecord> _allMeasurements = [];

  // All measurements (might get slow after some time)
  UnmodifiableListView<BloodPressureRecord> get allMeasurements => UnmodifiableListView(_allMeasurements);

  /// Adds a new measurement at the correct chronological position in the List.
  /// If the measurement was taken at exactly the same time as an existing
  /// measurement, the existing measurement gets replaced.
  void add(BloodPressureRecord measurement) {
    if (_allMeasurements.isNotEmpty &&
        _allMeasurements.last.compareTo(measurement) >= 0) {
      // naive approach; change algorithm
      for (int i = 0; i < _allMeasurements.length; i++) {
        if (_allMeasurements[i].compareTo(measurement) == 0) {
          _allMeasurements[i] = measurement;
        } else if (_allMeasurements[i].compareTo(measurement) > 0) {
          _allMeasurements.insert(i, measurement);
        }
      }
    } else {
        _allMeasurements.add(measurement);
    }
    notifyListeners();
  }

  /// Returns the
  UnmodifiableListView<BloodPressureRecord> getLastX(int count) {
    final List<BloodPressureRecord> lastMeasurements = [];
    // example length = 30 (last index  29) count = 5 => 29, 28, 27, 26, 25 (5)
    for (int i = _allMeasurements.length-1; i>=_allMeasurements.length-count &&
            i>=0; i--) {
      lastMeasurements.add(_allMeasurements[i]); // new list gets sorted high to low
    }
    return UnmodifiableListView(lastMeasurements);
  }
  
  /* TODO:
  - bool deleteFromTime (timestamp)
  - bool changeAtTime (newRecord)
   */


}

@immutable
class BloodPressureRecord {
  final DateTime creationTime;
  final int systolic;
  final int diastolic;
  final int pulse;
  final String notes;

  const BloodPressureRecord(
      this.creationTime, this.systolic, this.diastolic, this.pulse, this.notes);

  @override
  int compareTo(BloodPressureRecord other) {
    if (creationTime.isBefore(other.creationTime)) {
      return -1;
    } else if (creationTime.isAfter(other.creationTime)) {
      return 1;
    } else {
      return 0;
    }
  }
}