import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/settings/state/settings_controller.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>();
    final busy = settings.isUpdating;

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
            // --- CURRENT PASSWORD FIELD ---
            TextFormField(
              controller: _oldPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: _buildInputDecoration(
                label: 'Current Password',
                icon: Icons.lock_open_rounded,
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Current password required' : null,
            ),
            const SizedBox(height: 16),

            // --- NEW PASSWORD FIELD ---
            TextFormField(
              controller: _newPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: _buildInputDecoration(
                label: 'New Password',
                hint: 'Must be at least 8 characters',
                icon: Icons.vpn_key_outlined,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'New password required';
                if (v.length < 8) return 'At least 8 characters';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- CONFIRM NEW PASSWORD FIELD ---
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: _buildInputDecoration(
                label: 'Confirm New Password',
                icon: Icons.gpp_good_outlined,
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Confirm your new password';
                if (v != _newPasswordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            if (settings.updateError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  settings.updateError!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),

            // --- UPDATE PASSWORD ELEVATED SUBMITTER ---
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
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                onPressed: busy ? null : _handlePasswordChange,
                child: busy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Change Password"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // REUSABLE DECORATION LAYER METADATA METHOD
  InputDecoration _buildInputDecoration({required String label, String? hint, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60, fontSize: 14),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
      prefixIcon: Icon(icon, color: Colors.white38, size: 20),
      filled: true,
      fillColor: Colors.black.withOpacity(0.15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        borderSide: const BorderSide(color: Colors.purpleAccent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  Future<void> _handlePasswordChange() async {
    if (!_formKey.currentState!.validate()) return;

    final currentPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    final success = await context.read<SettingsController>().changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
          confirmPassword: confirmPassword,
        );

    if (!mounted) return;

    if (success) {
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Colors.greenAccent, size: 20),
              SizedBox(width: 12),
              Text('Password updated successfully', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          duration: const Duration(seconds: 3),
          backgroundColor: const Color(0xFF311B92), // Deep purple snackbar backdrop
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      
      // FIXED: Removed Navigator.pop(context) since this runs inline on SettingsScreen
    }
  }
}