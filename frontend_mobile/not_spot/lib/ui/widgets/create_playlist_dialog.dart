import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/playlist/state/playlist_controller.dart';

class CreatePlaylistDialog extends StatefulWidget {
  const CreatePlaylistDialog({super.key});

  @override
  State<CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<CreatePlaylistDialog> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the field when dialog opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlaylistController>(
      builder: (context, playlistController, _) {
        final isCreating = playlistController.isCreating;

        return AlertDialog(
          title: const Text('Playlist name'),
          content: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: !isCreating,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'My Playlist',
              errorText: playlistController.createError,
            ),
            onSubmitted:
                isCreating ? null : (_) => _submit(context, playlistController),
          ),
          actions: [
            TextButton(
              onPressed: isCreating ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed:
                  isCreating ? null : () => _submit(context, playlistController),
              child: isCreating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit(
    BuildContext context,
    PlaylistController playlistController,
  ) async {
    final title = _controller.text.trim();

    if (title.isEmpty) return;

    final success = await playlistController.createPlaylist(title);

    if (!context.mounted) return;

    if (success) {
      Navigator.pop(context);
    }
  }
}
