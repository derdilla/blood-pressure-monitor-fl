import 'package:blood_pressure_app/features/export_import/model/export_preset.dart';
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
        'label': preset.id,
        'columns': preset.columns,
        'editable': preset.editable,
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
      final editable = presetData['editable'];
      if (editable is! bool) continue;


      if (!presetData.containsKey('columns')) continue;
      final columns = ConvertUtil.parseList<String>(presetData['columns']);
      if (columns is! List<String>) continue;

      decoded.add(ExportPreset(label, columns, editable));
    }
    super.fromMapValue(decoded);
  }
}
