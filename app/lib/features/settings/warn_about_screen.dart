import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/blood_pressure/warn_values.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutWarnValuesScreen extends StatelessWidget {
  const AboutWarnValuesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.warnValues),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(90.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.warnAboutTxt1),
              const SizedBox(
                height: 5,
              ),
              InkWell(
                onTap: () async {
                  final url = Uri.parse(BloodPressureWarnValues.source);
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(AppLocalizations.of(context)!
                            .errCantOpenURL(BloodPressureWarnValues.source),),),);
                  }
                },
                child: SizedBox(
                  height: 48,
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.warnAboutTxt2,
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(AppLocalizations.of(context)!.warnAboutTxt3),
            ],
          ),
        ),
      ),
    );
}
