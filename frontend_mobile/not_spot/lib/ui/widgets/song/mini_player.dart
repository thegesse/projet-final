import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/songs/state/song_controller.dart';

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
        height: 70,
        margin: EdgeInsets.only(bottom: isDesktop ? 24 : 12),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black, blurRadius: 8, offset: Offset(0, 4))
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  Text(
                    currentSong.artist,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
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
                    size: 36,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
