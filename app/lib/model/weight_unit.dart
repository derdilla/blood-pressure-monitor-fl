import 'package:health_data_store/health_data_store.dart';

/// A unit [Weight] can be in.
enum WeightUnit {
  /// Kilograms, SI unit
  kg,

  /// Pounds, Defined by the Units of Measurement Regulations 1994
  lbs,

  /// Stone, the imperial unit of mass
  st;

  /// Restore from [serialized].
  static WeightUnit? deserialize(int? value) => switch(value) {
    0 => WeightUnit.kg,
    1 => WeightUnit.lbs,
    2 => WeightUnit.st,
    _ => null,
  };

  /// Create a [WeightUnit.deserialize]able number.
  int get serialized => switch(this) {
    WeightUnit.kg => 0,
    WeightUnit.lbs => 1,
    WeightUnit.st => 2,
  };

  /// Create a [Weight] from a double in this unit.
  Weight store(double value) => switch(this) {
    WeightUnit.kg => Weight.kg(value),
    WeightUnit.lbs => Weight.kg(value * 2.2046226218488),
    WeightUnit.st => Weight.kg(value * 6.350),
  };

  /// Extract a weight to the preferred unit.
  double extract(Weight w) => switch(this) {
    WeightUnit.kg => w.kg,
    WeightUnit.lbs => w.kg / 2.2046226218488,
    WeightUnit.st => w.kg / 6.350,
  };
}
