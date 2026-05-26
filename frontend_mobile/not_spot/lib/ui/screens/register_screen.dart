import 'package:flutter/material.dart';
import '../widgets/auth/register_form.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine if we are on a large screen
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      // Light grey background for desktop to make the form "pop"
      backgroundColor: isDesktop ? Colors.grey[100] : Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            // visual styling for desktop
            decoration: isDesktop
                ? BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 15)
                    ],
                  )
                : null,
            padding: isDesktop ? const EdgeInsets.all(40) : EdgeInsets.zero,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Join Us",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text("Create your account to get started"),
                  const SizedBox(height: 32),
                  const RegisterForm(), // This is your shared widget
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
