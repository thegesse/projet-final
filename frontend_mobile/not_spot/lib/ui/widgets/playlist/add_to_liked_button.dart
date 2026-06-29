import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/songs/models/domain/song.dart';
import '../../../features/songs/state/song_controller.dart';
import '../../../features/playlist/state/playlist_controller.dart';

class AddToLikedButton extends StatelessWidget {
  final Song song;

  const AddToLikedButton({
    super.key,
    required this.song,
  });

  @override
  Widget build(BuildContext context) {
    final songController = context.watch<SongController>();
    final playlistController = context.watch<PlaylistController>();

    // Check if THIS specific song is liked
    final isLiked = songController.isSongLiked(song.id);

    return IconButton(
      icon: Icon(
        isLiked ? Icons.favorite : Icons.favorite_border,
        color: isLiked ? Colors.purple : Colors.white,
      ),
      onPressed: () async {
        final success = isLiked
            ? await playlistController.removeSongFromLikedPlaylist(song)
            : await playlistController.addSongToLikedPlaylist(song);

        if (success) {
          songController.updateSongLikedCache(song.id, !isLiked);
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isLiked
                    ? 'Failed to remove song from liked playlist'
                    : 'Failed to add song to liked playlist',
              ),
            ),
          );
        }
      },
    );
  }
}
