import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:function_tree/function_tree.dart';
import 'package:intl/intl.dart';

class ExportConfigurationModel {
  List<ExportColumn> getDefaultFormates(Settings settings) => [
    ExportColumn(internalColumnName: 'timestampUnixMs', columnTitle: 'Unix timestamp', formatPattern: r'$TIMESTAMP'),
    ExportColumn(internalColumnName: 'formattedTimestamp', columnTitle: 'Time', formatPattern: '\$FORMAT{\$TIMESTAMP,${settings.dateFormatString}}'),
    ExportColumn(internalColumnName: 'systolic', columnTitle: 'Systolic', formatPattern: r'$SYS'),
    ExportColumn(internalColumnName: 'diastolic', columnTitle: 'Diastolic', formatPattern: r'$DIA'),
    ExportColumn(internalColumnName: 'pulse', columnTitle: 'Pulse', formatPattern: r'$PUL'),
    ExportColumn(internalColumnName: 'notes', columnTitle: 'Notes', formatPattern: r'$NOTE'),
  ];
}

class ExportColumn {
  /// pure name as in the title of the csv file and for internal purposes. Should not contain special characters and spaces.
  late final String internalColumnName;
  /// Display title of the column. Possibly localized
  late final String columnTitle;
  /// Pattern to create the field contents from: TODO implement user input and documentation
  /// It supports inserting values for $TIMESTAMP, $SYS $DIA $PUL and $NOTE. Where $TIMESTAMP is the time since unix epoch in milliseconds.
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

  /// Example: ExportColumn(internalColumnName: 'pulsePressure', columnTitle: 'Pulse pressure', formatPattern: '{{$SYS-$DIA}}')
  ExportColumn({required this.internalColumnName, required this.columnTitle, required String formatPattern}) {
    this.formatPattern = formatPattern.replaceAll('{{}}', '');
  }

  ExportColumn.fromJson(Map<String, dynamic> json) {
    ExportColumn(
      internalColumnName: json['internalColumnName'],
      columnTitle: json['columnTitle'],
      formatPattern: json['formatPattern']
    );
  }

  Map<String, dynamic> toJson() => {
    'internalColumnName': internalColumnName,
    'columnTitle': columnTitle,
    'formatPattern': formatPattern
  };

  String formatRecord(BloodPressureRecord record) {
    var fieldContents = formatPattern;

    // variables
    fieldContents = fieldContents.replaceAll(r'$TIMESTAMP', record.creationTime.millisecondsSinceEpoch.toString());
    fieldContents = fieldContents.replaceAll(r'$SYS', record.systolic.toString());
    fieldContents = fieldContents.replaceAll(r'$DIA', record.diastolic.toString());
    fieldContents = fieldContents.replaceAll(r'$PUL', record.pulse.toString());
    fieldContents = fieldContents.replaceAll(r'$NOTE', record.notes.toString());

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
}