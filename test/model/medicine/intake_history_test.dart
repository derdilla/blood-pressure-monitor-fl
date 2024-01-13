import 'package:blood_pressure_app/model/blood_pressure/medicine/intake_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'medicine_intake_test.dart';
import 'medicine_test.dart';

void main() {
  group('IntakeHistory', () { 
    test('should return all matching intakes in range', () {
      final history = IntakeHistory([
        mockIntake(timeMs: 2),
        mockIntake(timeMs: 2),
        mockIntake(timeMs: 4),
        mockIntake(timeMs: 5),
        mockIntake(timeMs: 6),
        mockIntake(timeMs: 9),
        mockIntake(timeMs: 9),
        mockIntake(timeMs: 12),
        mockIntake(timeMs: 15),
        mockIntake(timeMs: 15),
        mockIntake(timeMs: 16),
        mockIntake(timeMs: 17),
      ]);
      final found = history.getIntakes(DateTimeRange(
        start: DateTime.fromMillisecondsSinceEpoch(4), 
        end: DateTime.fromMillisecondsSinceEpoch(15),
      ),);
      expect(found.length, 8);
      expect(found.map((e) => e.timestamp.millisecondsSinceEpoch), containsAllInOrder([4,5,6,9,9,12,15,15]));
    });
    test('should return all matching intakes when only few are in range', () {
      final history = IntakeHistory([
        mockIntake(timeMs: 2),
        mockIntake(timeMs: 3),
      ]);
      final found = history.getIntakes(DateTimeRange(
          start: DateTime.fromMillisecondsSinceEpoch(0),
          end: DateTime.fromMillisecondsSinceEpoch(4),
      ),);
      expect(found.length, 2);
      expect(found.map((e) => e.timestamp.millisecondsSinceEpoch), containsAllInOrder([2,3]));
    });
    test('should return nothing when no intakes are present', () {
      final history = IntakeHistory([]);
      final found = history.getIntakes(DateTimeRange(
          start: DateTime.fromMillisecondsSinceEpoch(0),
          end: DateTime.fromMillisecondsSinceEpoch(1000),
      ),);
      expect(found.length, 0);
    });
    test('should return nothing when intakes are out of range', () {
      final history = IntakeHistory([
        mockIntake(timeMs: 2),
        mockIntake(timeMs: 3),
      ]);
      final found1 = history.getIntakes(DateTimeRange(
          start: DateTime.fromMillisecondsSinceEpoch(4),
          end: DateTime.fromMillisecondsSinceEpoch(10),
      ),);
      expect(found1.length, 0);
      final found2 = history.getIntakes(DateTimeRange(
          start: DateTime.fromMillisecondsSinceEpoch(0),
          end: DateTime.fromMillisecondsSinceEpoch(1),
      ),);
      expect(found2.length, 0);
    });
    test('should add to the correct position', () {
      final history = IntakeHistory([
        mockIntake(timeMs: 2),
        mockIntake(timeMs: 7),
      ]);

      history.addIntake(mockIntake(timeMs: 3));
      final found = history.getIntakes(DateTimeRange(
          start: DateTime.fromMillisecondsSinceEpoch(0),
          end: DateTime.fromMillisecondsSinceEpoch(10),
      ),);
      expect(found.length, 3);
      expect(found.map((e) => e.timestamp.millisecondsSinceEpoch), containsAllInOrder([2,3,7]));

      history.addIntake(mockIntake(timeMs: 3));
      final found2 = history.getIntakes(DateTimeRange(
          start: DateTime.fromMillisecondsSinceEpoch(0),
          end: DateTime.fromMillisecondsSinceEpoch(10),
      ),);
      expect(found2.length, 4);
      expect(found2.map((e) => e.timestamp.millisecondsSinceEpoch), containsAllInOrder([2,3,3,7]));

      history.addIntake(mockIntake(timeMs: 1));
      final found3 = history.getIntakes(DateTimeRange(
          start: DateTime.fromMillisecondsSinceEpoch(0),
          end: DateTime.fromMillisecondsSinceEpoch(10),
      ),);
      expect(found3.length, 5);
      expect(found3.map((e) => e.timestamp.millisecondsSinceEpoch), containsAllInOrder([1,2,3,3,7]));

      history.addIntake(mockIntake(timeMs: 10));
      final found4 = history.getIntakes(DateTimeRange(
          start: DateTime.fromMillisecondsSinceEpoch(0),
          end: DateTime.fromMillisecondsSinceEpoch(10),
      ),);
      expect(found4.length, 6);
      expect(found4.map((e) => e.timestamp.millisecondsSinceEpoch), containsAllInOrder([1,2,3,3,7,10]));
    });
    test('should remove deleted intakes', () {
      final history = IntakeHistory([
        mockIntake(timeMs: 2),
        mockIntake(timeMs: 2),
        mockIntake(timeMs: 4),
        mockIntake(timeMs: 5),
        mockIntake(timeMs: 6),
        mockIntake(timeMs: 9),
        mockIntake(timeMs: 9, dosis: 2),
        mockIntake(timeMs: 12),
      ]);
      history.deleteIntake(mockIntake(timeMs: 5));
      final found = history.getIntakes(DateTimeRange(
          start: DateTime.fromMillisecondsSinceEpoch(0),
          end: DateTime.fromMillisecondsSinceEpoch(20),
      ),);
      expect(found.length, 7);
      expect(found.map((e) => e.timestamp.millisecondsSinceEpoch),
          containsAllInOrder([2,2,4,6,9,9,12]),);

      history.deleteIntake(mockIntake(timeMs: 9));
      final found3 = history.getIntakes(DateTimeRange(
          start: DateTime.fromMillisecondsSinceEpoch(0),
          end: DateTime.fromMillisecondsSinceEpoch(20),
      ),);
      expect(found3.length, 6);
      expect(found3.map((e) => e.timestamp.millisecondsSinceEpoch),
          containsAllInOrder([2,2,4,6,9,12]),);

      history.deleteIntake(mockIntake(timeMs: 2));
      final found4 = history.getIntakes(DateTimeRange(
          start: DateTime.fromMillisecondsSinceEpoch(0),
          end: DateTime.fromMillisecondsSinceEpoch(20),
      ),);
      expect(found4.length, 4);
      expect(found4.map((e) => e.timestamp.millisecondsSinceEpoch),
          containsAllInOrder([4,6,9,12]),);
    });
    test('should not fail on deleting non existent intake', () {
      final history = IntakeHistory([]);
      history.deleteIntake(mockIntake(timeMs: 5));
      final found = history.getIntakes(DateTimeRange(
          start: DateTime.fromMillisecondsSinceEpoch(0),
          end: DateTime.fromMillisecondsSinceEpoch(20),
      ),);
      expect(found.length, 0);
    });
    test('should serialize and deserialize', () {
      final meds = [mockMedicine(defaultDosis: 1), mockMedicine(defaultDosis: 2),mockMedicine(defaultDosis: 3), mockMedicine(defaultDosis: 4)];
      final history = IntakeHistory([
        mockIntake(dosis: 123, timeMs: 1235, medicine: meds[0]),
        mockIntake(dosis: 123, timeMs: 1235, medicine: meds[0]),
        mockIntake(dosis: 123, timeMs: 1235, medicine: meds[1]),
        mockIntake(dosis: 123, timeMs: 1235, medicine: meds[2]),
        mockIntake(dosis: 123, timeMs: 132, medicine: meds[3]),
        mockIntake(dosis: 1232, timeMs: 132, medicine: meds[3]),
        mockIntake(dosis: 1232, timeMs: 132, medicine: meds[3]),
        mockIntake(dosis: 1232, timeMs: 132, medicine: meds[3]),
        mockIntake(dosis: 123, timeMs: 1235, medicine: meds[3]),
      ]);
      final deserializedHistory = IntakeHistory.deserialize(history.serialize(), meds);

      expect(deserializedHistory.serialize(), history.serialize());
      expect(deserializedHistory, history);
    });
  });
}
