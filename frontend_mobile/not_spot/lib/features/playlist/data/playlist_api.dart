import 'package:not_spot/features/playlist/models/requests/remove_song_from_playlist_request.dart';
import 'package:not_spot/features/playlist/models/requests/rename_playlist_request.dart';

import '../../../features/auth/state/auth_controller.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../models/domain/playlist.dart';
import '../models/dto/playlist_dto.dart';
import '../models/dto/short_playlist_dto.dart';
import '../models/requests/add_song_to_playlist_request.dart';
import '../models/requests/create_playlist_request.dart';

class PlaylistApi {
  final AuthController authController;
  PlaylistApi(this.authController);

  Future<List<Playlist>> getPlaylists() async {
    final user = authController.currentUser;
    if (user == null) throw 'Not authenticated';

    final response =
        await ApiClient.get(AppConfig.playlistsUri(username: user.username));

    final list = response as List<dynamic>;
    return list
        .map((e) => ShortPlaylistDTO.fromJson(e as Map<String, dynamic>))
        .map(Playlist.fromShortDTO)
        .toList();
  }

  Future<Playlist> getPlaylist(int playlistId) async {
    final user = authController.currentUser;
    if (user == null) throw 'Not authenticated';

    final response = await ApiClient.get(
      AppConfig.playlistUri(playlistId: playlistId, username: user.username),
    );

    final dto = PlaylistDTO.fromJson(response as Map<String, dynamic>);
    return Playlist.fromDTO(dto);
  }

  Future<Playlist> createPlaylist(CreatePlaylistRequest request) async {
    final user = authController.currentUser;
    if (user == null) throw 'Not authenticated';

    final response = await ApiClient.post(
      AppConfig.createPlaylistUri(userId: user.id),
      request.toJson(),
    );

    final dto = ShortPlaylistDTO.fromJson(response as Map<String, dynamic>);
    return Playlist.fromShortDTO(dto);
  }

  Future<Playlist> addSongToPlaylist(
    int playlistId,
    AddSongToPlaylistRequest request,
  ) async {
    final user = authController.currentUser;
    if (user == null) throw 'Not authenticated';

    final response = await ApiClient.post(
      AppConfig.playlistSongUri(
        playlistId: playlistId,
        username: user.username,
      ),
      request.toJson(),
    );

    final dto = PlaylistDTO.fromJson(response as Map<String, dynamic>);
    return Playlist.fromDTO(dto);
  }

  Future<Playlist> removeSongFromPlaylist(
    int playlistId,
    RemoveSongFromPlaylistRequest request,
  ) async {
    final user = authController.currentUser;
    if (user == null) throw 'Not authenticated';

    final response = await ApiClient.delete(
      AppConfig.playlistSongUri(
        playlistId: playlistId,
        username: user.username,
      ),
      body: request.toJson(),
    );

    final dto = PlaylistDTO.fromJson(response as Map<String, dynamic>);
    return Playlist.fromDTO(dto);
  }

  Future<Playlist> renamePlaylist(
    int playlistId,
    RenamePlaylistRequest request,
  ) async {
    final user = authController.currentUser;
    if (user == null) throw 'Not authenticated';

    final response = await ApiClient.patch(
      AppConfig.playlistUri(
        playlistId: playlistId,
        username: user.username,
      ),
      request.toJson(),
    );

    final dto = ShortPlaylistDTO.fromJson(response as Map<String, dynamic>);
    return Playlist.fromShortDTO(dto);
  }

  Future<void> deletePlaylist(int playlistId) async {
    final user = authController.currentUser;
    if (user == null) throw 'Not authenticated';

    await ApiClient.delete(
      AppConfig.playlistUri(
        playlistId: playlistId,
        username: user.username,
      ),
    );
  }
}
