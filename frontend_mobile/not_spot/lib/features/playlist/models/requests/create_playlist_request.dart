class CreatePlaylistRequest {
  final String title;

  const CreatePlaylistRequest({required this.title});

  Map<String, dynamic> toJson() => {'title': title};
}
