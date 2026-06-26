# NotSpot Flutter Client

Flutter client for NotSpot. It displays the music catalogue, streams songs from the backend, and manages playlists and account settings.

## Recommended Backend

For local testing of the current frontend, use this backend:

[https://github.com/thegesse/back-end-not-spot/tree/master](https://github.com/thegesse/back-end-not-spot/tree/master)

The backend included in this repository is still being reworked. It has not been fully finished or tested with the current frontend, and the frontend has not yet been adapted to all of its API differences.

## Run Locally

Start the recommended backend first, following its own setup instructions.

Then run the Flutter app from this directory:

```sh
flutter pub get
flutter run
```

For the web version:

```sh
flutter run -d chrome --web-port 3000
```

If the backend is not running on the default URL configured in `lib/core/config/app_config.dart`, override it at run/build time:

```sh
flutter run -d chrome --web-port 3000 --dart-define=API_BASE_URL=http://localhost:8080
```

## CORS for Flutter Web

Yes, CORS is required when running with Chrome. The web frontend is served from an origin such as `http://localhost:3000`, while the backend usually runs on another origin such as `http://localhost:8080`.

Use a fixed Flutter web port that the backend allows:

```sh
flutter run -d chrome --web-port 3000 --dart-define=API_BASE_URL=http://localhost:8080
```

If you use a different Flutter web port, add that origin to the backend CORS allow-list. In this repository's backend, the CORS configuration is in:

```text
../../backend/notSpot/src/main/java/com/goose/notspot/configuration/SecurityConfig.java
```

The local backend already allows `http://localhost:3000`.

## Audio Playback

Song playback is centralized in:

```text
lib/features/songs/state/song_controller.dart
```

Important implementation notes:

- Audio operations are serialized so pause, skip, stop, and source changes do not race each other.
- Do not `await AudioPlayer.play()` inside that serialized queue. On Flutter web, `play()` can stay pending while audio is playing, which blocks later commands like pause and skip.
- Start playback with a non-blocking call, currently wrapped by `_startPlayback()`.
- Web uses a fresh `AudioPlayer` when changing songs to avoid a browser audio element staying attached to the previous stream.
- Mobile and Linux keep the native playlist behavior through `ConcatenatingAudioSource`.

If pause or skip stops responding on web while stream requests still return HTTP 200, check for a blocking `await _audioPlayer.play()` first.
