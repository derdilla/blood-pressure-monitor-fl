
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
      List<String> exportItems;
      if (settings.exportCustomEntries) {
        exportItems = settings.exportItems;
      } else {
        exportItems = ['timestampUnixMs', 'systolic', 'diastolic', 'pulse', 'notes'];
      }

      var csvHead = '';
      if (settings.exportCsvHeadline) {
        for (var i = 0; i<exportItems.length; i++) {
          csvHead += exportItems[i];
          if (i<(exportItems.length - 1)) {
            csvHead += settings.csvFieldDelimiter;
          }
        }
        csvHead += '\r\n';
      }

      List<List<dynamic>> items = [];
      for (var record in records) {
        List<dynamic> row = [];
        for (var attribute in exportItems) {
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

  List<BloodPressureRecord> parseCSVFile(Uint8List data) {
    assert(settings.exportFormat == ExportFormat.csv);
    assert(settings.exportCsvHeadline);

    List<BloodPressureRecord> records = [];

    String fileContents = utf8.decode(data.toList());
    final converter = CsvToListConverter(fieldDelimiter: settings.csvFieldDelimiter, textDelimiter: settings.csvTextDelimiter);
    final csvLines = converter.convert(fileContents);
    if (csvLines.length <= 1) {
      throw const FormatException('empty file');
    }
    final attributes = csvLines.removeAt(0);
    var creationTimePos = -1;
    var sysPos = -1;
    var diaPos = -1;
    var pulPos = -1;
    var notePos = -1;
    for (var i = 0; i<attributes.length; i++) {
      switch (attributes[i]) {
        case 'timestampUnixMs':
          creationTimePos = i;
          break;
        case 'systolic':
          sysPos = i;
          break;
        case 'diastolic':
          diaPos = i;
          break;
        case 'pulse':
          pulPos = i;
          break;
        case 'notes':
          notePos = i;
          break;
      }
    }
    assert(creationTimePos >= 0);
    assert(sysPos >= 0);
    assert(diaPos >= 0);
    assert(pulPos >= 0);
    assert(notePos >= 0);

    for (final line in csvLines) {
      records.add(
          BloodPressureRecord(
              DateTime.fromMillisecondsSinceEpoch(line[creationTimePos]),
              line[sysPos],
              line[diaPos],
              line[pulPos],
              line[notePos]
          )
      );
    }
    // TODO: maybe use customized fields if no header is present?
    // requires changes in screen class

    return records;
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