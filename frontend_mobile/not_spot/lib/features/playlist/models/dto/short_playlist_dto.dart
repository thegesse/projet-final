class ShortPlaylistDTO {
  final int id;
  final String title;

  const ShortPlaylistDTO({
    required this.id,
    required this.title,
  });

  factory ShortPlaylistDTO.fromJson(Map<String, dynamic> json) {
    return ShortPlaylistDTO(
      id: json['id'] as int,
      title: json['title'] as String,
    );
  }
}
