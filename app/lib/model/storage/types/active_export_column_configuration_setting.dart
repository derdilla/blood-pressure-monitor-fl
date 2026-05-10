import 'package:blood_pressure_app/model/export_import/export_configuration.dart';
import 'package:settings_annotation/settings_annotation.dart';

class ActiveExportColumnConfigurationSetting extends DeepSetting<ActiveExportColumnConfiguration> {
  ActiveExportColumnConfigurationSetting({required super.initialValue});

  @override
  Object? toMapValue() => value.toJson();

  @override
  void fromMapValue(Object? value) => super
      .fromMapValue(ActiveExportColumnConfiguration.fromJson(value as String));
}
