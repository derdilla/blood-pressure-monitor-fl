import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';

class ErrorReporting {
  static bool isErrorState = false;
  ErrorReporting._create();

  /// Replaces the application with an ErrorScreen
  /// This method can be used to avoid running any further code in your current function, by awaiting
  static Future<void> reportCriticalError(String title, String text) async {
    if (isErrorState) throw Exception('Tried to report another error:\n title = $title,\n text = $text');
    isErrorState = true;
    runApp(ErrorScreen(
      title: title,
      text: text,
      debugInfo: await _carefullyCollectDebugInfo(),
    ));
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

class ErrorScreen extends StatelessWidget {
  final String title;
  final String text;
  final PackageInfo debugInfo;
  
  const ErrorScreen({super.key, required this.title, required this.text, required this.debugInfo});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                        text: 'Error:\nBuild number:${debugInfo.buildNumber}\n-----\n$title:\n---\n$text\n'
                      ));
                      scaffoldMessenger.showSnackBar(const SnackBar(
                          content: Text('Copied to clipboard')));
                    },
                    child: const Text('copy error message')
                  ),
                  TextButton(
                      onPressed: () async {
                        try {
                          final url = Uri.parse('https://github.com/NobodyForNothing/blood-pressure-monitor-fl/issues');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url, mode: LaunchMode.externalApplication);
                          } else {
                            scaffoldMessenger.showSnackBar(const SnackBar(
                              content: Text('ERR: Please open this website: https://github.com/NobodyForNothing/blood-pressure-monitor-fl/issues')));
                          }
                        } catch (e) {
                          scaffoldMessenger.showSnackBar(SnackBar(
                              content: Text('ERR: ${e.toString()}')));
                        }
                      },
                      child: const Text('open issue reporting website')
                  ),
                  TextButton(
                      onPressed: () async {
                        try {
                          String dbPath = await getDatabasesPath();

                          assert(dbPath != inMemoryDatabasePath);
                          dbPath = join(dbPath, 'blood_pressure.db');
                          assert(Platform.isAndroid);
                          Share.shareXFiles([
                            XFile(dbPath,)
                          ]);
                        } catch(e) {
                          scaffoldMessenger.showSnackBar(SnackBar(
                              content: Text('ERR: ${e.toString()}')));
                        }
                      },
                      child: const Text('rescue measurements')
                  ),
                  TextButton(
                      onPressed: () async {
                        try {
                          String dbPath = await getDatabasesPath();

                          assert(dbPath != inMemoryDatabasePath);
                          dbPath = join(dbPath, 'config.db');
                          assert(Platform.isAndroid);
                          Share.shareXFiles([
                            XFile(dbPath,)
                          ]);
                        } catch(e) {
                          scaffoldMessenger.showSnackBar(SnackBar(
                              content: Text('ERR: ${e.toString()}')));
                        }
                      },
                      child: const Text('rescue config.db')
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
  
}