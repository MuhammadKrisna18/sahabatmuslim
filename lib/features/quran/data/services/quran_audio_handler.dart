import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:adhan_reminder/features/quran/data/services/audio_player_service.dart';

class QuranAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayerService _audioPlayerService;
  AudioPlayer get _player => _audioPlayerService.audioPlayer;

  QuranAudioHandler(this._audioPlayerService) {
    _player.playbackEventStream.listen((_) => _broadcastState());
    _player.loopModeStream.listen((_) => _broadcastState());
    _player.shuffleModeEnabledStream.listen((_) => _broadcastState());
    _audioPlayerService.customLoopModeNotifier.addListener(_broadcastState);
    
    _player.sequenceStateStream.listen((sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      final currentItem = sequenceState?.currentSource?.tag as MediaItem?;
      if (currentItem != null) {
        mediaItem.add(currentItem);
      }
    });
  }

  MediaControl _getLoopControl(LoopModeState state) {
    switch (state) {
      case LoopModeState.shuffle:
        return const MediaControl(
            androidIcon: 'drawable/ic_shuffle',
            label: 'Shuffle',
            action: MediaAction.setRepeatMode);
      case LoopModeState.repeatOne:
        return const MediaControl(
            androidIcon: 'drawable/ic_repeat_one',
            label: 'Repeat 1',
            action: MediaAction.setRepeatMode);
      case LoopModeState.sequential:
      case LoopModeState.playOnce:
        return const MediaControl(
            androidIcon: 'drawable/ic_repeat',
            label: 'Repeat',
            action: MediaAction.setRepeatMode);
    }
  }

  void _broadcastState() {
    final playing = _player.playing;
    final processingState = const {
      ProcessingState.idle: AudioProcessingState.idle,
      ProcessingState.loading: AudioProcessingState.loading,
      ProcessingState.buffering: AudioProcessingState.buffering,
      ProcessingState.ready: AudioProcessingState.ready,
      ProcessingState.completed: AudioProcessingState.completed,
    }[_player.processingState] ?? AudioProcessingState.idle;

    final loopState = _audioPlayerService.customLoopModeNotifier.value;

    playbackState.add(playbackState.value.copyWith(
      controls: [
        _getLoopControl(loopState),
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.playPause,
        MediaAction.setRepeatMode,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
      },
      androidCompactActionIndices: const [1, 2, 3],
      processingState: processingState,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    ));
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> skipToNext() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    } else {
      await _player.seek(_player.duration ?? Duration.zero);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    } else {
      await _player.seek(Duration.zero);
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    await _audioPlayerService.toggleCustomLoopMode();
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    await _audioPlayerService.toggleCustomLoopMode();
  }
}
