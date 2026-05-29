import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../features/settings/state/settings_controller.dart';
import '../../../features/auth/state/auth_controller.dart';

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
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),

        // --- BASE DESTRUCTIVE TRIGGER BUTTON ---
        SizedBox(
          height: 44,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Colors.red[900]?.withOpacity(0.8), // Muted premium red base
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
              ),
              textStyle:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                : const Text('Delete Account'),
          ),
        ),
      ],
    );
  }

  // --- CONFIRMATION ACTION MODAL ---
  Future<void> _showDeleteDialog(BuildContext context) async {
    final settings = context.read<SettingsController>();
    final auth = context.read<AuthController>();
    final passwordController = TextEditingController();

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        // FORCE DARK THEME ON INPUT CONTEXTS INSIDE MODALS
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.redAccent, // Red cursor highlight focus accents
            ),
          ),
          child: AlertDialog(
            backgroundColor:
                const Color(0xFF1E1E1E), // Elevated surface container
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.redAccent, size: 24),
                SizedBox(width: 12),
                Text(
                  'Confirm Deletion',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'This action is irreversible. Please input your security password below to complete account purging operations.',
                  style: TextStyle(
                      color: Colors.white38, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle:
                        const TextStyle(color: Colors.white60, fontSize: 14),
                    prefixIcon: const Icon(Icons.lock_outline_rounded,
                        color: Colors.white38, size: 20),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.15),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.white.withOpacity(0.08)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.redAccent, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            actionsPadding:
                const EdgeInsets.only(right: 16, bottom: 16, left: 16),
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.white60),
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel',
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[800],
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  final ok =
                      await settings.deleteAccount(passwordController.text);
                  if (ok) {
                    if (!dialogContext.mounted) return;
                    Navigator.pop(dialogContext, true);

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                              'Your NotSpot account data profile has been permanently wiped.'),
                          backgroundColor: Colors.grey[900],
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                      auth.logout();
                      context.go('/login');
                    });
                  }
                },
                child: const Text('Delete Permanently',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );

    passwordController.dispose();
  }
}
