import 'package:blood_pressure_app/model/blood_pressure/model.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';


void main() {
  group('BloodPressureRecord', () {
    test('should initialize with all values supported by dart', () {
      final OldBloodPressureRecord record = OldBloodPressureRecord(DateTime.fromMicrosecondsSinceEpoch(1582991592), 0, -50, 1000,
          '((V⍳V)=⍳⍴V)/V←,V    ⌷←⍳→⍴∆∇⊃‾⍎⍕⌈๏ แผ่นดินฮั่นเABCDEFGHIJKLMNOPQRSTUVWXYZ /0123456789abcdefghijklmnopqrstuvwxyz £©µÀÆÖÞßéöÿ–—‘“”„†•…‰™œŠŸž€ ΑΒΓΔΩαβγδω АБВГДабвг, \n \t д∀∂∈ℝ∧∪≡∞ ↑↗↨↻⇣ ┐┼╔╘░►☺♀ ﬁ�⑀₂ἠḂӥẄɐː⍎אԱა',);

      expect(record.creationTime, DateTime.fromMicrosecondsSinceEpoch(1582991592));
      expect(record.systolic, 0);
      expect(record.diastolic, -50);
      expect(record.pulse, 1000);
      expect(record.notes,
          '((V⍳V)=⍳⍴V)/V←,V    ⌷←⍳→⍴∆∇⊃‾⍎⍕⌈๏ แผ่นดินฮั่นเABCDEFGHIJKLMNOPQRSTUVWXYZ /0123456789abcdefghijklmnopqrstuvwxyz £©µÀÆÖÞßéöÿ–—‘“”„†•…‰™œŠŸž€ ΑΒΓΔΩαβγδω АБВГДабвг, \n \t д∀∂∈ℝ∧∪≡∞ ↑↗↨↻⇣ ┐┼╔╘░►☺♀ ﬁ�⑀₂ἠḂӥẄɐː⍎אԱა',);
    });
    test('should not save times at or before epoch', () {
      expect(() => OldBloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(0), 0, 0, 0, ''), throwsAssertionError);
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
    /* TODO: make reliable and reduce test data size
    test('correctly loads db from v1.6.4 and prior', () async {

      final model = await BloodPressureModel.create(dbPath: 'test/model/export_import/exported_formats/v1.6.4.db', isFullPath: true);
      expect(model, isNotNull);

      final all = await model!.all;
      expect(all, hasLength(27620));
      expect(all, contains(isA<OldBloodPressureRecord>()
        .having((r) => r.creationTime.millisecondsSinceEpoch, 'time', 1077625200000)
        .having((r) => r.systolic, 'sys', 100)
        .having((r) => r.diastolic, 'dia', 82)
        .having((r) => r.pulse, 'pul', 63),
      ));
    }, timeout: Timeout(Duration(minutes: 3)));
    test('correctly loads db from v1.7.0 and later', () async {
      sqfliteFfiInit();
      final db = await databaseFactoryFfi.openDatabase('test/model/export_import/exported_formats/v1.7.0.db');
      final hDataStore = await HealthDataStore.load(db);
      final bpRepo = hDataStore.bpRepo;

      final all = await bpRepo.get(DateRange.all());
      expect(all, hasLength(27620));
      expect(all, contains(isA<FullEntry>()
        .having((r) => r.time.millisecondsSinceEpoch, 'time', 1077625200000)
        .having((r) => r.sys, 'sys', 100)
        .having((r) => r.dia, 'dia', 82)
        .having((r) => r.pul, 'pul', 63),
      ));
    }, timeout: Timeout(Duration(minutes: 3)));*/
  });
}
