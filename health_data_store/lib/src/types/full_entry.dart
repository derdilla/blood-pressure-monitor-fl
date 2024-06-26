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
  /// In the resulting list every passed value is contained exactly once. This
  /// requires that passed [records] and [notes] contain only one entry per
  /// timestamp.
  static List<FullEntry> merged(
    List<BloodPressureRecord> records,
    List<Note> notes,
    List<MedicineIntake> intakes,
  ) {
    // TODO: make these asserts unneccessary
    assert(!records
      .any((rOuter) => records
        .where((rInner) => rOuter.time == rInner.time).length != 1,
      ),
      'records should only contain one entry per timestamp',
    );
    assert(!notes
      .any((nOuter) => notes
        .where((nInner) => nOuter.time == nInner.time).length != 1,
      ),
      'notes should only contain one entry per timestamp',
    );

    // Algorithm:
    // 1. Create entry for every record and add notes and intakes at the same
    //    time.
    // 2. Determine notes that are not already in the list.
    // 3. Create entry for these notes and add intakes at the same time.
    // 4. Determine intakes that are not already in the list.
    // 5. Group intakes by time.
    // 6. Create entries for intakes at those times.

    final List<FullEntry> entries = [];
    for (final r in records) {
      final n = notes.where((n) => n.time == r.time).firstOrNull ?? Note(time: r.time);
      final i = intakes.where((n) => n.time == r.time).toList();
      entries.add((r, n, i));
    }

    Set<DateTime> times = entries.map((e) => e.time).toSet();
    final remainingNotes = notes.where((n) => !times.contains(n.time));

    for (final n in remainingNotes) {
      final i = intakes.where((i) => i.time == n.time).toList();
      entries.add((BloodPressureRecord(time: n.time), n, i));
    }

    times = entries.map((e) => e.time).toSet();
    final remainingIntakes = intakes.where((i) => !times.contains(i.time));

    final groupedIntakes = <DateTime, List<MedicineIntake>>{};
    for (final intake in remainingIntakes) {
      final list = (groupedIntakes[intake.time] ??= []);
      list.add(intake);
    }

    for (final i in groupedIntakes.values) {
      entries.add((BloodPressureRecord(time: i.first.time), Note(time: i.first.time), i));
    }

    return entries;
  }
}
