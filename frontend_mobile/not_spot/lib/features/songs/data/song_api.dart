import 'dart:io';
// ZA WARUDOOO TIME STOOP
import 'package:dio/dio.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../models/domain/song.dart';
import '../models/dto/song_dto.dart';
import '../models/requests/add_song_request.dart';

class SongApi {
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

  Future<Song> addSong(AddSongRequest request, File songFile) async {
    final dio = Dio();

    final formData = FormData.fromMap({
      'title': request.title,
      'artist': request.artist,
      'file': await MultipartFile.fromFile(songFile.path,
          filename: songFile.path.split('/').last),
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
