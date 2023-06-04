import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:blood_pressure_app/model/ram_only_implementations.dart';

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
  });

  group('BloodPressureModel',() {
    // setup db path
    databaseFactory = databaseFactoryFfi;

    test('should initialize', () async {
      expect(() async { await BloodPressureModel.create(dbPath: '/tmp/bp_test/should_init');
        }, returnsNormally);
    });
    test('should start empty', () async {
      var m = await BloodPressureModel.create(dbPath: '/tmp/bp_test/should_start_empty');

      expect((await m.getInTimeRange(DateTime.fromMillisecondsSinceEpoch(0), DateTime.now())).length, 0);

    });

    test('should notify when adding entries', () async {
      var m = await BloodPressureModel.create(dbPath: '/tmp/bp_test/should_notify_when_add');

      int listenerCalls = 0;
      m.addListener(() {
        listenerCalls++;
      });

      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(0), 0, 0, 0, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(1), 0, 0, 0, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(2), 0, 0, 0, ''));

      expect(listenerCalls, 3);
    });

    test('should return entries as added', () async {
      var m = await BloodPressureModel.create(dbPath: '/tmp/bp_test/should_return_as_added');

      var r = BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(31415926), -172, 10000, 0, "((V⍳V)=⍳⍴V)/V←,V    ⌷←⍳→⍴∆∇⊃‾⍎⍕⌈๏ แผ่นดินฮั่นเABCDEFGHIJKLMNOPQRSTUVWXYZ /0123456789abcdefghijklmnopqrstuvwxyz £©µÀÆÖÞßéöÿ–—‘“”„†•…‰™œŠŸž€ ΑΒΓΔΩαβγδω АБВГДабвг, \n \t д∀∂∈ℝ∧∪≡∞ ↑↗↨↻⇣ ┐┼╔╘░►☺♀ ﬁ�⑀₂ἠḂӥẄɐː⍎אԱა");
      m.addListener(() async {
        var res = (await m.getInTimeRange(DateTime.fromMillisecondsSinceEpoch(0), DateTime.now())).first;
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
      var m = await BloodPressureModel.create(dbPath: '/tmp/bp_test/should_store_between_sessions');
      var r = BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(31415926), -172, 10000, 0, "((V⍳V)=⍳⍴V)/V←,V    ⌷←⍳→⍴∆∇⊃‾⍎⍕⌈๏ แผ่นดินฮั่นเABCDEFGHIJKLMNOPQRSTUVWXYZ /0123456789abcdefghijklmnopqrstuvwxyz £©µÀÆÖÞßéöÿ–—‘“”„†•…‰™œŠŸž€ ΑΒΓΔΩαβγδω АБВГДабвг, \n \t д∀∂∈ℝ∧∪≡∞ ↑↗↨↻⇣ ┐┼╔╘░►☺♀ ﬁ�⑀₂ἠḂӥẄɐː⍎אԱა");
      await m.add(r);

      var m2 = await BloodPressureModel.create(dbPath: '/tmp/bp_test/should_store_between_sessions');
      var res = (await m2.getInTimeRange(DateTime.fromMillisecondsSinceEpoch(0), DateTime.now())).first;

      expect(res.creationTime, r.creationTime);
      expect(res.systolic, r.systolic);
      expect(res.diastolic, r.diastolic);
      expect(res.pulse, r.pulse);
      expect(res.notes, r.notes);
    });

    test('should import exported values', () async {
      var m = await BloodPressureModel.create(dbPath: '/tmp/bp_test/should_import_exported');
      var r = BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(31415926), -172, 10000, 0, "((V⍳V)=⍳⍴V)/V←,V    ⌷←⍳→⍴∆∇⊃‾⍎⍕⌈๏ แผ่นดินฮั่นเABCDEFGHIJKLMNOPQRSTUVWXYZ /0123456789abcdefghijklmnopqrstuvwxyz £©µÀÆÖÞßéöÿ–—‘“”„†•…‰™œŠŸž€ ΑΒΓΔΩαβγδω АБВГДабвг, \n \t д∀∂∈ℝ∧∪≡∞ ↑↗↨↻⇣ ┐┼╔╘░►☺♀ ﬁ�⑀₂ἠḂӥẄɐː⍎אԱა");
      await m.add(r);

      m.save((success, msg) {
        expect(success, true);
      });
    });

    test('should delete', () async {
      var m = await BloodPressureModel.create(dbPath: '/tmp/bp_test/should_delete');

      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(758934), 123, 87, 65, ';)'));
      expect((await m.getInTimeRange(DateTime.fromMillisecondsSinceEpoch(0), DateTime.now())).length, 1);
      expect((await m.getInTimeRange(DateTime.fromMillisecondsSinceEpoch(0), DateTime.now())).length, 1);

      await m.delete(DateTime.fromMillisecondsSinceEpoch(758934));

      expect((await m.getInTimeRange(DateTime.fromMillisecondsSinceEpoch(0), DateTime.now())).length, 0);
      expect((await m.getInTimeRange(DateTime.fromMillisecondsSinceEpoch(0), DateTime.now())).length, 0);
    });

    test('should return averages', () async {
      var m = await BloodPressureModel.create(dbPath: '/tmp/bp_test/should_avg');

      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(1), 122, 87, 65, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(2), 100, 60, 62, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(3), 111, 73, 73, ''));
      
      expect(await m.avgSys, 111); // 111 // gets 116
      expect(await m.avgDia, 73); // 73.3333...
      expect(await m.avgPul, 66); // 66.6666...
    });

    test('should return max', () async {
      var m = await BloodPressureModel.create(dbPath: '/tmp/bp_test/should_max');

      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(1), 123, 87, 65, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(2), 100, 60, 62, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(3), 111, 73, 73, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(4), 111, 73, 73, ''));

      expect(await m.maxSys, 123);
      expect(await m.maxDia, 87);
      expect(await m.maxPul, 73);
    });

    test('should return min', () async {
      var m = await BloodPressureModel.create(dbPath: '/tmp/bp_test/should_min');

      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(1), 123, 87, 65, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(2), 100, 60, 62, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(3), 111, 73, 73, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(4), 100, 60, 62, ''));

      expect(await m.minSys, 100);
      expect(await m.minDia, 60);
      expect(await m.minPul, 62);
    });

    test('should know count', () async {
      var m = await BloodPressureModel.create(dbPath: '/tmp/bp_test/should_count');

      for (int i = 1; i < 101; i++) {
        await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(i), 0, 0, 0, ''));
      }

      expect(await m.count, 100);
    });

    test('should determine special days', () async {
      var m = await BloodPressureModel.create(dbPath: '/tmp/bp_test/should_special_days');

      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(100), 0, 0, 0, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(-2200), 0, 0, 0, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(9000000), 0, 0, 0, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(3124159), 0, 0, 0, ''));

      expect((await m.firstDay), DateTime.fromMillisecondsSinceEpoch(-2200));
      expect((await m.lastDay), DateTime.fromMillisecondsSinceEpoch(9000000));
    });
  });

  group("RamBloodPressureModel should behave like BloodPressureModel", () {
    test('should initialize', () async {
      expect(() async => RamBloodPressureModel(), returnsNormally);
    });

    test('should start empty', () async {
      var m = RamBloodPressureModel();
      expect((await m.getInTimeRange(DateTime.fromMillisecondsSinceEpoch(0), DateTime.now())).length, 0);
    });

    test('should notify when adding entries', () async {
      var m = RamBloodPressureModel();

      int listenerCalls = 0;
      m.addListener(() {
        listenerCalls++;
      });

      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(0), 0, 0, 0, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(1), 0, 0, 0, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(2), 0, 0, 0, ''));

      expect(listenerCalls, 3);
    });

    test('should return entries as added', () async {
      var m = RamBloodPressureModel();

      var r = BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(31415926), -172, 10000, 0, "((V⍳V)=⍳⍴V)/V←,V    ⌷←⍳→⍴∆∇⊃‾⍎⍕⌈๏ แผ่นดินฮั่นเABCDEFGHIJKLMNOPQRSTUVWXYZ /0123456789abcdefghijklmnopqrstuvwxyz £©µÀÆÖÞßéöÿ–—‘“”„†•…‰™œŠŸž€ ΑΒΓΔΩαβγδω АБВГДабвг, \n \t д∀∂∈ℝ∧∪≡∞ ↑↗↨↻⇣ ┐┼╔╘░►☺♀ ﬁ�⑀₂ἠḂӥẄɐː⍎אԱა");
      m.addListener(() async {
        var res = (await m.getInTimeRange(DateTime.fromMillisecondsSinceEpoch(0), DateTime.now())).first;
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


    test('should return averages', () async {
      var m = RamBloodPressureModel();

      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(1), 122, 87, 65, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(2), 100, 60, 62, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(3), 111, 73, 73, ''));

      expect(await m.avgSys, 111); // 111 // gets 116
      expect(await m.avgDia, 73); // 73.3333...
      expect(await m.avgPul, 66); // 66.6666...
    });

    test('should return max', () async {
      var m = RamBloodPressureModel();

      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(1), 123, 87, 65, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(2), 100, 60, 62, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(3), 111, 73, 73, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(4), 111, 73, 73, ''));

      expect(await m.maxSys, 123);
      expect(await m.maxDia, 87);
      expect(await m.maxPul, 73);
    });

    test('should return min', () async {
      var m = RamBloodPressureModel();

      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(1), 123, 87, 65, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(2), 100, 60, 62, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(3), 111, 73, 73, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(4), 100, 60, 62, ''));

      expect(await m.minSys, 100);
      expect(await m.minDia, 60);
      expect(await m.minPul, 62);
    });

    test('should know count', () async {
      var m = RamBloodPressureModel();

      for (int i = 1; i < 101; i++) {
        await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(i), 0, 0, 0, ''));
      }

      expect(await m.count, 100);
    });

    test('should determine special days', () async {
      var m = RamBloodPressureModel();

      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(100), 0, 0, 0, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(-2200), 0, 0, 0, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(9000000), 0, 0, 0, ''));
      await m.add(BloodPressureRecord(DateTime.fromMillisecondsSinceEpoch(3124159), 0, 0, 0, ''));

      expect((await m.firstDay), DateTime.fromMillisecondsSinceEpoch(-2200));
      expect((await m.lastDay), DateTime.fromMillisecondsSinceEpoch(9000000));
    });
  });
}