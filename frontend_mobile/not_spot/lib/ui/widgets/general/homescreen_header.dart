import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/state/auth_controller.dart';

class HomescreenHeader extends StatelessWidget {
  const HomescreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final String username = auth.username ?? 'Guest';
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Padding(
      // FIXED: Reduced internal padding so it blends seamlessly with HomeScreen's layouts
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 12.0 : 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // FIXED: Swapped out black87 for white to make it legible in dark mode
              Text(
                "Hello $username",
                style: TextStyle(
                  fontSize: isDesktop ? 32 : 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              // Optional: Changed flat "Music Player" text into a premium dynamic version
              Text(
                "Premium Player",
                style: TextStyle(
                  color: Colors.purpleAccent.withOpacity(0.8),
                  fontSize: isDesktop ? 14 : 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}