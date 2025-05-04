import 'package:blood_pressure_app/data_util/consistent_future_builder.dart';
import 'package:blood_pressure_app/features/settings/tiles/titled_column.dart';
import 'package:blood_pressure_app/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
                          backgroundColor: switch(record.level.value) {
                            <= 500 => Colors.transparent,
                            <= 800 => Colors.grey.shade800,
                            <= 900 => Colors.deepOrange,
                            <= 1000 => Colors.red,
                            int() => Colors.red.shade900,
                          },
                          // TODO: color
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
