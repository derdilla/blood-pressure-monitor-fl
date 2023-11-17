import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:function_tree/function_tree.dart';
import 'package:intl/intl.dart';

/// Convert [BloodPressureRecord]s from and to strings and provide metadata about the conversion.
class ExportColumn {
  /// Create object that turns data into strings.
  ///
  /// Example: ExportColumn(internalColumnName: 'pulsePressure', columnTitle: 'Pulse pressure', formatPattern: '{{$SYS-$DIA}}')
  ExportColumn({required this.internalName, required this.columnTitle, required String formatPattern, this.editable = true, this.hidden = false}) {
    this.formatPattern = formatPattern.replaceAll('{{}}', '');
  }

  /// pure name as in the title of the csv file and for internal purposes. Should not contain special characters and spaces.
  late final String internalName;

  /// Display title of the column. Possibly localized
  late final String columnTitle;

  /// Pattern to create the field contents from:
  /// It supports inserting values for $TIMESTAMP, $SYS $DIA $PUL, $COLOR and $NOTE. Where $TIMESTAMP is the time since unix epoch in milliseconds.
  /// To format a timestamp in the same format as the $TIMESTAMP variable, $FORMAT(<timestamp>, <formatString>).
  /// It is supported to use basic mathematics inside of double brackets ("{{}}"). In case one of them is not present in the record, -1 is provided.
  /// The following math is supported:
  /// Operations: [+, -, *, /, %, ^]
  /// One-parameter functions [ abs, acos, asin, atan, ceil, cos, cosh, cot, coth, csc, csch, exp, floor, ln, log, round sec, sech, sin, sinh, sqrt, tan, tanh ]
  /// Two-parameter functions [ log, nrt, pow ]
  /// Constants [ e, pi, ln2, ln10, log2e, log10e, sqrt1_2, sqrt2 ]
  /// The full math interpreter specification can be found here: https://pub.dev/documentation/function_tree/latest#interpreter
  ///
  /// The String is processed in the following order:
  /// 1. variable replacement
  /// 2. Math
  /// 3. Date format
  late final String formatPattern;

  final bool editable;

  /// doesn't show up as unused / hidden field in list
  final bool hidden;

  factory ExportColumn.fromJson(Map<String, dynamic> json, [editable = true, hidden = false]) =>
    ExportColumn(
      internalName: json['internalColumnName'],
      columnTitle: json['columnTitle'],
      formatPattern: json['formatPattern'],
      editable: editable,
      hidden: hidden
    );

  Map<String, dynamic> toJson() => {
    'internalColumnName': internalName,
    'columnTitle': columnTitle,
    'formatPattern': formatPattern
  };

  /// Turns a [BloodPressureRecord] into a string as defined in the [formatPattern].
  String formatRecord(BloodPressureRecord record) {
    var fieldContents = formatPattern;

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

  /// Parses records if [isReversible] is true else returns an empty list
  List<(RowDataFieldType, dynamic)> parseRecord(String formattedRecord) {
    if (!isReversible || formattedRecord == 'null') return [];

    if (formatPattern == r'$NOTE') return [(RowDataFieldType.notes, formattedRecord)];
    if (formatPattern == r'$COLOR') {
      final value = int.tryParse(formattedRecord);
      return value == null ? [] : [(RowDataFieldType.color, Color(value))];
    }

    // records are parse by replacing the values with capture groups
    final types = RegExp(r'\$(TIMESTAMP|SYS|DIA|PUL)').allMatches(formatPattern).map((e) => e.group(0)).toList();
    final numRegex = formatPattern.replaceAll(RegExp(r'\$(TIMESTAMP|SYS|DIA|PUL)'), '([0-9]+.?[0-9]*)'); // ints and doubles
    final numMatches = RegExp(numRegex).allMatches(formattedRecord);
    final numbers = [];
    if (numMatches.isNotEmpty) {
      for (var i = 1; i <= numMatches.first.groupCount; i++) {
        numbers.add(numMatches.first[i]);
      }
    }

    List<(RowDataFieldType, dynamic)> records = [];
    for (var i = 0; i < types.length; i++) {
      switch (types[i]) {
        case r'$TIMESTAMP':
          records.add((RowDataFieldType.timestamp, int.tryParse(numbers[i] ?? '')));
          break;
        case r'$SYS':
          records.add((RowDataFieldType.sys, double.tryParse(numbers[i] ?? '')));
          break;
        case r'$DIA':
          records.add((RowDataFieldType.dia, double.tryParse(numbers[i] ?? '')));
          break;
        case r'$PUL':
          records.add((RowDataFieldType.pul, double.tryParse(numbers[i] ?? '')));
          break;
      }
    }
    return records;
  }

  /// Checks if the pattern can be used to parse records. This is the case when the pattern contains variables without
  /// containing curly brackets or commas.
  bool get isReversible {
    final match = RegExp(r'([^{},$]*(\$SYS|\$DIA|\$PUL|\$NOTE)[^{},$]*)|\$TIMESTAMP|\$COLOR').firstMatch(formatPattern);
    return (match != null) && (match.start == 0) && (match.end == formatPattern.length);
  }

  RowDataFieldType? get parsableFormat {
    if (formatPattern.contains(RegExp(r'[{},]'))) return null;
    if (formatPattern == r'$TIMESTAMP') return RowDataFieldType.timestamp;
    if (formatPattern == r'$COLOR') return RowDataFieldType.color;
    if (formatPattern.contains(RegExp(r'\$(SYS)'))) return RowDataFieldType.sys;
    if (formatPattern.contains(RegExp(r'\$(DIA)'))) return RowDataFieldType.dia;
    if (formatPattern.contains(RegExp(r'\$(PUL)'))) return RowDataFieldType.pul;
    if (formatPattern.contains(RegExp(r'\$(NOTE)'))) return RowDataFieldType.notes;
    return null;
  }

  @override
  String toString() {
    return 'ExportColumn{internalColumnName: $internalName, columnTitle: $columnTitle, formatPattern: $formatPattern}';
  }
}

/// Type a [ExportColumn] can be parsed as.
enum RowDataFieldType {
  timestamp, sys, dia, pul, notes, color;

  String localize(AppLocalizations localizations) {
    switch(this) {
      case RowDataFieldType.timestamp:
        return localizations.timestamp;
      case RowDataFieldType.sys:
        return localizations.sysLong;
      case RowDataFieldType.dia:
        return localizations.diaLong;
      case pul:
        return localizations.pulLong;
      case RowDataFieldType.notes:
        return localizations.notes;
      case RowDataFieldType.color:
        return localizations.color;
    }
  }
}