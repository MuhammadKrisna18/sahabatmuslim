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
        MediaControl.skipToPrevious,
        if (loopState == LoopModeState.repeatOne)
          const MediaControl(androidIcon: 'drawable/ic_repeat_one', label: 'Repeat 1', action: MediaAction.setRepeatMode)
        else
          const MediaControl(androidIcon: 'drawable/ic_repeat', label: 'Repeat', action: MediaAction.setRepeatMode),
        if (playing) MediaControl.pause else MediaControl.play,
        if (loopState == LoopModeState.shuffle)
          const MediaControl(androidIcon: 'drawable/ic_shuffle_on', label: 'Shuffle On', action: MediaAction.setShuffleMode)
        else
          const MediaControl(androidIcon: 'drawable/ic_shuffle', label: 'Shuffle', action: MediaAction.setShuffleMode),
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.playPause,
        MediaAction.setRepeatMode,
        MediaAction.setShuffleMode,
      },
      androidCompactActionIndices: const [0, 2, 4],
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
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    final currentState = _audioPlayerService.customLoopModeNotifier.value;
    LoopModeState nextState;
    if (currentState == LoopModeState.playOnce) {
      nextState = LoopModeState.sequential;
    } else if (currentState == LoopModeState.sequential) {
      nextState = LoopModeState.repeatOne;
    } else if (currentState == LoopModeState.repeatOne) {
      nextState = LoopModeState.playOnce;
    } else {
      nextState = LoopModeState.sequential;
    }
    _audioPlayerService.customLoopModeNotifier.value = nextState;
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final currentState = _audioPlayerService.customLoopModeNotifier.value;
    if (currentState == LoopModeState.shuffle) {
      _audioPlayerService.customLoopModeNotifier.value = LoopModeState.sequential;
    } else {
      _audioPlayerService.customLoopModeNotifier.value = LoopModeState.shuffle;
    }
  }
}
