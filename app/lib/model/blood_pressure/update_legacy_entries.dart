import 'dart:io';

import 'package:blood_pressure_app/model/blood_pressure/model.dart';
import 'package:blood_pressure_app/model/blood_pressure/record.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:health_data_store/health_data_store.dart' as hds;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../screens/error_reporting_screen.dart';
import 'medicine/intake_history.dart';
import 'medicine/medicine.dart';

/// Loads data from old storage locations, adds them to new repos and deletes old storage location on success.
@Deprecated('Only use to migrate legacy data')
Future<void> updateLegacyEntries(
  Settings settings,
  hds.BloodPressureRepository bpRepo,
  hds.NoteRepository noteRepo,
  hds.MedicineRepository medRepo,
  hds.MedicineIntakeRepository intakeRepo,
) async { // TODO: test
  // Migrate old meds still in use and old intakes
  try {
    if (settings.medications.isNotEmpty) {
      final intakeString = File(join(await getDatabasesPath(), 'medicine.intakes')).readAsStringSync();
      final intakeHistory = IntakeHistory.deserialize(intakeString, settings.medications);
      final addedMeds = <Medicine, hds.Medicine>{};
      for (final i in intakeHistory.getIntakes(DateTimeRange(
        start: DateTime.fromMillisecondsSinceEpoch(0),
        end: DateTime.now(),
      ))) {
        hds.Medicine? med = addedMeds[i.medicine];
        if (med == null) {
          med = hds.Medicine(
            designation: i.medicine.designation,
            color: i.medicine.color.value,
            dosis: i.medicine.defaultDosis == null ? null : hds.Weight.mg(i.medicine.defaultDosis!),
          );
          addedMeds[i.medicine] = med;
          await medRepo.add(med);
        }
        final newI = hds.MedicineIntake(
          time: i.timestamp,
          medicine: med,
          dosis: hds.Weight.mg(i.dosis),
        );
        await intakeRepo.add(newI);
      }
    }

    File(join(await getDatabasesPath(), 'medicine.intakes')).deleteSync();
  } on PathNotFoundException {
    // pass
  } catch (e, stack) {
    await ErrorReporting.reportCriticalError('Error while migrating intakes to '
      'new format', '$e\n$stack',);
  }

  // Migrating records and notes
  try {
    final oldBpModel = await BloodPressureModel.create();
    for (final BloodPressureRecord r in await oldBpModel?.all ?? []) {
      if (r.diastolic != null || r.systolic != null || r.pulse != null) {
        await bpRepo.add(hds.BloodPressureRecord(
          time: r.creationTime,
          sys: r.systolic == null ? null : hds.Pressure.mmHg(r.systolic!),
          dia: r.diastolic == null ? null : hds.Pressure.mmHg(r.diastolic!),
          pul: r.pulse,
        ));
      }
      if (r.notes.isNotEmpty || r.needlePin != null) {
        await noteRepo.add(hds.Note(
          time: r.creationTime,
          note: r.notes.isEmpty ? null : r.notes,
          color: r.needlePin?.color.value,
        ));
      }
    }
    await oldBpModel?.close();
    File(join(await getDatabasesPath(), 'blood_pressure.db')).deleteSync();
  } on PathNotFoundException {
    // pass
  } catch (e, stack)  {
    await ErrorReporting.reportCriticalError('Error while migrating records to '
      'new format', '$e\n$stack',);
  }
}
