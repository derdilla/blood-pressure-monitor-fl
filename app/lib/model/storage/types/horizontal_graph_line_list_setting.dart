import 'package:settings_annotation/settings_annotation.dart';
import '../convert_util.dart';
import 'package:blood_pressure_app/model/horizontal_graph_line.dart';
import 'dart:convert';

class HorizontalGraphLineListSetting extends Setting<List<HorizontalGraphLine>> {
  HorizontalGraphLineListSetting({required super.initialValue});

  @override
  Object? toMapValue() => value.map(jsonEncode).toList();

  @override
  void fromMapValue(Object? value) => super.fromMapValue(
      ConvertUtil.parseList<String>(value)
          ?.map(jsonDecode)
          .map((v) => HorizontalGraphLine.fromJson(v))
          .toList());
}
