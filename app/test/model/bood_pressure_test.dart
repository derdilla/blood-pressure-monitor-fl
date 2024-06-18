import 'package:blood_pressure_app/model/blood_pressure/model.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


void main() {
  group('BloodPressureRecord', () {
    test('should initialize with all values supported by dart', () {
      final BloodPressureRecord record = BloodPressureRecord(DateTime.fromMicrosecondsSinceEpoch(1582991592), 0, -50, 1000,
          '((V⍳V)=⍳⍴V)/V←,V    ⌷←⍳→⍴∆∇⊃‾⍎⍕⌈๏ แผ่นดินฮั่นเABCDEFGHIJKLMNOPQRSTUVWXYZ /0123456789abcdefghijklmnopqrstuvwxyz £©µÀÆÖÞßéöÿ–—‘“”„†•…‰™œŠŸž€ ΑΒΓΔΩαβγδω АБВГДабвг, \n \t д∀∂∈ℝ∧∪≡∞ ↑↗↨↻⇣ ┐┼╔╘░►☺♀ ﬁ�⑀₂ἠḂӥẄɐː⍎אԱა',);

      expect(record.creationTime, DateTime.fromMicrosecondsSinceEpoch(1582991592));
      expect(record.systolic, 0);
      expect(record.diastolic, -50);
      expect(record.pulse, 1000);
      expect(record.notes,
          '((V⍳V)=⍳⍴V)/V←,V    ⌷←⍳→⍴∆∇⊃‾⍎⍕⌈๏ แผ่นดินฮั่นเABCDEFGHIJKLMNOPQRSTUVWXYZ /0123456789abcdefghijklmnopqrstuvwxyz £©µÀÆÖÞßéöÿ–—‘“”„†•…‰™œŠŸž€ ΑΒΓΔΩαβγδω АБВГДабвг, \n \t д∀∂∈ℝ∧∪≡∞ ↑↗↨↻⇣ ┐┼╔╘░►☺♀ ﬁ�⑀₂ἠḂӥẄɐː⍎אԱა',);
    });
    test('should not save times at or before epoch', () {
      expect(() => BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(0), 0, 0, 0, ''), throwsAssertionError);
    });
  });

  group('BloodPressureModel', () {
    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    test("Doesn't create new models", () async {
      final model = await BloodPressureModel
        .create(dbPath: join(inMemoryDatabasePath, 'BPMShouldInit.db'));
      expect(model, isNull);
    });
    // TODO: test loading with db files from older versions
  });
}
