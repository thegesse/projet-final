import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:not_spot/features/playlist/state/playlist_controller.dart';
import 'package:not_spot/features/playlist/models/domain/playlist.dart';
import 'create_playlist_dialog.dart';

class PlaylistRail extends StatelessWidget {
  final bool isVertical;

  const PlaylistRail({
    super.key,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistController>(
      builder: (context, controller, _) {
        if (controller.isLoading && controller.playlists.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.purpleAccent),
          );
        }

        if (controller.errorMessage != null && controller.playlists.isEmpty) {
          return _buildErrorState(context, controller);
        }

        final playlists = controller.playlists;

        if (isVertical) {
          return _buildSidebar(context, controller, playlists);
        }

        return _buildHorizontalRail(context, controller, playlists);
      },
    );
  }

  // --- 1. HORIZONTAL SCROLL RAIL (MOBILE / TABLET) ---
  Widget _buildHorizontalRail(
    BuildContext context,
    PlaylistController controller,
    List<Playlist> playlists,
  ) {
    return SizedBox(
      height: 64, // Sleeker height blueprint profile
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        itemCount: playlists.length + 1,
        itemBuilder: (context, index) {
          if (index == playlists.length) {
            return _buildAddButton(context, controller);
          }

          final playlist = playlists[index];
          final isSelected = controller.currentPlaylist?.id == playlist.id;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _PlaylistChip(
              playlist: playlist,
              isSelected: isSelected,
              onTap: () {
                if (isSelected) {
                  controller.clearCurrentPlaylist();
                } else {
                  controller.selectPlaylist(playlist.id);
                }
              },
            ),
          );
        },
      ),
    );
  }

  // --- 2. VERTICAL SIDEBAR NAVIGATION (DESKTOP) ---
  Widget _buildSidebar(
    BuildContext context,
    PlaylistController controller,
    List<Playlist> playlists,
  ) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Elevated side rail base surface
        border: Border(
          right: BorderSide(color: Colors.white.withOpacity(0.04), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Row(
              children: [
                Icon(Icons.library_music_rounded, color: Colors.purpleAccent, size: 22),
                SizedBox(width: 12),
                Text(
                  'Your Library',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                final isSelected = controller.currentPlaylist?.id == playlist.id;
                final isLikedSongs = playlist.title == 'Liked Songs';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    tileColor: isSelected ? Colors.purple.withOpacity(0.12) : Colors.transparent,
                    leading: Icon(
                      isLikedSongs ? Icons.favorite_rounded : Icons.playlist_play_rounded,
                      color: isSelected 
                          ? Colors.purpleAccent 
                          : (isLikedSongs ? Colors.redAccent.withOpacity(0.7) : Colors.white60),
                      size: 22,
                    ),
                    title: Text(
                      playlist.title,
                      style: TextStyle(
                        color: isSelected ? Colors.purpleAccent : Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () {
                      if (isSelected) {
                        controller.clearCurrentPlaylist();
                      } else {
                        controller.selectPlaylist(playlist.id);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Divider(height: 1, color: Colors.white.withOpacity(0.06)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              leading: const Icon(Icons.add_rounded, color: Colors.purpleAccent, size: 22),
              title: const Text(
                'Create Playlist',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              onTap: () => _showCreatePlaylistDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. DOCK SUB-ELEMENT BUILDERS ---
  Widget _buildAddButton(BuildContext context, PlaylistController controller) {
    final isCreating = controller.isCreating;
    return GestureDetector(
      onTap: isCreating ? null : () => _showCreatePlaylistDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCreating)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.purpleAccent),
              )
            else
              const Icon(Icons.add_rounded, size: 16, color: Colors.white70),
            const SizedBox(width: 6),
            const Text(
              'New',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, PlaylistController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 28),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage!,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.purpleAccent),
              onPressed: controller.fetchPlaylists,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreatePlaylistDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => const CreatePlaylistDialog(),
    );
  }
}

// --- 4. CUSTOM RE-STYLED HORIZONTAL CHIP COMPONENT ---
class _PlaylistChip extends StatelessWidget {
  final Playlist playlist;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlaylistChip({
    required this.playlist,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLikedSongs = playlist.title == 'Liked Songs';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          // Active state glows bright purple, default state mimics an elegant flat dark capsule
          color: isSelected 
              ? Colors.purple.withOpacity(0.2) 
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.purpleAccent.withOpacity(0.4) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLikedSongs ? Icons.favorite_rounded : Icons.music_note_rounded,
              size: 15,
              color: isSelected 
                  ? Colors.purpleAccent 
                  : (isLikedSongs ? Colors.redAccent.withOpacity(0.8) : Colors.white38),
            ),
            const SizedBox(width: 8),
            Text(
              playlist.title,
              style: TextStyle(
                color: isSelected ? Colors.purpleAccent : Colors.white,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}