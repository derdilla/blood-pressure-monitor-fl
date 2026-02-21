import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/export_import/pdf_converter.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'csv_converter_test.dart';

void main() {
  test('should not return empty data', () async {
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    final converter = PdfConverter(PdfExportSettings(), localizations, Settings(), ExportColumnsManager());
    final pdf = await converter.create(createRecords());
    expect(pdf.length, isNonZero);
  });
  test('generated data length should be consistent', () async {
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    final converter = PdfConverter(PdfExportSettings(), localizations, Settings(), ExportColumnsManager());
    final pdf = await converter.create(createRecords());
    final converter2 = PdfConverter(PdfExportSettings(), localizations, Settings(), ExportColumnsManager());
    final pdf2 = await converter2.create(createRecords());
    expect(pdf.length, pdf2.length);
  });

  test('generated data should change on settings change', () async {
    final localizations = await AppLocalizations.delegate.load(const Locale('en'));
    final pdfSettings = PdfExportSettings(
      exportData: true,
      exportStatistics: true,
      exportTitle: true,
    );

    final converter = PdfConverter(pdfSettings, localizations, Settings(), ExportColumnsManager());
    final pdf1 = await converter.create(createRecords());

    pdfSettings.exportData = false;
    final pdf2 = await converter.create(createRecords());
    expect(pdf1.length, isNot(pdf2.length));
    expect(pdf1.length, greaterThan(pdf2.length));

    pdfSettings.exportStatistics = false;
    final pdf3 = await converter.create(createRecords());
    expect(pdf3.length, isNot(pdf2.length));
    expect(pdf3.length, isNot(pdf1.length));
    expect(pdf2.length, greaterThan(pdf3.length));

    pdfSettings.exportTitle = false;
    pdfSettings.exportData = true;
    final pdf4 = await converter.create(createRecords());
    expect(pdf4.length, isNot(pdf1.length));
    expect(pdf1.length, greaterThan(pdf4.length));
  });
}

