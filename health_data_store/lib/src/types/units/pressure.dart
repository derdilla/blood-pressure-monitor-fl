/// Class representing and converting [pressure](https://en.wikipedia.org/wiki/Pressure).
class Pressure {
  /// Create pressure from kilopascal.
  Pressure.kPa(double value) : _valPa = value * 1000;

  /// Create pressure from [Millimetre of mercury](https://en.wikipedia.org/wiki/Millimetre_of_mercury).
  Pressure.mmHg(int value) : _valPa = value * 133.322;

  /// Currently stored value in pascal.
  double _valPa;

  /// Get value in kilopascal.
  double get kPa => _valPa / 1000;

  /// Get value in [Millimetre of mercury](https://en.wikipedia.org/wiki/Millimetre_of_mercury).
  int get mmHg => (_valPa / 133.322).round();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Pressure &&
          runtimeType == other.runtimeType &&
          _valPa == other._valPa;

  @override
  int get hashCode => _valPa.hashCode;

  @override
  String toString() => mmHg.toString();
}
