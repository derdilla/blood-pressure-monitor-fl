
import 'dart:typed_data';

import 'package:intl/intl.dart';

import 'blood_pressure.dart';

class CSVExportSettings {
  final DateFormat dateFormatter;
  final String? fieldDelimiter;
  final String? textDelimiter;
  final String? textEndDelimiter;

  CSVExportSettings(this.dateFormatter, this.fieldDelimiter, this.textDelimiter, this.textEndDelimiter);
}

class ExportFormat {
  final int code;

  ExportFormat(this.code) {
    if (code < 0 || code > 1) throw const FormatException('Not a export format');
  }
  static ExportFormat csv = ExportFormat(0);
  static ExportFormat pdf = ExportFormat(1);

  @override
  bool operator == (Object other) {
    try {
      return code == (other as ExportFormat).code;
    } on Exception {
      try {
        return code == (other as int);
      } on Exception {
        return false;
      }
    }
  }

  @override
  int get hashCode => code;
}