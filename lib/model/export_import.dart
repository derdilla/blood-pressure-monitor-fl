
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:blood_pressure_app/model/blood_pressure_analyzer.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:jsaver/jSaver.dart';
import 'package:path/path.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';

import 'blood_pressure.dart';

extension PdfCompatability on Color {
  PdfColor toPdfColor() {
    return PdfColor(red / 256, green / 256, blue / 256, opacity);
  }
}

// TODO: respect new export columns
class ExportFileCreator {
  final Settings settings;
  final AppLocalizations localizations;
  final ThemeData theme;

  ExportFileCreator(this.settings, this.localizations, this.theme);

  Future<Uint8List> createFile(List<BloodPressureRecord> records) async {
    switch (settings.exportFormat) {
      case ExportFormat.csv:
        return createCSVCFile(records);
      case ExportFormat.pdf:
        return createPdfFile(records);
      case ExportFormat.db:
        return copyDBFile();
    }
  }

  Future<List<BloodPressureRecord>?> parseFile(String filePath, Uint8List data) async {
    switch(settings.exportFormat) {
      case ExportFormat.csv:
        try {
          return parseCSVFile(data);
        } catch (e) {
          return null;
        }
      case ExportFormat.pdf:
        return null;
      case ExportFormat.db:
        return loadDBFile(filePath);
    }
  }

  Uint8List createCSVCFile(List<BloodPressureRecord> records) {
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
          case 'isoUTCTime':
            row.add(record.creationTime.toIso8601String());
            break;
          case 'systolic':
            row.add(record.systolic ?? '');
            break;
          case 'diastolic':
            row.add(record.diastolic ?? '');
            break;
          case 'pulse':
            row.add(record.pulse ?? '');
            break;
          case 'notes':
            row.add(record.notes ?? '');
            break;
        }
      }
      items.add(row);
    }
    var converter = ListToCsvConverter(fieldDelimiter: settings.csvFieldDelimiter, textDelimiter: settings.csvTextDelimiter);
    var csvData = converter.convert(items);
    return Uint8List.fromList(utf8.encode(csvHead + csvData));
  }

  List<BloodPressureRecord> parseCSVFile(Uint8List data) {
    List<BloodPressureRecord> records = [];

    String fileContents = utf8.decode(data.toList());
    var converter = CsvToListConverter(fieldDelimiter: settings.csvFieldDelimiter, textDelimiter: settings.csvTextDelimiter);
    var csvLines = converter.convert(fileContents);
    if (csvLines.length <= 1) { // legacy files
      converter = CsvToListConverter(fieldDelimiter: settings.csvFieldDelimiter, textDelimiter: settings.csvTextDelimiter, eol: '\n');
      csvLines = converter.convert(fileContents);
    }
    final attributes = csvLines.removeAt(0);
    var creationTimePos = -1;
    var isoTimePos = -1;
    var sysPos = -1;
    var diaPos = -1;
    var pulPos = -1;
    var notePos = -1;
    for (var i = 0; i<attributes.length; i++) {
      switch (attributes[i].toString().trim()) {
        case 'timestampUnixMs':
          creationTimePos = i;
          break;
        case 'isoUTCTime':
          isoTimePos = i;
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
    if(creationTimePos < 0 && isoTimePos < 0) {
      throw ArgumentError('File didn\'t save timestamps');
    }

    int? convert(dynamic e) {
      if (e is int?) {
        return e;
      }
      return null;
    }
    for (final line in csvLines) {
      records.add(
          BloodPressureRecord(
              (creationTimePos >= 0 ) ? DateTime.fromMillisecondsSinceEpoch(line[creationTimePos]) : DateTime.parse(line[isoTimePos]),
              (sysPos >= 0) ? convert(line[sysPos]) : null,
              (diaPos >= 0) ? convert(line[diaPos]) : null,
              (pulPos >= 0) ? convert(line[pulPos]) : null,
              (notePos >= 0) ? line[notePos] : null
          )
      );
    }
    return records;
  }

  Future<Uint8List> createPdfFile(List<BloodPressureRecord> data) async {
    final analyzer = BloodPressureAnalyser(data.toList());
    final dateFormatter = DateFormat(settings.dateFormatString);

    pw.Document pdf = pw.Document();

    pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            _buildDocumentTitle(dateFormatter, analyzer),
            _buildPdfTable(data, dateFormatter),
          ];
        }));
    return await pdf.save();
  }

  pw.Widget _buildDocumentTitle(DateFormat dateFormatter, BloodPressureAnalyser analyzer) {
    return pw.Container(
      child: pw.Text(
        localizations.pdfDocumentTitle(dateFormatter.format(analyzer.firstDay!), dateFormatter.format(analyzer.lastDay!)),
        style: const pw.TextStyle(
          fontSize: 16,
        )
      )
    );
  }

  pw.SpanningWidget _buildPdfTable(List<BloodPressureRecord> data, DateFormat dateFormatter) {
    final tableHeaders = [
      localizations.time,
      localizations.sysLong,
      localizations.diaLong,
      localizations.pulLong,
      localizations.notes
    ];

    return pw.TableHelper.fromTextArray(
        border: null,
        cellAlignment: pw.Alignment.centerLeft,
        headerDecoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black))
        ),
        headerHeight: 20,
        cellHeight: 15,
        cellAlignments: {
          0: pw.Alignment.centerLeft,
          1: pw.Alignment.centerLeft,
          2: pw.Alignment.centerLeft,
          3: pw.Alignment.centerLeft,
          4: pw.Alignment.centerRight,
        },
        headerStyle: pw.TextStyle(
          color: PdfColors.black,
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
        cellStyle: const pw.TextStyle(
          fontSize: 8,
        ),
        headerCellDecoration: pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(
              color: theme.colorScheme.primaryContainer.toPdfColor(),
              width: 5,
            ),
          ),
        ),
        rowDecoration: const pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(
              color: PdfColors.blueGrey,
              width: .5,
            ),
          ),
        ),
        headers: tableHeaders,
        data: List<List<String>>.generate(
          data.length,
              (row) => [
                dateFormatter.format(data[row].creationTime),
                (data[row].systolic ?? '-').toString(),
                (data[row].diastolic ?? '-').toString(),
                (data[row].pulse ?? '-').toString(),
                data[row].notes ?? '-'
              ],
        )
    );
  }

  Future<Uint8List> copyDBFile() async {
    var dbPath = await getDatabasesPath();

    if (dbPath != inMemoryDatabasePath) {
      dbPath = join(dbPath, 'blood_pressure.db');
    }
    return File(dbPath).readAsBytes();
  }

  Future<List<BloodPressureRecord>> loadDBFile(String filePath) async {
    final loadedModel = await BloodPressureModel.create(dbPath: filePath, isFullPath: true);
    return await loadedModel.all;
  }
}

