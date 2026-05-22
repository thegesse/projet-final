class RemoveSongFromPlaylistRequest {
  final int songId;

  const RemoveSongFromPlaylistRequest({required this.songId});

  Map<String, dynamic> toJson() => {'songId': songId};
}
