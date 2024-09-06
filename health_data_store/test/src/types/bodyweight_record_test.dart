import 'package:health_data_store/src/types/bodyweight_record.dart';
import 'package:health_data_store/src/types/units/weight.dart';
import 'package:test/test.dart';

void main() {
  test('should initialize', () {
    final weight = BodyweightRecord(
      time: DateTime.now(),
      weight: Weight.kg(60),
    );
    expect(weight.weight, Weight.kg(60));
  });
}

BodyweightRecord mockWeight({
  int? time,
  double? kg,
}) => BodyweightRecord(
  time: time!=null ? DateTime.fromMillisecondsSinceEpoch(time) : DateTime.now(),
  weight: Weight.kg(kg ?? 42.0),
);
