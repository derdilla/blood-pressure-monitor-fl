import 'package:blood_pressure_app/model/export_import/export_configuration.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';

/// Common fields that are present in both [CsvExportSettings] and [PdfExportSettings].
abstract class CustomFieldsSettings {
  /// Active export columns.
  ///
  /// Implementers must propagate any notifyListener calls.
  ActiveExportColumnConfiguration get exportFieldsConfiguration;
}