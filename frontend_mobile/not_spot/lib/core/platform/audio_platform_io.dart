import 'dart:io';

import 'package:just_audio_background/just_audio_background.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';

//check for what platforms
Future<void> initializePlatformAudio() async {
  if (Platform.isLinux) {
    JustAudioMediaKit.ensureInitialized();
  } else if (Platform.isAndroid || Platform.isIOS) {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.notspot.app.channel.audio',
      androidNotificationChannelName: 'NotSpot Playback',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: true,
    );
  }
}
