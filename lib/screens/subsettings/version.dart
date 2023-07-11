import 'package:blood_pressure_app/components/consistent_future_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VersionScreen extends StatelessWidget {

  const VersionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.version),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(40.0),
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
                    for (final key in sharedPrefs.getKeys())
                      Row(
                        children: [
                          Text('$key:'),
                          const Spacer(),
                          Text(sharedPrefs.get(key).toString()),
                        ],
                      )
                  ]
              );
            },
          ),
        ),
      ),
    );
  }
}
