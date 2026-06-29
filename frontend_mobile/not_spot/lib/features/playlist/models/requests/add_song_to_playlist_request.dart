class AddSongToPlaylistRequest {
  final int songId;

  const AddSongToPlaylistRequest({required this.songId});

  Map<String, dynamic> toJson() => {'songId': songId};
}
