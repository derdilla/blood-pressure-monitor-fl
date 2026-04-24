import 'package:settings_annotation/settings_annotation.dart';
import '../convert_util.dart';

class StringListSetting extends Setting<List<String>> {
  StringListSetting({required super.initialValue});

  @override
  void fromMapValue(Object? value) => super.fromMapValue(
      ConvertUtil.parseList<String>(value));
}
