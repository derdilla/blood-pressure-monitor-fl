import 'package:blood_pressure_app/features/health_connect/sync_model.dart';
import 'package:flutter/material.dart';

class SyncTile extends StatelessWidget {
  const SyncTile({super.key, required this.mdl});
// TODO: add disabled
  final SyncModel mdl;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: mdl,
    builder: (context, _) => ListTile(
      title: Text('Sync now'),
      subtitle: mdl.syncing ? LinearProgressIndicator(
        value: mdl.progress,
      ) : null,
      trailing: mdl.syncing
          ? const CircularProgressIndicator()
          : const Icon(Icons.sync),
      onTap: mdl.syncing ? null : mdl.syncWeight,
    ),
  );
}
