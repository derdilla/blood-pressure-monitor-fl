import 'package:health_data_store/health_data_store.dart';

/// Utility collection that containing all types that make sense at one point in
/// time.
typedef FullEntry = (BloodPressureRecord, Note, List<MedicineIntake>);

extension FastFullEntryGetters on FullEntry {
  /// Timestamp when the entry occurred.
  DateTime get time => this.$1.time;

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
extension FullEntryListUtils on List<FullEntry> {
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
}
