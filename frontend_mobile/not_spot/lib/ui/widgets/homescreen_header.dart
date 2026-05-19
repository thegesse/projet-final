import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/state/auth_controller.dart';

class HomescreenHeader extends StatelessWidget {
  const HomescreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final String username = auth.username ?? 'Guest';
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Padding(
      padding: EdgeInsets.all(isDesktop ? 32 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Hello $username",
                style: TextStyle(
                  fontSize: isDesktop ? 32 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Text(
                "Music player",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isDesktop)
            ElevatedButton.icon(
              onPressed: () {
                // Go to profile / settings
              },
              icon: const Icon(Icons.person),
              label: const Text("Account"),
            ),
        ],
      ),
    );
  }
}
