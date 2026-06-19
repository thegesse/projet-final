import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/state/auth_controller.dart';

//screen
import '../../ui/screens/secondary screens/login_screen.dart';
import '../../ui/screens/secondary screens/register_screen.dart';
import '../../ui/screens/home_screen.dart';
import '../../ui/screens/main screens/settings_screen.dart';
import '../../ui/screens/main screens/add_song_screen.dart';
import '../../ui/screens/main screens/song_screen.dart';
import '../../ui/screens/main screens/playlist_screen.dart';
import '../../ui/screens/secondary screens/playlist_detail_screen.dart';

//navbars
import '../../ui/widgets/general/mobile_nav_bar.dart';
import '../../ui/widgets/general/side_bar_pc.dart';

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
        path: '/',
        redirect: (context, state) =>
            authController.isAuthenticated ? '/home' : '/login',
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
          path: '/playlist/:id',
          builder: (context, state) {
            final playlistId = int.parse(state.pathParameters['id']!);
            return PlaylistDetailScreen(playlistId: playlistId);
          }),
      ShellRoute(
        builder: (context, state, child) {
          // Responsive Check: Use MediaQuery to check screen width
          final isDesktop = MediaQuery.of(context).size.width > 600;

          if (isDesktop) {
            // Return your PC layout shell wrapper
            return SideBarPc(child: child);
          } else {
            // Return your Mobile layout shell wrapper
            return MobileNavBar(child: child);
          }
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/addSong',
            builder: (context, state) => const AddSongScreen(),
          ),
          GoRoute(
            path: '/song',
            builder: (context, state) => const SongScreen(),
          ),
          GoRoute(
            path: '/playlists',
            builder: (context, state) => const PlaylistScreen(),
          ),
        ],
      )
    ],
  );
}
