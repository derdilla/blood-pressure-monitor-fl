import 'package:blood_pressure_app/features/bluetooth/logic/characteristics/decoding_util.dart';

extension BleDateTimeParser on DateTime {
  static DateTime? parseBle(List<int> bytes, int offset) {
    if (bytes.length < offset + 7) return null;

    final int? year = readUInt16Le(bytes, offset);
    offset += 2;
    final int? month = readUInt8(bytes, offset);
    offset += 1;
    final int? day = readUInt8(bytes, offset);
    offset += 1;
    final int? hourOfDay = readUInt8(bytes, offset);
    offset += 1;
    final int? minute = readUInt8(bytes, offset);
    offset += 1;
    final int? second = readUInt8(bytes, offset);

    if (year == null
      || month == null
      || day == null
      || hourOfDay == null
      || minute == null
      || second == null) {
      return null;
    }

    if (year <= 0
      || month <= 0
      || day <= 0) {
      return null;
    }

    return DateTime(year, month, day, hourOfDay, minute, second);
  }
}
