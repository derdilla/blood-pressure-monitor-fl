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
  xsl,
  pdf,
  db;

  int serialize() => switch(this) {
    ExportFormat.csv => 0,
    ExportFormat.pdf => 1,
    ExportFormat.db => 2,
    ExportFormat.xsl => 3,
  };

  factory ExportFormat.deserialize(Object? value) {
    final int? intValue = ConvertUtil.parseInt(value);
    if (value == null || intValue == null) return ExportFormat.csv;

    switch(intValue) {
      case 0:
        return ExportFormat.csv;
      case 1:
        return ExportFormat.pdf;
      case 2:
        return ExportFormat.db;
      case 3:
        return ExportFormat.xsl;
      default:
        assert(false);
        return ExportFormat.csv;
    }
  }
}