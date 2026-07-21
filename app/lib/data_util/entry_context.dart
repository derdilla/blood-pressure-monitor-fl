import 'package:blood_pressure_app/components/confirm_deletion_dialog.dart';
import 'package:blood_pressure_app/features/input/add_entry_dialog.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:blood_pressure_app/model/combined_entry.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:blood_pressure_app/screens/add_entry_screen.dart';
import 'package:blood_pressure_app/screens/error_reporting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide ProviderNotFoundException;
import 'package:health/health.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

/// Allow high level operations on the repositories in context.
extension EntryUtils on BuildContext {
  Logger get _logger => Logger('BPM[context.EntryUtils]');

  /// Open the [AddEntryDialog] and save received entries.
  ///
  /// Follows [ExportSettings.exportAfterEveryEntry]. When [initial] is not null
  /// the dialog will be opened in edit mode.
  Future<void> createEntry([CombinedEntry? initial]) async {
    _logger.finer('createEntry($initial)');
    try {
      await Navigator.of(this).push(MaterialPageRoute<Object?>(
        builder: (_) => AddEntryScreen(
          initialRecord: initial,
        )
      ));

    } on ProviderNotFoundException {
      log.severe('[extension.EntryUtils] createEntry($initial) was called from a context without Provider.');
    } catch (e, stack) {
      await ErrorReporting.reportCriticalError('Error opening add measurement dialog', '$e\n$stack',);
    }
  }

  /// Delete record and note of an entry from the repositories.
  Future<void> deleteEntry(CombinedEntry entry, [Health? health]) async {
    try {
      final localizations = AppLocalizations.of(this)!;
      final settings = Provider.of<Settings>(this, listen: false);
      final hcSettings = Provider.of<HealthConnectSettings>(this, listen: false);
      final bpRepo = RepositoryProvider.of<BloodPressureRepository>(this);
      final noteRepo = RepositoryProvider.of<NoteRepository>(this);
      final intakeRepo = RepositoryProvider.of<MedicineIntakeRepository>(this);
      final messenger = ScaffoldMessenger.of(this);

      bool confirmedDeletion = true;
      if (settings.confirmDeletion) {
        confirmedDeletion = await showConfirmDeletionDialog(this);
      }

      if (confirmedDeletion) {
        if (entry.record != null) await bpRepo.remove(entry.record!);
        if (entry.record != null) await noteRepo.remove(entry.note!);
        if (entry.intake != null) await intakeRepo.remove(entry.intake!);

        // Avoid automatically re-adding deleted measurements on app start
        if (hcSettings.useHealthConnect && hcSettings.syncPressureMeasurements){
          health ??= Health();
          if (entry.sys != null) {
            await health.delete(
              type: HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
              startTime: entry.time.subtract(Duration(milliseconds: 500)),
              endTime: entry.time.add(Duration(milliseconds: 500)),
            );
          }
          if (entry.dia != null) {
            await health.delete(
              type: HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
              startTime: entry.time.subtract(Duration(milliseconds: 500)),
              endTime: entry.time.add(Duration(milliseconds: 500)),
            );
          }
        }

        messenger.removeCurrentSnackBar();
        messenger.showSnackBar(SnackBar(
          content: Text(localizations.deletionConfirmed),
          action: SnackBarAction(
            label: localizations.btnUndo,
            onPressed: () async {
              if (entry.record != null) await bpRepo.add(entry.record!);
              if (entry.note != null) await noteRepo.add(entry.note!);
            },
          ),
        ),);
      }
    } on ProviderNotFoundException {
      log.severe('[extension.EntryUtils] deleteEntry($entry) was called from a context without Provider.');
    }
  }
}
