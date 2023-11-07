import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';

/// Common fields that are present in both [CsvExportSettings] and [PdfExportSettings].
abstract class CustomFieldsSettings {
  bool get exportCustomFields;
  set exportCustomFields(bool value);
  List<String> get customFields;
  set customFields(List<String> value);
}