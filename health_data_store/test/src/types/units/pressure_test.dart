import 'package:health_data_store/health_data_store.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('returns values the same as passed in', () {
    expect(Pressure.mmHg(120).mmHg, 120);
    expect(Pressure.mmHg(80).mmHg, 80);
    expect(Pressure.kPa(15.5).kPa, 15.5);
    expect(Pressure.kPa(10.0).kPa, 10.0);
  });

  test('converts values correctly', () {
    expect(Pressure.mmHg(120).kPa, inInclusiveRange(15.998, 15.999));
    expect(Pressure.mmHg(80).kPa, inInclusiveRange(10.665, 10.666));
    expect(Pressure.kPa(15.9987).mmHg, 120);
    expect(Pressure.kPa(10.0).mmHg, 75);
  });

  test('should attempt to avoid printing', () {
    expect(() => Pressure.mmHg(120).toString(), throwsA(isA<AssertionError>()));
  });
}
