import 'package:blood_pressure_app/components/custom_banner.dart';
import 'package:blood_pressure_app/features/export_import/model/export_preset.dart';
import 'package:blood_pressure_app/features/export_import/model/import_field_type.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/storage/export_columns_store.dart';
import 'package:blood_pressure_app/model/storage/export_csv_settings.dart';
import 'package:blood_pressure_app/model/storage/export_settings.dart';
import 'package:blood_pressure_app/model/storage/types/export_format_setting.dart';
import 'package:flutter/material.dart';

/// Banner that gives the user information on the importability of their export.
class ExportWarnBanner extends StatefulWidget {
  /// Create either a banner that informs the user of import problems or an
  /// empty widget.
  ///
  /// Whether the config is importable is determined by the passed settings.
  const ExportWarnBanner({super.key,
    required this.exportSettings,
    required this.csvExportSettings,
    required this.availableColumns,});

  /// The [ExportSettings] validated for importability.
  final ExportSettings exportSettings;

  /// The [CsvExportSettings] validated for importability if applicable.
  final CsvExportSettings csvExportSettings;

  /// The columns used to validate importability in case custom export is
  /// enabled.
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
        return _buildNotImportable(context);
      case ExportFormat.csv:
        if (!widget.csvExportSettings.exportHeadline) return _buildNoHeadline(context);
        if (![',', '|'].contains(widget.csvExportSettings.fieldDelimiter)) {
          return _buildNotImportable(context);
        }
        if (!['"', "'"].contains(widget.csvExportSettings.textDelimiter)) {
          return _buildNotImportable(context);
        }
        final preset = widget.exportSettings
            .getPresetById(widget.csvExportSettings.activePreset);
        final exportedTypes = widget.availableColumns
            .resolveColumns(preset?.columns ?? [])
            .map((c) => c.restoreAbleType)
            .nonNulls;
        final expectedTypes = widget.availableColumns
            .resolveColumns(ExportPreset.appDefault.columns)
            .map((c) => c.restoreAbleType)
            .nonNulls
            .toSet();

        final missingTypes = [
          for (final t in expectedTypes)
            if (!exportedTypes.contains(t))
              t,
        ];
        if (missingTypes.isEmpty) {
          return _buildOK();
        } else {
          return _buildIncompleteExport(context, missingTypes);
        }
      case ExportFormat.xls:
        return _buildNotImportable(context);
    }
  }

  /// Exports made with this configuration are importable.
  Widget _buildOK() => const SizedBox.shrink();

  /// Exports made with this configuration are not importable for a variety of reasons.
  Widget _buildNotImportable(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return _banner(localizations.exportWarnConfigNotImportable, localizations);
  }

  /// Exports made with this configuration are not importable because there
  /// is no headline to infer types.
  Widget _buildNoHeadline(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return _banner(localizations.errNeedHeadline, localizations);
  }

  /// Exports made with this configuration are not fully importable.
  Widget _buildIncompleteExport(BuildContext context, Iterable<RowDataFieldType?> missingTypes) {
    final localizations = AppLocalizations.of(context)!;
    return _banner(localizations.exportWarnNotEveryFieldExported(
      missingTypes.length,
      missingTypes
          .nonNulls
          .map((e) => e.localize(localizations))
          .join(', '),
    ), localizations,);
  }

  Widget _banner(String text, AppLocalizations localizations) => CustomBanner(
      content: Text(text),
      action: TextButton(
        onPressed: () => setState(() {
          _hidden = true;
        }),
        child: Text(localizations.btnConfirm),
      ),
    );
}
