import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:blood_pressure_app/model/blood_pressure_analyzer.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';
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
  Future<Uint8List> create(List<(DateTime, BloodPressureRecord, Note, List<MedicineIntake>, Weight?)> entries) async {
    final pdf = pw.Document(
      creator: 'Blood pressure app',
    );
    final analyzer = BloodPressureAnalyser(entries.map((e) => e.$2).toList());

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        final title = (pdfSettings.exportTitle) ? _buildPdfTitle(analyzer) : null;
        title?.layout(context, const pw.BoxConstraints());
        final statistics = (pdfSettings.exportStatistics) ? _buildPdfStatistics(analyzer) : null;
        statistics?.layout(context, const pw.BoxConstraints());
        final availableHeight = PdfPageFormat.a4.availableHeight
            - (title?.box?.height ?? 0)
            - (statistics?.box?.height ?? 0);
        return [
          if (pdfSettings.exportTitle)
            title!,
          if (pdfSettings.exportStatistics)
            statistics!,
          if (pdfSettings.exportData)
            _buildPdfTable(entries, availableHeight),
        ];
      },
      maxPages: 100,
    ),);
    return pdf.save();
  }

  pw.Widget _buildPdfTitle(BloodPressureAnalyser analyzer) {
    if (analyzer.count < 2) return pw.Text(localizations.errNoData);
    final dateFormatter = DateFormat(settings.dateFormatString);
    return pw.Container(
      child: pw.Text(
        localizations.pdfDocumentTitle(
          dateFormatter.format(analyzer.firstDay!),
          dateFormatter.format(analyzer.lastDay!),
        ),
        style: const pw.TextStyle(
          fontSize: 16,
        ),
      ),
    );
  }

  pw.Widget _buildPdfStatistics(BloodPressureAnalyser analyzer) => pw.Container(
      margin: const pw.EdgeInsets.all(20),
      child: pw.TableHelper.fromTextArray(
          data: [
            ['',localizations.sysLong, localizations.diaLong, localizations.pulLong],
            [localizations.average, analyzer.avgSys?.mmHg, analyzer.avgDia?.mmHg, analyzer.avgPul],
            [localizations.maximum, analyzer.maxSys?.mmHg, analyzer.maxDia?.mmHg, analyzer.maxPul],
            [localizations.minimum, analyzer.minSys?.mmHg, analyzer.minDia?.mmHg, analyzer.minPul],
          ],
      ),
    );

  pw.Widget _buildPdfTable(Iterable<(DateTime, BloodPressureRecord, Note, List<MedicineIntake>, Weight?)> entries, double availableHeightOnFirstPage) {
    final columns = pdfSettings.exportFieldsConfiguration.getActiveColumns(availableColumns);
    final data = entries.map(
      (entry) => columns.map(
        (column) => column.encode(entry.$2, entry.$3, entry.$4, entry.$5),
      ).toList(),
    ).toList();

    return pw.Builder(builder: (
      pw.Context context,) {
        final realCellHeight = () {
          final cell = pw.TableHelper.fromTextArray(
            data: data,
            border: null,
            cellHeight: pdfSettings.cellHeight,
            cellStyle: pw.TextStyle(
              fontSize: pdfSettings.cellFontSize,
            ),
            rowDecoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: PdfColors.blueGrey,
                  width: .5,
                ),
              ),
            ),
          );
          cell.layout(context, pw.BoxConstraints(maxWidth: PdfPageFormat.a4.availableWidth ~/2 - 10));
          return cell.box!.height / data.length;
        }();
        final realHeaderHeight = () {
          final cell = pw.TableHelper.fromTextArray(
            data: [],
            border: null,
            headerDecoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide()),
            ),
            headerHeight: pdfSettings.headerHeight,
            headerStyle: pw.TextStyle(
              color: PdfColors.black,
              fontSize: pdfSettings.headerFontSize,
              fontWeight: pw.FontWeight.bold,
            ),
            headerCellDecoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(
                  color: settings.accentColor.toPdfColor(),
                  width: 5,
                ),
              ),
            ),
            headers: columns.map((c) => c.userTitle(localizations)).toList(),
          );
          // subtracting padding during layout
          cell.layout(context, pw.BoxConstraints(maxWidth: PdfPageFormat.a4.availableWidth ~/2 - 10));
          return cell.box!.height;
        }();
        if (realHeaderHeight > (pdfSettings.headerHeight + 10)
            || realCellHeight > (pdfSettings.cellHeight + 5)) {
          return pw.TableHelper.fromTextArray(
            border: null,
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide()),
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
            data: data,
          );
        }

        int rowCount = (availableHeightOnFirstPage - realHeaderHeight)
            ~/ (realCellHeight);

        final List<pw.Widget> tables = [];
        int pageNum = 0;
        for (int offset = 0; offset < data.length; offset += (rowCount - 1)) {
          final dataRange = data.getRange(offset, min(offset + rowCount, data.length)).toList();
          // Correct rowcount after first page (2 tables)
          if (pageNum == 1) {
            rowCount = (PdfPageFormat.a4.availableHeight - realHeaderHeight)
                ~/ (realCellHeight);
            offset -= 1;
          }
          tables.add(pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 5),
            width: PdfPageFormat.a4.availableWidth / 2 - 1,
            height: ((pageNum < 2) ? availableHeightOnFirstPage : PdfPageFormat.a4.availableHeight) - 20,
            alignment: pw.Alignment.topCenter,
            child: pw.TableHelper.fromTextArray(
              border: null,
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide()),
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
              data: dataRange,
            ),
          ),);
          pageNum++;
        }

        return pw.Wrap(
            children: [
              for (final table in tables)
                pw.Expanded(child: table),
            ],
        );
      },
    );
  }
}

extension _PdfCompatability on Color {
  PdfColor toPdfColor() => PdfColor(r / 256, g / 256, b / 256, a);
}
