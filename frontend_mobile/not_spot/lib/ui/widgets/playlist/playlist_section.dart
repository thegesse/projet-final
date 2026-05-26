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
          return const Center(child: CircularProgressIndicator());
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

  Widget _buildHorizontalRail(
    BuildContext context,
    PlaylistController controller,
    List<Playlist> playlists,
  ) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: playlists.length + 1, // +1 for "Add" button
        itemBuilder: (context, index) {
          if (index == playlists.length) {
            return _buildAddButton(context, controller);
          }

          final playlist = playlists[index];
          final isSelected = controller.currentPlaylist?.id == playlist.id;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _PlaylistChip(
              playlist: playlist,
              isSelected: isSelected,
              onTap: () {
                final isSelected =
                    controller.currentPlaylist?.id == playlist.id;
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

  Widget _buildSidebar(
    BuildContext context,
    PlaylistController controller,
    List<Playlist> playlists,
  ) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Your Library',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                final isSelected =
                    controller.currentPlaylist?.id == playlist.id;

                return ListTile(
                  leading: const Icon(Icons.playlist_play),
                  title: Text(playlist.title),
                  selected: isSelected,
                  onTap: () {
                    final isSelected =
                        controller.currentPlaylist?.id == playlist.id;
                    if (isSelected) {
                      controller.clearCurrentPlaylist();
                    } else {
                      controller.selectPlaylist(playlist.id);
                    }
                  },
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Create Playlist'),
            onTap: () => _showCreatePlaylistDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, PlaylistController controller) {
    return ActionChip(
      avatar: controller.isCreating
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.add, size: 18),
      label: const Text('Add'),
      onPressed: controller.isCreating
          ? null
          : () => _showCreatePlaylistDialog(context),
    );
  }

  Widget _buildErrorState(BuildContext context, PlaylistController controller) {
    return Center(
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
    );
  }

  Future<void> _showCreatePlaylistDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => const CreatePlaylistDialog(),
    );
  }
}

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
    return ChoiceChip(
      label: Text(playlist.title),
      selected: isSelected,
      onSelected: (_) => onTap(),
      avatar: playlist.title == 'Liked Songs'
          ? const Icon(Icons.favorite, size: 16)
          : const Icon(Icons.music_note, size: 16),
    );
  }
}
