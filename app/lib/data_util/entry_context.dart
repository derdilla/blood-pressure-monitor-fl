import 'package:blood_pressure_app/components/confirm_deletion_dialoge.dart';
import 'package:blood_pressure_app/features/export_import/export_button_bar.dart';
import 'package:blood_pressure_app/features/input/add_measurement_dialoge.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:blood_pressure_app/screens/error_reporting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide ProviderNotFoundException;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:provider/provider.dart';

/// Allow high level operations on the repositories in context.
extension EntryUtils on BuildContext {
  /// Open the [AddEntryDialoge] and save received entries.
  ///
  /// Follows [ExportSettings.exportAfterEveryEntry]. When [initial] is not null
  /// the dialoge will be opened in edit mode.
  Future<void> createEntry([FullEntry? initial]) async {
    try {
      final recordRepo = RepositoryProvider.of<BloodPressureRepository>(this);
      final noteRepo = RepositoryProvider.of<NoteRepository>(this);
      final intakeRepo = RepositoryProvider.of<MedicineIntakeRepository>(this);
      final exportSettings = Provider.of<ExportSettings>(this, listen: false);

      final entry = await showAddEntryDialoge(this,
        RepositoryProvider.of<MedicineRepository>(this),
        initial,
      );
      if (entry != null) {
        if (initial != null) {
          if ((initial.sys != null || initial.dia != null || initial.pul != null)) {
            await recordRepo.remove(initial.$1);
          }
          if ((initial.note != null || initial.color != null)) {
            await noteRepo.remove(initial.$2);
          }
          for (final intake in initial.$3) {
            await intakeRepo.remove(intake);
          }
        }

        if (entry.sys != null || entry.dia != null || entry.pul != null) {
          await recordRepo.add(entry.$1);
        }
        if (entry.note != null || entry.color != null) {
          await noteRepo.add(entry.$2);
        }
        for (final intake in entry.$3) {
          await intakeRepo.add(intake);
        }
        if (mounted && exportSettings.exportAfterEveryEntry) {
          read<IntervalStoreManager>().exportPage.setToMostRecentInterval();
          performExport(this, AppLocalizations.of(this)!);
        }
      }
    } on ProviderNotFoundException {
      log.severe('[extension.EntryUtils] createEntry($initial) was called from a context without Provider.');
    } catch (e, stack) {
      await ErrorReporting.reportCriticalError('Error opening add measurement dialoge', '$e\n$stack',);
    }
  }

  /// Delete record and note of an entry from the repositories.
  Future<void> deleteEntry(FullEntry entry) async {
    try {
      final localizations = AppLocalizations.of(this)!;
      final settings = Provider.of<Settings>(this, listen: false);
      final bpRepo = RepositoryProvider.of<BloodPressureRepository>(this);
      final noteRepo = RepositoryProvider.of<NoteRepository>(this);
      final intakeRepo = RepositoryProvider.of<MedicineIntakeRepository>(this);
      final messenger = ScaffoldMessenger.of(this);

      bool confirmedDeletion = true;
      if (settings.confirmDeletion) {
        confirmedDeletion = await showConfirmDeletionDialoge(this);
      }

      if (confirmedDeletion) {
        await bpRepo.remove(entry.$1);
        await noteRepo.remove(entry.$2);
        await Future.forEach(entry.$3, intakeRepo.remove);
        messenger.removeCurrentSnackBar();
        messenger.showSnackBar(SnackBar(
          content: Text(localizations.deletionConfirmed),
          action: SnackBarAction(
            label: localizations.btnUndo,
            onPressed: () async {
              await bpRepo.add(entry.$1);
              await noteRepo.add(entry.$2);
            },
          ),
        ),);
      }
    } on ProviderNotFoundException {
      log.severe('[extension.EntryUtils] deleteEntry($entry) was called from a context without Provider.');
    }
  }
}
