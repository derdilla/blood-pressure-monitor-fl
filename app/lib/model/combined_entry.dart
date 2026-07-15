import 'package:health_data_store/health_data_store.dart';

/// Timestamped collection of values
class CombinedEntry {
  CombinedEntry({
    required this.time,
    Note? note,
    BloodPressureRecord? record,
    MedicineIntake? intake,
    BodyweightRecord? weight,
  }): assert(note == null || note.time == time),
      assert(record == null || record.time == time),
      assert(intake == null || intake.time == time),
      assert(weight == null || weight.time == time),
      _note = note,
      _record = record,
      _intake = intake,
      _weight = weight;

  final DateTime time;

  Note? _note;
  Note? get note => _note;
  set note(Note? value) {
    assert(value == null || value.time == time);
    _note = value;
  }

  BloodPressureRecord? _record;
  BloodPressureRecord? get record => _record;
  set record(BloodPressureRecord? value) {
    assert(value == null || value.time == time);
    _record = value;
  }

  MedicineIntake? _intake;
  MedicineIntake? get intake => _intake;
  set intake(MedicineIntake? value) {
    assert(value == null || value.time == time);
    _intake = value;
  }

  BodyweightRecord? _weight;
  BodyweightRecord? get weight => _weight;
  set weight(BodyweightRecord? value) {
    assert(value == null || value.time == time);
    _weight = value;
  }

  /// Systolic value of the measurement.
  Pressure? get sys => record?.sys;

  /// Diastolic value of the measurement.
  Pressure? get dia => record?.dia;

  /// Pulse value of the measurement in bpm.
  int? get pul => record?.pul;

  /// ARGB color in number format.
  ///
  /// Can also be obtained through the `Colors.toARGB32()` method in `dart:ui`.
  /// Sample value: `0xFF42A5F5`
  int? get color => note?.color;

  @override
    String toString() => 'CombinedEntry($time, $sys, $dia, $pul, '
      '${note?.note}, $color, ${intake?.medicine}, ${intake?.dosis}, '
      '${weight?.weight})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CombinedEntry &&
          runtimeType == other.runtimeType &&
          time == other.time &&
          _note == other._note &&
          _record == other._record &&
          _intake == other._intake &&
          _weight == other._weight;

  @override
  int get hashCode => Object.hash(time, _note, _record, _intake, _weight);
}

/// Utility methods to work on full entries.
extension CombinedEntryList on List<CombinedEntry> {
  /// Create a list that only contains the records field from the entries.
  List<BloodPressureRecord> get records => map((e) => e.record)
      .nonNulls
      .toList();

  /// Create a list that only contains the note field from the entries.
  List<Note> get notes => map((e) => e.note).nonNulls.toList();

  /// Get all medicines that appear anywhere in the list.
  List<Medicine> get distinctMedicines => <Medicine>{
    for (final e in this)
      if (e.intake != null)
        e.intake!.medicine,
  }.toList();

  /// Merges values at the same time from passed lists to FullEntries and
  /// creates list of them.
  ///
  /// In the resulting list every passed value is contained exactly once.
  static List<CombinedEntry> merged(
    List<BloodPressureRecord> records,
    List<Note> notes,
    List<MedicineIntake> intakes,
  ) {
    final entries = <DateTime, CombinedEntry>{};

    for (final r in records) {
      entries.putIfAbsent(r.time, () => CombinedEntry(time: r.time));
      entries[r.time]!.record = r;
    }
    for (final n in notes) {
      if ((n.note?.isEmpty ?? true) && n.color == null) continue;
      entries.putIfAbsent(n.time, () => CombinedEntry(time: n.time));
      entries[n.time]!.note = n;
    }
    for (final i in intakes) {
      entries.putIfAbsent(i.time, () => CombinedEntry(time: i.time));
      entries[i.time]!.intake = i;
    }

    return entries.values.toList();
  }
}
