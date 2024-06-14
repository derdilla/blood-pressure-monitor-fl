import 'package:health_data_store/health_data_store.dart';

/// Utility collection that containing all types that make sense at one point in
/// time.
typedef FullEntry = (BloodPressureRecord, Note, List<MedicineIntake>);

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
