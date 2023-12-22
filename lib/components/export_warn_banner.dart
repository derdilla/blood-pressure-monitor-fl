import 'package:blood_pressure_app/model/export_import/column.dart';
import 'package:blood_pressure_app/model/export_import/export_configuration.dart';
import 'package:blood_pressure_app/model/export_import/import_field_type.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings_store.dart';
import 'package:blood_pressure_app/model/storage/export_settings_store.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Banner that gives the user information on the importability of their export.
class ExportWarnBanner extends StatefulWidget {
  /// Create either a banner that informs the user of import problems or an empty widget.
  ///
  /// Whether the config is importable is determined by the passed settings.
  const ExportWarnBanner({super.key,
    required this.exportSettings,
    required this.csvExportSettings,
    required this.availableColumns});
  // TODO: consider attempting to import a file with that config and checking success.
  // This would allow for more detailed error messages as well.

  final ExportSettings exportSettings;
  final CsvExportSettings csvExportSettings;
  final ExportColumnsManager availableColumns;

  @override
  State<ExportWarnBanner> createState() => _ExportWarnBannerState();
}

class _ExportWarnBannerState extends State<ExportWarnBanner> {
  /// Whether the banner was hidden by pressing a button.
  bool _hidden = false;

  @override
  Widget build(BuildContext context) {
    if (_hidden) return _buildOK();

    switch (widget.exportSettings.exportFormat) {
      case ExportFormat.db:
        return _buildOK();
      case ExportFormat.pdf:
        return _buildNotExportable(context);
      case ExportFormat.csv:
        if (widget.csvExportSettings.exportHeadline == false) return _buildNoHeadline(context);
        if (widget.csvExportSettings.fieldDelimiter != ',' && widget.csvExportSettings.fieldDelimiter != '|') return _buildNotExportable(context);
        if (widget.csvExportSettings.textDelimiter != '"' && widget.csvExportSettings.textDelimiter != "'") return _buildNotExportable(context);
        final preset = widget.csvExportSettings.exportFieldsConfiguration.activePreset;
        switch (preset) {
          case ExportImportPreset.bloodPressureApp:
            return _buildOK();
          case ExportImportPreset.myHeart:
            return _buildNotExportable(context);
          case ExportImportPreset.none:
            final exportedColumns = widget.csvExportSettings.exportFieldsConfiguration
                .getActiveColumns(widget.availableColumns);
            final exportedTypes = exportedColumns
                .map((column) => column.restoreAbleType);

            if (!exportedTypes.contains(RowDataFieldType.timestamp)) return _buildNotExportable(context);

            if (exportedColumns.firstWhereOrNull((e) => (e is TimeColumn)) != null) return _buildAccuracyLoss(context);

            final neededForFullExport = ActiveExportColumnConfiguration()
                .getActiveColumns(widget.availableColumns)
                .map((column) => column.restoreAbleType);
            final missingTypes = neededForFullExport
                .where((column) => !exportedTypes.contains(column));
            if (missingTypes.isEmpty) return _buildOK();

            return _buildIncompleteExport(context, missingTypes);
        }
    }
  }

  /// Exports made with this configuration are importable.
  Widget _buildOK() => const SizedBox.shrink();

  /// Exports made with this configuration are not importable for a variety of reasons.
  Widget _buildNotExportable(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return _banner(localizations.exportWarnConfigNotImportable, localizations);
  }

  /// Exports made with this configuration are not importable because there
  /// is no headline to infer types.
  Widget _buildNoHeadline(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return _banner(localizations.errNeedHeadline, localizations);
  }

  /// The exported time looses accuracy.
  Widget _buildAccuracyLoss(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return _banner(localizations.errAccuracyLoss, localizations);
  }

  /// Exports made with this configuration are not fully importable.
  Widget _buildIncompleteExport(BuildContext context, Iterable<RowDataFieldType?> missingTypes) {
    final localizations = AppLocalizations.of(context)!;
    return _banner(localizations.exportWarnNotEveryFieldExported(
      missingTypes.length,
      missingTypes
          .whereNotNull()
          .map((e) => e.localize(localizations))
          .join(', ')
    ), localizations);
  }

  Widget _banner(String text, AppLocalizations localizations) {
    return MaterialBanner(
        padding: const EdgeInsets.all(20),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _hidden = true;
              });
            },
            child: Text(localizations.btnConfirm)
          )
        ]
      );
  }
}