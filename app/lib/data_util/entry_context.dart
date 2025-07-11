import 'package:blood_pressure_app/components/confirm_deletion_dialoge.dart';
import 'package:blood_pressure_app/features/input/add_entry_dialogue.dart';
import 'package:blood_pressure_app/features/input/forms/add_entry_form.dart';
import 'package:blood_pressure_app/features/export_import/export_button.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:blood_pressure_app/model/storage/storage.dart';
import 'package:blood_pressure_app/screens/error_reporting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide ProviderNotFoundException;
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:health_data_store/health_data_store.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

/// Allow high level operations on the repositories in context.
extension EntryUtils on BuildContext {
  Logger get _logger => Logger('BPM[context.EntryUtils]');

  /// Open the [AddEntryDialogue] and save received entries.
  ///
  /// Follows [ExportSettings.exportAfterEveryEntry]. When [initial] is not null
  /// the dialoge will be opened in edit mode.
  Future<void> createEntry([AddEntryFormValue? initial]) async {
    _logger.finer('createEntry($initial)');
    try {
      final recordRepo = RepositoryProvider.of<BloodPressureRepository>(this);
      final noteRepo = RepositoryProvider.of<NoteRepository>(this);
      final intakeRepo = RepositoryProvider.of<MedicineIntakeRepository>(this);
      final weightRepo = RepositoryProvider.of<BodyweightRepository>(this);
      final exportSettings = Provider.of<ExportSettings>(this, listen: false);

      final entry = await showAddEntryDialogue(this,
        RepositoryProvider.of<MedicineRepository>(this),
        initial,
      );
      _logger.finest('received $entry from dialog');
      if (entry != null) {
        if (initial?.record != null) await recordRepo.remove(initial!.record!);
        if (initial?.note != null) await noteRepo.remove(initial!.note!);
        if (initial?.intake != null) await intakeRepo.remove(initial!.intake!);
        if (initial?.weight != null) await weightRepo.remove(initial!.weight!);

        if (entry.record != null) await recordRepo.add(entry.record!);
        if (entry.note != null) await noteRepo.add(entry.note!);
        if (entry.intake != null) await intakeRepo.add(entry.intake!);
        if(entry.weight != null) await weightRepo.add(entry.weight!);

        /*
        read<IntervalStoreManager>().mainPage.setToMostRecentInterval();
        read<IntervalStoreManager>().statsPage.setToMostRecentInterval();
        read<IntervalStoreManager>().exportPage.setToMostRecentInterval();*/

        _logger.finest('mounted=$mounted');
        if (!mounted) {
          _logger.warning('Context no longer mounted');
          return;
        }

        log.info(read<IntervalStoreManager>());
        if (mounted && exportSettings.exportAfterEveryEntry) {
          performExport(this, false);
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
