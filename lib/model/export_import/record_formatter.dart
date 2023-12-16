import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import/import_field_type.dart';
import 'package:flutter/material.dart';
import 'package:function_tree/function_tree.dart';
import 'package:intl/intl.dart';

/// Class to serialize and deserialize [BloodPressureRecord] values.
abstract interface class Formatter {
  /// Pattern that a user can use to achieve the effect of [convertToCsvValue].
  // TODO: consider making this implementer specific later in the development process
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

  /// Pattern used for formatting values. TODO: explain
  final String pattern;

  @override
  (RowDataFieldType, dynamic)? decode(String formattedRecord) {
    if (restoreAbleType == null) return null;

    final valueRegex = RegExp(pattern.replaceAll(RegExp(r'\$(TIMESTAMP|COLOR|SYS|DIA|PUL|NOTE)'), '(?<value>.*)'),);
    final match = valueRegex.firstMatch(formattedRecord);
    if (match == null) return null;
    var text = match.namedGroup('value');
    if (text == null) return null;

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
      case RowDataFieldType.color:
        final num = int.tryParse(text);
        if (num != null) return Color(num);
        return null;
      case RowDataFieldType.needlePin:
        final num = int.tryParse(text);
        if (num == null) return null;
        return MeasurementNeedlePin(Color(num));
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
    fieldContents = fieldContents.replaceAll(r'$COLOR', record.needlePin?.color.value.toString() ?? '');

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

  @override
  RowDataFieldType? get restoreAbleType {
    if (_hasRestoreableType == false) {
      final replaced = pattern.replaceFirst(RegExp(r'[^{},$]*\$(SYS|DIA|PUL)[^{},$]*'), '');
      print('$pattern - $replaced - ${replaced.contains(RegExp(r'[^{},$]*\$(PUL|DIA|SYS)[^{},$]*'))}');
      if (pattern.contains(RegExp(r'[{},]'))) {
        _restoreAbleType = null;
      } else if (pattern == r'$TIMESTAMP') { 
        _restoreAbleType = RowDataFieldType.timestamp; 
      } else if (pattern == r'$COLOR') { 
        _restoreAbleType = RowDataFieldType.color; 
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
    }
    return _restoreAbleType;
  }

}