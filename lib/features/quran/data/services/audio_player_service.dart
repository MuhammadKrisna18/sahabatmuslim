import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:adhan_reminder/features/quran/data/services/quran_audio_handler.dart';

enum LoopModeState { playOnce, sequential, repeatOne, shuffle }

class AudioPlayerService {
  final AudioPlayer audioPlayer = AudioPlayer(userAgent: 'Mozilla/5.0 (Linux; Android 10; SM-G981B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.162 Mobile Safari/537.36');
  Uri? _artUriCache;
  QuranAudioHandler? audioHandler;
  
  final ValueNotifier<LoopModeState> customLoopModeNotifier = ValueNotifier(LoopModeState.sequential);

  Future<void> initAudioService() async {
    if (audioHandler == null) {
      audioHandler = await AudioService.init(
        builder: () => QuranAudioHandler(this),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
          androidNotificationChannelName: 'Pemutaran Audio',
          androidNotificationOngoing: true,
        ),
      );
    }
  }

  Stream<PlayerState> get playerStateStream => audioPlayer.playerStateStream;
  Stream<Duration?> get durationStream => audioPlayer.durationStream;
  Stream<Duration> get positionStream => audioPlayer.positionStream;
  Stream<int?> get currentIndexStream => audioPlayer.currentIndexStream;
  SequenceState? get sequenceState => audioPlayer.sequenceState;
  Stream<LoopMode> get loopModeStream => audioPlayer.loopModeStream;
  Stream<bool> get shuffleModeEnabledStream => audioPlayer.shuffleModeEnabledStream;
  LoopMode get loopMode => audioPlayer.loopMode;
  bool get shuffleModeEnabled => audioPlayer.shuffleModeEnabled;

  Future<Uri?> getArtUri() async {
    if (_artUriCache != null) return _artUriCache;
    try {
      final byteData = await rootBundle.load('assets/quran_cover_small.png');
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/quran_cover_small.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      _artUriCache = file.uri;
      return _artUriCache;
    } catch (e) {
      return null;
    }
  }

  Future<void> setAudioSource(AudioSource source) async {
    await audioPlayer.setAudioSource(source);
  }

  Future<void> play() async {
    await audioPlayer.play();
  }

  Future<void> pause() async {
    await audioPlayer.pause();
  }

  Future<void> stop() async {
    await audioPlayer.stop();
  }

  Future<void> seek(Duration position, {int? index}) async {
    await audioPlayer.seek(position, index: index);
  }

  Future<void> setSpeed(double speed) async {
    await audioPlayer.setSpeed(speed);
  }

  Future<void> setLoopMode(LoopMode mode) async {
    await audioPlayer.setLoopMode(mode);
  }

  Future<void> setShuffleModeEnabled(bool enabled) async {
    await audioPlayer.setShuffleModeEnabled(enabled);
  }

  void dispose() {
    audioPlayer.dispose();
  }
}
