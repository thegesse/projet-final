import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/playlist/state/playlist_controller.dart';
import '../../../features/songs/models/domain/song.dart';

class AddToPlaylistSheet extends StatelessWidget {
  final Song song;
  final VoidCallback? onRemovePressed;

  const AddToPlaylistSheet({
    super.key,
    required this.song,
    this.onRemovePressed,
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
                // Smooth Dark Drag Handle Accent Line
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Styled Header Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 48,
                          height: 48,
                          color: Colors.purple.withOpacity(0.12),
                          child: const Icon(Icons.music_note_rounded, color: Colors.purpleAccent),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Add to Playlist',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              song.title,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 13,
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
                const SizedBox(height: 12),
                Divider(height: 1, color: Colors.white.withOpacity(0.08)),

                //Dynamic "Remove from Playlist" Row (Danger Accent)
                if (onRemovePressed != null) ...[
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                    ),
                    title: const Text(
                      'Remove from this playlist',
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onRemovePressed!();
                    },
                  ),
                  Divider(height: 1, color: Colors.white.withOpacity(0.08)),
                ],

                // 4. Playlists Content Builder Deck
                if (controller.isLoading && controller.playlists.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator(color: Colors.purple)),
                  )
                else if (controller.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 32),
                          const SizedBox(height: 12),
                          Text(
                            controller.errorMessage!,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            style: TextButton.styleFrom(foregroundColor: Colors.purpleAccent),
                            onPressed: controller.fetchPlaylists,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (controller.playlists.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.playlist_add_rounded, color: Colors.white24, size: 48),
                          SizedBox(height: 12),
                          Text(
                            'No playlists found.\nCreate one from your library page!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white38, fontSize: 14, height: 1.4),
                          ),
                        ],
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
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = controller.playlists[index];
                        final isAdding = controller.isUpdating &&
                            controller.currentPlaylist?.id == playlist.id;

                        final isLikedSongs = playlist.title == 'Liked Songs';

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isLikedSongs 
                                  ? Colors.red.withOpacity(0.1) 
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isLikedSongs ? Icons.favorite_rounded : Icons.playlist_play_rounded,
                              color: isLikedSongs ? Colors.redAccent : Colors.white70,
                              size: 22,
                            ),
                          ),
                          title: Text(
                            playlist.title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              '${playlist.songs.length} songs',
                              style: const TextStyle(color: Colors.white38, fontSize: 13),
                            ),
                          ),
                          trailing: isAdding
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.purpleAccent),
                                )
                              : const Icon(Icons.add_rounded, color: Colors.white38, size: 22),
                          onTap: isAdding
                              ? null
                              : () => _addToPlaylist(context, controller, playlist.id),
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
          content: Text('Added "${song.title}" to playlist', style: const TextStyle(fontWeight: FontWeight.w500)),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFF311B92), // Deep purple snackbar confirmation accent
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.updateError ?? 'Failed to add song'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}