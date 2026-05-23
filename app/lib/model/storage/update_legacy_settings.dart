import 'package:blood_pressure_app/model/storage/db/config_dao.dart';
import 'package:blood_pressure_app/model/storage/db/config_db.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings.dart';
import 'package:blood_pressure_app/model/storage/export_pdf_settings.dart';
import 'package:blood_pressure_app/model/storage/export_settings.dart';
import 'package:blood_pressure_app/model/storage/interval_store_manager.dart';
import 'package:blood_pressure_app/model/storage/settings.dart';
import 'package:health_data_store/health_data_store.dart';

/// Migrate to file based settings format from db in pre 1.7.4 (Jul 24).
Future<void> migrateDatabaseSettings(
  Settings settings,
  ExportSettings exportSettings,
  CsvExportSettings csvExportSettings,
  PdfExportSettings pdfExportSettings,
  IntervalStoreManager intervallStoreManager,
  ExportColumnsManager manager,
  MedicineRepository medRepo,
) async {
  final configDB = await ConfigDB.open();
  if(configDB == null) return; // not upgradable

  final configDao = ConfigDao(configDB);

  settings.copyFrom(await configDao.loadSettings());
  exportSettings.copyFrom(await configDao.loadExportSettings());
  csvExportSettings.copyFrom(await configDao.loadCsvExportSettings());
  pdfExportSettings.copyFrom(await configDao.loadPdfExportSettings());
  intervallStoreManager.copyFrom(await configDao.loadIntervalStorageManager());
  manager.copyFrom(await configDao.loadExportColumnsManager());
}
