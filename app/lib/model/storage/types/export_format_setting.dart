import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:settings_annotation/settings_annotation.dart';

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

  int serialize() => switch(this) {
    ExportFormat.csv => 0,
    ExportFormat.pdf => 1,
    ExportFormat.db => 2,
    ExportFormat.xls => 3,
  };
}
