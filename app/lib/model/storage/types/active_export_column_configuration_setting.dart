import 'package:blood_pressure_app/features/export_import/model/export_configuration.dart';
import 'package:settings_annotation/settings_annotation.dart';

class ActiveExportColumnConfigurationSetting extends DeepSetting<ActiveExportColumnConfiguration> {
  ActiveExportColumnConfigurationSetting({required super.initialValue});

  @override
  Object? toMapValue() => value.toJson();

  @override
  void fromMapValue(Object? value) => super
      .fromMapValue(ActiveExportColumnConfiguration.fromJson(value as String));
}
