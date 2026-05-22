import 'dart:io';
import 'package:flutter/material.dart';
import '../models/domain/song.dart';
import '../models/requests/add_song_request.dart';
import '../data/song_api.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/config/app_config.dart';

class SongController extends ChangeNotifier {
  final SongApi _songService = SongApi();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Song> _songs = [];
  List<Song> _searchResults = [];
  Song? _currentSong;

  bool _isLoading = false;
  bool _isSearching = false;
  bool _isUploading = false;
  bool _isDeleting = false;

  String? _errorMessage;
  String? _uploadError;
  String? _deleteError;

  SongController() {
    _audioPlayer.playerStateStream.listen((playerState) {
      notifyListeners();
    });
  }

  List<Song> get songs => _songs;
  List<Song> get searchResults => _searchResults;
  Song? get currentSong => _currentSong;

  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isUploading => _isUploading;
  bool get isDeleting => _isDeleting;
  bool get isPlaying => _audioPlayer.playing;

  String? get errorMessage => _errorMessage;
  String? get uploadError => _uploadError;
  String? get deleteError => _deleteError;

  bool get hasActiveSong => _currentSong != null;

  Future<void> fetchSongs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _songs = await _songService.getSongs();
    } catch (e) {
      _errorMessage = "Failed to load music catalogue: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchSongs(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _songService.searchSong(query.trim());
    } catch (e) {
      _errorMessage = "Couldn't find songs: $e";
      _searchResults = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<bool> addSong({
    required AddSongRequest request,
    required File audiofile,
  }) async {
    _isUploading = true;
    _uploadError = null;
    notifyListeners();

    try {
      final Song newSong = await _songService.addSong(request, audiofile);
      _songs = [..._songs, newSong];
      return true;
    } catch (e) {
      _uploadError = "Failed to upload song: $e";
      return false;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSong(int songId) async {
    _isDeleting = true;
    _deleteError = null;
    notifyListeners();

    try {
      await _songService.deleteSong(songId);
      _songs.removeWhere((song) => song.id == songId);

      if (_currentSong?.id == songId) {
        await _audioPlayer.stop();
        _currentSong = null;
      }
    } catch (e) {
      _deleteError = "Failed to delete this song: $e";
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  Future<void> selectSong(Song song) async {
    _currentSong = song;
    _errorMessage = null;
    notifyListeners();

    try {
      await _audioPlayer.setUrl('${AppConfig.origin}${song.streamUrl}');
      await _audioPlayer.play();
    } catch (e) {
      _errorMessage = "couldn't play song $e";
      notifyListeners();
    }
  }

  Future<void> togglePlayPause() async {
    if (!hasActiveSong) return;

    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
