import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/domain/song.dart';
import '../models/requests/add_song_request.dart';
import '../data/song_api.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/config/app_config.dart';
import '../../auth/state/auth_controller.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';

class SongController extends ChangeNotifier {
  final SongApi _songService;
  late AudioPlayer _audioPlayer;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<int?>? _currentIndexSubscription;
  final AuthController authController;
  final bool authStateAtCreation;
  Future<void> _audioOperation = Future.value();
  bool _isDisposed = false;

  final Map<int, bool> _likedSongsCache = {};

  bool isSongLiked(int songId) => _likedSongsCache[songId] ?? false;

  List<Song> _songs = [];
  List<Song> _searchResults = [];
  Song? _currentSong;

  // Track the active play session queue and index
  List<Song> _activeQueue = [];
  // Preserve original queue order when shuffle is enabled so we can restore it
  List<Song>? _originalQueue;
  int _queueIndex = -1;
  bool _shuffleEnabled = false;
  bool _isNavigating = false;

  bool _isLoading = false;
  bool _isSearching = false;
  bool _isUploading = false;
  bool _isDeleting = false;
  bool _isCurrentSongLiked = false;

  String? _errorMessage;
  String? _uploadError;
  String? _deleteError;

  SongController({required this.authController})
      : _songService = SongApi(authController),
        authStateAtCreation = authController.isAuthenticated {
    _initializeAudioPlayer();
    authController.addListener(_handleAuthChange);
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
  AudioPlayer get audioPlayer => _audioPlayer;

  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get isUploading => _isUploading;
  bool get isDeleting => _isDeleting;
  bool get isPlaying => _audioPlayer.playing;
  bool get isShuffling => _shuffleEnabled;
  bool get isCurrentSongLiked => _isCurrentSongLiked;

  String? get errorMessage => _errorMessage;
  String? get uploadError => _uploadError;
  String? get deleteError => _deleteError;

  bool get hasActiveSong => _currentSong != null;

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
      WidgetsBinding.instance.ensureVisualUpdate();
    }
  }

  Future<void> _runAudioOperation(Future<void> Function() operation) {
    _audioOperation = _audioOperation.catchError((_) {}).then((_) async {
      if (_isDisposed) return;
      await operation();
    });

    return _audioOperation;
  }

  void setQueue(List<Song> queue, {Song? startSong}) {
    // Always store the original (ordered) queue so we can restore it when
    // shuffle is turned off. The active queue is a working copy that may be
    // shuffled.
    _originalQueue = List<Song>.from(queue);

    if (_shuffleEnabled) {
      _activeQueue = List<Song>.from(_originalQueue!)..shuffle();
    } else {
      _activeQueue = List<Song>.from(_originalQueue!);
    }

    if (_activeQueue.isEmpty) {
      _queueIndex = -1;
      notifyListeners();
      return;
    }

    if (startSong != null) {
      final idx = _activeQueue.indexWhere((s) => s.id == startSong.id);
      _queueIndex = idx >= 0 ? idx : 0;
    } else {
      _queueIndex = 0;
    }

    notifyListeners();
  }

  Future<void> toggleShuffle() async {
    _shuffleEnabled = !_shuffleEnabled;

    if (_activeQueue.isNotEmpty) {
      final current = _currentSong;

      if (_shuffleEnabled) {
        // Enabling shuffle: preserve the current ordered queue and then
        // shuffle the active queue.
        _originalQueue = List<Song>.from(_activeQueue);
        _activeQueue = List<Song>.from(_activeQueue)..shuffle();
      } else {
        // Disabling shuffle: restore the preserved original order when
        // possible. Keep the current song selected.
        if (_originalQueue != null) {
          final currentId = current?.id;
          _activeQueue = List<Song>.from(_originalQueue!);
          if (currentId != null) {
            _queueIndex = _activeQueue.indexWhere((s) => s.id == currentId);
            if (_queueIndex < 0) _queueIndex = 0;
          } else {
            _queueIndex = 0;
          }
          _originalQueue = null;
        } else {
          // Fallback: if we don't have an original queue, attempt to order
          // by the global `_songs` ordering.
          _activeQueue.sort((a, b) {
            final ai = _songs.indexWhere((s) => s.id == a.id);
            final bi = _songs.indexWhere((s) => s.id == b.id);
            return ai.compareTo(bi);
          });
          if (current != null) {
            _queueIndex = _activeQueue.indexWhere((s) => s.id == current.id);
            if (_queueIndex < 0) _queueIndex = 0;
          }
        }
      }

      final currentId = current?.id;
      if (currentId != null) {
        final currentIndex = _activeQueue.indexWhere((s) => s.id == currentId);
        if (currentIndex >= 0) _queueIndex = currentIndex;
      }
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

  void setLocalLikedStatus(bool liked) {
    _isCurrentSongLiked = liked;
    if (_currentSong != null) {
      _likedSongsCache[_currentSong!.id] = liked;
    }
    notifyListeners();
  }

  void updateSongLikedCache(int songId, bool liked) {
    _likedSongsCache[songId] = liked;
    if (_currentSong?.id == songId) {
      _isCurrentSongLiked = liked;
    }
    notifyListeners();
  }

  Future<bool> addSong({
    required AddSongRequest request,
    required PlatformFile audiofile,
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

    _setCurrentSongAtIndex(_queueIndex);

    try {
      if (kIsWeb) {
        await _playWebSongAtIndex(_queueIndex);
      } else {
        await _playNativeQueueAtIndex(_queueIndex);
      }
    } catch (e) {
      _errorMessage = "couldn't play song $e";
      notifyListeners();
    }
  }

  Future<void> setSongLikedStatus(int songId, bool liked) async {
    try {
      if (liked) {
        await _songService.addSongToLiked(songId);
      } else {
        await _songService.removeSongFromLiked(songId);
      }
      _isCurrentSongLiked = liked;
      _likedSongsCache[songId] = liked;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Failed to update liked status: $e";
      notifyListeners();
    }
  }

  Future<void> fetchLikedStatus(int songId) async {
    // 1. Safely grab the current username from your AuthController
    final currentUsername = authController.username;

    if (currentUsername == null) {
      debugPrint("Cannot check liked status: User is not logged in.");
      return;
    }

    try {
      // 2. Pass the dynamic username cleanly down to the API layer
      final isLiked = await _songService.checkIsSongLiked(
        songId,
        username: currentUsername,
      );

      _likedSongsCache[songId] = isLiked;
      notifyListeners();
    } catch (e) {
      debugPrint("Error fetching liked status: $e");
    }
  }

  Future<void> togglePlayPause() async {
    if (!hasActiveSong) return;

    await _runAudioOperation(() async {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      } else {
        _startPlayback();
      }
    });
    notifyListeners();
  }

  //for radio sicne player is shared now
  Future<void> playExternalAudioSource(
    AudioSource source, {
    bool preload = false,
  }) async {
    _currentSong = null;
    _activeQueue = [];
    _originalQueue = null;
    _queueIndex = -1;
    notifyListeners();

    await _runAudioOperation(() async {
      if (kIsWeb) {
        await _replaceAudioPlayer();
      }
      await _audioPlayer.setAudioSource(source, preload: preload);
      _startPlayback();
    });
    notifyListeners();
  }

  Future<void> stopExternalAudio() async {
    await _runAudioOperation(() => _audioPlayer.stop());
  }

  Future<void> playNext() async {
    if (_activeQueue.isEmpty || _isNavigating) return;
    _isNavigating = true;

    try {
      if (_queueIndex < 0) _queueIndex = 0;
      final currentIndex = _queueIndex;
      final nextIndex = (currentIndex + 1) % _activeQueue.length;
      _setCurrentSongAtIndex(nextIndex);

      if (kIsWeb) {
        await _playWebSongAtIndex(nextIndex);
      } else {
        await _seekNativeQueueToIndex(nextIndex);
      }
    } catch (e) {
      _errorMessage = 'Failed to skip to next song: $e';
      notifyListeners();
    } finally {
      _isNavigating = false;
      notifyListeners();
    }
  }

  Future<void> playPrevious() async {
    if (_activeQueue.isEmpty || _isNavigating) return;
    _isNavigating = true;

    try {
      if (_queueIndex < 0) _queueIndex = 0;
      final currentIndex = _queueIndex;
      final previousIndex =
          (currentIndex - 1) < 0 ? _activeQueue.length - 1 : currentIndex - 1;
      _setCurrentSongAtIndex(previousIndex);

      if (kIsWeb) {
        await _playWebSongAtIndex(previousIndex);
      } else {
        await _seekNativeQueueToIndex(previousIndex);
      }
    } catch (e) {
      _errorMessage = 'Failed to skip to previous song: $e';
      notifyListeners();
    } finally {
      _isNavigating = false;
      notifyListeners();
    }
  }

  AudioSource _audioSourceForSong(Song song) {
    final streamUri = Uri.parse(song.streamUrl);

    return AudioSource.uri(
      streamUri.hasScheme ? streamUri : AppConfig.uri(song.streamUrl),
      tag: MediaItem(
        id: song.id.toString(),
        title: song.title,
        artist: song.artist,
      ),
    );
  }

  ConcatenatingAudioSource _playlistSourceForQueue() {
    return ConcatenatingAudioSource(
      children: _activeQueue.map(_audioSourceForSong).toList(),
    );
  }

  void _setCurrentSongAtIndex(int index) {
    if (index < 0 || index >= _activeQueue.length) return;

    final song = _activeQueue[index];
    _queueIndex = index;
    _currentSong = song;
    _isCurrentSongLiked = _likedSongsCache[song.id] ?? false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _playWebSongAtIndex(int index) async {
    if (index < 0 || index >= _activeQueue.length) return;

    final song = _activeQueue[index];

    await _runAudioOperation(() async {
      await _replaceAudioPlayer();
      await _audioPlayer.setAudioSource(
        _audioSourceForSong(song),
        initialPosition: Duration.zero,
      );
      _startPlayback();
    });
  }

  Future<void> _playNativeQueueAtIndex(int index) async {
    if (index < 0 || index >= _activeQueue.length) return;

    await _runAudioOperation(() async {
      await _audioPlayer.setAudioSource(
        _playlistSourceForQueue(),
        initialIndex: index,
        initialPosition: Duration.zero,
      );
      _startPlayback();
    });
  }

  void _startPlayback() {
    unawaited(
      _audioPlayer.play().catchError((Object error) {
        _errorMessage = 'Playback failed: $error';
        notifyListeners();
      }),
    );
  }

  Future<void> _seekNativeQueueToIndex(int index) async {
    await _runAudioOperation(
      () => _audioPlayer.seek(Duration.zero, index: index),
    );
  }

  Future<void> _handleAuthChange() async {
    if (!authController.isAuthenticated) {
      await stopAndClear();
    }
  }

  void _initializeAudioPlayer() {
    _audioPlayer = AudioPlayer();
    _attachAudioPlayerListeners();
  }

  void _attachAudioPlayerListeners() {
    _playerStateSubscription =
        _audioPlayer.playerStateStream.listen((playerState) {
      notifyListeners();

      if (playerState.processingState == ProcessingState.completed) {
        _handleSongComplete();
      }
    });

    if (!kIsWeb) {
      _currentIndexSubscription =
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
  }

  Future<void> _replaceAudioPlayer() async {
    final oldPlayer = _audioPlayer;

    await _playerStateSubscription?.cancel();
    await _currentIndexSubscription?.cancel();
    _playerStateSubscription = null;
    _currentIndexSubscription = null;

    _audioPlayer = AudioPlayer();
    _attachAudioPlayerListeners();

    try {
      await oldPlayer.stop();
    } catch (_) {
      // Ignore failures while replacing the web audio element.
    }

    try {
      await oldPlayer.dispose();
    } catch (_) {
      // Ignore failures while replacing the web audio element.
    }
  }

  Future<void> _disposeAudioPlayer() async {
    await _playerStateSubscription?.cancel();
    await _currentIndexSubscription?.cancel();

    try {
      await _audioOperation.catchError((_) {});
    } catch (_) {
      // Ignore pending player failures during teardown.
    }

    try {
      await _audioPlayer.dispose();
    } catch (_) {
      // Ignore dispose failures during cleanup.
    }

    _playerStateSubscription = null;
    _currentIndexSubscription = null;
  }

  // because song wont stop playing once I logout
  Future<void> stopAndClear() async {
    try {
      await _runAudioOperation(() async {
        if (kIsWeb) {
          await _replaceAudioPlayer();
        } else {
          await _audioPlayer.stop();
          await _audioPlayer.setAudioSource(
            ConcatenatingAudioSource(children: []),
          );
        }
      });
    } catch (_) {
      // Ignore failures while cleaning up on logout.
    }

    _currentSong = null;
    _activeQueue = [];
    _originalQueue = null;
    _shuffleEnabled = false;
    _queueIndex = -1;
    _isCurrentSongLiked = false;
    _searchResults = [];
    _errorMessage = null;

    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    authController.removeListener(_handleAuthChange);
    _disposeAudioPlayer();
    super.dispose();
  }

  Stream<PositionData> get positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
        (position, bufferedPosition, duration) => PositionData(
          position,
          bufferedPosition,
          duration ?? Duration.zero,
        ),
      );
}

//helper for the progress bar
class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;

  PositionData(this.position, this.bufferedPosition, this.duration);
}
