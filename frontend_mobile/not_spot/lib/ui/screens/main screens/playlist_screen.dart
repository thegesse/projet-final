import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/playlist/state/playlist_controller.dart';
import '../../widgets/playlist/playlist_card.dart';
import '../../widgets/playlist/create_playlist_dialog.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlaylistController>().fetchPlaylists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PlaylistController>();
    final playlists = controller.playlists;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            onPressed: () => _showCreatePlaylistDialog(context),
            tooltip: 'Create Playlist',
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          int crossAxisCount = 1;
          if (width > 1200) {
            crossAxisCount = 4; // Desktop large
          } else if (width > 900) {
            crossAxisCount = 3; // Desktop small
          } else if (width > 600) {
            crossAxisCount = 2; // Mobile
          }

          final horizontalPadding = width > 900 ? 32.0 : 16.0;

          return RefreshIndicator(
            onRefresh: () =>
                context.read<PlaylistController>().fetchPlaylists(),
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: const Color(0xFF1E1E1E),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: horizontalPadding,
                        right: horizontalPadding,
                        bottom: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Library',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${playlists.length} ${playlists.length == 1 ? 'playlist' : 'playlists'} total',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (controller.isLoading && playlists.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (controller.errorMessage != null && playlists.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.redAccent, size: 40),
                          const SizedBox(height: 12),
                          Text(controller.errorMessage!,
                              style: const TextStyle(color: Colors.white70)),
                          TextButton(
                            onPressed: () => controller.fetchPlaylists(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (playlists.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.library_music_outlined,
                              color: Colors.white.withOpacity(0.15), size: 64),
                          const SizedBox(height: 16),
                          const Text(
                            'No playlists yet',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Create your first custom collection!',
                            style:
                                TextStyle(color: Colors.white38, fontSize: 14),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Create Playlist'),
                            onPressed: () => _showCreatePlaylistDialog(context),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  // 3. Grid Adapter that behaves like a column layout on mobile and grid layout on desktop
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding -
                            16), // balances internal card margins
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisExtent:
                            86, // Keeps cards uniform and stops them stretching vertically
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final playlist = playlists[index];
                          return PlaylistCard(playlist: playlist);
                        },
                        childCount: playlists.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
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
