class SongDTO {
  final int id;
  final String title;
  final String artist;
  final String streamUrl;

  const SongDTO({
    required this.id,
    required this.title,
    required this.artist,
    required this.streamUrl,
  });
  factory SongDTO.fromJson(Map<String, dynamic> json) {
    return SongDTO(
        id: json['id'] as int,
        title: json['title'] as String,
        artist: json['artist'] as String,
        streamUrl: json['streamUrl'] as String);
  }
}
