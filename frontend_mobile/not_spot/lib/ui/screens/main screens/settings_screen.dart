import 'package:flutter/material.dart';
import '../../widgets/settings/change_password_form.dart';
import '../../widgets/settings/change_username_form.dart';
import '../../widgets/settings/delete_account_form.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      // Unified deep AMOLED-friendly dark canvas base background
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: isDesktop ? 40 : 16,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                // Cards stand out slightly lighter than the base canvas background
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 30,
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- PROFILE SECTION GROUPS ---
                  const Row(
                    children: [
                      Icon(Icons.person_outline_rounded,
                          color: Colors.purpleAccent, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Account Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Update Username',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const ChangeUsernameForm(),

                  const SizedBox(height: 32),

                  // --- SECURITY SECTION GROUPS ---
                  const Row(
                    children: [
                      Icon(Icons.lock_outline_rounded,
                          color: Colors.purpleAccent, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'Security',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Change Password',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const ChangePasswordForm(),

                  const SizedBox(height: 24),
                  Divider(height: 40, color: Colors.white.withOpacity(0.08)),

                  // --- DANGER ZONE SECTION GROUPS ---
                  Row(
                    children: [
                      Icon(Icons.gpp_maybe_outlined,
                          color: Colors.red[400], size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Danger Zone',
                        style: TextStyle(
                          color: Colors.red[400],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Deleting your account is permanent and cannot be undone. All of your custom music playlists, saved queues, and account data will be completely wiped from NotSpot.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.38),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const DeleteAccountForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
