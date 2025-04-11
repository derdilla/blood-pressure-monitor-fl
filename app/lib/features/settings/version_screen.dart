import 'package:blood_pressure_app/data_util/consistent_future_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
              Clipboard.setData(ClipboardData(
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
      body: Container(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: ConsistentFutureBuilder<PackageInfo>(
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
        ),
      ),
    );
  }
}
