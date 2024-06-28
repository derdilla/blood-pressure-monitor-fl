
import 'package:health_data_store/health_data_store.dart';

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

  /// Converts a value to a [Pressure] of this [PressureUnit].
  Pressure wrap(num value) => switch(this) {
    PressureUnit.mmHg => Pressure.mmHg(value.toInt()),
    PressureUnit.kPa => Pressure.kPa(value.toDouble()),
  };
}
