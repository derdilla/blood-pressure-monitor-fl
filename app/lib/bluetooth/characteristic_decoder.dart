import 'package:blood_pressure_app/model/blood_pressure/record.dart';

/// Decoder for blood pressure values.
class CharacteristicDecoder {
  /// Parse a measurement from binary data.
  static BloodPressureRecord decodeMeasurement(List<int> data) {
    // This is valid parsing according to: https://github.com/NobodyForNothing/blood-pressure-monitor-fl/issues/80#issuecomment-2067212894
    // TODO: check if this really works and remove old characteristics decodes if it does.
    print(data);
    return BloodPressureRecord(DateTime.now(), data[1], data[3], data[14], '');
  }
}
