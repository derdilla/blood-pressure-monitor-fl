import 'package:blood_pressure_app/components/custom_banner.dart';
import 'package:blood_pressure_app/components/input_dialoge.dart';
import 'package:blood_pressure_app/features/settings/tiles/number_input_list_tile.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:blood_pressure_app/model/blood_pressure/warn_values.dart';
import 'package:blood_pressure_app/model/storage/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen containing warn value related information and settings.
class ConfigureWarnValuesScreen extends StatelessWidget {
  /// Create screen containing warn value related information and settings.
  const ConfigureWarnValuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<Settings>();
    return Scaffold(
      appBar: AppBar(forceMaterialTransparency: true),
      floatingActionButton: FloatingActionButton.extended(
        label: Text(AppLocalizations.of(context)!.determineWarnValues),
        onPressed:() async {
          final age = (await showNumberInputDialoge(context,
            hintText: AppLocalizations.of(context)!.age,
          ))?.round();
          if (age != null) {
            settings.sysWarn = BloodPressureWarnValues.getUpperSysWarnValue(age);
            settings.diaWarn = BloodPressureWarnValues.getUpperDiaWarnValue(age);
          }
        },
      ),
      body: ListView(
        //mainAxisAlignment: MainAxisAlignment.start,
        //crossAxisAlignment: CrossAxisAlignment.start,
        //crossAxisAlignment: CrossAxisAlignment.start,
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomBanner(
            content: Column(children: [
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
              const SizedBox(height: 10.0),
            ],),
          ),
          NumberInputListTile(
            label: AppLocalizations.of(context)!.sysWarn,
            leading: const Icon(Icons.warning_amber_outlined),
            value: settings.sysWarn,
            onParsableSubmit: (double value) {
              settings.sysWarn = value.round();
            },
          ),
          NumberInputListTile(
            label: AppLocalizations.of(context)!.diaWarn,
            leading: const Icon(Icons.warning_amber_outlined),
            value: settings.diaWarn,
            onParsableSubmit: (double value) {
              settings.diaWarn = value.round();
            },
          ),
        ],
      ) ,
    );
  }

}
