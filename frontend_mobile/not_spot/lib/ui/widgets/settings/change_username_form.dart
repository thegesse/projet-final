import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../features/settings/state/settings_controller.dart';

class ChangeUsernameForm extends StatefulWidget {
  const ChangeUsernameForm({super.key});

  @override
  State<ChangeUsernameForm> createState() => _ChangeUsernameFormState();
}

class _ChangeUsernameFormState extends State<ChangeUsernameForm> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();

  @override
  void dispose() {
    _userController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final busy = settings
        .isUpdating; // Match with SettingsController flag names if needed

    // FORCE DARK THEME ON ACCENT ELEMENTS AND TEXT ENTRY FIELDS
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.purpleAccent,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- NEW USERNAME FIELD ---
            TextFormField(
              controller: _userController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textCapitalization: TextCapitalization.none,
              decoration: InputDecoration(
                labelText: 'New Username',
                labelStyle:
                    const TextStyle(color: Colors.white60, fontSize: 14),
                prefixIcon: const Icon(Icons.badge_outlined,
                    color: Colors.white38, size: 20),
                filled: true,
                fillColor: Colors.black.withOpacity(0.15),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Colors.purpleAccent, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Colors.redAccent, width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Colors.redAccent, width: 1.5),
                ),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Username required' : null,
            ),
            const SizedBox(height: 16),

            if (settings.updateError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  settings.updateError!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),

            // --- CHANGE USERNAME BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.purple.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                onPressed: busy ? null : _handleNameChange,
                child: busy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Change Username"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNameChange() async {
    if (_formKey.currentState!.validate()) {
      final success = await context
          .read<SettingsController>()
          .changeUsername(_userController.text.trim());

      if (!mounted) return;

      if (success) {
        _userController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    color: Colors.greenAccent, size: 20),
                SizedBox(width: 12),
                Text('Username updated successfully',
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
            duration: const Duration(seconds: 3),
            backgroundColor:
                const Color(0xFF311B92), // Deep purple floating snackbar
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        // FIXED: Replaced raw Navigator call with correct GoRouter state shift
        context.go('/home');
      }
    }
  }
}
