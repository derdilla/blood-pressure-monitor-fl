import 'dart:collection';
import 'dart:convert';

import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:flutter/material.dart';

class ExportColumnsManager extends ChangeNotifier { // TODO: separate ExportColumnsManager for export and import ?
  /// Create a new class for managing export columns.
  ///
  /// It will be filled with the default columns but won't contain initial user columns.
  ExportColumnsManager({
    this.activePreset = ExportImportPreset.bloodPressureApp
  });

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

  final List<String> _activeColumnIDs = []; // TODO import/export
  ExportImportPreset activePreset;

  List<ExportColumn> getActiveColumns() => switch (activePreset) {
    // TODO: Handle this case.
    ExportImportPreset.none => [],
    // TODO: Handle this case.
    ExportImportPreset.bloodPressureApp => [
      NativeColumn.timestamp,
      NativeColumn.systolic,
      NativeColumn.diastolic,
      NativeColumn.pulse,
      NativeColumn.notes,
      NativeColumn.color,
    ],
    // TODO: Handle this case.
    ExportImportPreset.myHeart => [],
  }

  String toJson() {
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
        case NativeColumn():
          assert(false, 'User is currently not able to create native columns.');
      }
    }
    return jsonEncode({
      'userColumns': columns,
      'preset': activePreset.encode(),
    });
  }

  factory ExportColumnsManager.fromJson(String jsonString) {
    final json = jsonDecode(jsonString);
    final ExportImportPreset preset = ExportImportPreset.decode(json['preset']) ?? ExportImportPreset.bloodPressureApp;
    final List<dynamic> jsonUserColumns = json['userColumns'];
    final manager = ExportColumnsManager(activePreset: preset);
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

enum ExportImportPreset {
  /// Custom export configuration.
  none,

  /// Default preset, that ensures working exports and restoration.
  bloodPressureApp,
  myHeart;

  int encode() => switch (this) {
    ExportImportPreset.none => 0,
    ExportImportPreset.bloodPressureApp => 1,
    ExportImportPreset.myHeart => 2
  };

  static ExportImportPreset? decode(dynamic e) {
    return switch(e) {
      0 => ExportImportPreset.none,
      1 => ExportImportPreset.bloodPressureApp,
      2 => ExportImportPreset.myHeart,
      _ => (){
        assert(false);
        return null;
      }(),
    };
  }
}