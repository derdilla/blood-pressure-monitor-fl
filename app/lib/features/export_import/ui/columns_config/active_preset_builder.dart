import 'package:blood_pressure_app/features/export_import/model/export_preset.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:blood_pressure_app/model/storage/types/export_format_setting.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActivePresetBuilder extends StatelessWidget {
  const ActivePresetBuilder({super.key, required this.builder});

  final Widget Function(BuildContext, ExportPreset) builder;

  String? _getPreset(BuildContext context) => switch(context.watch<ExportSettings>().exportFormat) {
    ExportFormat.csv => context.watch<CsvExportSettings>().activePreset,
    ExportFormat.xls => context.watch<PdfExportSettings>().activePreset,
    ExportFormat.pdf => context.watch<ExcelExportSettings>().activePreset,
    ExportFormat.db => null,
  };

  @override
  Widget build(BuildContext context) {
    final presetId = _getPreset(context);
    return _InnerPresetBuilder(presetId: presetId, builder: builder);
  }
}

class _InnerPresetBuilder extends StatefulWidget {
  const _InnerPresetBuilder({required this.presetId, required this.builder});

  final String? presetId;

  final Widget Function(BuildContext, ExportPreset) builder;

  @override
  State<_InnerPresetBuilder> createState() => __InnerPresetBuilderState();
}

class __InnerPresetBuilderState extends State<_InnerPresetBuilder> {
  late ExportPreset preset;

  @override
  void initState() {
    super.initState();
    _updatePreset();
   }

  void _updatePreset() {
    // Here we explicitly don't want updates, if the stored preset updates
    final savedPreset = widget.presetId == null
        ? null
        : context.read<ExportSettings>().getPresetById(widget.presetId!);

    if (savedPreset == null) {
      preset = CustomPreset([]);
    } else if (savedPreset.editable) {
      // Wrap in editor
      preset = CustomPreset.fromPreset(savedPreset);
    } else {
      preset = savedPreset;
    }

  }

  @override
  void didUpdateWidget(_InnerPresetBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.presetId == widget.presetId) return;
    _updatePreset();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, preset);
}
