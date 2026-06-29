import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/state/auth_controller.dart';
import '../../features/playlist/state/playlist_controller.dart';
import '../../features/songs/state/song_controller.dart';
import '../widgets/general/homescreen_header.dart';
import '../widgets/song/mini_player.dart';
import '../widgets/playlist/playlist_section.dart'; // Handles PlaylistRail
import '../widgets/song/song_list.dart';
import '../widgets/general/searchbar.dart' as custom_search;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SongController>().fetchSongs();
      context.read<PlaylistController>().fetchPlaylists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final songController = context.watch<SongController>();
    final playlistController = context.watch<PlaylistController>();
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 600;

    // Filter rules logic engine matching your playlist state
    final songsToShow = playlistController.hasCurrentPlaylist
        ? playlistController.currentPlaylist!.songs
        : songController.searchResults.isNotEmpty
            ? songController.searchResults
            : songController.songs;

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Sleek AMOLED dark base theme
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          playlistController.hasCurrentPlaylist
              ? playlistController.currentPlaylist!.title
              : 'Discover',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          // App bar shortcut to exit the current playlist layout frame
          if (playlistController.hasCurrentPlaylist)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white70),
              tooltip: 'Clear playlist filter',
              onPressed: () => playlistController.clearCurrentPlaylist(),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white70),
              tooltip: 'Logout',
              onPressed: () {
                context.read<AuthController>().logout();
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main Body Column
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: HomescreenHeader(),
                ),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: custom_search.SearchBar(),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child:
                      PlaylistRail(), // Renders horizontal playlist selections
                ),

                // Active dynamic playlist filter tag item indicator
                if (playlistController.hasCurrentPlaylist)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 4.0),
                    child: InputChip(
                      label: Text(
                        'Viewing: ${playlistController.currentPlaylist!.title}',
                        style: const TextStyle(
                          color: Colors.purpleAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: Colors.purple.withOpacity(0.15),
                      deleteIcon: const Icon(Icons.cancel,
                          color: Colors.purpleAccent, size: 18),
                      onDeleted: () {
                        playlistController.clearCurrentPlaylist();
                      },
                    ),
                  ),

                const SizedBox(height: 8),

                // Main Content Workspace Area Switch Box
                if (songController.isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.purple),
                    ),
                  )
                else if (songController.errorMessage != null)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          songController.errorMessage!,
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
                else if (songsToShow.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'No songs available to display',
                        style: TextStyle(color: Colors.white38, fontSize: 16),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      // Generous bottom layout spacing margin padding to safeguard scrolling elements from the miniplayer banner limits
                      padding:
                          EdgeInsets.fromLTRB(24, 0, 24, isDesktop ? 120 : 110),
                      itemCount: songsToShow.length,
                      itemBuilder: (context, index) {
                        final song = songsToShow[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: SongList(
                            song: song,
                            isCurrent:
                                songController.currentSong?.id == song.id,
                            onTap: () {
                              songController.selectSong(song,
                                  queue: songsToShow);
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Fixed background opacity overlay layout wrapper hosting the MiniPlayer
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.85),
                    Colors.black.withOpacity(0.0),
                  ],
                ),
              ),
              padding: const EdgeInsets.only(bottom: 4.0),
              child: const MiniPlayer(),
            ),
          ),
        ],
      ),
    );
  }
}
