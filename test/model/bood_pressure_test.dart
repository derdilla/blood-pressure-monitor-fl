import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

void main() {
  group('BloodPressureRecord', () {
    test('should initialize with all values supported by dart', () {
      BloodPressureRecord record = BloodPressureRecord(
          DateTime.fromMicrosecondsSinceEpoch(0),
          0,
          -50,
          1000,
          "((V⍳V)=⍳⍴V)/V←,V    ⌷←⍳→⍴∆∇⊃‾⍎⍕⌈๏ แผ่นดินฮั่นเABCDEFGHIJKLMNOPQRSTUVWXYZ /0123456789abcdefghijklmnopqrstuvwxyz £©µÀÆÖÞßéöÿ–—‘“”„†•…‰™œŠŸž€ ΑΒΓΔΩαβγδω АБВГДабвг, \n \t д∀∂∈ℝ∧∪≡∞ ↑↗↨↻⇣ ┐┼╔╘░►☺♀ ﬁ�⑀₂ἠḂӥẄɐː⍎אԱა");

      expect(record.creationTime, DateTime.fromMicrosecondsSinceEpoch(0));
      expect(record.systolic, 0);
      expect(record.diastolic, -50);
      expect(record.pulse, 1000);
      expect(record.notes, "((V⍳V)=⍳⍴V)/V←,V    ⌷←⍳→⍴∆∇⊃‾⍎⍕⌈๏ แผ่นดินฮั่นเABCDEFGHIJKLMNOPQRSTUVWXYZ /0123456789abcdefghijklmnopqrstuvwxyz £©µÀÆÖÞßéöÿ–—‘“”„†•…‰™œŠŸž€ ΑΒΓΔΩαβγδω АБВГДабвг, \n \t д∀∂∈ℝ∧∪≡∞ ↑↗↨↻⇣ ┐┼╔╘░►☺♀ ﬁ�⑀₂ἠḂӥẄɐː⍎אԱა");
    });
    test('should compare depending on creation time', () {
      var first = BloodPressureRecord(DateTime.fromMicrosecondsSinceEpoch(0), 0, 0, 0, '');
      var middle = BloodPressureRecord(DateTime.fromMicrosecondsSinceEpoch(10000), 0, 0, 0, '');
      var last = BloodPressureRecord(DateTime.now(), 0, 0, 0, '');

      expect(first.compareTo(middle), -1);
      expect(middle.compareTo(first), 1);
      expect(last.compareTo(first), 1);
      expect(last.compareTo(last), 0);
    });
  });

  group('BloodPressureModel',() {
    // setup db path
    databaseFactory = databaseFactoryFfi;

    test('should initialize', () async {
      await clearDbDir();
      expect(() async { await BloodPressureModel.create(); }, returnsNormally);
    });
    test('should start empty', () async {
      await clearDbDir();
      var m = await BloodPressureModel.create();

      expect((await m.getLastX(100)).length, 0);
      expect((await m.getInTimeRange(DateTime.fromMillisecondsSinceEpoch(0), DateTime.now())).length, 0);

    });

    test('should notify when adding entries', () async {
      await clearDbDir();
      var m = await BloodPressureModel.create();

      int listenerCalls = 0;
      int added = 0;
      m.addListener(() {
        listenerCalls++;
        expect(listenerCalls, added);
      });

      m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(0), 0, 0, 0, ''));
      added++;
      m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(1), 0, 0, 0, ''));
      added++;
      m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(2), 0, 0, 0, ''));
      added++;

    });

    test('should return entries as added', () async {
      await clearDbDir();
      var m = await BloodPressureModel.create();

      var r = BloodPressureRecord(DateTime.now(), -172, 10000, 0, "((V⍳V)=⍳⍴V)/V←,V    ⌷←⍳→⍴∆∇⊃‾⍎⍕⌈๏ แผ่นดินฮั่นเABCDEFGHIJKLMNOPQRSTUVWXYZ /0123456789abcdefghijklmnopqrstuvwxyz £©µÀÆÖÞßéöÿ–—‘“”„†•…‰™œŠŸž€ ΑΒΓΔΩαβγδω АБВГДабвг, \n \t д∀∂∈ℝ∧∪≡∞ ↑↗↨↻⇣ ┐┼╔╘░►☺♀ ﬁ�⑀₂ἠḂӥẄɐː⍎אԱა");
      m.addListener(() async {
        var res = (await m.getLastX(1)).first;
        expect(res, isNotNull);
        expect(res.creationTime, r.creationTime);
        expect(res.systolic, r.systolic);
        expect(res.diastolic, r.diastolic);
        expect(res.pulse, r.pulse);
        expect(res.notes, r.notes);
      });

      m.add(r);
    });

    test('should save and load between objects/sessions', () async {
      await clearDbDir();

      var m = await BloodPressureModel.create();
      var r = BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(31415926), -172, 10000, 0, "((V⍳V)=⍳⍴V)/V←,V    ⌷←⍳→⍴∆∇⊃‾⍎⍕⌈๏ แผ่นดินฮั่นเABCDEFGHIJKLMNOPQRSTUVWXYZ /0123456789abcdefghijklmnopqrstuvwxyz £©µÀÆÖÞßéöÿ–—‘“”„†•…‰™œŠŸž€ ΑΒΓΔΩαβγδω АБВГДабвг, \n \t д∀∂∈ℝ∧∪≡∞ ↑↗↨↻⇣ ┐┼╔╘░►☺♀ ﬁ�⑀₂ἠḂӥẄɐː⍎אԱა");
      await m.add(r);

      var m2 = await BloodPressureModel.create();
      var res = (await m2.getLastX(1)).first;

      expect(res.creationTime, r.creationTime);
      expect(res.systolic, r.systolic);
      expect(res.diastolic, r.diastolic);
      expect(res.pulse, r.pulse);
      expect(res.notes, r.notes);
    });

    test('should import exported values', () async {
      await clearDbDir();
      var m = await BloodPressureModel.create();
      var r = BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(31415926), -172, 10000, 0, "((V⍳V)=⍳⍴V)/V←,V    ⌷←⍳→⍴∆∇⊃‾⍎⍕⌈๏ แผ่นดินฮั่นเABCDEFGHIJKLMNOPQRSTUVWXYZ /0123456789abcdefghijklmnopqrstuvwxyz £©µÀÆÖÞßéöÿ–—‘“”„†•…‰™œŠŸž€ ΑΒΓΔΩαβγδω АБВГДабвг, \n \t д∀∂∈ℝ∧∪≡∞ ↑↗↨↻⇣ ┐┼╔╘░►☺♀ ﬁ�⑀₂ἠḂӥẄɐː⍎אԱა");
      await m.add(r);

      m.save((success, msg) {
        expect(success, true);
        // TODO: rewrite blood_pressure to remove UI code entirely
      });
    });
  });
}

Future<void> clearDbDir() async {
  databaseFactory.setDatabasesPath((await getDatabasesPath()).replaceAll('databases', 'test_databases'));
  try {
    Directory(await getDatabasesPath()).deleteSync(recursive: true);
  } catch (e) {
    print('no directory to delete!');
  }
  Directory(await getDatabasesPath()).create(recursive: true);
}