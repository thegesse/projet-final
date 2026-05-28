import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:not_spot/features/playlist/state/playlist_controller.dart';
import 'package:go_router/go_router.dart';
import '../widgets/song/song_list.dart';
import 'package:not_spot/features/songs/state/song_controller.dart';


class PlaylistDetailScreen extends StatefulWidget {
  final int playlistId;
  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  State<PlaylistDetailScreen> createState() => _playlistDetailSCreenState();
}

class _playlistDetailSCreenState extends State<PlaylistDetailScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlaylistController>().selectPlaylist(widget.playlistId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PlaylistController>();

    if (controller.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final playlist = controller.currentPlaylist;

    if(playlist == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(child: Text("Playlists not found", style: TextStyle(color: Colors.white))),
      );
    }

    final songs = playlist.songs ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.go('/home'),
        ),
        title: Text(playlist.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: songs.isEmpty
          ? const Center(
              child: Text(
                "No songs in this playlist yet.",
                style: TextStyle(color: Colors.white38, fontSize: 16),
              ),
            )
          : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  final song = songs[index];
                  final isCurrentPlaying = context.watch<SongController>().currentSong?.id == song.id;
                  return SongList(
                    song: song,
                    isCurrent: isCurrentPlaying,
                    onTap: () {
                      context.read<SongController>().selectSong(song, queue: songs);
                    },
                    onRemovePressed: () async {
                      final success = await context.read<PlaylistController>().removeSongFromPlaylist(playlist.id, song);
                      if(success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${song.title} removed from${playlist.title}')),
                        );
                      }
                    },
                );
              },
            ),
    );
  }
}