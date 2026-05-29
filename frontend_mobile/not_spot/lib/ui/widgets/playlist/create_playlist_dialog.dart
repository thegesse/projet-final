import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/playlist/state/playlist_controller.dart';

class CreatePlaylistDialog extends StatefulWidget {
  const CreatePlaylistDialog({super.key});

  @override
  State<CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<CreatePlaylistDialog> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      // FORCE DARK THEME ON DIALOG ASSETS
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.purpleAccent,
        ),
      ),
      child: const _CreatePlaylistDialogContent(),
    );
  }
}

// Internal widget split to keep implementation clean and maintain lifecycle logic
class _CreatePlaylistDialogContent extends StatefulWidget {
  const _CreatePlaylistDialogContent();

  @override
  State<_CreatePlaylistDialogContent> createState() => __CreatePlaylistDialogContentState();
}

class __CreatePlaylistDialogContentState extends State<_CreatePlaylistDialogContent> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
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
          backgroundColor: const Color(0xFF1E1E1E), // Elevated charcoal background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            // FIXED: Using 'side' instead of 'border' to compile correctly
            side: BorderSide(
              color: Colors.white.withOpacity(0.05),
              width: 1,
            ),
          ),
          title: const Text(
            'Create Playlist',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Give your new playlist a distinctive title collection name.',
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !isCreating,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'e.g., Chill Beats',
                  hintStyle: const TextStyle(color: Colors.white24),
                  errorText: playlistController.createError,
                  errorStyle: const TextStyle(color: Colors.redAccent),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.15),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.purpleAccent, width: 1.5),
                  ),
                ),
                onSubmitted: isCreating ? null : (_) => _submit(context, playlistController),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.only(right: 16, bottom: 16, left: 16),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.white60),
              onPressed: isCreating ? null : () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.purple.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isCreating ? null : () => _submit(context, playlistController),
              child: isCreating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Create', style: TextStyle(fontWeight: FontWeight.bold)),
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