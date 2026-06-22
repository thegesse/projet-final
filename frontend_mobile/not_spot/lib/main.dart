import 'dart:io';
import 'package:flutter/material.dart';
import 'package:not_spot/features/playlist/state/playlist_controller.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'features/auth/state/auth_controller.dart';
import 'features/songs/state/song_controller.dart';
import 'features/settings/state/settings_controller.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //import magic, dont pay mind, I dont know what it does
  if (!kIsWeb) {
    if (Platform.isLinux) {
      JustAudioMediaKit.ensureInitialized();
    } else if (Platform.isAndroid || Platform.isIOS) {
      await JustAudioBackground.init(
        androidNotificationChannelId: 'com.notspot.app.channel.audio',
        androidNotificationChannelName: 'NotSpot Playback',
        androidNotificationOngoing: true,
        androidShowNotificationBadge: true,
      );
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProxyProvider<AuthController, SongController>(
          create: (context) =>
              SongController(authController: context.read<AuthController>()),
          update: (context, auth, previous) {
            if (previous == null) {
              return SongController(authController: auth);
            }

            if (previous.authStateAtCreation != auth.isAuthenticated) {
              previous.dispose();
              return SongController(authController: auth);
            }

            return previous;
          },
        ),
        ChangeNotifierProxyProvider<AuthController, PlaylistController>(
          create: (context) =>
              PlaylistController(context.read<AuthController>()),
          update: (context, auth, previous) =>
              previous ?? PlaylistController(auth),
        ),
        ChangeNotifierProxyProvider<AuthController, SettingsController>(
          create: (context) =>
              SettingsController(context.read<AuthController>()),
          update: (context, auth, previous) =>
              previous ?? SettingsController(auth),
        ),
      ],
      child: const NotSpot(),
    ),
  );
}

class NotSpot extends StatefulWidget {
  const NotSpot({super.key});

  @override
  State<NotSpot> createState() => _NotSpotState();
}

class _NotSpotState extends State<NotSpot> {
  late AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    final authController = context.read<AuthController>();
    _appRouter = AppRouter(authController);
  }

  @override
  Widget build(BuildContext context) {
    final authLoading =
        context.select<AuthController, bool>((auth) => auth.isLoading);

    if (authLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'NotSpot',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: _appRouter.router,
    );
  }
}
