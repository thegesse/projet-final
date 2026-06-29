import 'package:not_spot/features/songs/models/dto/song_dto.dart';

class PlaylistDTO {
  final int id;
  final String title;
  final List<SongDTO> songs;

  const PlaylistDTO({
    required this.id,
    required this.title,
    required this.songs,
  });

  factory PlaylistDTO.fromJson(Map<String, dynamic> json) {
    final songsJson = (json['songs'] as List<dynamic>? ?? const []);
    return PlaylistDTO(
      id: json['id'] as int,
      title: json['title'] as String,
      songs: songsJson
          .map((e) => SongDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
