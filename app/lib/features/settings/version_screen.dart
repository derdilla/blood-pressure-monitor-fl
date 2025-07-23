import 'dart:io';

import 'package:blood_pressure_app/data_util/consistent_future_builder.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:blood_pressure_app/screens/error_reporting_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Screen that shows app version and debug options.
class VersionScreen extends StatefulWidget {
  /// Screen that shows app version and debug options.
  const VersionScreen({super.key});

  @override
  State<VersionScreen> createState() => _VersionScreenState();
}

class _VersionScreenState extends State<VersionScreen> with TypeLogger {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.version),
        actions: [
          IconButton(
            onPressed: () async {
              final packageInfo = await PackageInfo.fromPlatform();
              await Clipboard.setData(ClipboardData(
                  text: 'Blood pressure monitor\n'
                      '${packageInfo.packageName}\n'
                      '${packageInfo.version} - ${packageInfo.buildNumber}',
              ),);
            },
            tooltip: localizations.export,
            icon: const Icon(Icons.copy),
          ),
        ],
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView(
          children: [
            // Debug info
            ConsistentFutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              onData: (context, packageInfo) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(localizations.packageNameOf(packageInfo.packageName)),
                    Text(localizations.versionOf(packageInfo.version)),
                    Text(localizations.buildNumberOf(packageInfo.buildNumber)),
                  ],
                ),
            ),
            // Logs
            SwitchListTile(
              // Would not be used by regular users so no need to translate
              title: Text('Enable ultra-verbose logging until app restart'),
              subtitle: Text('This can help to track down hard to reproduce bugs'),
              value: Log.isVerbose,
              onChanged: (v) =>  setState(() => Log.setVerbose(v)),
            ),
            FutureBuilder(future: Future(() async {
              final dbPath = await getDatabasesPath();
              return join(dbPath, 'blood_pressure.db');
            }), builder: (context, snapshot) {
              if (snapshot.data == null || !File(snapshot.data!).existsSync()) {
                return SizedBox.shrink();
              }
              return ListTile(
                onTap: () async {
                  try {
                    await FilePicker.platform.saveFile(
                      fileName: 'blood_pressure.db',
                      bytes: File(snapshot.data!).readAsBytesSync(),
                      type: FileType.any, // application/vnd.sqlite3
                    );
                  } catch(e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('ERR: $e'),),);
                  }
                },
                title: const Text('rescue legacy db'),
              );
            }),
            ListTile(
              title: Text('Logs:'),
              trailing: Icon(Icons.copy),
              onTap: () async {
                await Clipboard.setData(ClipboardData(
                  text: Log.logs
                    .map((e) => '${e.level.name} - ${e.time.toIso8601String()}||'
                      '${e.loggerName}||"${e.message}"||{${e.stackTrace}}\n')
                    .fold('', (res, e) => res + e),
                ));
                if(context.mounted){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Logs copied to clipboard'),
                  ));
                }
              },
            ),
            SizedBox(
               height: 600,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: Log.logs.length,
                itemBuilder: (context, idx) {
                  final record = Log.logs[Log.logs.length - idx - 1];
                  return ExpansionTile(
                    title: Wrap(
                      spacing: 4.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          // FIXME: doesn't work in light mode
                          backgroundColor: switch(record.level.value) {
                            <= 500 => Colors.transparent,
                            <= 800 => Colors.grey.shade800,
                            <= 900 => Colors.deepOrange,
                            <= 1000 => Colors.red,
                            int() => Colors.red.shade900,
                          },
                          label: Text(record.level.name),
                        ),
                        Text(record.loggerName),
                      ],
                    ),
                    subtitle: Text('Timestamp: ${record.time.hour}:${record.time.minute}.${record.time.second}'),
                    children: [
                      Text(record.message),
                      if (record.stackTrace != null)
                        Text(record.stackTrace.toString()),
                    ],
                  );
                },
              ),
            ),
            ListTile(
              title: Text('Test log messages'),
              trailing: Icon(Icons.chevron_right),
              onTap: () {
                logger.finest('test finest');
                logger.finer('test finer');
                logger.fine('test fine');
                logger.info('test info');
                logger.warning('test warning');
                logger.severe('test severe');
                logger.shout('test shout');
              },
            )
          ],
        ),
      ),
    );
  }
}
