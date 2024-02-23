import 'package:blood_pressure_app/components/consistent_future_builder.dart';
import 'package:blood_pressure_app/components/dialoges/tree_selection_dialoge.dart';
import 'package:blood_pressure_app/model/export_import/import_field_type.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:sqflite/sqflite.dart';

/// Screen to select the columns from a database and annotate types.
class ForeignDBImportScreen extends StatefulWidget {
  /// Create a screen to import data from a database with unknown structure.
  const ForeignDBImportScreen({super.key, required this.db});

  /// Database from which to import data.
  final Database db;

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
        validator: (elements) {
          const kMetaColumns = 2;
          if (elements.isEmpty) return 'No table selected';
          if (elements.length < kMetaColumns) return 'No time column selected';
          if (elements.length % 2 != kMetaColumns % 2) {
            return 'Select a data column or return to last screen';
          }
          if (elements.length < 4) return 'Select at least one data column';

          return 'The schnibledumps doesn\'t schwibble!'; // TODO
        },
        buildTitle: (selections) {
          if (selections.isEmpty) return 'Select table';
          if (selections.length == 1) return 'Select time column';
          if ((selections.length % 2 == 0)) {
            return 'Select data column';
          } else {
            return 'Select column type (${selections.last})';
          }
        },
        bottomAppBars: true, // TODO
      );
      // TODO: perform import
      // TODO: localize everything
      // TODO: detect when no more selections are possible
    },
  );
}

class _ColumnImportData {
  _ColumnImportData._create(this.columns);
  
  static Future<_ColumnImportData> loadFromDB(Database db) async {
    final masterTable = await db.query('sqlite_master',
      columns: ['name', 'sql'],
      where: 'type = "table"'
    );
    final columns = <String, List<String>?>{};
    for (final e in masterTable) {
      final tableName = e['name']!.toString();
      final creationSql = e['sql']!.toString();
      final colNames = RegExp(r'CREATE\s+TABLE\s+[0-9\w]+\s*\(([\w\s()0-9,]+?)\)+')
          .firstMatch(creationSql)
          ?.group(1)
          ?.split(RegExp(r'[,()]'))
          .map((e) => e
              .split(' ')
              .where((e) => e.isNotEmpty)
              .whereNot((e) => ['INTEGER', 'TEXT', 'NOT', 'OR', 'PRIMARY',
                    'FOREIGN', 'DEFAULT', 'NULL', 'KEY', 'PREFERENCES', 'BLOB',]
                  .contains(e),
              )
              .firstWhereOrNull((e) => e.trim().isNotEmpty),
          )
          .whereNotNull()
          .toSet() // remove duplicates
          .toList();
      print('$creationSql:\t $colNames');
      // don't show tables without columns
      if (colNames?.isNotEmpty ?? false) {
        columns[tableName] = colNames;
      }
    } 
    return _ColumnImportData._create(columns);
  }

  /// Map of table names and their respective column names.
  Map<String, List<String>?> columns;

  /// Names of all tables.
  Iterable<String> get tableNames => columns.keys;
}
