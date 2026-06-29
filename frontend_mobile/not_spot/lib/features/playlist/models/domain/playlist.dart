import '../dto/playlist_dto.dart';
import '../dto/short_playlist_dto.dart';
import '../../../songs/models/domain/song.dart';

class Playlist {
  final int id;
  final String title;
  final List<Song> songs;

  const Playlist(
      {required this.id, required this.title, this.songs = const []});

  factory Playlist.fromShortDTO(ShortPlaylistDTO dto) {
    return Playlist(
      id: dto.id,
      title: dto.title,
    );
  }

  factory Playlist.fromDTO(PlaylistDTO dto) {
    return Playlist(
      id: dto.id,
      title: dto.title,
      songs: dto.songs.map(Song.fromDTO).toList(),
    );
  }
}