class Exporter {
  final Settings settings;
  final BloodPressureModel model;
  final ScaffoldMessengerState messenger;
  final AppLocalizations localizations;
  final ThemeData theme;

  Exporter(this.settings, this.model, this.messenger, this.localizations, this.theme);

  Future<void> export() async {
    final entries = await model.getInTimeRange(settings.displayDataStart, settings.displayDataEnd);
    var fileContents = await ExportFileCreator(settings, localizations, theme).createFile(entries);
    String filename = 'blood_press_${DateTime.now().toIso8601String()}';
    String ext;
    switch(settings.exportFormat) {
      case ExportFormat.csv:
        ext = 'CSV'; // lower case 'csv' gets automatically converted to 'csv.xls' for some reason
        break;
      case ExportFormat.pdf:
        ext = 'pdf';
        break;
      case ExportFormat.db:
        ext = 'db';
        break;
    }
    String path = await FileSaver.instance.saveFile(name: filename, ext: ext, bytes: fileContents);

    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      messenger.showSnackBar(SnackBar(content: Text(localizations.success(path))));
    } else if (Platform.isAndroid || Platform.isIOS) {
      if (settings.defaultExportDir.isNotEmpty) {
        JSaver.instance.save(
            fromPath: path,
            androidPathOptions: AndroidPathOptions(toDefaultDirectory: true)
        );
        messenger.showSnackBar(SnackBar(content: Text(localizations.success(settings.defaultExportDir))));
      } else {
        Share.shareXFiles([
          XFile(
              path,
              mimeType: MimeType.csv.type
          )
        ]);
      }
    } else {
      messenger.showSnackBar(const SnackBar(content: Text('UNSUPPORTED PLATFORM')));
    }
  }


  Future<void> import() async {
    if (!([ExportFormat.csv, ExportFormat.db].contains(settings.exportFormat))) {
      messenger.showSnackBar(SnackBar(content: Text(localizations.errWrongImportFormat)));
      return;
    }

    var result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
    );
    if (result == null) {
      messenger.showSnackBar(SnackBar(content: Text(localizations.errNoFileOpened)));
      return;
    }
    var binaryContent = result.files.single.bytes;
    if (binaryContent == null) {
      messenger.showSnackBar(SnackBar(content: Text(localizations.errCantReadFile)));
      return;
    }
    var path = result.files.single.path;
    assert(path != null); // null state directly linked to binary content

    var fileContents = await ExportFileCreator(settings, localizations, theme).parseFile(path! ,binaryContent);
    if (fileContents == null) {
      messenger.showSnackBar(SnackBar(content: Text(localizations.errNotImportable)));
      return;
    }
    messenger.showSnackBar(SnackBar(content: Text(localizations.importSuccess(fileContents.length))));
    for (final e in fileContents) {
      model.add(e);
    }
  }
}

enum ExportFormat {
  csv,
  pdf,
  db
}