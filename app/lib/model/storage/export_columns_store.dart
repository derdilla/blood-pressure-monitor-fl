import 'dart:collection';
import 'dart:convert';

import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:flutter/material.dart';

/// Class for managing columns available to the user.
class ExportColumnsManager extends ChangeNotifier {
  /// Create a instance from a map created by [toMap].
  factory ExportColumnsManager.fromMap(Map<String, dynamic> map) {
    final List<dynamic> jsonUserColumns = map['userColumns'];
    final manager = ExportColumnsManager();
    for (final Map<String, dynamic> c in jsonUserColumns) {
      switch (c['t']) {
        case 0:
          manager.addOrUpdate(UserColumn.explicit(c['id'], c['csvTitle'], c['formatString']));
          break;
        case 1:
          manager.addOrUpdate(TimeColumn.explicit(c['id'], c['csvTitle'], c['formatPattern']));
          break;
        default:
          assert(false, 'Unexpected column type ${c['t']}.');
      }
    }
    return manager;
  }

  /// Create a instance from a [String] created by [toJson].
  factory ExportColumnsManager.fromJson(String jsonString) {
    try {
      return ExportColumnsManager.fromMap(jsonDecode(jsonString));
    } catch (e) {
      assert(e is FormatException || e is TypeError);
      return ExportColumnsManager();
    }
  }
  /// Create a new manager for export columns.
  ///
  /// It will be filled with the default columns but won't contain initial user columns.
  ExportColumnsManager();

  /// Reset all fields to their default values.
  void reset() {
    _userColumns.clear();
    notifyListeners();
  }

  /// Namespaces that may not lead a user columns internal identifier.
  static const List<String> reservedNamespaces = ['buildIn', 'myHeart'];

  /// Map between all [ExportColumn.internalIdentifier]s and [ExportColumn]s
  /// added by a user.
  final Map<String, ExportColumn> _userColumns = {};

  /// View of map between all [ExportColumn.internalIdentifier]s and columns
  /// added by a user.
  UnmodifiableMapView<String, ExportColumn> get userColumns => UnmodifiableMapView(_userColumns);

  /// Tries to save the column to the map with the [ExportColumn.internalIdentifier]
  /// key.
  ///
  /// This method fails and returns false when there is a default [ExportColumn] with the same internal name is
  /// available.
  bool addOrUpdate(ExportColumn column) {
    if (reservedNamespaces.any((element) => column.internalIdentifier.startsWith(element))) return false;
    _userColumns[column.internalIdentifier] = column;
    notifyListeners();
    return true;
  }

  /// Deletes a [ExportColumn] the user added.
  ///
  /// Calling this with the [ExportColumnI.internalIdentifier] of build-in columns
  /// or undefined columns will have no effect.
  void deleteUserColumn(String identifier) {
    assert(_userColumns.containsKey(identifier), "Don't call deleteUserColumn for non-existent or non-user columns");
    _userColumns.remove(identifier);
    notifyListeners();
  }

  /// Get any defined column (user or build in) by identifier.
  ExportColumn? getColumn(String identifier) => 
      firstWhere((c) => c.internalIdentifier == identifier);

  /// Get the first of column that satisfies [test].
  /// 
  /// Checks in the order: 
  /// 1. userColumns 
  /// 2. NativeColumn 
  /// 3. BuildInColumn
  ExportColumn? firstWhere(bool Function(ExportColumn) test) =>
    userColumns.values.where(test).firstOrNull
      ?? NativeColumn.allColumns.where(test).firstOrNull
      ?? BuildInColumn.allColumns.where(test).firstOrNull;
      // ?? ...

  /// Returns a list of all userColumns, NativeColumns and BuildInColumns defined.
  ///
  /// Prefer using other methods like [firstWhere] when possible.
  UnmodifiableListView<ExportColumn> getAllColumns() {
    final columns = <ExportColumn>[];
    columns.addAll(NativeColumn.allColumns);
    columns.addAll(userColumns.values);
    columns.addAll(BuildInColumn.allColumns);
    return UnmodifiableListView(columns);
  }

  /// Returns a list of all NativeColumns and BuildInColumns defined.
  UnmodifiableListView<ExportColumn> getAllUnmodifiableColumns() {
    final columns = <ExportColumn>[];
    columns.addAll(NativeColumn.allColumns);
    columns.addAll(BuildInColumn.allColumns);
    return UnmodifiableListView(columns);
  }

  /// Serialize the object to a restoreable map.
  Map<String, dynamic> toMap() {
    final columns = [];
    for (final c in _userColumns.values) {
      switch (c) {
        case UserColumn():
          columns.add({
            't': 0, // class type
            'id': c.internalIdentifier,
            'csvTitle': c.csvTitle,
            'formatString': c.formatPattern,
          });
          break;
        case BuildInColumn():
        case NativeColumn():
          assert(false, 'User is currently not able to create these columns.');
          break;
        case TimeColumn():
          columns.add({
            't': 1, // class type
            'id': c.internalIdentifier,
            'csvTitle': c.csvTitle,
            'formatPattern': c.formatPattern,
          });
          break;
      }
    }
    return {
      'userColumns': columns,
    };
  }

  /// Serialize the object to a restoreable string.
  String toJson() => jsonEncode(toMap());
}

