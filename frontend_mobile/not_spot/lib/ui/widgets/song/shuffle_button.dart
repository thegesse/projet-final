import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/songs/state/song_controller.dart';

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SongController>();
    final isShuffling = controller.isShuffling;

    return IconButton(
      icon: Icon(
        Icons.shuffle_rounded,
        color: isShuffling ? Colors.purple : Colors.white,
      ),
      onPressed: () {
        controller.toggleShuffle();
      },
    );
  }
}
