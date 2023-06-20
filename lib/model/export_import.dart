
import 'dart:convert';
import 'dart:typed_data';

import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:csv/csv.dart';

import 'blood_pressure.dart';

class DataExporter {
  Settings settings;

  DataExporter(this.settings);

  Uint8List createFile(List<BloodPressureRecord> records) {
    if (settings.exportFormat == ExportFormat.csv) {
      var csvHead = '';
      for (var attribute in settings.exportItems) {
        csvHead += attribute;
        csvHead += settings.csvFieldDelimiter;
      }
      csvHead += '\n';

      List<List<dynamic>> items = [];
      for (var record in records) {
        List<dynamic> row = [];
        for (var attribute in settings.exportItems) {
          switch (attribute) {
            case 'timestampUnixMs':
              row.add(record.creationTime.millisecondsSinceEpoch);
              break;
            case 'systolic':
              row.add(record.systolic);
              break;
            case 'diastolic':
              row.add(record.diastolic);
              break;
            case 'pulse':
              row.add(record.pulse);
              break;
            case 'notes':
              row.add(record.notes);
              break;
          }
        }
        items.add(row);
      }
      var converter = ListToCsvConverter(fieldDelimiter: settings.csvFieldDelimiter, textDelimiter: settings.csvTextDelimiter);
      var csvData = converter.convert(items);
      return Uint8List.fromList(utf8.encode(csvHead + csvData));
    } else if (settings.exportFormat == ExportFormat.pdf) {
      throw UnimplementedError('TODO');
    }
    return Uint8List(0);
  }
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