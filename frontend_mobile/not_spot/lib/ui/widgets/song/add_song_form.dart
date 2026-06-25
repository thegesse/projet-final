import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../features/songs/models/requests/add_song_request.dart';
import '../../../features/songs/state/song_controller.dart';

class AddSongForm extends StatefulWidget {
  const AddSongForm({super.key});

  @override
  State<AddSongForm> createState() => _AddSongFormState();
}

class _AddSongFormState extends State<AddSongForm> {
  final _formKey = GlobalKey<FormState>();
  final _songTitleController = TextEditingController();
  final _songArtistController = TextEditingController();

  PlatformFile? _selectAudioFile;
  String? _selectedFileName;
  bool _fileHasError = false;

  @override
  void dispose() {
    _songArtistController.dispose();
    _songTitleController.dispose();
    super.dispose();
  }

  Future<void> _pickMp3File() async {
    // FIXED: Swapped outdated pickFiles call for modern platform accessor
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
      allowMultiple: false,
      withData: true,
    );

    if (result == null) return;

    setState(() {
      _selectAudioFile = result.files.single;
      _selectedFileName = result.files.single.name;
      _fileHasError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final register = context.watch<SongController>();

    // FORCE DARK THEME ON ACCENT ELEMENTS AND TEXT ENTRY FIELDS
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: const ColorScheme.dark(
          primary: Colors.purpleAccent,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- SONG TITLE FIELD ---
            TextFormField(
              controller: _songTitleController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: _buildInputDecoration(
                label: 'Title',
                icon: Icons.title_rounded,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // --- SONG ARTIST FIELD ---
            TextFormField(
              controller: _songArtistController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: _buildInputDecoration(
                label: 'Artist',
                icon: Icons.person_outline_rounded,
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            // --- FILE PICKER SELECTION BUTTON DECK ---
            InkWell(
              onTap: _pickMp3File,
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  color: _selectAudioFile != null
                      ? Colors.purple.withOpacity(0.05)
                      : Colors.black.withOpacity(0.15),
                  border: Border.all(
                    color: _fileHasError
                        ? Colors.redAccent
                        : (_selectAudioFile != null
                            ? Colors.purpleAccent.withOpacity(0.4)
                            : Colors.white.withOpacity(0.06)),
                    width: _selectAudioFile != null ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _fileHasError
                            ? Colors.red.withOpacity(0.1)
                            : (_selectAudioFile != null
                                ? Colors.purple.withOpacity(0.2)
                                : Colors.white.withOpacity(0.05)),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _selectAudioFile != null
                            ? Icons.audiotrack_rounded
                            : Icons.cloud_upload_outlined,
                        color: _fileHasError
                            ? Colors.redAccent
                            : (_selectAudioFile != null
                                ? Colors.purpleAccent
                                : Colors.white38),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFileName ?? 'Select audio file',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _fileHasError
                                  ? Colors.redAccent
                                  : Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Supported format: MP3 format audio track assets.',
                            style:
                                TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_fileHasError)
              const Padding(
                padding: EdgeInsets.only(top: 8.0, left: 12.0),
                child: Text(
                  'Please pick an mp3 file to proceed',
                  style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ),
            const SizedBox(height: 24),

            if (register.uploadError != null || register.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  register.uploadError ?? register.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),

            // --- SAVE SONG SUBMIT ELEVATED BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.purple.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                onPressed: register.isUploading ? null : _handleSave,
                child: register.isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Save Song"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // REUSABLE FIELD INPUT STYLING CONFIGURATOR METADATA
  InputDecoration _buildInputDecoration(
      {required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.white38, size: 20),
      filled: true,
      fillColor: Colors.black.withOpacity(0.15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.purpleAccent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  void _handleSave() async {
    final formValid = _formKey.currentState!.validate();
    if (_selectAudioFile == null) {
      setState(() => _fileHasError = true);
    }

    if (formValid && _selectAudioFile != null) {
      final success = await context.read<SongController>().addSong(
            request: AddSongRequest(
              title: _songTitleController.text.trim(),
              artist: _songArtistController.text.trim(),
            ),
            audiofile: _selectAudioFile!,
          );

      if (success && mounted) {
        context.go('/home');
      }
    }
  }
}
