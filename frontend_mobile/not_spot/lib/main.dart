import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'features/auth/state/auth_controller.dart';
import 'features/songs/state/song_controller.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => SongController()),
      ],
      child: const NotSpot(),
    ),
  );
}

class NotSpot extends StatefulWidget{
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