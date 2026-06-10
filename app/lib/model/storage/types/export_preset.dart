import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:settings_annotation/settings_annotation.dart';

class ExportPresetListSetting extends Setting<List<ExportPreset>> {
  ExportPresetListSetting({
    List<ExportPreset>? initialValue,
  }): super(initialValue: initialValue ?? []);
  @override
  Object? toMapValue() => [
    for (final preset in value)
      {
        'label': preset.label,
        'columns': preset.columns,
      },
  ];

  @override
  void fromMapValue(Object? value) {
    if (value is! List) return;
    final decoded = <ExportPreset>[];
    for (final presetData in value) {
      if (presetData is! Map) continue;
      if (!presetData.containsKey('label')) continue;
      final label = presetData['label'];
      if (label is! String) continue;

      if (!presetData.containsKey('columns')) continue;
      final columns = ConvertUtil.parseList<String>(presetData['columns']);
      if (columns is! List<String>) continue;

      decoded.add(ExportPreset(label, columns));
    }
    super.fromMapValue(decoded);
  }

}

class ExportPreset {
  const ExportPreset(this.label, this.columns);

  final String label;

  /// IDs of active columns
  final List<String> columns;
}
