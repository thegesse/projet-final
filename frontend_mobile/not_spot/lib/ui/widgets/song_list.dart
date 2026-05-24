import 'package:flutter/material.dart';
import '../../features/songs/models/domain/song.dart';
import 'add_to_playlist_sheet.dart';

class SongList extends StatelessWidget {
  final Song song;
  final bool isCurrent;
  final VoidCallback onTap;

  const SongList({
    super.key,
    required this.song,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Card(
      elevation: isCurrent ? 2 : 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: isCurrent
          ? Theme.of(context).colorScheme.primary.withOpacity(0.85)
          : Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          isCurrent ? Icons.volume_up : Icons.music_note,
          color: isCurrent
              ? Theme.of(context).colorScheme.primary
              : Colors.grey,
        ),
        title: Text(
          song.title,
          style: TextStyle(
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(song.artist),
        trailing: SizedBox(
          width: isDesktop ? 200 : 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isDesktop) ...[
                const Text(
                  "3:45",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(width: 20),
              ],
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showSongOptions(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSongOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => AddToPlaylistSheet(song: song),
    );
  }
}