import 'dart:collection';
import 'dart:convert';

import 'package:blood_pressure_app/model/horizontal_graph_line.dart';
import 'package:blood_pressure_app/model/storage/convert_util.dart';
import 'package:settings_annotation/settings_annotation.dart';

class HorizontalGraphLineListSetting
    extends Setting<List<HorizontalGraphLine>> {
  HorizontalGraphLineListSetting({required super.initialValue});

  @override
  Object? toMapValue() =>
      value.map((line) => line.toJson()).map(jsonEncode).toList();

  @override
  void fromMapValue(Object? value) =>
      super.fromMapValue(ConvertUtil.parseList<String>(value)
          ?.map(jsonDecode)
          .whereType<Map<String, dynamic>>()
          .map(HorizontalGraphLine.fromJson)
          .toList());

  @override
  List<HorizontalGraphLine> get value => UnmodifiableListView(super.value);
}
