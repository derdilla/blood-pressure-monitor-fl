import 'dart:collection';

import 'package:blood_pressure_app/main.dart';
import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/storage/common_settings_interfaces.dart';
import 'package:blood_pressure_app/model/storage/db/config_dao.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:function_tree/function_tree.dart';
import 'package:intl/intl.dart';

class ExportFields {
  static const defaultCsv = ['timestampUnixMs', 'systolic', 'diastolic', 'pulse', 'notes', 'color'];
  static const defaultPdf = ['formattedTimestamp','systolic','diastolic','pulse','notes']; 
}

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
  List<ExportColumn> getActiveExportColumns(ExportFormat format, CustomFieldsSettings fieldsSettings) {
    switch (format) {
      case ExportFormat.csv:
        final fields = (fieldsSettings.exportCustomFields) ? fieldsSettings.customFields : ExportFields.defaultCsv;
        return availableFormats.where((e) => fields.contains(e.internalName)).toList();
      case ExportFormat.pdf:
        final fields = (fieldsSettings.exportCustomFields) ? fieldsSettings.customFields : ExportFields.defaultPdf;
        return availableFormats.where((e) => fields.contains(e.internalName)).toList();
      case ExportFormat.db:
        // Export formats don't work on this one
        return [];
    }
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

class ExportColumn {
  /// pure name as in the title of the csv file and for internal purposes. Should not contain special characters and spaces.
  late final String internalName;
  /// Display title of the column. Possibly localized
  late final String columnTitle;
  /// Pattern to create the field contents from:
  /// It supports inserting values for $TIMESTAMP, $SYS $DIA $PUL and $NOTE. Where $TIMESTAMP is the time since unix epoch in milliseconds.
  /// To format a timestamp in the same format as the $TIMESTAMP variable, $FORMAT(<timestamp>, <formatString>).
  /// It is supported to use basic mathematics inside of double brackets ("{{}}"). In case one of them is not present in the record, -1 is provided.
  /// The following math is supported:
  /// Operations: [+, -, *, /, %, ^]
  /// One-parameter functions [ abs, acos, asin, atan, ceil, cos, cosh, cot, coth, csc, csch, exp, floor, ln, log, round sec, sech, sin, sinh, sqrt, tan, tanh ]
  /// Two-parameter functions [ log, nrt, pow ]
  /// Constants [ e, pi, ln2, ln10, log2e, log10e, sqrt1_2, sqrt2 ]
  /// The full math interpreter specification can be found here: https://pub.dev/documentation/function_tree/latest#interpreter
  ///
  /// The String is processed in the following order:
  /// 1. variable replacement
  /// 2. Math
  /// 3. Date format
  late final String formatPattern;

  final bool editable;
  /// doesn't show up as unused / hidden field in list
  final bool hidden;

  /// Example: ExportColumn(internalColumnName: 'pulsePressure', columnTitle: 'Pulse pressure', formatPattern: '{{$SYS-$DIA}}')
  ExportColumn({required this.internalName, required this.columnTitle, required String formatPattern, this.editable = true, this.hidden = false}) {
    this.formatPattern = formatPattern.replaceAll('{{}}', '');
  }

  ExportColumn.fromJson(Map<String, dynamic> json, [this.editable = true, this.hidden = false]) {
    ExportColumn(
      internalName: json['internalColumnName'],
      columnTitle: json['columnTitle'],
      formatPattern: json['formatPattern'],
    );
  }

  Map<String, dynamic> toJson() => {
    'internalColumnName': internalName,
    'columnTitle': columnTitle,
    'formatPattern': formatPattern
  };

  String formatRecord(BloodPressureRecord record) {
    var fieldContents = formatPattern;

    // variables
    fieldContents = fieldContents.replaceAll(r'$TIMESTAMP', record.creationTime.millisecondsSinceEpoch.toString());
    fieldContents = fieldContents.replaceAll(r'$SYS', record.systolic.toString());
    fieldContents = fieldContents.replaceAll(r'$DIA', record.diastolic.toString());
    fieldContents = fieldContents.replaceAll(r'$PUL', record.pulse.toString());
    fieldContents = fieldContents.replaceAll(r'$NOTE', record.notes.toString());
    fieldContents = fieldContents.replaceAll(r'$COLOR', record.needlePin?.color.value.toString() ?? '');

    // math
    fieldContents = fieldContents.replaceAllMapped(RegExp(r'\{\{([^}]*)}}'), (m) {
      assert(m.groupCount == 1, 'If a math block is found content is expected');
      final result = m.group(0)!.interpret();
      return result.toString();
    });

    // date format
    fieldContents = fieldContents.replaceAllMapped(RegExp(r'\$FORMAT\{([^}]*)}'), (m) {
      assert(m.groupCount == 1, 'If a FORMAT block is found a group is expected');
      final bothArgs = m.group(1)!;
      int separatorPosition = bothArgs.indexOf(",");
      final timestamp = DateTime.fromMillisecondsSinceEpoch(int.parse(bothArgs.substring(0,separatorPosition)));
      final formatPattern = bothArgs.substring(separatorPosition+1);
      return DateFormat(formatPattern).format(timestamp);
    });

    return fieldContents;
  }

  /// Parses records if the format is easily reversible else returns an empty list
  List<(RowDataFieldType, dynamic)> parseRecord(String formattedRecord) {
    if (!isReversible || formattedRecord == 'null') return [];

    if (formatPattern == r'$NOTE') return [(RowDataFieldType.notes, formattedRecord)];
    if (formatPattern == r'$COLOR') {
      final value = int.tryParse(formattedRecord);
      return value == null ? [] : [(RowDataFieldType.color, Color(value))];
    }

    // records are parse by replacing the values with capture groups
    final types = RegExp(r'\$(TIMESTAMP|SYS|DIA|PUL)').allMatches(formatPattern).map((e) => e.group(0)).toList();
    final numRegex = formatPattern.replaceAll(RegExp(r'\$(TIMESTAMP|SYS|DIA|PUL)'), '([0-9]+.?[0-9]*)'); // ints and doubles
    final numMatches = RegExp(numRegex).allMatches(formattedRecord);
    final numbers = [];
    if (numMatches.isNotEmpty) {
      for (var i = 1; i <= numMatches.first.groupCount; i++) {
        numbers.add(numMatches.first[i]);
      }
    }

    List<(RowDataFieldType, dynamic)> records = [];
    for (var i = 0; i < types.length; i++) {
      switch (types[i]) {
        case r'$TIMESTAMP':
          records.add((RowDataFieldType.timestamp, int.tryParse(numbers[i] ?? '')));
          break;
        case r'$SYS':
          records.add((RowDataFieldType.sys, double.tryParse(numbers[i] ?? '')));
          break;
        case r'$DIA':
          records.add((RowDataFieldType.dia, double.tryParse(numbers[i] ?? '')));
          break;
        case r'$PUL':
          records.add((RowDataFieldType.pul, double.tryParse(numbers[i] ?? '')));
          break;
      }
    }
    return records;
  }

  /// Checks if the pattern can be used to parse records. This is the case when the pattern contains variables without
  /// containing curly brackets or commas.
  bool get isReversible {
    return (formatPattern == r'$TIMESTAMP') || (formatPattern == r'$COLOR') ||
        formatPattern.contains(RegExp(r'\$(SYS|DIA|PUL|NOTE)')) && !formatPattern.contains(RegExp(r'[{},]'));
  }

  RowDataFieldType? get parsableFormat {
    if (formatPattern.contains(RegExp(r'[{},]'))) return null;
    if (formatPattern == r'$TIMESTAMP') return RowDataFieldType.timestamp;
    if (formatPattern == r'$COLOR') return RowDataFieldType.color;
    if (formatPattern.contains(RegExp(r'\$(SYS)'))) return RowDataFieldType.sys;
    if (formatPattern.contains(RegExp(r'\$(DIA)'))) return RowDataFieldType.dia;
    if (formatPattern.contains(RegExp(r'\$(PUL)'))) return RowDataFieldType.pul;
    if (formatPattern.contains(RegExp(r'\$(NOTE)'))) return RowDataFieldType.notes;
    return null;
  }

  @override
  String toString() {
    return 'ExportColumn{internalColumnName: $internalName, columnTitle: $columnTitle, formatPattern: $formatPattern}';
  }
}

/// Type a [ExportColumn] can be parsed as.
enum RowDataFieldType {
  timestamp, sys, dia, pul, notes, color;

  @override
  String toString() {
    assert(false, "RowDataFieldType.toString should not be called by UI code. Use localize instead.");
    return name;
  }

  String localize(AppLocalizations localizations) {
    switch(this) {
      case RowDataFieldType.timestamp:
        return localizations.timestamp;
      case RowDataFieldType.sys:
        return localizations.sysLong;
      case RowDataFieldType.dia:
        return localizations.diaLong;
      case pul:
        return localizations.pulLong;
      case RowDataFieldType.notes:
        return localizations.notes;
      case RowDataFieldType.color:
        return localizations.color;
    }
  }
}