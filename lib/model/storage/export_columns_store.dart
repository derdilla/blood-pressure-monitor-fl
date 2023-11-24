import 'dart:collection';
import 'dart:convert';

import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:flutter/material.dart';

class ExportColumnsManager extends ChangeNotifier {
  static const List<String> reservedNamespaces = ['buildIn', 'myHeart'];

  /// Map between all [ExportColumn.internalIdentifier]s and [ExportColumn]s added by a user.
  final Map<String, ExportColumn> _userColumns = {};

  /// View of map between all [ExportColumn.internalName]s and [ExportColumn]s added by a user.
  UnmodifiableMapView<String, ExportColumn> get userColumns => UnmodifiableMapView(_userColumns);

  /// Tries to save the column to the map with the [ExportColumn.internalName] key.
  ///
  /// This method fails and returns false when there is a default [ExportColumn] with the same internal name is
  /// available.
  bool addOrUpdate(ExportColumn column) {
    if (reservedNamespaces.any((element) => column.internalIdentifier.startsWith(element)) return false;
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
  }

  String toJson() {
    // TODO
    throw UnimplementedError();
  }
}