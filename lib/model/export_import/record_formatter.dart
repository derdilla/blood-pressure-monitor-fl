import 'dart:convert';

import 'package:blood_pressure_app/model/blood_pressure/needle_pin.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:blood_pressure_app/model/export_import/import_field_type.dart';
import 'package:flutter/material.dart';
import 'package:function_tree/function_tree.dart';
import 'package:intl/intl.dart';

/// Class to serialize and deserialize [BloodPressureRecord] values.
abstract interface class Formatter {
  /// Pattern that a user can use to achieve the effect of [convertToCsvValue].
  String? get formatPattern;

  /// Creates a string representation of the record.
  ///
  /// There is no guarantee that the information in the record can be restored.
  /// If not null this must follow [formatPattern].
  String encode(BloodPressureRecord record);

  /// Type of data that can be restored from a string obtained by [encode].
  RowDataFieldType? get restoreAbleType;

  /// Attempts to restore data from a encoded record.
  ///
  /// When [restoreAbleType] is null, null will be returned. When [restoreAbleType]
  /// is not null and the pattern was obtained through the [encode] method of this
  /// object a non-null return value of [restoreAbleType] is guaranteed.
  ///
  /// Behavior when decoding data not formatted by [encode] is undefined.
  (RowDataFieldType, dynamic)? decode(String pattern);
}

/// Record [Formatter] that is based on a format pattern.
class ScriptedFormatter implements Formatter {
  ScriptedFormatter(this.pattern);

  /// Pattern used for formatting values.
  final String pattern;

  @override
  (RowDataFieldType, dynamic)? decode(String formattedRecord) {
    if (restoreAbleType == null) return null;

    final text = formattedRecord.substring(_padLeft!, formattedRecord.length - _padRight!);

    final value = (){switch(restoreAbleType!) {
      case RowDataFieldType.timestamp:
        final num = int.tryParse(text);
        if (num != null) return DateTime.fromMillisecondsSinceEpoch(num);
        return null;
      case RowDataFieldType.sys:
      case RowDataFieldType.dia:
      case RowDataFieldType.pul:
        return int.tryParse(text);
      case RowDataFieldType.notes:
        return text;
      case RowDataFieldType.needlePin:
        final num = int.tryParse(text);
        if (num != null) return MeasurementNeedlePin(Color(num));
        try {
          return MeasurementNeedlePin.fromJson(jsonDecode(text));
        } catch (e) {
          assert(e is FormatException || e is TypeError);
          return null;
        }
    }}();
    if (value != null) return (restoreAbleType!, value);
    return null;
  }

  @override
  String encode(BloodPressureRecord record) {
    var fieldContents = pattern;

    // variables
    fieldContents = fieldContents.replaceAll(r'$TIMESTAMP', record.creationTime.millisecondsSinceEpoch.toString());
    fieldContents = fieldContents.replaceAll(r'$SYS', record.systolic.toString());
    fieldContents = fieldContents.replaceAll(r'$DIA', record.diastolic.toString());
    fieldContents = fieldContents.replaceAll(r'$PUL', record.pulse.toString());
    fieldContents = fieldContents.replaceAll(r'$NOTE', record.notes.toString());
    fieldContents = fieldContents.replaceAll(r'$COLOR', jsonEncode(record.needlePin?.toJson()));

    // math
    fieldContents = fieldContents.replaceAllMapped(RegExp(r'\{\{([^}]*)}}'), (m) {
      assert(m.groupCount == 1, 'If a math block is found content is expected');
      final result = m.group(0)!.interpret();
      return result.toString();
    });

    // date format
    fieldContents = fieldContents.replaceAllMapped(RegExp(r'\$FORMAT\{([^}]*)}'), (m) {
      assert(m.groupCount == 1, 'If a FORMAT block is found a group is expected');
      final bothArgs = m.group(1)!;
      int separatorPosition = bothArgs.indexOf(",");
      final timestamp = DateTime.fromMillisecondsSinceEpoch(int.parse(bothArgs.substring(0,separatorPosition)));
      final formatPattern = bothArgs.substring(separatorPosition+1);
      return DateFormat(formatPattern).format(timestamp);
    });

    return fieldContents;
  }

