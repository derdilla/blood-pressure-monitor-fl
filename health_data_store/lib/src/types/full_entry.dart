import 'dart:math';

import 'package:health_data_store/health_data_store.dart';

/// Utility collection that containing all types that make sense at one point in
/// time.
typedef FullEntry = (BloodPressureRecord, Note, List<MedicineIntake>);

/// Utility getters for nested attributes.
extension FastFullEntryGetters on FullEntry {
  /// Timestamp when the entry occurred.
  DateTime get time => this.$1.time;

  /// Record stored in this entry.
  BloodPressureRecord get recordObj => this.$1;

  /// Note stored in this entry.
  Note get noteObj => this.$2;

  /// Medicine intakes stored in this entry.
  List<MedicineIntake> get intakes => this.$3;

  /// Systolic value of the measurement.
  Pressure? get sys => this.$1.sys;

  /// Diastolic value of the measurement.
  Pressure? get dia => this.$1.dia;

  /// Pulse value of the measurement in bpm.
  int? get pul => this.$1.pul;

  /// Content of the note.
  String? get note => this.$2.note;

  /// ARGB color in number format.
  ///
  /// Can also be obtained through the `dart:ui` Colors `value` attribute.
  /// Sample value: `0xFF42A5F5`
  int? get color => this.$2.color;
}

/// Utility methods to work on full entries.
extension FullEntryList on List<FullEntry> {
  /// Create a list that only contains the records field from the entries.
  List<BloodPressureRecord> get records => map((e) => e.$1).toList();

  /// Create a list that only contains the note field from the entries.
  List<Note> get notes => map((e) => e.$2).toList();

  /// Get all medicines that appear anywhere in the list.
  List<Medicine> get distinctMedicines {
    final Set<Medicine> meds = Set();
    forEach((e) => e.$3.forEach((m) {
          meds.add(m.medicine);
        }));
    return meds.toList();
  }

  /// Merges values at the same time from passed lists to FullEntries and
  /// creates list of them.
  ///
  /// In the resulting list every passed value is contained exactly once.
  static List<FullEntry> merged(
    List<BloodPressureRecord> records,
    List<Note> notes,
    List<MedicineIntake> intakes,
  ) {
    final Set<DateTime> allTimes = {
      ...records.map((r) => r.time),
      ...notes.map((r) => r.time),
      ...intakes.map((r) => r.time),
    };
    final List<FullEntry> entries = [];

    for (final time in allTimes) {
      final recordsAtTime = records.where((r) => r.time == time);
      final notesAtTime = notes.where((n) => n.time == time);
      final intakesAtTime = intakes.where((i) => i.time == time).toList();
      final int count = max(max(recordsAtTime.length, notesAtTime.length), 1);

      final recordsAtTimeIt = recordsAtTime.iterator;
      final notesAtTimeIt = notesAtTime.iterator;
      for (int i = 0; i < count; i++) {
        entries.add((
          recordsAtTimeIt.moveNext()
              ? recordsAtTimeIt.current
              : BloodPressureRecord(time: time),
          notesAtTimeIt.moveNext() ? notesAtTimeIt.current : Note(time: time),
          [],
        ));
      }
      entries.last.$3.addAll(intakesAtTime);
    }

    return entries;
  }
}
