import 'dart:collection';
import 'dart:convert';

import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:flutter/material.dart';

/// Class for managing columns available to the user.
class ExportColumnsManager extends ChangeNotifier { // TODO: separate ExportColumnsManager for export and import ?
  /// Create a new manager for export columns.
  ///
  /// It will be filled with the default columns but won't contain initial user columns.
  ExportColumnsManager();

  static const List<String> reservedNamespaces = ['buildIn', 'myHeart'];

  /// Map between all [ExportColumn.internalIdentifier]s and [ExportColumn]s added by a user.
  final Map<String, ExportColumn> _userColumns = {};

  /// View of map between all [ExportColumn.internalName]s and [ExportColumn]s added by a user.
  UnmodifiableMapView<String, ExportColumn> get userColumns => UnmodifiableMapView(_userColumns);
  // TODO: consider replacing with a allColumns getter once build ins are added.

  /// Tries to save the column to the map with the [ExportColumn.internalName] key.
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
    assert(_userColumns.containsKey(identifier), 'Don\'t call for non user columns');
    _userColumns.remove(identifier);
    notifyListeners();
  }

  // TODO test
  /// Get any defined column (user or build in) by identifier.
  ExportColumn? getColumn(String identifier) => 
      firstWhere((c) => c.internalIdentifier == identifier);
  
  // TODO test
  /// Get the first of column that satisfies [test].
  /// 
  /// Checks in the order: 
  /// 1. userColumns 
  /// 2. NativeColumn 
  /// 3. BuildInColumn
  ExportColumn? firstWhere(bool Function(ExportColumn) test) {
    return userColumns.values.where(test).firstOrNull
        ?? NativeColumn.allColumns.where(test).firstOrNull
        ?? BuildInColumn.allColumns.where(test).firstOrNull; 
        // ?? ...
  }

  String toJson() { // TODO: update from and TO json to new style
    final columns = [];
    for (final c in _userColumns.values) {
      switch (c) {
        case UserColumn():
          columns.add({
            't': 0, // class type
            'id': c.internalIdentifier,
            'csvTitle': c.csvTitle,
            'formatString': c.formatPattern
          });
          break;
        case BuildInColumn():
        case NativeColumn():
          assert(false, 'User is currently not able to create these columns.');
      }
    }
    return jsonEncode({
      'userColumns': columns,
    });
  }

  factory ExportColumnsManager.fromJson(String jsonString) {
    final json = jsonDecode(jsonString);
    final List<dynamic> jsonUserColumns = json['userColumns'];
    final manager = ExportColumnsManager();
    for (final Map<String, dynamic> c in jsonUserColumns) {
      switch (c['t']) {
        case 0:
          manager.addOrUpdate(UserColumn(c['id'], c['csvTitle'], c['formatString']));
          break;
        default:
          assert(false, 'Unexpected column type ${c['t']}.');
      }
    }

    return manager;
  }
}