  @override
  String? get formatPattern => pattern;

  bool _hasRestoreableType = false;
  RowDataFieldType? _restoreAbleType;

  /// Count of characters to the left of the value to parse in [pattern].
  ///
  /// Guaranteed to be not null when [restoreAbleType] != null.
  int? _padLeft;

  /// Count of characters to the right of the value to parse in [pattern].
  ///
  /// Guaranteed to be not null when [restoreAbleType] != null.
  int? _padRight;


  @override
  RowDataFieldType? get restoreAbleType {
    if (_hasRestoreableType == false) {
      final replaced = pattern.replaceFirst(RegExp(r'[^{},$]*\$(SYS|DIA|PUL)[^{},$]*'), '');
      if (pattern.contains(RegExp(r'[{},]'))) {
        _restoreAbleType = null;
      } else if (pattern == r'$TIMESTAMP') {
        _restoreAbleType = RowDataFieldType.timestamp;
      } else if (pattern == r'$COLOR') {
        _restoreAbleType = RowDataFieldType.needlePin;
      } else if (pattern == r'$NOTE') {
        _restoreAbleType = RowDataFieldType.notes;
      } else if (replaced.contains(RegExp(r'[^{},$]*\$(PUL|DIA|SYS)[^{},$]*'))) {
        _restoreAbleType = null;
      } else if (pattern.contains(RegExp(r'[^{},$]*\$(SYS)[^{},$]*'))) {
        _restoreAbleType = RowDataFieldType.sys;
      } else if (pattern.contains(RegExp(r'[^{},$]*\$(DIA)[^{},$]*'))) {
        _restoreAbleType = RowDataFieldType.dia;
      } else if (pattern.contains(RegExp(r'[^{},$]*\$(PUL)[^{},$]*'))) {
        _restoreAbleType = RowDataFieldType.pul;
      } else { _restoreAbleType = null; }
      _hasRestoreableType = true;

      if (_restoreAbleType != null) {
        int index = pattern.indexOf(RegExp(r'\$(SYS|DIA|PUL)'));
        int len = 3;
        if (index < 0) {
          index = pattern.indexOf(RegExp(r'\$(NOTE)'));
          len = 4;
        }
        if (index < 0) {
          index = pattern.indexOf(RegExp(r'\$(COLOR)'));
          len = 5;
        }
        if (index < 0) {
          index = pattern.indexOf(RegExp(r'\$(TIMESTAMP)'));
          len = 9;
        }
        assert(index >= 0);
        _padLeft = index;
        _padRight = pattern.length - (index + len + 1);
      }
    }
    return _restoreAbleType;
  }

}

/// Record formatter to format encode and decode formatted timestamps.
///
/// Where possible the direct timestamp should be used as this may reduce
/// accuracy of timestamps.
///
/// This class is mainly a wrapper around [DateFormat].
class ScriptedTimeFormatter implements Formatter {
  /// Creates a new scripted time formatter from a format pattern.
  ///
  /// The pattern follows the ICU style like [DateFormat].
  ScriptedTimeFormatter(String newPattern):
    timeFormatter = DateFormat(newPattern);

  final DateFormat timeFormatter;
  
  @override
  (RowDataFieldType, dynamic)? decode(String pattern) {
    if (pattern.isEmpty) return null;
    try {
      return (RowDataFieldType.timestamp, timeFormatter.parseLoose(pattern));
    } on FormatException {
      return null;
    }
  }

  @override
  String encode(BloodPressureRecord record) => timeFormatter.format(record.creationTime);

  @override
  String? get formatPattern => timeFormatter.pattern;

  @override
  RowDataFieldType? get restoreAbleType => RowDataFieldType.timestamp;
}