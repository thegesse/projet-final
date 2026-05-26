import 'package:flutter/material.dart';
import 'package:not_spot/features/auth/state/auth_controller.dart';
import '../models/domain/playlist.dart';
import 'package:not_spot/features/playlist/models/requests/remove_song_from_playlist_request.dart';
import 'package:not_spot/features/playlist/models/requests/rename_playlist_request.dart';
import '../models/requests/add_song_to_playlist_request.dart';
import '../models/requests/create_playlist_request.dart';
import '../data/playlist_api.dart';
import '../../songs/models/domain/song.dart';

class PlaylistController extends ChangeNotifier {
  final PlaylistApi _playlistApi;

  PlaylistController(AuthController authController)
      : _playlistApi = PlaylistApi(authController);

  List<Playlist> _playlists = [];
  Playlist? _currentPlaylist;

  bool _isLoading = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;

  String? _errorMessage;
  String? _createError;
  String? _updateError;
  String? _deleteError;

  List<Playlist> get playlists => _playlists;
  Playlist? get currentPlaylist => _currentPlaylist;

  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;

  String? get errorMessage => _errorMessage;
  String? get createError => _createError;
  String? get updateError => _updateError;
  String? get deleteError => _deleteError;

  bool get hasCurrentPlaylist => _currentPlaylist != null;

  Future<void> fetchPlaylists() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _playlists = await _playlistApi.getPlaylists();
    } catch (e) {
      _errorMessage = 'Failed to load playlists $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectPlaylist(int playlistId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPlaylist = await _playlistApi.getPlaylist(playlistId);
    } catch (e) {
      _errorMessage = 'failed to load playlist $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPlaylist(String title) async {
    _isCreating = true;
    _createError = null;
    notifyListeners();

    try {
      final playlist = await _playlistApi.createPlaylist(
        CreatePlaylistRequest(title: title),
      );
      _playlists = [..._playlists, playlist];
      return true;
    } catch (e) {
      _createError = 'Failed to create playlist $e';
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  Future<bool> renamePlaylist(int playlistId, String title) async {
    _isUpdating = true;
    _updateError = null;
    notifyListeners();

    try {
      final renamed = await _playlistApi.renamePlaylist(
        playlistId,
        RenamePlaylistRequest(title: title),
      );
      _playlists = _playlists
          .map((playlist) => playlist.id == playlistId ? renamed : playlist)
          .toList();

      if (_currentPlaylist?.id == playlistId) {
        _currentPlaylist = renamed;
      }
      return true;
    } catch (e) {
      _updateError = 'Failed to rename playlist $e';
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<bool> deletePlaylist(int playlistId) async {
    _isDeleting = true;
    _deleteError = null;
    notifyListeners();

    try {
      await _playlistApi.deletePlaylist(playlistId);
      _playlists.removeWhere((playlist) => playlist.id == playlistId);

      if (_currentPlaylist?.id == playlistId) {
        _currentPlaylist = null;
      }
      return true;
    } catch (e) {
      _deleteError = 'Failed to delete playlist $e';
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  Future<bool> addSongToPlaylist(int playlistId, Song song) async {
    _isUpdating = true;
    _updateError = null;
    notifyListeners();

    try {
      final updated = await _playlistApi.addSongToPlaylist(
        playlistId,
        AddSongToPlaylistRequest(songId: song.id),
      );

      _currentPlaylist = updated;
      _playlists =
          _playlists.map((p) => p.id == playlistId ? updated : p).toList();
      return true;
    } catch (e) {
      _updateError = 'Failed to add song to playlist $e';
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<bool> removeSongFromPlaylist(int playlistId, Song song) async {
    _isUpdating = true;
    _updateError = null;
    notifyListeners();

    try {
      final updated = await _playlistApi.removeSongFromPlaylist(
        playlistId,
        RemoveSongFromPlaylistRequest(songId: song.id),
      );

      _currentPlaylist = updated;
      return true;
    } catch (e) {
      _updateError = 'Failed to remove song from playlist $e';
      return false;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  void clearCurrentPlaylist() {
    if (_currentPlaylist == null) return;
    _currentPlaylist = null;
    notifyListeners();
  }
}
