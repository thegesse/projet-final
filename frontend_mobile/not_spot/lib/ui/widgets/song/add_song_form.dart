import 'dart:io';

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

  File? _selectAudioFile;
  String? _selectedFileName;
  bool _fileHasError = false;

  @override
  void dispose() {
    _songArtistController.dispose();
    _songTitleController.dispose();
    super.dispose();
  }

  Future<void> _pickMp3File() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) return;

    setState(() {
      _selectAudioFile = File(result.files.single.path!);
      _selectedFileName = result.files.single.name;
      _fileHasError = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final register = context.watch<SongController>();

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _songTitleController,
            decoration: const InputDecoration(labelText: 'Title'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _songArtistController,
            decoration: const InputDecoration(labelText: 'Artist'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickMp3File,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: _fileHasError ? Colors.red.shade700 : Colors.grey,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedFileName ?? 'Select audio file',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _fileHasError ? Colors.red.shade700 : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Use an audio file. Recommended filename: Artist - Title.mp3',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          if (_fileHasError)
            const Padding(
              padding: EdgeInsets.only(top: 6.0, left: 12.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Please pick an mp3 file to proceed',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ),
          const SizedBox(height: 24),
          if (register.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                register.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: register.isLoading ? null : _handleSave,
              child: register.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Save song"),
            ),
          ),
        ],
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