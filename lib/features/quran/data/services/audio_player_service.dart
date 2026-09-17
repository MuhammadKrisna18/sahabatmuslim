import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

class AudioPlayerService {
  final AudioPlayer audioPlayer = AudioPlayer();
  Uri? _artUriCache;

  Stream<PlayerState> get playerStateStream => audioPlayer.playerStateStream;
  Stream<Duration?> get durationStream => audioPlayer.durationStream;
  Stream<Duration> get positionStream => audioPlayer.positionStream;
  Stream<int?> get currentIndexStream => audioPlayer.currentIndexStream;
  SequenceState? get sequenceState => audioPlayer.sequenceState;

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

  void dispose() {
    audioPlayer.dispose();
  }
}
