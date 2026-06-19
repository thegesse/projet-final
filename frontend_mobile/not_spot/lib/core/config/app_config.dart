class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    //only touch this to change the export case, then replace with domain url in prod
    defaultValue: 'https://notspot.kaillou.de',
  );
  static Uri get baseUri => Uri.parse(baseUrl);

  static String get origin {
    final port = baseUri.hasPort ? ':${baseUri.port}' : '';
    return '${baseUri.scheme}://${baseUri.host}$port';
  }

  static const String authPath = '/auth';
  static const String loginPath = '$authPath/login';
  static const String registerPath = '$authPath/register';

  static const String songsPath = '/songs';
  static const String playlistsPath = '/playlists';
  static const String settingsPath = '/settings';

  static Uri uri(String path, [Map<String, dynamic>? queryParameters]) {
    return Uri.parse('$baseUrl$path').replace(
      queryParameters:
          queryParameters?.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  static Uri loginUri() => uri(loginPath);
  static Uri registerUri() => uri(registerPath);
  static Uri songsUri() => uri(songsPath);
  static Uri songUri(int songId) => uri('$songsPath/$songId');
  static Uri songStreamUri(int songId) => uri('$songsPath/$songId/stream');
  static Uri searchSongsUri(String query) =>
      uri('$songsPath/search', {'query': query});
  static Uri createPlaylistUri({required int userId}) =>
      uri(playlistsPath, {'userId': userId});
  static Uri playlistsUri({required String username}) =>
      uri(playlistsPath, {'username': username});
  static Uri playlistUri({
    required int playlistId,
    required String username,
  }) =>
      uri('$playlistsPath/$playlistId', {'username': username});
  static Uri playlistSongUri({
    required int playlistId,
    required String username,
  }) =>
      uri('$playlistsPath/$playlistId/song', {'username': username});

  static Uri changeUsernameUri({required int userId}) =>
      uri('$settingsPath/users/$userId/username');

  static Uri changePasswordUri({required int userId}) =>
      uri('$settingsPath/users/$userId/password');

  static Uri deleteAccountUri({required int userId}) =>
      uri('$settingsPath/users/$userId');

  static Uri likedPlaylistSongUri({required int likedPlaylistId, required String username}) => 
      uri('$playlistsPath/$likedPlaylistId/song', {'username': username});
static Uri isSongLikedUri(int songId, {required String username}) => 
    uri('$songsPath/$songId/isLiked', {'username': username});}
