import 'package:flutter/material.dart';
import '../../../features/songs/models/domain/song.dart';
import '../playlist/add_to_playlist_sheet.dart';
import '../playlist/add_to_liked_button.dart';

class SongList extends StatelessWidget {
  final Song song;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback? onRemovePressed;

  const SongList({
    super.key,
    required this.song,
    required this.isCurrent,
    required this.onTap,
    this.onRemovePressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 16), // Adjusted horizontal margin to line up with headers
      color: isCurrent ? Colors.purple.withOpacity(0.12) : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isCurrent
              ? Colors.purpleAccent.withOpacity(0.4)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

        // --- LEADING TRACK BADGE ICON ---
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCurrent
                ? Colors.purple.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isCurrent ? Icons.volume_up_rounded : Icons.music_note_rounded,
            color: isCurrent ? Colors.purpleAccent : Colors.white60,
            size: 22,
          ),
        ),

        // --- TRACK IDENTITY TEXTS ---
        title: Text(
          song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isCurrent ? Colors.purpleAccent : Colors.white,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
            letterSpacing: -0.1,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            song.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 13,
            ),
          ),
        ),

        // --- TRAILING OPTIONS CONTROLS ---
        trailing: SizedBox(
          width: isDesktop ? 200 : 88,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isDesktop) ...[
                const SizedBox(width: 12),
              ],
              AddToLikedButton(song: song),
              IconButton(
                onPressed: () => _showSongOptions(context),
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Colors.white60,
                ),
                tooltip: 'More options',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ACTIONS REGISTRY MENU BOTTOM SHEET ---
  void _showSongOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E), // Match elevated charcoal tone
      barrierColor: Colors.black
          .withOpacity(0.6), // Darken back layout content stack focus
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(
          color: Colors.white
              .withOpacity(0.05), // Fixed matching upper border stroke line
          width: 1,
        ),
      ),
      builder: (context) => AddToPlaylistSheet(
        song: song,
        onRemovePressed: onRemovePressed,
      ),
    );
  }
}
