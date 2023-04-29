import 'dart:collection';

import 'package:flutter/foundation.dart';

class BloodPressureModel extends ChangeNotifier {
  final List<BloodPressureRecord> _allMeasurements = [];

  // All measurements (might get slow after some time)
  UnmodifiableListView<BloodPressureRecord> get allMeasurements => UnmodifiableListView(_allMeasurements);

  void add(BloodPressureRecord measurement) {
    _allMeasurements.add(measurement);
    notifyListeners();
  }
  
  /* TODO:
  - getLast (x)
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
}