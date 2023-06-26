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
          child: FutureBuilder(
            future: Future.wait([PackageInfo.fromPlatform(), SharedPreferences.getInstance()]),
            builder: (context, snapshot) {
              final localizations = AppLocalizations.of(context);
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Text(AppLocalizations.of(context)!.loading);
                default:
                  if (snapshot.hasError) {
                    return Text(AppLocalizations.of(context)!.error(snapshot.error.toString()));
                  } else if (snapshot.hasData && snapshot.data != null) {
                    PackageInfo packageInfo = snapshot.data![0] as PackageInfo;
                    SharedPreferences sharedPrefs = snapshot.data![1] as SharedPreferences;
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(localizations!.packageNameOf(packageInfo.packageName)),
                          Text(localizations.versionOf(packageInfo!.version)),
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
                  }
              }
              return Text(localizations!.errNotStarted);

            },
          ),
        ),
      ),
    );
  }
}
