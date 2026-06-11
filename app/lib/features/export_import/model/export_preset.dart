import 'package:blood_pressure_app/features/export_import/model/column.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:flutter/cupertino.dart';

class ExportPreset {
  const ExportPreset(this.id, this.columns);

  static ExportPreset appDefault = _DefaultPreset();
  
  static ExportPreset appPdf = _PDFPreset();
  
  static ExportPreset myHeart = ExportPreset('"My Heart" export', [
    BuildInColumn.mhDate.internalIdentifier,
    BuildInColumn.mhSys.internalIdentifier,
    BuildInColumn.mhDia.internalIdentifier,
    BuildInColumn.mhPul.internalIdentifier,
    BuildInColumn.mhDesc.internalIdentifier,
    BuildInColumn.mhTags.internalIdentifier,
    BuildInColumn.mhWeight.internalIdentifier,
    BuildInColumn.mhOxygen.internalIdentifier,
  ]);
  
  final String id;

  /// IDs of active columns
  final List<String> columns;

  String localize(AppLocalizations _) => id;
}

class _DefaultPreset implements ExportPreset {
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
}

class _PDFPreset implements ExportPreset {
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
  String localize(AppLocalizations l) => l.default_;
}

class CustomPreset with ChangeNotifier implements ExportPreset {
  @override
  String get id => 'Custom';
  
  List<String> _columns = <String>[];

  @override
  List<String> get columns => _columns;

  @override
  String localize(AppLocalizations l) => l.default_;

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
