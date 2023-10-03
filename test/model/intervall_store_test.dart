
import 'package:blood_pressure_app/model/storage/intervall_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IntervallStorage', () {
    test('base constructor should initialize with values', () {
      final storageObject = IntervallStorage(stepSize: TimeStep.month, range: DateTimeRange(
          start: DateTime.fromMillisecondsSinceEpoch(1234),
          end: DateTime.fromMillisecondsSinceEpoch(5678)
      ));

      expect(storageObject.stepSize, TimeStep.month);
      expect(storageObject.currentRange.start.millisecondsSinceEpoch, 1234);
      expect(storageObject.currentRange.end.millisecondsSinceEpoch, 5678);
    });

    test('base constructor should initialize to default without values', () {
      final storageObject = IntervallStorage();
      expect(storageObject.stepSize, TimeStep.last7Days);
      expect(storageObject.currentRange.start.millisecondsSinceEpoch, lessThanOrEqualTo(DateTime
          .now()
          .millisecondsSinceEpoch));
    });

    test('base constructor should initialize with only incomplete parameters', () {
      // only tests for no crashes
      IntervallStorage(stepSize: TimeStep.last30Days);
      IntervallStorage(range: DateTimeRange(
          start: DateTime.fromMillisecondsSinceEpoch(1234),
          end: DateTime.fromMillisecondsSinceEpoch(5678)
      ));
    });

    test('should create json without error', () {
      final intervall = IntervallStorage(stepSize: TimeStep.year);
      final json = intervall.toJson();
      expect(json.length, greaterThan(0));
    });

    test('should load same data from json', () {
      final initialData = IntervallStorage();
      final json = initialData.toJson();
      final recreatedData = IntervallStorage.fromJson(json);

      expect(initialData.stepSize, recreatedData.stepSize);
      expect(initialData.currentRange.start.millisecondsSinceEpoch,
          recreatedData.currentRange.start.millisecondsSinceEpoch);
      expect(initialData.currentRange.end.millisecondsSinceEpoch,
          recreatedData.currentRange.end.millisecondsSinceEpoch);
    });

    test('should load same data from json in edge cases', () {
      final initialData = IntervallStorage(stepSize: TimeStep.month, range: DateTimeRange(
          start: DateTime.fromMillisecondsSinceEpoch(1234),
          end: DateTime.fromMillisecondsSinceEpoch(5678)
      ));
      final json = initialData.toJson();
      final recreatedData = IntervallStorage.fromJson(json);

      expect(initialData.stepSize, TimeStep.month);
      expect(recreatedData.currentRange.start.millisecondsSinceEpoch, 1234);
      expect(recreatedData.currentRange.end.millisecondsSinceEpoch, 5678);
    });

    test('should not crash when parsing incorrect json', () {
      IntervallStorage.fromJson('banana');
      IntervallStorage.fromJson('{"stepSize" = 1}');
      IntervallStorage.fromJson('{"stepSize": 1');
      IntervallStorage.fromJson('{stepSize: 1}');
      IntervallStorage.fromJson('green{stepSize: 1}');
    });

    test('should not crash when parsing invalid values and ignore them', () {
      final v1 = IntervallStorage.fromJson('{"stepSize": true}');
      final v2 = IntervallStorage.fromJson('{"stepSize": "month"}');
      final v3 = IntervallStorage.fromJson('{"start": "month", "end": 10.5}');
      final v4 = IntervallStorage.fromJson('{"start": 18.6, "end": 90.65}');

      expect(v1.stepSize, TimeStep.last7Days);
      expect(v2.stepSize, TimeStep.last7Days);
      expect(v3.stepSize, TimeStep.last7Days);

      // in minutes to avoid failing through performance
      expect(v2.currentRange.duration.inMinutes, v1.currentRange.duration.inMinutes);
      expect(v3.currentRange.duration.inMinutes, v1.currentRange.duration.inMinutes);
      expect(v4.currentRange.duration.inMinutes, v1.currentRange.duration.inMinutes);
    });


    test('intervall lengths should match step size', () {
      final dayIntervall = IntervallStorage(stepSize: TimeStep.day);
      final weekIntervall = IntervallStorage(stepSize: TimeStep.week);
      final monthIntervall = IntervallStorage(stepSize: TimeStep.month);
      final yearIntervall = IntervallStorage(stepSize: TimeStep.year);
      final last7DaysIntervall = IntervallStorage(stepSize: TimeStep.last7Days);
      final last30DaysIntervall = IntervallStorage(stepSize: TimeStep.last30Days);
      
      expect(dayIntervall.currentRange.duration.inHours, 24);
      expect(weekIntervall.currentRange.duration.inDays, 7);
      expect(monthIntervall.currentRange.duration.inDays, inInclusiveRange(28, 31));
      expect(yearIntervall.currentRange.duration.inDays, inInclusiveRange(365, 366));
      expect(last7DaysIntervall.currentRange.duration.inDays, 7);
      expect(last30DaysIntervall.currentRange.duration.inDays, 30);
    });

    test('intervall lengths should still be correct after moving', () {
      final dayIntervall = IntervallStorage(stepSize: TimeStep.day);
      final weekIntervall = IntervallStorage(stepSize: TimeStep.week);
      final monthIntervall = IntervallStorage(stepSize: TimeStep.month);
      final yearIntervall = IntervallStorage(stepSize: TimeStep.year);
      final last7DaysIntervall = IntervallStorage(stepSize: TimeStep.last7Days);
      final last30DaysIntervall = IntervallStorage(stepSize: TimeStep.last30Days);
      final customIntervall = IntervallStorage(stepSize: TimeStep.custom, range: DateTimeRange(
          start: DateTime.fromMillisecondsSinceEpoch(1234),
          end: DateTime.fromMillisecondsSinceEpoch(1234 + 24 * 60 * 60 * 1000) // one day
      ));

      expect(customIntervall.currentRange.duration.inMilliseconds, 24 * 60 * 60 * 1000);

      dayIntervall.moveDataRangeByStep(1);
      weekIntervall.moveDataRangeByStep(1);
      monthIntervall.moveDataRangeByStep(1);
      yearIntervall.moveDataRangeByStep(1);
      last7DaysIntervall.moveDataRangeByStep(1);
      last30DaysIntervall.moveDataRangeByStep(1);
      customIntervall.moveDataRangeByStep(1);

      expect(dayIntervall.currentRange.duration.inHours, 24);
      expect(weekIntervall.currentRange.duration.inDays, 7);
      expect(monthIntervall.currentRange.duration.inDays, inInclusiveRange(28, 31));
      expect(yearIntervall.currentRange.duration.inDays, inInclusiveRange(365, 366));
      expect(last7DaysIntervall.currentRange.duration.inDays, 7);
      expect(last30DaysIntervall.currentRange.duration.inDays, 30);
      expect(customIntervall.currentRange.duration.inMilliseconds, 24 * 60 * 60 * 1000);

      dayIntervall.moveDataRangeByStep(-2);
      weekIntervall.moveDataRangeByStep(-2);
      monthIntervall.moveDataRangeByStep(-2);
      yearIntervall.moveDataRangeByStep(-2);
      last7DaysIntervall.moveDataRangeByStep(-2);
      last30DaysIntervall.moveDataRangeByStep(-2);
      customIntervall.moveDataRangeByStep(-2);

      expect(dayIntervall.currentRange.duration.inHours, 24);
      expect(weekIntervall.currentRange.duration.inDays, 7);
      expect(monthIntervall.currentRange.duration.inDays, inInclusiveRange(28, 31));
      expect(yearIntervall.currentRange.duration.inDays, inInclusiveRange(365, 366));
      expect(last7DaysIntervall.currentRange.duration.inDays, 7);
      expect(last30DaysIntervall.currentRange.duration.inDays, 30);
      expect(customIntervall.currentRange.duration.inMilliseconds, 24 * 60 * 60 * 1000);
    });
    // TODO: test if it's the most recent intervall
  });

}