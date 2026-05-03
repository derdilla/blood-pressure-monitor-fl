import 'dart:collection';
import 'dart:convert';

import 'package:blood_pressure_app/model/horizontal_graph_line.dart';
import 'package:settings_annotation/settings_annotation.dart';

import '../convert_util.dart';

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
          .map((v) => HorizontalGraphLine.fromJson(v))
          .toList());

  @override
  List<HorizontalGraphLine> get value => UnmodifiableListView(super.value);
}
