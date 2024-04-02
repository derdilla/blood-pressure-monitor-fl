/// Package to easily store health domain data.
///
/// This package provides a safe abstraction over the underlying databases and
/// is constructed in a way that allows to add new measurement types without
/// problems. It follows higher standards regarding backwards compatability and
/// code quality than the rest of the project to prevent data loss.
///
/// All data managed by this package is present in [SI-Units](https://en.wikipedia.org/wiki/SI_units)
/// and dates are rounded to the second.
///
/// To get started call `HealthDataStore.load` with a *new* database object. All
/// database interaction including table setup and versioning will be performed
/// by this library, to avoid inconsistencies and confusion about
/// responsibility.
///
/// Every type of entry (`BloodPressureRecord`, `MedicineIntake` and `Note`) is
/// organized in its own repository. The `MedicineRepository` allows to store
/// medicines used in intakes. Adding medicines to this repository before
/// storing them in the intake repository is required for the intake repository
/// to function correctly.
///
/// Repositories allow querying all entries in a `DateRange` which is a custom
/// implementation of flutters `DateTimeRange` due to the fact that this is a
/// dart library and to facilitate the use of second based timestamps.
library;

export 'src/health_data_store.dart';
// repositories
export 'src/repositories/blood_pressure_repository.dart';
export 'src/repositories/medicine_intake_repository.dart';
export 'src/repositories/medicine_repository.dart';
export 'src/repositories/note_repository.dart';
// types
export 'src/types/blood_pressure_record.dart';
export 'src/types/date_range.dart';
export 'src/types/medicine.dart';
export 'src/types/medicine_intake.dart';
export 'src/types/note.dart';
export 'src/types/units/pressure.dart';
export 'src/types/units/weight.dart';
