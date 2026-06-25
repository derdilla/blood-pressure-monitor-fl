import 'package:blood_pressure_app/features/export_import/model/column.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';

class ExportPreset {
  const ExportPreset(this.id, this.columns, this.editable);

  static const ExportPreset appDefault = _DefaultPreset();
  
  static const ExportPreset appPdf = _PDFPreset();
  
  static final ExportPreset myHeart = ExportPreset('"My Heart" export', [
    BuildInColumn.mhDate.internalIdentifier,
    BuildInColumn.mhSys.internalIdentifier,
    BuildInColumn.mhDia.internalIdentifier,
    BuildInColumn.mhPul.internalIdentifier,
    BuildInColumn.mhDesc.internalIdentifier,
    BuildInColumn.mhTags.internalIdentifier,
    BuildInColumn.mhWeight.internalIdentifier,
    BuildInColumn.mhOxygen.internalIdentifier,
  ], false);

  static final buildInPresets = <ExportPreset>[
    ExportPreset.appDefault,
    ExportPreset.appPdf,
    ExportPreset.myHeart,
  ];
  
  final String id;

  /// IDs of active columns
  final List<String> columns;

  String localize(AppLocalizations _) => id;

  final bool editable;
}

class _DefaultPreset implements ExportPreset {
  const _DefaultPreset();

  @override
  String get id => 'BpApp Default';

  @override
  List<String> get columns => [
    NativeColumn.timestampUnixMs.internalIdentifier,
    NativeColumn.systolic.internalIdentifier,
    NativeColumn.diastolic.internalIdentifier,
    NativeColumn.pulse.internalIdentifier,
    NativeColumn.notes.internalIdentifier,
    NativeColumn.color.internalIdentifier,
    NativeColumn.intakes.internalIdentifier,
    NativeColumn.bodyweight.internalIdentifier,
  ];

  @override
  String localize(AppLocalizations l) => l.default_;

  @override
  bool get editable => false;
}

class _PDFPreset implements ExportPreset {
  const _PDFPreset();

  @override
  String get id => 'BpApp PDF';

  @override
  List<String> get columns => [
    BuildInColumn.formattedTime.internalIdentifier,
    NativeColumn.systolic.internalIdentifier,
    NativeColumn.diastolic.internalIdentifier,
    NativeColumn.pulse.internalIdentifier,
  ];

  @override
  String localize(AppLocalizations l) => l.pdf;

  @override
  bool get editable => false;
}

class CustomPreset with ChangeNotifier implements ExportPreset {
  CustomPreset(this._columns): baseId = null;

  CustomPreset.fromPreset(ExportPreset preset): baseId = preset.id {
    _columns = preset.columns.toList();
  }

  @override
  String get id => 'Custom';
  
  late final List<String> _columns;

  /// Canonical ID, if this is stored as a user column.
  final String? baseId;

  @override
  List<String> get columns => _columns;

  @override
  String localize(AppLocalizations l) => baseId ?? l.custom;

  @override
  bool get editable => true;

  /// Put the user column at [oldIndex] to [newIndex].
  void reorderUserColumns(int oldIndex, int newIndex) {
    if (newIndex >= _columns.length) {
      // prevent dragging over add button
      newIndex = newIndex = _columns.length - 1;
    }
    assert(oldIndex >= 0 && oldIndex < _columns.length);
    assert(newIndex >= 0 && newIndex < _columns.length);
    final item = _columns.removeAt(oldIndex);
    _columns.insert(newIndex, item);
    notifyListeners();
  }

  /// Add a export column to the end of user columns.
  void addUserColumn(ExportColumn column) {
    _columns.add(column.internalIdentifier);
    notifyListeners();
  }

  /// Removes the first export column from user columns where
  /// [ExportColumn.internalIdentifier] matches [identifier].
  void removeUserColumn(String identifier) {
    _columns.removeWhere((c) => c == identifier);
    notifyListeners();
  }
}

extension BuildInPresets on ExportSettings {
  /// Returns all export presets including build-ins.
  List<ExportPreset> get allPresets => [
    ...ExportPreset.buildInPresets,
    ...presets,
  ];

  ExportPreset? getPresetById(String presetId) => allPresets
      .firstWhereOrNull((p) => p.id == presetId);
}
