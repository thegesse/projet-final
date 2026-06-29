class RenamePlaylistRequest {
  final String title;

  const RenamePlaylistRequest({required this.title});

  Map<String, dynamic> toJson() => {'title': title};
}
