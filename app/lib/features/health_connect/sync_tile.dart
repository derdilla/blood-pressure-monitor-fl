import 'package:blood_pressure_app/features/health_connect/sync_model.dart';
import 'package:blood_pressure_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class SyncTile extends StatelessWidget {
  const SyncTile({super.key,
    required this.mdl,
    required this.disabled,
  });

  final SyncModel mdl;

  final bool disabled;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: mdl,
    builder: (context, _) => ListTile(
      title: Text(AppLocalizations.of(context)!.syncNow),
      subtitle: mdl.syncing ? LinearProgressIndicator(
        value: mdl.progress,
      ) : null,
      trailing: mdl.syncing
          ? const CircularProgressIndicator()
          : const Icon(Icons.sync),
      onTap: (disabled || mdl.syncing) ? null : mdl.syncWeight,
      enabled: !disabled,
    ),
  );
}
