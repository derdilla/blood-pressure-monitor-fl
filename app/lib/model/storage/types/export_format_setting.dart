import 'package:settings_annotation/settings_annotation.dart';
import '../convert_util.dart';

class ExportFormatSetting extends Setting<ExportFormat> {
  ExportFormatSetting({required super.initialValue});

  @override
  Object? toMapValue() => value.serialize();

  @override
  void fromMapValue(Object? value) => super
      .fromMapValue(ExportFormat.deserialize(value));
}

/// File formats to which measurements can be exported.
enum ExportFormat {
  csv,
  xls,
  pdf,
  db;

  int serialize() => switch(this) {
    ExportFormat.csv => 0,
    ExportFormat.pdf => 1,
    ExportFormat.db => 2,
    ExportFormat.xls => 3,
  };

  factory ExportFormat.deserialize(Object? value) {
    final int? intValue = ConvertUtil.parseInt(value);
    if (value == null || intValue == null) return ExportFormat.csv;

    return switch(intValue) {
      0 => ExportFormat.csv,
      1 => ExportFormat.pdf,
      2 => ExportFormat.db,
      3 => ExportFormat.xls,
      _ => ExportFormat.csv,
    };
  }
}