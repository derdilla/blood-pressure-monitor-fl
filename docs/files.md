# App files

The app stores persistent data in the app storage. This document aims to provide an overview of the purpose and structure of the files stored.

## Current files

The `dbPath`/`config.db` file is a SQLite3 database containing Settings and some other configuration data such as the current display ranges and added medications. The database contains tables for logically different parts of the config, which all contain one line with the config in json format and an userid (which currently serves no purpose). The intervall table contains multiple entries.

In the `dbPath`/`blood_pressure.db` SQLite3 database you find one `bloodPressureModel` table containing entries with the blood pressure records including a json representation of the color in the ("needlePin") column.

The `await getDatabasesPath()`/`medicine.intakes` File consists of a plain text csv like representation of medicine intakes. The format of this file was rather experimental and gets replaced as part of [#257](https://github.com/NobodyForNothing/blood-pressure-monitor-fl/issues/257). For an exact description look at the `deserialize` factory method of the `IntakeHistory` class, but in general every line (including the first) contains a medicine intake with fields seperated by `\x00`. The first field is the medicine id, the second is the time the medicine was taken in milliseconds since epoch and the third is the dosis of the medicine.

## Exported files

Exporting the records as a SqliteDB will export a copy of the `blood_pressure.db` file described above. Similarly, the settings export will yield the `config.db` file as present in storage.

When exporting the data as CSV, the file will use standard platform newlines (`\r\n`) unless not configured differently a headline with the names of all exported columns delimited by the `,` character. Unlike the config suggests note strings are not always wrapped in `'` characters. Fields without any value are either empty or contain a lowercase `null`.

## Legacy data

Until [#189](https://github.com/NobodyForNothing/blood-pressure-monitor-fl/pull/189) and [#195](https://github.com/NobodyForNothing/blood-pressure-monitor-fl/pull/195) ([v1.5.5](https://github.com/NobodyForNothing/blood-pressure-monitor-fl/tree/v1.5.5)) settings were stored in androids shared preferences storage. It consisted of a lot of individual keys and update code can be found in the [update_legacy_settings.dart](https://github.com/NobodyForNothing/blood-pressure-monitor-fl/blob/main/app/lib/model/storage/update_legacy_settings.dart) file. Support will be dropped in october 2024 (a year after migration started).