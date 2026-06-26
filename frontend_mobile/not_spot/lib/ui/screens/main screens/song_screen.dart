import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../features/radio/controller/radio_controller.dart';
import '../../../features/songs/state/song_controller.dart';
import '../../widgets/song/mini_player_progress_bar.dart';
import 'dart:ui';

void _closePlayer(BuildContext context) {
  final router = GoRouter.of(context);
  if (router.canPop()) {
    router.pop();
  } else {
    context.go('/home');
  }
}

class SongScreen extends StatelessWidget {
  const SongScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SongController>();
    final radioController = context.watch<RadioController>();

    if (!controller.hasActiveSong) {
      final stationName = radioController.currentStationName;

      if (stationName == null) {
        return const Scaffold(
          body: Center(
            child: Text("No song playing"),
          ),
        );
      }

      return _RadioPlayingView(
        stationName: stationName,
        isPlaying: radioController.isPlaying,
        onToggle: () {
          if (radioController.isPlaying) {
            radioController.stopRadio();
          } else {
            radioController.playStation(stationName);
          }
        },
      );
    }

    final currentSong = controller.currentSong!;
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
            size: 32,
          ),
          onPressed: () => _closePlayer(context),
        ),
      ),
      body: Stack(
        children: [
          Container(color: const Color(0xff121212)),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                color: Colors.grey.withOpacity(0.15),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 460 : double.infinity,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(height: 20),
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(24),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.music_note_rounded,
                            size: isDesktop ? 140 : screenSize.width * 0.3,
                            color: Colors.white38,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          currentSong.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentSong.artist,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white60,
                                  ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 36),
                        const MiniPlayerInlineProgressBar(),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.skip_previous_rounded),
                              iconSize: 44,
                              color: Colors.white,
                              onPressed: () => controller.playPrevious(),
                            ),
                            IconButton(
                              icon: Icon(
                                controller.isPlaying
                                    ? Icons.pause_circle_filled_rounded
                                    : Icons.play_circle_outline_rounded,
                              ),
                              iconSize: 76,
                              color: Colors.white,
                              onPressed: () => controller.togglePlayPause(),
                            ),
                            IconButton(
                                icon: const Icon(Icons.skip_next_rounded),
                                iconSize: 44,
                                color: Colors.white,
                                onPressed: () => controller.playNext()),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _RadioPlayingView extends StatelessWidget {
  final String stationName;
  final bool isPlaying;
  final VoidCallback onToggle;

  const _RadioPlayingView({
    required this.stationName,
    required this.isPlaying,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
            size: 32,
          ),
          onPressed: () => _closePlayer(context),
        ),
      ),
      body: Stack(
        children: [
          Container(color: const Color(0xff121212)),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                color: Colors.purple.withOpacity(0.12),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 460 : double.infinity,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const SizedBox(height: 20),
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(24),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.radio_rounded,
                            size: isDesktop ? 140 : screenSize.width * 0.3,
                            color: Colors.white38,
                          ),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          stationName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isPlaying ? "Live radio" : "Radio stopped",
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white60,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 36),
                        IconButton(
                          icon: Icon(
                            isPlaying
                                ? Icons.stop_circle_rounded
                                : Icons.play_circle_outline_rounded,
                          ),
                          iconSize: 76,
                          color: Colors.white,
                          onPressed: onToggle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
