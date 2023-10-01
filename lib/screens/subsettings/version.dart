import 'package:blood_pressure_app/components/consistent_future_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VersionScreen extends StatelessWidget {

  const VersionScreen({super.key});

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
              final prefs = await SharedPreferences.getInstance();
              var prefsText = '';
              for (final key in prefs.getKeys()) {
                prefsText += '$key:\t${prefs.get(key).toString()}\n';
              }
              Clipboard.setData(ClipboardData(
                  text: 'Blood pressure monitor\nBuild number:${packageInfo.buildNumber}\n$prefsText'
              ));
            },
            tooltip: localizations.export,
            icon: const Icon(Icons.copy),
          )
        ],
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: ConsistentFutureBuilder<List<Object>>(
              future: Future.wait([PackageInfo.fromPlatform(), SharedPreferences.getInstance()]),
              onData: (context, data) {
                final localizations = AppLocalizations.of(context);
                PackageInfo packageInfo = data[0] as PackageInfo;
                SharedPreferences sharedPrefs = data[1] as SharedPreferences;

                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(localizations!.packageNameOf(packageInfo.packageName)),
                      Text(localizations.versionOf(packageInfo.version)),
                      Text(localizations.buildNumberOf(packageInfo.buildNumber)),
                      Text(localizations.buildSignatureOf(packageInfo.buildSignature)),
                      const SizedBox(height: 30,),
                      Text(localizations.sharedPrefsDump),
                      Table(
                        children: [
                          for (final key in sharedPrefs.getKeys())
                            TableRow(children: [
                              Text(key),
                              Text(sharedPrefs.get(key).toString())
                            ]),
                        ],
                      )
                    ]
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
