import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../../songs/state/song_controller.dart';

class RadioController extends ChangeNotifier {
  SongController _songController;

  final Map<String, String> stations = {
    'Lofi Cafe Chilling':
        'https://radio.loficafe.net/listen/chilling/radio.mp3',
    'Hotmix Lofi France':
        'https://streaming.hotmixradio.com/hotmix-lofi-en-mp3',
    'LITT Live Instrumental': 'https://das-sa39.cdnstream1.com/5582_128',
    'LautFM Lofi HipHop': 'https://lofi.stream.laut.fm/lofi',
  };

  String? _currentStationName;
  bool _isPlaying = false;
  bool _isDisposed = false;

  RadioController(this._songController);

  String? get currentStationName => _currentStationName;
  bool get isPlaying => _isPlaying;
  List<String> get stationNames => stations.keys.toList();

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
      WidgetsBinding.instance.ensureVisualUpdate();
    }
  }

  void updateSongController(SongController songController) {
    if (identical(_songController, songController)) return;

    _songController = songController;
    _isPlaying = false;
    _currentStationName = null;
    notifyListeners();
  }

  Future<void> playStation(String name) async {
    final url = stations[name];
    if (url == null) return;

    try {
      _currentStationName = name;
      _isPlaying = true;
      notifyListeners();

      final audioSource = AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: url,
          album: "Live Radio",
          title: name,
          artUri: Uri.parse(
            "https://radio.loficafe.net/static/images/logo.png",
          ),
        ),
      );

      await _songController.playExternalAudioSource(audioSource);
    } catch (e) {
      debugPrint("Error loading radio stream: $e");
      _isPlaying = false;
      _currentStationName = null;
      notifyListeners();
    }
  }

  Future<void> playLocalTrack(String name, String urlOrFilePath) async {
    try {
      _currentStationName = name;
      _isPlaying = true;
      notifyListeners();

      AudioSource source;
      if (urlOrFilePath.startsWith('http')) {
        source = AudioSource.uri(
          Uri.parse(urlOrFilePath),
          tag: MediaItem(id: urlOrFilePath, album: "Library", title: name),
        );
      } else {
        source = AudioSource.file(
          urlOrFilePath,
          tag: MediaItem(id: urlOrFilePath, album: "Local Files", title: name),
        );
      }

      await _songController.playExternalAudioSource(source);
    } catch (e) {
      debugPrint("Error playing library track: $e");
      _isPlaying = false;
      notifyListeners();
    }
  }

  void stopRadio() {
    _isPlaying = false;
    _currentStationName = null;
    notifyListeners();
    Future<void>.delayed(Duration.zero, notifyListeners);

    unawaited(
      _songController.stopExternalAudio().catchError((error) {
        debugPrint("Error stopping radio stream: $error");
      }),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
