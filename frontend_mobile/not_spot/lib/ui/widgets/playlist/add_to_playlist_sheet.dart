import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/playlist/state/playlist_controller.dart';
import '../../../features/songs/models/domain/song.dart';

class AddToPlaylistSheet extends StatelessWidget {
  final Song song;

  const AddToPlaylistSheet({
    super.key,
    required this.song,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistController>(
      builder: (context, controller, _) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          width: 48,
                          height: 48,
                          color: Colors.grey.shade800,
                          child: const Icon(Icons.music_note,
                              color: Colors.white54),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add to playlist',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              song.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 24),

                // Playlists list
                if (controller.isLoading && controller.playlists.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (controller.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(height: 8),
                          Text(controller.errorMessage!),
                          TextButton(
                            onPressed: controller.fetchPlaylists,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (controller.playlists.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No playlists yet.\nCreate one first!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.45,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = controller.playlists[index];
                        final isAdding = controller.isUpdating &&
                            controller.currentPlaylist?.id == playlist.id;

                        return ListTile(
                          leading: playlist.title == 'Liked Songs'
                              ? const Icon(Icons.favorite, color: Colors.red)
                              : const Icon(Icons.playlist_play),
                          title: Text(playlist.title),
                          subtitle: Text('${playlist.songs.length} songs'),
                          trailing: isAdding
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.add),
                          onTap: isAdding
                              ? null
                              : () => _addToPlaylist(
                                  context, controller, playlist.id),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addToPlaylist(
    BuildContext context,
    PlaylistController controller,
    int playlistId,
  ) async {
    final success = await controller.addSongToPlaylist(playlistId, song);

    if (!context.mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Added to playlist'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.updateError ?? 'Failed to add song'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
