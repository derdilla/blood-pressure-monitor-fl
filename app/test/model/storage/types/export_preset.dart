import 'dart:convert';

import 'package:blood_pressure_app/model/storage/types/export_preset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Deserializes serialized export preset', () {
    final setting = ExportPresetListSetting(
      initialValue: [
        ExportPreset('label1', ['a', 'B', 'c']),
        ExportPreset('label 2', ['huiasdolö822']),
      ]
    );

    final mapValue = setting.toMapValue();
    final setting2 = ExportPresetListSetting();
    setting2.fromMapValue(mapValue);
    expect(setting2.value.length, setting.value.length);
    expect(setting2.value[0].id, setting.value[0].id);
    expect(setting2.value[0].columns[1], setting.value[0].columns[1]);
    expect(setting2.value[1].columns[0], setting.value[1].columns[0]);


    setting2.fromMapValue(jsonDecode(jsonEncode(mapValue)));
    expect(setting2.value.length, setting.value.length);
    expect(setting2.value[0].id, setting.value[0].id);
    expect(setting2.value[0].columns[1], setting.value[0].columns[1]);
    expect(setting2.value[1].columns[0], setting.value[1].columns[0]);
  });
}