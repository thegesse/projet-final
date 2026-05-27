import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:not_spot/features/playlist/state/playlist_controller.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'features/auth/state/auth_controller.dart';
import 'features/songs/state/song_controller.dart';
import 'features/settings/state/settings_controller.dart';
import 'package:just_audio_background/just_audio_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // If running on Mobile, we initialize the background notification thread.
  // If running on Linux, just_audio_mpv registers itself automatically under the hood!
  if (Platform.isAndroid || Platform.isIOS) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.notspot.app.channel.audio',
      androidNotificationChannelName: 'NotSpot Playback',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => SongController()),
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
    return MaterialApp.router(
      title: 'NotSpot',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: _appRouter.router,
    );
  }
}