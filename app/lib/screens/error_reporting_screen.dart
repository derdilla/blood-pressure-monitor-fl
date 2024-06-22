import 'package:blood_pressure_app/platform_integration/platform_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';

/// A static location to report errors to and disrupt the program flow in case
/// there is the risk of data loss when continuing.
class ErrorReporting {
  ErrorReporting._create();

  /// Whether there is already an critical error displayed.
  static bool isErrorState = false;

  /// Replaces the application with an ErrorScreen.
  ///
  /// This method can be used to avoid running any further code in your current function, by awaiting
  static Future<void> reportCriticalError(String title, String text) async {
    if (isErrorState) throw Exception('Tried to report another error:\n title = $title,\n text = $text');
    isErrorState = true;
    runApp(ErrorScreen(
      title: title,
      text: text,
      debugInfo: await _carefullyCollectDebugInfo(),
    ),);
    return Future.delayed(const Duration(days: 30,));
  }

  static Future<PackageInfo> _carefullyCollectDebugInfo() async {
    PackageInfo packageInfo;
    try {
      packageInfo = await PackageInfo.fromPlatform();
    } catch (e) {
      packageInfo = PackageInfo(appName: 'err', packageName: 'err', version: 'err', buildNumber: 'err');
    }

    return packageInfo;
  }
}

/// A full [MaterialApp] that is especially safe against throwing errors and
/// allows for debugging and data extraction.
class ErrorScreen extends StatelessWidget {
  
  const ErrorScreen({super.key, required this.title, required this.text, required this.debugInfo});

  final String title;
  final String text;
  final PackageInfo debugInfo;

  @override
  Widget build(BuildContext context) => MaterialApp(
      title: 'Critical error',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Critical error'),
          backgroundColor: Colors.red,
        ),
        body: Builder(
          builder: (context) {
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20,),
                  Text('App version: ${debugInfo.version}'),
                  Text('Build number: ${debugInfo.buildNumber}'),
                  const Divider(),
                  Text(title, style: const TextStyle(fontSize: 20, ), ),
                  Text(text),
                  const Divider(),
                  TextButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                        text: 'Error:\nBuild number:${debugInfo.buildNumber}\n-----\n$title:\n---\n$text\n',
                      ),);
                      scaffoldMessenger.showSnackBar(const SnackBar(
                          content: Text('Copied to clipboard'),),);
                    },
                    child: const Text('copy error message'),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        final url = Uri.parse('https://github.com/NobodyForNothing/blood-pressure-monitor-fl/issues');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          scaffoldMessenger.showSnackBar(const SnackBar(
                            content: Text('ERR: Please open this website: https://github.com/NobodyForNothing/blood-pressure-monitor-fl/issues'),),);
                        }
                      } catch (e) {
                        scaffoldMessenger.showSnackBar(SnackBar(
                            content: Text('ERR: $e'),),);
                      }
                    },
                    child: const Text('open issue reporting website'),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        String dbPath = await getDatabasesPath();

                        assert(dbPath != inMemoryDatabasePath);
                        dbPath = join(dbPath, 'blood_pressure.db');
                        await PlatformClient.shareFile(dbPath, 'application/vnd.sqlite3');
                      } catch(e) {
                        scaffoldMessenger.showSnackBar(SnackBar(
                            content: Text('ERR: $e'),),);
                      }
                    },
                    child: const Text('rescue old measurements'),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        String dbPath = await getDatabasesPath();

                        assert(dbPath != inMemoryDatabasePath);
                        dbPath = join(dbPath, 'config.db');
                        await PlatformClient.shareFile(dbPath, 'application/vnd.sqlite3');
                      } catch(e) {
                        scaffoldMessenger.showSnackBar(SnackBar(
                            content: Text('ERR: $e'),),);
                      }
                    },
                    child: const Text('rescue config.db'),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        String dbPath = await getDatabasesPath();

                        assert(dbPath != inMemoryDatabasePath);
                        dbPath = join(dbPath, 'medicine.intakes');
                        await PlatformClient.shareFile(dbPath, 'application/octet-stream');
                      } catch(e) {
                        scaffoldMessenger.showSnackBar(SnackBar(
                          content: Text('ERR: $e'),),);
                      }
                    },
                    child: const Text('rescue old medicine intakes'),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        String dbPath = await getDatabasesPath();

                        assert(dbPath != inMemoryDatabasePath);
                        dbPath = join(dbPath, 'bp.db');
                        await PlatformClient.shareFile(dbPath, 'application/vnd.sqlite3');
                      } catch(e) {
                        scaffoldMessenger.showSnackBar(SnackBar(
                          content: Text('ERR: $e'),),);
                      }
                    },
                    child: const Text('rescue new db'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  
}
