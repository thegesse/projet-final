import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/songs/state/song_controller.dart';
import 'mini_player_progress_bar.dart'; // Ensure your progress bar import is linked here
import 'shuffle_button.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SongController>();
    if (!controller.hasActiveSong) return const SizedBox.shrink();

    final currentSong = controller.currentSong!;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 600;

    return Center(
      child: Container(
        width: isDesktop ? 500 : width - 32,
        height: 96,
        margin: EdgeInsets.only(bottom: isDesktop ? 24 : 12),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4), 
              blurRadius: 12, 
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 14.0, left: 16.0, right: 16.0),
              child: MiniPlayerInlineProgressBar(),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentSong.title,
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentSong.artist,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.skip_previous_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () => controller.playPrevious(),
                        ),
                        IconButton(
                          icon: Icon(
                            controller.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            color: Colors.white,
                            size: 38,
                          ),
                          onPressed: () => controller.togglePlayPause(),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () => controller.playNext(),
                        ),
                        const ShuffleButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}