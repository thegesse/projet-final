import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/state/auth_controller.dart';
import '../../../features/songs/state/song_controller.dart';
import '../../../features/songs/models/domain/song.dart';

class AdminSongsPage extends StatefulWidget {
  const AdminSongsPage({super.key});

  @override
  State<AdminSongsPage> createState() => _AdminSongsPageState();
}

class _AdminSongsPageState extends State<AdminSongsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SongController>().fetchSongs();
    });
  }

  void _confirmDelete(BuildContext context, Song song, SongController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "Delete Track permanently?",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to remove '${song.title}' by ${song.artist}? This will delete it from the server.",
          style: const TextStyle(color: Colors.white60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(ctx);
              await controller.deleteSong(song.id);
              
              if (mounted) {
                if (controller.errorMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(controller.errorMessage!),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Track successfully removed from catalog."),
                      backgroundColor: Colors.purple,
                    ),
                  );
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    if (!authController.isAdmin) {
      return const Scaffold(
        backgroundColor: Color(0xFF121212),
        body: Center(
          child: Text(
            "Access Denied: Administrators Only.",
            style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Admin Console",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
            ),
            Text(
              "Catalog Moderation & Maintenance",
              style: TextStyle(fontSize: 14, color: Colors.white38),
            ),
          ],
        ),
      ),
      body: Consumer<SongController>(
        builder: (context, controller, child) {
          if (controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.purple),
            );
          }

          if (controller.songs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_music_outlined, size: 64, color: Colors.white.withOpacity(0.15)),
                  const SizedBox(height: 16),
                  const Text(
                    "The audio library is completely empty.",
                    style: TextStyle(color: Colors.white38, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                children: [
                  // Column titles
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    child: Row(
                      children: [
                        const SizedBox(width: 48),
                        const Expanded(
                          flex: 3,
                          child: Text("TITLE", style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        ),
                        const Expanded(
                          flex: 2,
                          child: Text("ARTIST", style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        ),
                        Text("ACTIONS", style: TextStyle(color: Colors.white24, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        const SizedBox(width: 90),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1),

                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: controller.songs.length,
                      separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                      itemBuilder: (context, index) {
                        final song = controller.songs[index];
                        final bool isCurrentlyPlayingThis = controller.currentSong?.id == song.id;

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            color: isCurrentlyPlayingThis ? const Color(0xFF1E1E1E) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E), // 🎨 Tile background
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                isCurrentlyPlayingThis && controller.isPlaying 
                                  ? Icons.volume_up_rounded 
                                  : Icons.music_note_rounded,
                                color: isCurrentlyPlayingThis ? Colors.purple : Colors.white60,
                                size: 20,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    song.title,
                                    style: TextStyle(
                                      color: isCurrentlyPlayingThis ? Colors.purple : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    song.artist,
                                    style: const TextStyle(color: Colors.white38, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    isCurrentlyPlayingThis && controller.isPlaying
                                        ? Icons.pause_circle_filled_rounded
                                        : Icons.play_circle_fill_rounded,
                                  ),
                                  color: isCurrentlyPlayingThis ? Colors.purple : Colors.white60,
                                  onPressed: () {
                                    if (isCurrentlyPlayingThis) {
                                      // 🔄 Use your controller's built-in toggle functionality
                                      controller.togglePlayPause();
                                    } else {
                                      // 🎶 If it's a completely different song, select and stream it
                                      controller.selectSong(song, queue: controller.songs);
                                    }
                                  },
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                  hoverColor: Colors.redAccent.withOpacity(0.1),
                                  onPressed: () => _confirmDelete(context, song, controller),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}