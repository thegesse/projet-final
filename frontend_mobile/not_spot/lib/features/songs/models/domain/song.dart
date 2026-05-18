import "../dto/song_dto.dart";

class Song {
  final int id;
  final String title;
  final String artist;
  final String streamUrl;

  const Song(
      {required this.id,
      required this.title,
      required this.artist,
      required this.streamUrl});

  factory Song.fromDTO(SongDTO dto) {
    return Song(
      id: dto.id,
      title: dto.title,
      artist: dto.artist,
      streamUrl: dto.streamUrl,
    );
  }
}
