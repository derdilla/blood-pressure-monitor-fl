import 'package:blood_pressure_app/components/consistent_future_builder.dart';
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

  /// The name of the selected column that contains the timestamps.
  String? _activeTimeColumnName;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: ConsistentFutureBuilder(
      future: _ColumnImportData.loadFromDB(widget.db),
      onData: (BuildContext context, data) {
        final localizations = AppLocalizations.of(context);
        return ListView(
          children: [
            ListTile(
              title: Text(
                'Select table:',
                style: Theme.of(context).textTheme.titleLarge!,
              ),
            ),
            for (final table in data.tableNames)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(table),
                ),
              ),
            // TODO
          ],
        );
      },
    ),
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
          ?.group(0)
          ?.split(',')
          .map((e) => e.split(' ').first)
          .toList();
      assert(colNames != null);
      columns[tableName] = colNames;
    } 
    return _ColumnImportData._create(columns);
  }

  /// Map of table names and their respective column names.
  Map<String, List<String>?> columns;

  /// Names of all tables.
  Iterable<String> get tableNames => columns.keys;
}
