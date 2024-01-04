import 'dart:io';
import 'dart:math';

import 'package:blood_pressure_app/components/CustomBanner.dart';
import 'package:blood_pressure_app/components/consistent_future_builder.dart';
import 'package:blood_pressure_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path/path.dart';
import 'package:restart_app/restart_app.dart';
import 'package:sqflite/sqflite.dart';

class DeleteDataScreen extends StatefulWidget {
  const DeleteDataScreen({super.key});

  @override
  State<DeleteDataScreen> createState() => _DeleteDataScreenState();
}

class _DeleteDataScreenState extends State<DeleteDataScreen> {
  /// Whether or not files were deleted while on this page.
  ///
  /// Should never be reset to false.
  bool _deletedData = false;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete data'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_deletedData) {
              Restart.restartApp();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          if (_deletedData)
            CustomBanner(
                content: Text(localizations.warnNeedsRestartForUsingApp),
                action: TextButton(
                  onPressed: () => Restart.restartApp(),
                  child: Text(localizations.restartNow),
                )
            ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(localizations.data, style: Theme.of(context).textTheme.headlineMedium),
                  Expanded(
                    flex: 1,
                    child: ListView(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.timeline),
                          title: Text(localizations.deleteAllMeasurements),
                          subtitle: ConsistentFutureBuilder(
                            future: Future(() async {
                              final String dbPath = join(await getDatabasesPath(), 'blood_pressure.db');
                              final String dbJournalPath = join(await getDatabasesPath(), 'blood_pressure.db-journal');
                              int sizeBytes;
                              try {
                                sizeBytes = File(dbPath).lengthSync();
                              } on PathNotFoundException {
                                sizeBytes = 0;
                              }
                              try {
                                sizeBytes += File(dbJournalPath).lengthSync();
                              } on PathNotFoundException {}

                              return _bytesToString(sizeBytes);
                            }),
                            onData: (context, data) {
                              return Text(data.toString());
                            },
                          ),
                          trailing: const Icon(Icons.delete_forever),
                          onTap: () async {
                            final messanger = ScaffoldMessenger.of(context);
                            if (await showDeleteDialoge(context, localizations)) {
                            final String dbPath = join(await getDatabasesPath(), 'blood_pressure.db');
                            final String dbJournalPath = join(await getDatabasesPath(), 'blood_pressure.db-journal');
                            await closeDatabases();
                            tryDeleteFile(dbPath, messanger, localizations);
                            tryDeleteFile(dbJournalPath, messanger, localizations);
                            setState(() {
                            _deletedData = true;
                            });
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.settings),
                          title: Text(localizations.deleteAllSettings),
                          subtitle: ConsistentFutureBuilder(
                            future: Future(() async {
                              final String dbPath = join(await getDatabasesPath(), 'config.db');
                              final String dbJournalPath = join(await getDatabasesPath(), 'config.db-journal');
                              int sizeBytes;
                              try {
                                sizeBytes = File(dbPath).lengthSync();
                              } on PathNotFoundException {
                                sizeBytes = 0;
                              }
                              try {
                                sizeBytes += File(dbJournalPath).lengthSync();
                              } on PathNotFoundException {}
                              return _bytesToString(sizeBytes);
                            }),
                            onData: (context, data) {
                              return Text(data.toString());
                            },
                          ),
                          trailing: const Icon(Icons.delete_forever),
                          onTap: () async {
                            final messanger = ScaffoldMessenger.of(context);
                            if (await showDeleteDialoge(context, localizations)) {
                              final String dbPath = join(await getDatabasesPath(), 'config.db');
                              final String dbJournalPath = join(await getDatabasesPath(), 'config.db-journal');
                              await closeDatabases();
                              tryDeleteFile(dbPath, messanger, localizations);
                              tryDeleteFile(dbJournalPath, messanger, localizations);
                              setState(() {
                                _deletedData = true;
                              });
                            }
                          },
                        )
                      ],
                    ),
                  ),
                  /* Text('Files', style: Theme.of(context).textTheme.headlineMedium),
                  Expanded(
                    flex: 3,
                    child: ConsistentFutureBuilder(
                      future: Future(() async => Directory(await getDatabasesPath()).list(recursive: true).toList()),
                      onData: (context, files) =>
                        ListView.builder(
                          itemCount: files.length,
                          itemBuilder: (context, idx) => ListTile(
                            title: Text(files[idx].path),
                            trailing: const Icon(Icons.delete_forever),
                            onTap: () async {
                              final messanger = ScaffoldMessenger.of(context);
                              if (await showDeleteDialoge(context, localizations)) {
                                if (!context.mounted) return;
                                await unregisterAllProviders(context);
                                files[idx].deleteSync();
                                messanger.showSnackBar(SnackBar(
                                  duration: const Duration(seconds: 5),
                                  content: Text('File deleted.'),
                                ));
                                setState(() {
                                  _deletedData = true;
                                });
                              }
                            },
                          )
                        )
                    ),
                  ), */
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Converts file size in bytes to human readable string
  String _bytesToString(int sizeBytes) {
    if (sizeBytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(sizeBytes) / log(1024)).floor();
    return '${(sizeBytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  Future<bool> showDeleteDialoge(BuildContext context, AppLocalizations localizations) async {
    return await showDialog<bool>(context: context, builder: (context) =>
        AlertDialog(
          title: Text(localizations.confirmDelete),
          content: Text(localizations.warnDeletionUnrecoverable),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(AppLocalizations.of(context)!.btnCancel)),
            Theme(
              data: ThemeData.from(
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.red, brightness: Theme.of(context).brightness),
                  useMaterial3: true
              ),
              child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(true),
                  icon: const Icon(Icons.delete_forever),
                  label: Text(AppLocalizations.of(context)!.btnConfirm)
              ),
            )

          ],
        )
    ) ?? false;
  }
  
  void tryDeleteFile(String path, ScaffoldMessengerState messanger, AppLocalizations localizations) {
    try {
      File(path).deleteSync();
      messanger.showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(localizations.fileDeleted),
      ));
    } on PathNotFoundException {
      messanger.showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(localizations.fileAlreadyDeleted),
      ));
    }
  }
}