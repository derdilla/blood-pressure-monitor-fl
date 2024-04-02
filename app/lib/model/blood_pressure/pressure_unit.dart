
/// A unit blood pressure can be in.
///
/// While mmHg is more common, some devices use kPa
enum PressureUnit {
  /// Millimeters of mercury.
  mmHg,
  /// Kilo Pascal
  kPa;

  /// Encodes the pressure unit to [decode]able value.
  int encode() => switch(this) {
    PressureUnit.mmHg => 0,
    PressureUnit.kPa => 1,
  };
  /// Decodes a pressure unit from an [encode]d value.
  static PressureUnit? decode(int? encoded) => switch(encoded) {
    0 => PressureUnit.mmHg,
    1 => PressureUnit.kPa,
    null => null,
    _ => (){
      assert(false);
      return null;
    }(),
  };
}
