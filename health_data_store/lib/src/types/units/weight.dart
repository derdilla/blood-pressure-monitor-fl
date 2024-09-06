/// Class representing and converting weight.
class Weight {
  /// Create a weight from milligrams.
  Weight.mg(this._value);

  /// Create a weight from grams.
  Weight.g(double value): _value = value * 1000;

  /// Create a weight from kilograms.
  Weight.kg(double value): _value = value * 1000 * 1000;

  /// Create a weight from [grain](https://en.wikipedia.org/wiki/Grain_(unit)).
  Weight.gr(double value): _value = value * 64.79891;

  /// Currently stored weight in milligrams.
  double _value;

  /// The weight in milligrams.
  double get mg => _value;

  /// The weight in grams.
  double get g => _value / 1000;

  /// The weight in kilograms.
  double get kg => _value / 1000000;

  /// Get the value in [grain](https://en.wikipedia.org/wiki/Grain_(unit)).
  double get gr => mg / 64.79891;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
        other is Weight
        && runtimeType == other.runtimeType
        && _value == other._value;

  @override
  int get hashCode => _value.hashCode;
}
