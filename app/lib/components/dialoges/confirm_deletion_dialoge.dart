import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Show a dialoge that prompts the user to confirm a deletion.
///
/// Returns whether it is ok to proceed with deletion.
Future<bool> showConfirmDeletionDialoge(BuildContext context) async =>
await showDialog<bool>(context: context,
  builder: (context) => AlertDialog(
    title: Text(AppLocalizations.of(context)!.confirmDelete),
    content: Text(AppLocalizations.of(context)!.confirmDeleteDesc),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: Text(AppLocalizations.of(context)!.btnCancel),
      ),
      Theme(
        data: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red,
            brightness: Theme.of(context).brightness,
          ),
          useMaterial3: true,
        ),
        child: ElevatedButton.icon(
          onPressed: () => Navigator.pop(context, true),
          icon: const Icon(Icons.delete_forever),
          label: Text(AppLocalizations.of(context)!.btnConfirm),
        ),
      ),
    ],
  ),
) ?? false;
