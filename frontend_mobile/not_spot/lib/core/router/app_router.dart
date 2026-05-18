import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/state/auth_controller.dart';

//screen
import '../../ui/screens/login_screen.dart';
import '../../ui/screens/register_screen.dart';
import '../../ui/screens/home_screen.dart';

class AppRouter {
  final AuthController authController;

  AppRouter(this.authController);

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: authController,
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = authController.isAuthenticated;
      final bool loggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/home';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      )
    ],
  );
}
