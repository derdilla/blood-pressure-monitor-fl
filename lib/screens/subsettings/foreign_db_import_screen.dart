import 'package:blood_pressure_app/components/consistent_future_builder.dart';
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

  /// The name of the table that contains the data.
  String? _selectedTableName;

  /// The name of the selected column that contains the timestamps.
  String? _activeTimeColumnName;

  /// The name of the column selected before selecting a datatype.
  ///
  /// Once a datatype is selected, this is reset to null.
  String? _lastSelectedColumnName;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: (_selectedTableName == null)
          ? const Text('Table')
          : const Text('Time column'),
    ),
    body: ConsistentFutureBuilder(
      future: _ColumnImportData.loadFromDB(widget.db),
      onData: (BuildContext context, _ColumnImportData data) {
        final localizations = AppLocalizations.of(context)!;

        if (_selectedTableName == null) {
          return _buildTableSelection(data);
        }
        if (_activeTimeColumnName == null) {
          return _buildColumnSelection(data, (String columnName) => setState(() {
            _activeTimeColumnName = columnName;
          }),);
        }

        if (_lastSelectedColumnName == null) {
          return _buildColumnSelection(data, (columnName) => setState(() {
            _lastSelectedColumnName = columnName;
          }),);
        }
        return _buildCardList(
          RowDataFieldType.values.map((e) => e.localize(localizations)),
          (columnName) {
            setState(() {
              // TODO: add to columns
              _lastSelectedColumnName = null;
            });
          },
        );

        // TODO: add finalize button

        
      },
    ),
  );

  Widget _buildTableSelection(_ColumnImportData data) =>
      _buildCardList(data.tableNames, (tableName) => setState(() {
        _selectedTableName = tableName;
      }));

  Widget _buildColumnSelection(
      _ColumnImportData data, 
      void Function(String columnName) onSelection,
  ) => _buildCardList(data.columns[_selectedTableName]!, onSelection);

  Widget _buildCardList(
      Iterable<String> allOptions,
      void Function(String columnName) onSelection,
  ) => ListView(
    children: [
      for (final option in allOptions)
        InkWell(
          onTap: () => onSelection(option),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(option),
            ),
          ),
        ),
    ],
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
          .map((e) => e
              .split(' ')
              .firstWhereOrNull((e) => e.trim().isNotEmpty),
          )
          .whereNotNull()
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
