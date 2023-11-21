import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import/column.dart';
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
    // TODO: rewrite contents
    if (restoreAbleType == null) return null;

    if (pattern == r'$NOTE') return (RowDataFieldType.notes, formattedRecord);
    if (pattern == r'$COLOR') {
      final value = int.tryParse(formattedRecord);
      return value == null ? null : (RowDataFieldType.color, Color(value));
    }

    // records are parse by replacing the values with capture groups
    final types = RegExp(r'\$(TIMESTAMP|SYS|DIA|PUL)').allMatches(pattern).map((e) => e.group(0)).toList();
    final numRegex = pattern.replaceAll(RegExp(r'\$(TIMESTAMP|SYS|DIA|PUL)'), '([0-9]+.?[0-9]*)'); // ints and doubles
    final numMatches = RegExp(numRegex).allMatches(formattedRecord);
    final numbers = [];
    if (numMatches.isNotEmpty) {
      for (var i = 1; i <= numMatches.first.groupCount; i++) {
        numbers.add(numMatches.first[i]);
      }
    }

    for (var i = 0; i < types.length; i++) {
      switch (types[i]) {
        case r'$TIMESTAMP':
          return (RowDataFieldType.timestamp, int.tryParse(numbers[i] ?? ''));
        case r'$SYS':
          return (RowDataFieldType.sys, double.tryParse(numbers[i] ?? ''));
        case r'$DIA':
          return (RowDataFieldType.dia, double.tryParse(numbers[i] ?? ''));
        case r'$PUL':
          return (RowDataFieldType.pul, double.tryParse(numbers[i] ?? ''));
      }
    }

    assert(false);
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
  // TODO: rewrite (logic)
  RowDataFieldType? get restoreAbleType {
    if (_hasRestoreableType == false) {
      if (pattern.contains(RegExp(r'[{},]'))) {
        _restoreAbleType = null;
      } else if (pattern == r'$TIMESTAMP') { 
        _restoreAbleType = RowDataFieldType.timestamp; 
      } else if (pattern == r'$COLOR') { 
        _restoreAbleType = RowDataFieldType.color; 
      } else if (pattern.contains(RegExp(r'[^{},$]*\$(SYS)[^{},$]*'))) { 
        _restoreAbleType = RowDataFieldType.sys; 
      } else if (pattern.contains(RegExp(r'[^{},$]*\$(DIA)[^{},$]*'))) { 
        _restoreAbleType = RowDataFieldType.dia; 
      } else if (pattern.contains(RegExp(r'[^{},$]*\$(PUL)[^{},$]*'))) { 
        _restoreAbleType = RowDataFieldType.pul; 
      } else if (pattern.contains(RegExp(r'[^{},$]*\$(NOTE)[^{},$]*'))) { 
        _restoreAbleType = RowDataFieldType.notes; 
      } else { _restoreAbleType = null; }
      _hasRestoreableType = true;
    }
    return _restoreAbleType;
  }

}