import 'dart:typed_data';
import 'dart:ui';

import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/blood_pressure_analyzer.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Utility class for creating pdf files.
class PdfConverter {
  /// Create pdf builder.
  PdfConverter(this.pdfSettings, this.localizations, this.settings, this.availableColumns);

  /// pdf specific settings.
  final PdfExportSettings pdfSettings;
  
  /// General customised design information that can be applied to the Pdf.
  final Settings settings;
  
  /// Strings in the pdf.
  final AppLocalizations localizations;
  
  /// Columns manager used for ex- and import.
  final ExportColumnsManager availableColumns;

  /// Create a pdf from a record list.
  Future<Uint8List> create(List<BloodPressureRecord> records) async {
    final pdf = pw.Document(
      creator: 'Blood pressure app',
    );
    final analyzer = BloodPressureAnalyser(records.toList());

    pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            if (pdfSettings.exportTitle)
              _buildPdfTitle(records, analyzer),
            if (pdfSettings.exportStatistics)
              _buildPdfStatistics(analyzer),
            if (pdfSettings.exportData)
              _buildPdfTable(records),
          ];
        }));
    return await pdf.save();
  }

  pw.Widget _buildPdfTitle(List<BloodPressureRecord> records, BloodPressureAnalyser analyzer) {
    if (records.length < 2) return pw.Text(localizations.errNoData);
    final dateFormatter = DateFormat(settings.dateFormatString);
    return pw.Container(
        child: pw.Text(
            localizations.pdfDocumentTitle(
                dateFormatter.format(analyzer.firstDay!),
                dateFormatter.format(analyzer.lastDay!)
            ),
            style: const pw.TextStyle(
              fontSize: 16,
            )
        )
    );
  }

  pw.Widget _buildPdfStatistics(BloodPressureAnalyser analyzer) {
    return pw.Container(
      margin: const pw.EdgeInsets.all(20),
      child: pw.TableHelper.fromTextArray(
          data: [
            ['',localizations.sysLong, localizations.diaLong, localizations.pulLong],
            [localizations.average, analyzer.avgSys, analyzer.avgDia, analyzer.avgPul],
            [localizations.maximum, analyzer.maxSys, analyzer.maxDia, analyzer.maxPul],
            [localizations.minimum, analyzer.minSys, analyzer.minDia, analyzer.minPul],
          ]
      ),
    );
  }

  pw.Widget _buildPdfTable(Iterable<BloodPressureRecord> records) {
    final columns = pdfSettings.exportFieldsConfiguration.getActiveColumns(availableColumns);
    
    return pw.TableHelper.fromTextArray(
      border: null,
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: PdfColors.black))
      ),
      headerHeight: pdfSettings.headerHeight,
      cellHeight: pdfSettings.cellHeight,
      cellAlignments: { 
        for (final v in List.generate(columns.length, (idx)=>idx)) 
          v : pw.Alignment.centerLeft,
      },
      headerStyle: pw.TextStyle(
        color: PdfColors.black,
        fontSize: pdfSettings.headerFontSize,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: pw.TextStyle(
        fontSize: pdfSettings.cellFontSize,
      ),
      headerCellDecoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: settings.accentColor.toPdfColor(),
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
      headers: columns.map((c) => c.userTitle(localizations)).toList(),
      data: records.map(
              (record) => columns.map(
                  (column) => column.encode(record)
          ).toList()
      ).toList(),
    );
  }
}

extension PdfCompatability on Color {
  PdfColor toPdfColor() => PdfColor(red / 256, green / 256, blue / 256, opacity);
}