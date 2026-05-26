import 'package:flutter/material.dart';
import '../widgets/settings/change_password_form.dart';
import '../widgets/settings/change_username_form.dart';
import '../widgets/settings/delete_account_form.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: isDesktop ? Colors.grey[100] : Colors.white,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: isDesktop
                  ? BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 20,
                          color: Color(0x14000000),
                          offset: Offset(0, 8),
                        )
                      ],
                    )
                  : null,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Change username',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 12),
                  ChangeUsernameForm(),
                  SizedBox(height: 24),
                  Text(
                    'Change password',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 12),
                  ChangePasswordForm(),
                  SizedBox(height: 24),
                  Divider(height: 32),
                  Text(
                    'Danger zone',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 12),
                  DeleteAccountForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
