import 'package:flutter_test/flutter_test.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';

void main() {
  test('test storing and loading blood pressures', () {
    final pressureStorage = BloodPressureModel();
    var listenerCalled = 0;
    pressureStorage.addListener(() {
      expect(pressureStorage.allMeasurements.length, 1);
      expect(pressureStorage.allMeasurements.first.systolic, 100);
      expect(pressureStorage.allMeasurements.first.diastolic, 90);
      expect(pressureStorage.allMeasurements.first.pulse, 80);
      expect(pressureStorage.allMeasurements.first.notes, "Test comment 测试评论");
      listenerCalled++;
    });
    pressureStorage.add(BloodPressureRecord(DateTime.fromMicrosecondsSinceEpoch(0), 100, 90, 80, "Test comment 测试评论"));
    expect(listenerCalled, 1);
  });
}