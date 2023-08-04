import 'dart:collection';

import 'package:blood_pressure_app/model/blood_pressure.dart';
import 'package:blood_pressure_app/model/settings_store.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:function_tree/function_tree.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ExportConfigurationModel {
  static ExportConfigurationModel? _instance;

  final Settings settings;
  final AppLocalizations localizations;
  late final Database _database;
  
  final List<ExportColumn> _availableFormats = [];

  ExportConfigurationModel._create(this.settings, this.localizations);
  Future<void> _asyncInit(String? dbPath, bool isFullPath) async {
    dbPath ??= await getDatabasesPath();
    if (dbPath != inMemoryDatabasePath && !isFullPath) {
      dbPath = join(dbPath, 'config.db');
    }

    _database = await openDatabase(
      dbPath,
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE exportStrings(internalColumnName STRING PRIMARY KEY, columnTitle STRING, formatPattern STRING)');
      },
      version: 1,
    );

    final existingDbEntries = await _database.rawQuery('SELECT * FROM exportStrings');
    for (final e in existingDbEntries) {
      _availableFormats.add(ExportColumn(internalName: e['internalColumnName'].toString(),
          columnTitle: e['columnTitle'].toString(), formatPattern: e['formatPattern'].toString()));
    }
    _availableFormats.addAll(getDefaultFormates());
  }
  static Future<ExportConfigurationModel> get(Settings settings, AppLocalizations localizations, {String? dbPath, bool isFullPath = false}) async {
    if (_instance == null) {
      _instance = ExportConfigurationModel._create(settings, localizations);
      await _instance!._asyncInit(dbPath, isFullPath);
    }
    return _instance!;
  }

  List<ExportColumn> getActiveExportColumns() {
    List<ExportColumn> activeFields = [];
    for (final internalName in settings.exportItems) {
      activeFields.add(availableFormats.singleWhere((e) => e.internalName == internalName));
    }
    return activeFields;
  }
  
  List<ExportColumn> getDefaultFormates() => [
    ExportColumn(internalName: 'timestampUnixMs', columnTitle: localizations.unixTimestamp, formatPattern: r'$TIMESTAMP', editable: false),
    ExportColumn(internalName: 'formattedTimestamp', columnTitle: localizations.time, formatPattern: '\$FORMAT{\$TIMESTAMP,${settings.dateFormatString}}', editable: false),
    ExportColumn(internalName: 'systolic', columnTitle: localizations.sysLong, formatPattern: r'$SYS', editable: false),
    ExportColumn(internalName: 'diastolic', columnTitle: localizations.diaLong, formatPattern: r'$DIA', editable: false),
    ExportColumn(internalName: 'pulse', columnTitle: localizations.pulLong, formatPattern: r'$PUL', editable: false),
    ExportColumn(internalName: 'notes', columnTitle: localizations.notes, formatPattern: r'$NOTE', editable: false),
    ExportColumn(internalName: 'pulsePressure', columnTitle: localizations.pulsePressure, formatPattern: r'{{$SYS-$DIA}}', editable: false),

    ExportColumn(internalName: 'DATUM', columnTitle: '"My Heart" export time', formatPattern: r'$FORMAT{$TIMESTAMP,yyyy-MM-dd HH:mm:ss}', editable: false, hidden: true),
    ExportColumn(internalName: 'SYSTOLE', columnTitle: '"My Heart" export sys', formatPattern: r'$SYS', editable: false, hidden: true),
    ExportColumn(internalName: 'DIASTOLE', columnTitle: '"My Heart" export dia', formatPattern: r'$DIA', editable: false, hidden: true),
    ExportColumn(internalName: 'PULS', columnTitle: '"My Heart" export pul', formatPattern: r'$PUL', editable: false, hidden: true),
    ExportColumn(internalName: 'Beschreibung', columnTitle: '"My Heart" export description', formatPattern: r'null', editable: false, hidden: true),
    ExportColumn(internalName: 'Tags', columnTitle: '"My Heart" export tags', formatPattern: r'', editable: false, hidden: true),
    ExportColumn(internalName: 'Gewicht', columnTitle: '"My Heart" export weight', formatPattern: r'0.0', editable: false, hidden: true),
    ExportColumn(internalName: 'Sauerstoffsättigung', columnTitle: '"My Heart" export oxygen', formatPattern: r'0', editable: false, hidden: true),
  ];

  void addOrUpdate(ExportColumn format) {
    final existingEntries = _availableFormats.where((element) => element.internalName == format.internalName);
    if (existingEntries.isNotEmpty) {
      assert(existingEntries.length == 1);
      if (!existingEntries.first.editable) {
        assert(false, 'Attempted to update non editable field. While this doesn\'t cause any direct issues, it should not be made possible through the UI.');
        return;
      }
      _availableFormats.remove(existingEntries.first);
      _availableFormats.add(format);
      _database.update('exportStrings', {
        'columnTitle': format.columnTitle,
        'formatPattern': format.formatPattern
      }, where: 'internalColumnName = ?', whereArgs: [format.internalName]);
    }
    _availableFormats.add(format);
    _database.insert('exportStrings', {
      'internalColumnName': format.internalName,
      'columnTitle': format.columnTitle,
      'formatPattern': format.formatPattern
    },);
  }

  void delete(ExportColumn format) {
    final existingEntries = _availableFormats.where((element) => (element.internalName == format.internalName) && element.editable);
    assert(existingEntries.isNotEmpty, 'Tried to delete entry that doesn\'t exist');
    _availableFormats.removeWhere((element) => element.internalName == format.internalName);
    _database.delete('exportStrings', where: 'internalColumnName = ?', whereArgs: [format.internalName]);
  }

  UnmodifiableListView<ExportColumn> get availableFormats => UnmodifiableListView(_availableFormats);
  UnmodifiableMapView<String, ExportColumn> get availableFormatsMap =>
      UnmodifiableMapView(Map.fromIterable(_availableFormats, key: (e) => e.internalName));

  List<List<String>> createTable(List<BloodPressureRecord> data, bool createHeadline) {
    List<ExportColumn> exportItems;
    if (settings.exportCustomEntries) {
      exportItems = getActiveExportColumns();
    } else {
      exportItems = getDefaultFormates().where((e) => ['timestampUnixMs','systolic','diastolic','pulse','notes'].contains(e.internalName)).toList();
    }

    List<List<String>> items = [];
    if (createHeadline) {
      List<String> headline = [];
      for (var i = 0; i<exportItems.length; i++) {
        headline.add(exportItems[i].internalName);
      }
      items.add(headline);
    }

    for (var record in data) {
      List<String> row = [];
      for (var attribute in exportItems) {
        row.add(attribute.formatRecord(record));
      }
      items.add(row);
    }
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

  List<(RowDataFieldType, dynamic)> parseRecord(String formattedRecord) {
    if (!isReversible || formattedRecord == 'null') return [];

    if (formatPattern == r'$NOTE') return [(RowDataFieldType.notes, formattedRecord)];

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
    return formatPattern == r'$TIMESTAMP' ||
        formatPattern.contains(RegExp(r'\$(TIMESTAMP|SYS|DIA|PUL|NOTE)')) && !formatPattern.contains(RegExp(r'[{},]'));
  }

  @override
  String toString() {
    return 'ExportColumn{internalColumnName: $internalName, columnTitle: $columnTitle, formatPattern: $formatPattern}';
  }
}

enum RowDataFieldType {
  timestamp,
  sys,
  dia,
  pul,
  notes
}