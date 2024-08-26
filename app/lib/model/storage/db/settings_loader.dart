import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:blood_pressure_app/model/storage/interval_store.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';

/// A backend agnostic loader for settings data.
abstract class SettingsLoader {
  /// Loads the profiles [Settings] object from disk.
  ///
  /// If any errors occur or the object is not present, a default one will be
  /// created. Changes in the object will save to the automatically.
  ///
  /// Changes to the disk data will not propagate to the object.
  Future<Settings> loadSettings();

  /// Loads the profiles [Settings] object from disk.
  ///
  /// If any errors occur or the object is not present, a default one will be
  /// created. Changes in the object will save to the automatically.
  ///
  /// Changes to the disk data will not propagate to the object.
  Future<ExportSettings> loadExportSettings();

  /// Loads the profiles [Settings] object from disk.
  ///
  /// If any errors occur or the object is not present, a default one will be
  /// created. Changes in the object will save to the automatically.
  ///
  /// Changes to the disk data will not propagate to the object.
  Future<CsvExportSettings> loadCsvExportSettings();

  /// Loads the profiles [Settings] object from disk.
  ///
  /// If any errors occur or the object is not present, a default one will be
  /// created. Changes in the object will save to the automatically.
  ///
  /// Changes to the disk data will not propagate to the object.
  Future<PdfExportSettings> loadPdfExportSettings();

  /// Loads a [IntervalStoreManager] object from disk.
  ///
  /// If any errors occur or the object is not present, a default one will be
  /// created. Changes in the object will save to the automatically.
  ///
  /// Changes to the database will not propagate to the object.
  Future<IntervalStoreManager> loadIntervalStorageManager();

  /// Loads the profiles [ExportColumnsManager] object from disk.
  ///
  /// If any errors occur or the object is not present, a default one will be
  /// created. Changes in the object will save to the automatically.
  ///
  /// Changes to the disk data will not propagate to the object.
  Future<ExportColumnsManager> loadExportColumnsManager();
}
