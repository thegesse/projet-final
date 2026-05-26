import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/settings/state/settings_controller.dart';

class DeleteAccountForm extends StatelessWidget {
  const DeleteAccountForm({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (settings.deleteError != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              settings.deleteError!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          onPressed:
              settings.isDeleting ? null : () => _showDeleteDialog(context),
          child: settings.isDeleting
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Delete account'),
        ),
      ],
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final settings = context.read<SettingsController>();
    final passwordController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: !settings.isDeleting,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm account deletion'),
          content: TextField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
            ),
          ),
          actions: [
            TextButton(
              onPressed: settings.isDeleting
                  ? null
                  : () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: settings.isDeleting
                  ? null
                  : () async {
                      final ok =
                          await settings.deleteAccount(passwordController.text);
                      if (!context.mounted) return;
                      Navigator.pop(context, ok);
                    },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    passwordController.dispose();

    if (confirmed == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted')),
      );
    }
  }
}
