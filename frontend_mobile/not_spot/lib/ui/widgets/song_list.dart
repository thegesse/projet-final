import 'package:flutter/material.dart';
import '../../features/songs/models/domain/song.dart';

class SongList extends StatelessWidget {
  final Song song;
  final bool isCurrent;
  final VoidCallback onTap;

  const SongList(
      {super.key,
      required this.song,
      required this.isCurrent,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Card(
      elevation: isCurrent ? 2 : 0,
      margin: const EdgeInsets.only(bottom: 8),
      color: isCurrent
          ? Theme.of(context).primaryColor.withOpacity(0.85)
          : Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          isCurrent ? Icons.volume_up : Icons.music_note,
          color: isCurrent ? Theme.of(context).primaryColor : Colors.grey,
        ),
        title: Text(
          song.title,
          style: TextStyle(
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal),
        ),
        subtitle: Text(song.artist),
        trailing: SizedBox(
          width: isDesktop ? 200 : 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isDesktop) ...[
                //place holder until I make runtimes
                const Text("3:45",
                    style: TextStyle(color: Colors.grey, fontSize: 13)),
                const SizedBox(width: 20),
              ],
              const Icon(Icons.more_vert),
            ],
          ),
        ),
      ),
    );
  }
}
