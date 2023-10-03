
import 'package:flutter/material.dart';

/// Utility class for converting dynamic values to concrete data types.
///
/// Mainly used for PDF conversion. There is no guarantee that the internal logic will be useful anywhere else.
class ConvertUtil {
  /// Parses all forms of a boolean someone might put in a a boolean.
  static bool? parseBool(dynamic value) {
    if (value is bool) return value;
    if (value == 'true' || value == 1) return true;
    if (value == 'false' || value == 0) return false;
    return null;
  }

  static int? parseInt(dynamic value) {
    if (value is int || value is int?) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }

  static String? parseString(dynamic value) {
    if (value is String) return value;
    if (value is int || value is double || value is bool) return value.toString();
    return null;
  }

  static String serializeLocale(Locale? value) {
    if (value == null) return 'NULL';
    return value.languageCode;
  }

  static Locale? parseLocale(dynamic value) {
    if (value == 'NULL') return null;
    return Locale(value);
  }

  static MaterialColor? parseMaterialColor(dynamic value) {
    if (value is MaterialColor) return value;
    if (value == null) return null;

    late final Color color;
    if (value is Color) {
      color = value;
    } else if (value is int) {
      color = Color(value);
    } else if (value is String) {
      final int? parsedValue = int.tryParse(value);
      if (parsedValue == null) return null;
      color = Color(parsedValue);
    } else {
      assert(false);
      return null;
    }

    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(value, swatch);
  }

  static DateTimeRange? parseRange(dynamic start, dynamic end) {
    final startTimestamp = parseInt(start);
    final endTimestamp = parseInt(end);
    if (startTimestamp == null || endTimestamp == null) return null;
    return DateTimeRange(
        start: DateTime.fromMillisecondsSinceEpoch(startTimestamp),
        end: DateTime.fromMillisecondsSinceEpoch(endTimestamp)
    );
  }
}