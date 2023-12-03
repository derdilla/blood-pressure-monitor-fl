import 'dart:collection';

import 'package:blood_pressure_app/main.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/export_import/legacy_column.dart';
import 'package:blood_pressure_app/model/storage/common_settings_interfaces.dart';
import 'package:blood_pressure_app/model/storage/db/config_dao.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ExportFields {
  static const defaultCsv = ['timestampUnixMs', 'systolic', 'diastolic', 'pulse', 'notes', 'color'];
  static const defaultPdf = ['formattedTimestamp','systolic','diastolic','pulse','notes']; 
}

@Deprecated('will get replaced with ExportColumnsManager')
class ExportConfigurationModel {
  // 2 sources.
  static ExportConfigurationModel? _instance;

  final AppLocalizations localizations;
  final ConfigDao _configDao; // TODO: remove after #181 is complete
  
  final List<ExportColumn> _availableFormats = [];

  /// Format: (title, List<internalNameOfExportFormat>)
  List<(String, List<String>)> get exportConfigurations => [
    // Not fully localized, as potential user added configurations can't be localized as well
    // TODO: explain why check for pdf is not needed; write guides for modifying this code;
    (localizations.default_, ['timestampUnixMs', 'systolic', 'diastolic', 'pulse', 'notes', 'color']),
    ('"My Heart" export', ['DATUM', 'SYSTOLE', 'DIASTOLE', 'PULS', 'Beschreibung', 'Tags', 'Gewicht', 'Sauerstoffsättigung']),
  ];

  ExportConfigurationModel._create(this.localizations, this._configDao);
  Future<void> _asyncInit() async {
    _availableFormats.addAll(getDefaultFormates());
    _availableFormats.addAll(await _configDao.loadExportColumns());
  }
  static Future<ExportConfigurationModel> get(AppLocalizations localizations) async {
    if (_instance == null) {
      _instance = ExportConfigurationModel._create(localizations, globalConfigDao);
      await _instance!._asyncInit();
    }
    return _instance!;
  }

  /// Determines which export columns should be used.
  ///
  /// The [fieldSettings] parameter describes the settings of the current export format and should be set accordingly.
  @Deprecated('not implemented anymore')
  List<ExportColumn> getActiveExportColumns(ExportFormat format, CustomFieldsSettings fieldsSettings) {
    return [];
  }
  
  List<ExportColumn> getDefaultFormates() => [
    ExportColumn(internalName: 'timestampUnixMs', columnTitle: localizations.unixTimestamp, formatPattern: r'$TIMESTAMP', editable: false),
    ExportColumn(internalName: 'formattedTimestamp', columnTitle: localizations.time, formatPattern: '\$FORMAT{\$TIMESTAMP,yyyy-MM-dd HH:mm:ss}', editable: false),
    ExportColumn(internalName: 'systolic', columnTitle: localizations.sysLong, formatPattern: r'$SYS', editable: false),
    ExportColumn(internalName: 'diastolic', columnTitle: localizations.diaLong, formatPattern: r'$DIA', editable: false),
    ExportColumn(internalName: 'pulse', columnTitle: localizations.pulLong, formatPattern: r'$PUL', editable: false),
    ExportColumn(internalName: 'notes', columnTitle: localizations.notes, formatPattern: r'$NOTE', editable: false),
    ExportColumn(internalName: 'pulsePressure', columnTitle: localizations.pulsePressure, formatPattern: r'{{$SYS-$DIA}}', editable: false),
    ExportColumn(internalName: 'color', columnTitle: localizations.color, formatPattern: r'$COLOR', editable: false),

    ExportColumn(internalName: 'DATUM', columnTitle: '"My Heart" export time', formatPattern: r'$FORMAT{$TIMESTAMP,yyyy-MM-dd HH:mm:ss}', editable: false, hidden: true),
    ExportColumn(internalName: 'SYSTOLE', columnTitle: '"My Heart" export sys', formatPattern: r'$SYS', editable: false, hidden: true),
    ExportColumn(internalName: 'DIASTOLE', columnTitle: '"My Heart" export dia', formatPattern: r'$DIA', editable: false, hidden: true),
    ExportColumn(internalName: 'PULS', columnTitle: '"My Heart" export pul', formatPattern: r'$PUL', editable: false, hidden: true),
    ExportColumn(internalName: 'Beschreibung', columnTitle: '"My Heart" export description', formatPattern: r'null', editable: false, hidden: true),
    ExportColumn(internalName: 'Tags', columnTitle: '"My Heart" export tags', formatPattern: r'', editable: false, hidden: true),
    ExportColumn(internalName: 'Gewicht', columnTitle: '"My Heart" export weight', formatPattern: r'0.0', editable: false, hidden: true),
    ExportColumn(internalName: 'Sauerstoffsättigung', columnTitle: '"My Heart" export oxygen', formatPattern: r'0', editable: false, hidden: true),
  ];

  /// Saves a new [ExportColumn] to the list of the available columns.
  ///
  /// In case one with the same internal name exists it gets updated with the new values
  void addOrUpdate(ExportColumn format) {
    _availableFormats.removeWhere((e) => e.internalName == format.internalName);
    _availableFormats.add(format);
    _configDao.updateExportColumn(format);
  }

  void delete(ExportColumn format) {
    final existingEntries = _availableFormats.where((element) => (element.internalName == format.internalName) && element.editable);
    assert(existingEntries.isNotEmpty, r"Tried to delete entry that doesn't exist or is not editable.");
    _availableFormats.removeWhere((element) => element.internalName == format.internalName);
    _configDao.deleteExportColumn(format.internalName);
  }

  UnmodifiableListView<ExportColumn> get availableFormats => UnmodifiableListView(_availableFormats);
  UnmodifiableMapView<String, ExportColumn> get availableFormatsMap =>
      UnmodifiableMapView(Map.fromIterable(_availableFormats, key: (e) => e.internalName));


  /// Creates list of rows with that follow the order and format described by [activeExportColumns].
  ///
  /// The [createHeadline] option will create put a row at the start that contains [ExportColumn.internalName] of the
  /// given [activeExportColumns].
  List<List<String>> createTable(Iterable<BloodPressureRecord> data, List<ExportColumn> activeExportColumns,
      {bool createHeadline = true,}) {
    List<List<String>> items = [];
    if (createHeadline) {
      items.add(activeExportColumns.map((e) => e.internalName).toList());
    }

    final dataRows = data.map((record) =>
        activeExportColumns.map((attribute) =>
            attribute.formatRecord(record)).toList());
    items.addAll(dataRows);
    return items;
  }
}
