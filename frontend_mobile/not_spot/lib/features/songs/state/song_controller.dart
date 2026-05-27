import 'dart:io';
import 'package:flutter/material.dart';
import '../models/domain/song.dart';
import '../models/requests/add_song_request.dart';
import '../data/song_api.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/config/app_config.dart';
import 'package:just_audio_background/just_audio_background.dart';

class SongController extends ChangeNotifier {
  final SongApi _songService = SongApi();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Song> _songs = [];
  List<Song> _searchResults = [];
  Song? _currentSong;

  // Track the active play session queue and index
  List<Song> _activeQueue = [];
  int _queueIndex = -1;
  bool _shuffleEnabled = false;

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

      if (playerState.processingState == ProcessingState.completed) {
        _handleSongComplete();
      }
    });

    // Native index changes from notification skips will update our current song selection
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null &&
          _activeQueue.isNotEmpty &&
          index < _activeQueue.length) {
        _queueIndex = index;
        _currentSong = _activeQueue[index];
        notifyListeners();
      }
    });
  }

  void _handleSongComplete() {
    if (_activeQueue.isNotEmpty) {
      playNext();
    }
  }

  List<Song> get songs => _songs;
  List<Song> get searchResults => _searchResults;
  Song? get currentSong => _currentSong;
  List<Song> get currentQueue =>
      _activeQueue; // Points to our managed active queue
  List<Song> get activeQueue => _activeQueue;
  bool get shuffleEnabled => _shuffleEnabled;

  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isUploading => _isUploading;
  bool get isDeleting => _isDeleting;
  bool get isPlaying => _audioPlayer.playing;

  String? get errorMessage => _errorMessage;
  String? get uploadError => _uploadError;
  String? get deleteError => _deleteError;

  bool get hasActiveSong => _currentSong != null;

  void setQueue(List<Song> queue, {Song? startSong}) {
    _activeQueue = List<Song>.from(queue);

    if (_activeQueue.isEmpty) {
      _queueIndex = -1;
      notifyListeners();
      return;
    }

    if (_shuffleEnabled) {
      _activeQueue.shuffle();
    }

    if (startSong != null) {
      final idx = _activeQueue.indexWhere((s) => s.id == startSong.id);
      _queueIndex = idx >= 0 ? idx : 0;
    } else {
      _queueIndex = 0;
    }

    notifyListeners();
  }

  void toggleShuffle() {
    _shuffleEnabled = !_shuffleEnabled;

    if (_activeQueue.isNotEmpty) {
      final current = _currentSong;
      _activeQueue = List<Song>.from(_activeQueue)..shuffle();
      if (current != null) {
        _queueIndex = _activeQueue.indexWhere((s) => s.id == current.id);
        if (_queueIndex < 0) _queueIndex = 0;
      } else {
        _queueIndex = 0;
      }
    }

    // Refresh the player playlist sequence in the background with the new scrambled list
    if (_currentSong != null) {
      _updatePlayerPlaylistSilently();
    }

    notifyListeners();
  }

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

  Future<void> selectSong(Song song, {List<Song>? queue}) async {
    if (queue != null) {
      setQueue(queue, startSong: song);
    } else if (_activeQueue.isEmpty) {
      setQueue(_songs, startSong: song);
    } else {
      final idx = _activeQueue.indexWhere((s) => s.id == song.id);
      _queueIndex = idx >= 0 ? idx : 0;
    }

    _currentSong = song;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Fully stop any lingering native instances
      await _audioPlayer.stop();

      final streamUrlString = '${AppConfig.origin}${song.streamUrl}';

      if (Platform.isLinux) {
        // FIX FOR LINUX: Avoid AudioSource completely. 
        // Pass the raw string URL straight into the player engine.
        await _audioPlayer.setUrl(streamUrlString);
      } else {
        // Mobile platform remains completely unaffected with its robust background features
        final playlist = ConcatenatingAudioSource(
          children: _activeQueue.map((s) {
            return AudioSource.uri(
              Uri.parse('${AppConfig.origin}${s.streamUrl}'),
              tag: MediaItem(
                id: s.id.toString(),
                title: s.title,
                artist: s.artist,
              ),
            );
          }).toList(),
        );

        await _audioPlayer.setAudioSource(
          playlist,
          initialIndex: _queueIndex,
          initialPosition: Duration.zero,
        );
      }

      // 2. Play the stream safely
      await _audioPlayer.play();
    } catch (e) {
      _errorMessage = "couldn't play song $e";
      notifyListeners();
    }
  }

  // Updates the native audio source background array to synchronize shuffle states
  // cleanly without interrupting the currently playing audio track stream
  Future<void> _updatePlayerPlaylistSilently() async {
    if (Platform.isLinux) return; // Skip playlist updates on Linux entirely
    try {
      final playlist = ConcatenatingAudioSource(
        children: _activeQueue.map((s) {
          return AudioSource.uri(
            Uri.parse('${AppConfig.origin}${s.streamUrl}'),
            tag: MediaItem(
              id: s.id.toString(),
              title: s.title,
              artist: s.artist,
            ),
          );
        }).toList(),
      );

      await _audioPlayer.setAudioSource(
        playlist,
        initialIndex: _queueIndex,
        initialPosition: _audioPlayer.position,
      );
    } catch (_) {}
  }

  Future<void> togglePlayPause() async {
    if (!hasActiveSong) return;

    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  Future<void> playNext() async {
    if (_activeQueue.isEmpty) return;

    if (_queueIndex < 0) _queueIndex = 0;

    // Natively skip using the platform engine if a next track exists in our timeline container
    if (_audioPlayer.hasNext) {
      await _audioPlayer.seekToNext();
    } else {
      // Loop back to the very first song if we are at the end of the playlist
      _queueIndex = (_queueIndex + 1) % _activeQueue.length;
      await _audioPlayer.seek(Duration.zero, index: _queueIndex);
    }
  }

  Future<void> playPrevious() async {
    if (_activeQueue.isEmpty) return;

    if (_queueIndex < 0) _queueIndex = 0;

    // Natively skip back using the platform engine if a previous track exists
    if (_audioPlayer.hasPrevious) {
      await _audioPlayer.seekToPrevious();
    } else {
      // Loop around to the last song if we press back on the first track
      _queueIndex =
          (_queueIndex - 1) < 0 ? _activeQueue.length - 1 : _queueIndex - 1;
      await _audioPlayer.seek(Duration.zero, index: _queueIndex);
    }
  }

  //because song wont stop playing once I logout
  Future<void> stopAndClear() async {
    await _audioPlayer.stop();
    await _audioPlayer.setAudioSource(ConcatenatingAudioSource(children: []));

    _currentSong = null;
    _activeQueue = [];
    _searchResults = [];
    _queueIndex = -1;

    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
