import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../../../features/songs/state/song_controller.dart';

class MiniPlayerInlineProgressBar extends StatelessWidget {
  const MiniPlayerInlineProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final songController = context.read<SongController>();

    return StreamBuilder<PositionData>(
      stream: songController.positionDataStream,
      builder: (context, snapshot) {
        final positionData = snapshot.data;

        final position = positionData?.position ?? Duration.zero;
        final bufferedPosition =
            positionData?.bufferedPosition ?? Duration.zero;
        final duration = positionData?.duration ?? Duration.zero;

        return ProgressBar(
          progress: position,
          buffered: bufferedPosition,
          total: duration,
          progressBarColor: Colors.white,
          baseBarColor: Colors.white12,
          bufferedBarColor: Colors.white30,
          thumbColor: Colors.white,
          barHeight: 3.5,
          thumbRadius: 5.0,
          thumbGlowRadius: 12.0,
          timeLabelLocation: TimeLabelLocation.none,
          onSeek: (duration) {
            songController.audioPlayer.seek(duration);
          },
        );
      },
    );
  }
}
