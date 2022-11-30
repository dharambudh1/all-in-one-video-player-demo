import 'package:just_audio/just_audio.dart';

class SoundSingleton {
  static final SoundSingleton _singleton = SoundSingleton._internal();
  factory SoundSingleton() {
    return _singleton;
  }
  SoundSingleton._internal();

  AudioPlayer player = AudioPlayer();

  static String url =
      'https://wholebodyprayerapi.admindd.com/uploads/cms/audio/1660048791739.wav';

  LockCachingAudioSource audioSource = LockCachingAudioSource(Uri.parse(url));

  Future<void> myInit() async {
    if (audioSource.uri.toString().isNotEmpty) {
      await player.setAudioSource(audioSource); // fetch from cache, if found.
    } else {
      await player.setUrl(url); // fetch from URL, if not found.
    }
    return Future.value();
  }

  Future<void> myPlay() async {
    if (player.playing) {
      await player.stop();
    }
    await myInit();
    await player.play();
    return Future.value();
  }
}
