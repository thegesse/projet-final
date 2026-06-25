// ZA WARUDOOO TIME STOOP
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../models/domain/song.dart';
import '../models/dto/song_dto.dart';
import '../models/requests/add_song_request.dart';
import '../../auth/state/auth_controller.dart';

class SongApi {
  final AuthController? authController;

  SongApi([this.authController]);

  Future<List<Song>> getSongs() async {
    final response = await ApiClient.get(AppConfig.songsUri());

    return (response as List)
        .map((json) => Song.fromDTO(SongDTO.fromJson(json)))
        .toList();
  }

  Future<Song> getSong(int songId) async {
    final response = await ApiClient.get(AppConfig.songUri(songId));
    return Song.fromDTO(SongDTO.fromJson(response));
  }

  Future<List<Song>> searchSong(String query) async {
    final response = await ApiClient.get(AppConfig.searchSongsUri(query));

    return (response as List)
        .map((json) => Song.fromDTO(SongDTO.fromJson(json)))
        .toList();
  }

  Future<bool> checkIsSongLiked(int songId, {required String username}) async {
    final uri = AppConfig.isSongLikedUri(songId, username: username);
    final response = await ApiClient.get(uri);

    if (response != null && response['isLiked'] != null) {
      return response['isLiked'] as bool;
    }
    return false;
  }

  int _extractLikedPlaylistId(List<dynamic> playlists) {
    final likedPlaylist = playlists.cast<Map<String, dynamic>>().firstWhere(
          (p) =>
              (p['title'] == 'Liked Songs' || p['title'] == 'Liked') ||
              (p['name'] == 'Liked Songs' || p['name'] == 'Liked') ||
              p['isLikedSystemPlaylist'] == true,
          orElse: () => {},
        );

    final playlistId = likedPlaylist['id'];
    if (playlistId == null) throw 'Liked playlist not found';

    return playlistId as int;
  }

  Future<bool> addSongToLiked(int songId) async {
    final user = authController?.currentUser;
    if (user == null) throw 'Not authenticated';

    final playlistsResponse = await ApiClient.get(
      AppConfig.playlistsUri(username: user.username),
    );

    final int likedPlaylistId = _extractLikedPlaylistId(
      playlistsResponse as List<dynamic>,
    );

    final response = await ApiClient.post(
      AppConfig.playlistSongUri(
        playlistId: likedPlaylistId,
        username: user.username,
      ),
      {'songId': songId},
    );

    return response != null;
  }

  Future<bool> removeSongFromLiked(int songId) async {
    final user = authController?.currentUser;
    if (user == null) throw 'Not authenticated';

    final playlistsResponse = await ApiClient.get(
      AppConfig.playlistsUri(username: user.username),
    );

    final int likedPlaylistId = _extractLikedPlaylistId(
      playlistsResponse as List<dynamic>,
    );

    final response = await ApiClient.delete(
      AppConfig.playlistSongUri(
        playlistId: likedPlaylistId,
        username: user.username,
      ),
      body: {'songId': songId},
    );

    return response != null;
  }

  Future<Song> addSong(AddSongRequest request, PlatformFile songFile) async {
    final dio = Dio();
    final MultipartFile multipartFile;

    if (songFile.bytes != null) {
      multipartFile = MultipartFile.fromBytes(
        songFile.bytes!,
        filename: songFile.name,
      );
    } else if (songFile.path != null) {
      multipartFile = await MultipartFile.fromFile(
        songFile.path!,
        filename: songFile.name,
      );
    } else {
      throw 'Selected file could not be read';
    }

    final formData = FormData.fromMap({
      'title': request.title,
      'artist': request.artist,
      'file': multipartFile,
    });

    final response = await dio.post(AppConfig.songsUri().toString(),
        data: formData,
        options: Options(headers: {'Accept': 'application/json'}));

    return Song.fromDTO(SongDTO.fromJson(response.data));
  }

  Future<void> deleteSong(int songId) async {
    await ApiClient.delete(AppConfig.songUri(songId));
  }
}
