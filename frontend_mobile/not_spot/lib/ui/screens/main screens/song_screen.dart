import 'package:flutter/material.dart';
import 'package:not_spot/ui/widgets/song/mini_player.dart';
import 'package:provider/provider.dart';
import '../../../features/songs/state/song_controller.dart';
import '../../widgets/song/mini_player_progress_bar.dart';
import 'dart:ui';

class SongScreen extends StatelessWidget{
  const SongScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SongController>();

    if(!controller.hasActiveSong) {
      return const Scaffold(
        body: Center(child: Text("No song playing"),),
      );
    }

    final currentSong = controller.currentSong;
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white,size: 32,),
          onPressed: () => Navigator.of(context).pop,
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
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                          currentSong!.title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentSong!.artist,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                              onPressed: () => controller.playPrevious,
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
                                onPressed: () => controller.playNext()
                            ),
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

