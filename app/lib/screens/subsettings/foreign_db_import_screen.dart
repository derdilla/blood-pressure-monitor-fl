import 'dart:convert';

import 'package:blood_pressure_app/components/consistent_future_builder.dart';
import 'package:blood_pressure_app/components/dialoges/tree_selection_dialoge.dart';
import 'package:blood_pressure_app/model/blood_pressure/needle_pin.dart';
import 'package:blood_pressure_app/model/export_import/import_field_type.dart';
import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlparser/sqlparser.dart';

/// Screen to select the columns from a database and annotate types.
///
/// Parses data table to [BloodPressureRecord] list.
class ForeignDBImportScreen extends StatefulWidget {
  /// Create a screen to import data from a database with unknown structure.
  /// 
  /// Parses selected data to a [BloodPressureRecord] list.
  const ForeignDBImportScreen({super.key,
    required this.db,
    required this.bottomAppBars,
  });

  /// Database from which to import data.
  final Database db;

  /// Whether to move the app bar for saving and loading to the bottom of the
  /// screen.
  final bool bottomAppBars;

  @override
  State<ForeignDBImportScreen> createState() => _ForeignDBImportScreenState();
}

class _ForeignDBImportScreenState extends State<ForeignDBImportScreen> {
  @override
  Widget build(BuildContext context) => ConsistentFutureBuilder(
    future: _ColumnImportData.loadFromDB(widget.db),
    onData: (BuildContext context, _ColumnImportData data) {
      final localizations = AppLocalizations.of(context)!;
      return TreeSelectionDialoge(
        buildOptions: (selections) {
          if (selections.isEmpty) {
            return data.tableNames.toList();
          }
          if (selections.length == 1) {
            return data.columns[selections[0]]!;
          }

          if ((selections.length % 2 == 0)) {
            final columns = data.columns[selections[0]]!;
            return columns.whereNot((e) => selections.contains(e)).toList();
          } else {
            return RowDataFieldType.values
                .whereNot((e) => e == RowDataFieldType.timestamp
                || selections.contains(e),)
                .map((e) => e.localize(localizations))
                .toList();
          }
        },
        validator: (List<String> elements) {
          const kMetaColumns = 2;
          if (elements.isEmpty) return 'No table selected';
          if (elements.length < kMetaColumns) return 'No time column selected';
          if (elements.length % 2 != kMetaColumns % 2) {
            return 'Select a data column or return to last screen';
          }
          if (elements.length < 4) return 'Select at least one data column';

          // return 'The schnibledumps doesn\'t schwibble!'; // TODO check if more tests are required
          return null;
        },
        onSaved: (List<String> madeSelections) async {
          final tableName = madeSelections.removeAt(0);
          final timeColumn = madeSelections.removeAt(0);
          final dataColumns = <(String, RowDataFieldType)>[];
          while (madeSelections.isNotEmpty) {
            final column = madeSelections.removeAt(0);
            final typeStr = madeSelections.removeAt(0);
            final type = RowDataFieldType.values
                .firstWhere((t) => t.localize(localizations) == typeStr);
            dataColumns.add((column, type));
          }

          final data = await widget.db.query(tableName);
          final entries = <FullEntry>[];
          for (final row in data) {
            assert(row.containsKey(timeColumn)
                && madeSelections.every(row.containsKey),);
            final timestamp = ConvertUtil.parseTime(row[timeColumn]);
            if (timestamp == null) throw FormatException('Unable to parse time: ${row[timeColumn]}'); // TODO: error handling
            FullEntry entry = (BloodPressureRecord(time: timestamp), Note(time: timestamp), []);
            final settings = context.read<Settings>();
            for (final colType in dataColumns) {
              switch (colType.$2) {
                case RowDataFieldType.timestamp:
                  assert(false, 'Not up for selection');
                case RowDataFieldType.sys:
                  final val = ConvertUtil.parseInt(row[colType.$1]);
                  entry = (entry.$1.copyWith(sys: (val == null) ? null : settings.preferredPressureUnit.wrap(val),), entry.$2, entry.$3);
                case RowDataFieldType.dia:
                  final val = ConvertUtil.parseInt(row[colType.$1]);
                  entry = (entry.$1.copyWith(dia: (val == null) ? null : settings.preferredPressureUnit.wrap(val),), entry.$2, entry.$3);
                case RowDataFieldType.pul:
                  entry = (entry.$1.copyWith(pul: ConvertUtil.parseInt(row[colType.$1]),), entry.$2, entry.$3);
                case RowDataFieldType.notes:
                  final note = ConvertUtil.parseString(row[colType.$1]);
                  entry = (entry.$1, entry.$2.copyWith(note: note), entry.$3);
                case RowDataFieldType.color:
                  try {
                    final json = jsonDecode(row[colType.$1].toString());
                    if (json is! Map<String, dynamic>) continue;
                    final pin = MeasurementNeedlePin.fromMap(json);
                    entry = (entry.$1, entry.$2.copyWith(color: pin.color.value), entry.$3);
                  } on FormatException {
                    // Not parsable: silently ignore for now
                  }
              }
            }
            entries.add(entry);
          }
          if (context.mounted) Navigator.pop(context, entries);
        },
        buildTitle: (List<String> selections) {
          if (selections.isEmpty) return 'Select table';
          if (selections.length == 1) return 'Select time column';
          if ((selections.length % 2 == 0)) {
            return 'Select data column';
          } else {
            return 'Select column type (${selections.last})';
          }
        },
        bottomAppBars: widget.bottomAppBars, // TODO
      );
      // TODO: localize everything
      // TODO: detect when no more selections are possible
    },
  );
}

class _ColumnImportData {
  _ColumnImportData._create(this.columns);

  static Future<_ColumnImportData> loadFromDB(Database db) async {
    final engine = SqlEngine();

    final masterTable = await db.query('sqlite_master',
      columns: ['sql'],
      where: 'type = "table"',
    );
    final columns = <String, List<String>?>{};
    for (final e in masterTable) {
      final creationSql = e['sql']!.toString();
      final rootNode = engine.analyze(creationSql).root;
      if (rootNode is CreateTableStatement) {
        final colNames = rootNode.columns
            .map((e) => e.columnName)
            .toSet()
            .toList();

        if (colNames.isNotEmpty) columns[rootNode.tableName] = colNames;
      }
    }
    return _ColumnImportData._create(columns);
  }

  /// Map of table names and their respective column names.
  Map<String, List<String>?> columns;

  /// Names of all tables.
  Iterable<String> get tableNames => columns.keys;
}

/// Shows a dialoge to import arbitrary data from a external database.
Future<List<FullEntry>?> showForeignDBImportDialoge(
    BuildContext context,
    bool bottomAppBars,
    Database db,) =>
    showDialog<List<FullEntry>>(
      context: context, builder: (context) => ForeignDBImportScreen(
        bottomAppBars: bottomAppBars,
        db: db,
      ),
    );
