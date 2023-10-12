import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/ram_only_implementations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('BloodPressureRecord', () {
    test('should initialize with all values supported by dart', () {
      BloodPressureRecord record = BloodPressureRecord(DateTime.fromMicrosecondsSinceEpoch(1582991592), 0, -50, 1000,
          "((V⍳V)=⍳⍴V)/V←,V    ⌷←⍳→⍴∆∇⊃‾⍎⍕⌈๏ แผ่นดินฮั่นเABCDEFGHIJKLMNOPQRSTUVWXYZ /0123456789abcdefghijklmnopqrstuvwxyz £©µÀÆÖÞßéöÿ–—‘“”„†•…‰™œŠŸž€ ΑΒΓΔΩαβγδω АБВГДабвг, \n \t д∀∂∈ℝ∧∪≡∞ ↑↗↨↻⇣ ┐┼╔╘░►☺♀ ﬁ�⑀₂ἠḂӥẄɐː⍎אԱა");

      expect(record.creationTime, DateTime.fromMicrosecondsSinceEpoch(1582991592));
      expect(record.systolic, 0);
      expect(record.diastolic, -50);
      expect(record.pulse, 1000);
      expect(record.notes,
          "((V⍳V)=⍳⍴V)/V←,V    ⌷←⍳→⍴∆∇⊃‾⍎⍕⌈๏ แผ่นดินฮั่นเABCDEFGHIJKLMNOPQRSTUVWXYZ /0123456789abcdefghijklmnopqrstuvwxyz £©µÀÆÖÞßéöÿ–—‘“”„†•…‰™œŠŸž€ ΑΒΓΔΩαβγδω АБВГДабвг, \n \t д∀∂∈ℝ∧∪≡∞ ↑↗↨↻⇣ ┐┼╔╘░►☺♀ ﬁ�⑀₂ἠḂӥẄɐː⍎אԱა");
    });
    test('should not save times at or before epoch', () {
      expect(() => BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(0), 0, 0, 0, ""), throwsAssertionError);
    });
  });

  group('BloodPressureModel', () {
    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    test('should initialize', () async {
      expect(() async {
        await BloodPressureModel.create(dbPath: join(inMemoryDatabasePath, 'BPMShouldInit.db'));
      }, returnsNormally);
    });
    test('should start empty', () async {
      var m = await BloodPressureModel.create(dbPath: join(inMemoryDatabasePath, 'BPMShouldStartEmpty.db'));

      expect((await m.getInTimeRange(DateTime.fromMillisecondsSinceEpoch(1), DateTime.now())).length, 0);
    });

    test('should notify when adding entries', () async {
      var m = await BloodPressureModel.create(dbPath: join(inMemoryDatabasePath, 'BPMShouldNotifyWhenAdding.db'));

      int listenerCalls = 0;
      m.addListener(() {
        listenerCalls++;
      });

      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(1), 0, 0, 0, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(1), 0, 0, 0, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(2), 0, 0, 0, ''));

      expect(listenerCalls, 3);
    });

    test('should return entries as added', () async {
      var m = await BloodPressureModel.create(dbPath: join(inMemoryDatabasePath, 'BPMShouldReturnAddedEntries.db'));

      var r = BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(31415926), -172, 10000, 0,
          "((V⍳V)=⍳⍴V)/V←,V    ⌷←⍳→⍴∆∇⊃‾⍎⍕⌈๏ แผ่นดินฮั่นเABCDEFGHIJKLMNOPQRSTUVWXYZ /0123456789abcdefghijklmnopqrstuvwxyz £©µÀÆÖÞßéöÿ–—‘“”„†•…‰™œŠŸž€ ΑΒΓΔΩαβγδω АБВГДабвг, \n \t д∀∂∈ℝ∧∪≡∞ ↑↗↨↻⇣ ┐┼╔╘░►☺♀ ﬁ�⑀₂ἠḂӥẄɐː⍎אԱა");
      m.addListener(() async {
        var res = (await m.getInTimeRange(DateTime.fromMillisecondsSinceEpoch(1), DateTime.now())).first;
        expect(res, isNotNull);
        expect(res.creationTime, r.creationTime);
        expect(res.systolic, r.systolic);
        expect(res.diastolic, r.diastolic);
        expect(res.pulse, r.pulse);
        expect(res.notes, r.notes);
        return;
      });

      m.add(r);
    });

    test('should save and load between objects/sessions', () async {
      var m = await BloodPressureModel.create(dbPath: join(inMemoryDatabasePath, 'BPMShouldPersist.db'));
      var r = BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(31415926), -172, 10000, 0,
          "((V⍳V)=⍳⍴V)/V←,V    ⌷←⍳→⍴∆∇⊃‾⍎⍕⌈๏ แผ่นดินฮั่นเABCDEFGHIJKLMNOPQRSTUVWXYZ /0123456789abcdefghijklmnopqrstuvwxyz £©µÀÆÖÞßéöÿ–—‘“”„†•…‰™œŠŸž€ ΑΒΓΔΩαβγδω АБВГДабвг, \n \t д∀∂∈ℝ∧∪≡∞ ↑↗↨↻⇣ ┐┼╔╘░►☺♀ ﬁ�⑀₂ἠḂӥẄɐː⍎אԱა");
      await m.add(r);

      var m2 = await BloodPressureModel.create(dbPath: join(inMemoryDatabasePath, 'BPMShouldPersist.db'));
      var res = (await m2.getInTimeRange(DateTime.fromMillisecondsSinceEpoch(1), DateTime.now())).first;

      expect(res.creationTime, r.creationTime);
      expect(res.systolic, r.systolic);
      expect(res.diastolic, r.diastolic);
      expect(res.pulse, r.pulse);
      expect(res.notes, r.notes);
    });

    test('should delete', () async {
      var m = await BloodPressureModel.create(dbPath: join(inMemoryDatabasePath, 'BPMShouldDelete.db'));

      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(758934), 123, 87, 65, ';)'));
      expect((await m.getInTimeRange(DateTime.fromMillisecondsSinceEpoch(1), DateTime.now())).length, 1);
      expect((await m.getInTimeRange(DateTime.fromMillisecondsSinceEpoch(1), DateTime.now())).length, 1);

      await m.delete(DateTime.fromMillisecondsSinceEpoch(758934));

      expect((await m.getInTimeRange(DateTime.fromMillisecondsSinceEpoch(1), DateTime.now())).length, 0);
      expect((await m.getInTimeRange(DateTime.fromMillisecondsSinceEpoch(1), DateTime.now())).length, 0);
    });
  });

  group("RamBloodPressureModel should behave like BloodPressureModel", () {
    test('should initialize', () async {
      expect(() async => RamBloodPressureModel(), returnsNormally);
    });

    test('should start empty', () async {
      var m = RamBloodPressureModel();
      expect((await m.getInTimeRange(DateTime.fromMillisecondsSinceEpoch(1), DateTime.now())).length, 0);
    });

    test('should notify when adding entries', () async {
      var m = RamBloodPressureModel();

      int listenerCalls = 0;
      m.addListener(() {
        listenerCalls++;
      });

      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(1), 0, 0, 0, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(1), 0, 0, 0, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(2), 0, 0, 0, ''));

      expect(listenerCalls, 3);
    });

    test('should return entries as added', () async {
      var m = RamBloodPressureModel();

      var r = BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(31415926), -172, 10000, 0,
          "((V⍳V)=⍳⍴V)/V←,V    ⌷←⍳→⍴∆∇⊃‾⍎⍕⌈๏ แผ่นดินฮั่นเABCDEFGHIJKLMNOPQRSTUVWXYZ /0123456789abcdefghijklmnopqrstuvwxyz £©µÀÆÖÞßéöÿ–—‘“”„†•…‰™œŠŸž€ ΑΒΓΔΩαβγδω АБВГДабвг, \n \t д∀∂∈ℝ∧∪≡∞ ↑↗↨↻⇣ ┐┼╔╘░►☺♀ ﬁ�⑀₂ἠḂӥẄɐː⍎אԱა");
      m.addListener(() async {
        var res = (await m.getInTimeRange(DateTime.fromMillisecondsSinceEpoch(1), DateTime.now())).first;
        expect(res, isNotNull);
        expect(res.creationTime, r.creationTime);
        expect(res.systolic, r.systolic);
        expect(res.diastolic, r.diastolic);
        expect(res.pulse, r.pulse);
        expect(res.notes, r.notes);
        return;
      });

      m.add(r);
    });
  });
}
