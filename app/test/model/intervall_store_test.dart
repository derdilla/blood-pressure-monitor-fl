
import 'package:blood_pressure_app/model/storage/interval_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_data_store/health_data_store.dart';

void main() {
  test('base constructor should initialize with values', () {
    final storageObject = IntervalStorage(stepSize: TimeStep.month, range: DateRange(
        start: DateTime.fromMillisecondsSinceEpoch(1234),
        end: DateTime.fromMillisecondsSinceEpoch(5678),
    ),);

    expect(storageObject.stepSize, TimeStep.month);
    expect(storageObject.currentRange.start.millisecondsSinceEpoch, 1234);
    expect(storageObject.currentRange.end.millisecondsSinceEpoch, 5678);
  });

  test('base constructor should initialize to default without values', () {
    final storageObject = IntervalStorage();
    expect(storageObject.stepSize, TimeStep.last7Days);
    expect(storageObject.currentRange.start.millisecondsSinceEpoch, lessThanOrEqualTo(DateTime
        .now()
        .millisecondsSinceEpoch,),);
  });

  test('base constructor should initialize with only incomplete parameters', () {
    // only tests for no crashes
    IntervalStorage(stepSize: TimeStep.last30Days);
    IntervalStorage(range: DateRange(
        start: DateTime.fromMillisecondsSinceEpoch(1234),
        end: DateTime.fromMillisecondsSinceEpoch(5678),
    ),);
  });


  test('intervall lengths should match step size', () {
    final dayIntervall = IntervalStorage(stepSize: TimeStep.day);
    final weekIntervall = IntervalStorage(stepSize: TimeStep.week);
    final monthIntervall = IntervalStorage(stepSize: TimeStep.month);
    final yearIntervall = IntervalStorage(stepSize: TimeStep.year);
    final last7DaysIntervall = IntervalStorage(stepSize: TimeStep.last7Days);
    final last30DaysIntervall = IntervalStorage(stepSize: TimeStep.last30Days);

    expect(dayIntervall.currentRange.duration.inHours, 24);
    expect(weekIntervall.currentRange.duration.inDays, 7);
    expect(monthIntervall.currentRange.duration.inDays, inInclusiveRange(28, 31));
    expect(yearIntervall.currentRange.duration.inDays, inInclusiveRange(365, 366));
    expect(last7DaysIntervall.currentRange.duration.inDays, 7);
    expect(last30DaysIntervall.currentRange.duration.inDays, 30);
  });

  test('intervall lengths should still be correct after moving', () {
    final dayIntervall = IntervalStorage(stepSize: TimeStep.day);
    final weekIntervall = IntervalStorage(stepSize: TimeStep.week);
    final monthIntervall = IntervalStorage(stepSize: TimeStep.month);
    final yearIntervall = IntervalStorage(stepSize: TimeStep.year);
    final last7DaysIntervall = IntervalStorage(stepSize: TimeStep.last7Days);
    final last30DaysIntervall = IntervalStorage(stepSize: TimeStep.last30Days);
    final customIntervall = IntervalStorage(stepSize: TimeStep.custom, range: DateRange(
        start: DateTime.fromMillisecondsSinceEpoch(1234),
        end: DateTime.fromMillisecondsSinceEpoch(1234 + 24 * 60 * 60 * 1000), // one day
    ),);

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

}
