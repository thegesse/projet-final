import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/playlist/models/domain/playlist.dart';
import '../../../features/playlist/state/playlist_controller.dart';
import 'package:go_router/go_router.dart';


class PlaylistCard extends StatelessWidget {
    final Playlist playlist;
    final VoidCallback? onTap;

    const PlaylistCard({
        super.key,
        required this.playlist,
        this.onTap,
    });

    @override
    Widget build(BuildContext context) {
        final songCount = playlist.songs?.length ?? 0;
        return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            elevation: 0,
            color: Colors.white.withOpacity(0.05),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            child: ListTile(
                onTap: onTap ?? () {
                  context.push('/playlist/${playlist.id}');
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

                leading: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                        child: Icon(
                            Icons.queue_music_rounded,
                            color: Colors.white70,
                            size: 28,
                        ),
                    ),
                ),
                title: Text(
                    playlist.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                ),
                subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                        '$songCount ${songCount == 1 ? 'song' : 'songs'}',
                        style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                        ),
                    ),
                ),
                //right menu
                trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: Colors.white70),
                    color: const Color(0xFF222222),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    onSelected: (action) => _handleMenuAction(context, action),
                    itemBuilder: (BuildContext context) => [
                        const PopupMenuItem(
                            value: 'rename',
                            child: ListTile(
                                leading: Icon(Icons.edit_rounded, color: Colors.white70, size: 20),
                                title: Text('Rename', style: TextStyle(color: Colors.white)),
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                            ),
                        ),
                        PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                                leading: Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                                title: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                            ),
                        ),
                    ],
                ),
            ),
        );
    }

    void _handleMenuAction(BuildContext context, String action) {
        if(action == 'rename') {
            _showRenameDialog(context);
        } else if (action == 'delete') {
            _showDeleteConfirmation(context);
        }
    }

    void _showRenameDialog(BuildContext context) {
        final textController = TextEditingController(text: playlist.title);

        showDialog(
            context: context,
            builder: (dialogContext) => AlertDialog(
                backgroundColor: const Color(0xFF1E1E1E),
                title: const Text('Rename Playlist', style: TextStyle(color: Colors.white)),
                content: TextField(
                    controller: textController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        hintText: "Enter playlist title",
                        hintStyle: TextStyle(color: Colors.white38),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                    ),
                    autofocus: true,
                ),
                actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                    ),
                    ElevatedButton(
                        onPressed: () async {
                            final newTitle = textController.text.trim();
                            if (newTitle.isNotEmpty && newTitle != playlist.title) {
                                final success = await context.read<PlaylistController>().renamePlaylist(playlist.id, newTitle);
                                if (success && dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                                }
                            } else {
                                Navigator.pop(dialogContext);
                            }
                        },
                            child: const Text('Save'),
                    )
                ],
            )
        );
    }

    void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete Playlist?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${playlist.title}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          TextButton(
            onPressed: () async {
              final success = await context.read<PlaylistController>().deletePlaylist(playlist.id);
              if (success && dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}