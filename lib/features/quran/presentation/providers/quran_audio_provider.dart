import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:math';
import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';
import 'package:adhan_reminder/features/quran/domain/entities/ayah.dart';
import 'package:adhan_reminder/features/quran/presentation/providers/quran_provider.dart';

import 'package:adhan_reminder/features/quran/data/services/audio_player_service.dart';
import 'package:adhan_reminder/features/quran/data/services/playlist_manager.dart';
import 'package:adhan_reminder/features/quran/data/services/qori_audio_resolver.dart';

class QuranAudioProvider with ChangeNotifier {
  LoopModeState get loopModeState => _audioPlayerService.customLoopModeNotifier.value;
  
  List<Ayah> _currentAyahs = [];

  final AudioPlayerService _audioPlayerService;
  final QuranProvider _quranProvider;
  final PlaylistManager _playlistManager;

  Surah? _currentSurah;
  String _selectedQoriId = '05';

  bool _isPlaying = false;
  bool _isBuffering = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _playbackRate = 1.0;

  Surah? get currentSurah => _currentSurah;
  String get selectedQoriId => _selectedQoriId;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  Duration get duration => _duration;
  Duration get position => _position;
  double get playbackRate => _playbackRate;
  List<Ayah> get currentAyahs => _currentAyahs;
  Map<String, String> get qoriNames => QoriAudioResolver.qoriNames;

  QuranAudioProvider({
    required AudioPlayerService audioPlayerService,
    required QuranProvider quranProvider,
    required PlaylistManager playlistManager,
  })  : _audioPlayerService = audioPlayerService,
        _quranProvider = quranProvider,
        _playlistManager = playlistManager {
    _initListeners();
    _audioPlayerService.onSkipToPrevious = _handleSkipToPrevious;
  }

  void _handleSkipToPrevious() {
    if (_currentSurah == null) return;
    
    // Jika durasi sudah lewat 3 detik, rewind ke awal surah
    if (_position.inSeconds > 3) {
      _audioPlayerService.seek(Duration.zero);
      return;
    }

    final surahList = _quranProvider.surahList;
    if (surahList.isEmpty) return;

    int prevIndex = surahList.indexWhere((s) => s.nomor == _currentSurah!.nomor) - 1;
    if (prevIndex >= 0) {
      final prevSurah = surahList[prevIndex];
      final prevAyahs = _quranProvider.getAyahs(prevSurah.nomor);
      toggleAudio(prevSurah, ayahs: prevAyahs);
    } else {
      _audioPlayerService.seek(Duration.zero);
    }
  }

  void _initListeners() {
    _audioPlayerService.playerStateStream.listen((state) async {
      _isPlaying = state.playing;
      if (state.processingState == ProcessingState.ready ||
          state.processingState == ProcessingState.completed ||
          state.processingState == ProcessingState.idle) {
        _isBuffering = false;
      } else if (state.processingState == ProcessingState.buffering || state.processingState == ProcessingState.loading) {
        _isBuffering = true;
      }

      if (state.processingState == ProcessingState.completed) {
        _isPlaying = false;
        _position = Duration.zero;
        await _audioPlayerService.pause();
        await _audioPlayerService.seek(Duration.zero);
        await _handleSurahCompletion();
      }
      notifyListeners();
    });

    _audioPlayerService.durationStream.listen((d) {
      _duration = d ?? Duration.zero;
      notifyListeners();
    });

    _audioPlayerService.positionStream.listen((p) {
      _position = p;
      notifyListeners();
    });

    _audioPlayerService.currentIndexStream.listen((index) {
      if (index != null) {
        if (_currentAyahs.isNotEmpty && index < _currentAyahs.length) {
          _currentAyahIndex = index;
          notifyListeners();
        } else if (_allSurahs.isNotEmpty && index < _allSurahs.length) {
          if (_currentSurah?.nomor != _allSurahs[index].nomor) {
            _currentSurah = _allSurahs[index];
            notifyListeners();
          }
        }
      }
    });

    _audioPlayerService.customLoopModeNotifier.addListener(() {
      notifyListeners();
    });
  }

  Future<void> _handleSurahCompletion() async {
    final state = loopModeState;
    if (state == LoopModeState.playOnce) {
      return; 
    }
    
    final surahList = _quranProvider.surahList;
    if (surahList.isEmpty || _currentSurah == null) return;

    if (state == LoopModeState.sequential) {
      int nextIndex = surahList.indexWhere((s) => s.nomor == _currentSurah!.nomor) + 1;
      if (nextIndex < surahList.length) {
        final nextSurah = surahList[nextIndex];
        final nextAyahs = _quranProvider.getAyahs(nextSurah.nomor);
        Future.delayed(const Duration(milliseconds: 500), () {
          toggleAudio(nextSurah, ayahs: nextAyahs);
        });
      }
    } else if (state == LoopModeState.shuffle) {
      int randomIndex = Random().nextInt(surahList.length);
      final randomSurah = surahList[randomIndex];
      final randomAyahs = _quranProvider.getAyahs(randomSurah.nomor);
      Future.delayed(const Duration(milliseconds: 500), () {
        toggleAudio(randomSurah, ayahs: randomAyahs);
      });
    }
  }

  int _currentAyahIndex = -1;
  int get currentAyahIndex => _currentAyahIndex;

  void setQori(String qoriId) {
    if (_selectedQoriId != qoriId) {
      _selectedQoriId = qoriId;
      if (_isPlaying) {
        stopAudio();
      }
      notifyListeners();
    }
  }

  List<Surah> _allSurahs = [];
  bool _isPlaylistBuilt = false;
  String _builtQoriId = '';

  Future<void> _buildPlaylist() async {
    if (_allSurahs.isEmpty) return;
    await _playlistManager.buildFullPlaylist(_allSurahs, _selectedQoriId);
    _isPlaylistBuilt = true;
    _builtQoriId = _selectedQoriId;
  }

  Future<void> toggleAudio(Surah surah, {List<Surah>? allSurahs, List<Ayah>? ayahs}) async {
    if (allSurahs != null && allSurahs.isNotEmpty) {
      _allSurahs = allSurahs;
      _currentAyahs = [];
    } else {
      _allSurahs = [];
      _currentAyahs = ayahs ?? [];
    }

    try {
      if (_allSurahs.isNotEmpty) {
        if (!_isPlaylistBuilt || _builtQoriId != _selectedQoriId) {
          _isBuffering = true;
          notifyListeners();
          await _buildPlaylist();
        }

        int index = _allSurahs.indexWhere((s) => s.nomor == surah.nomor);
        if (index == -1) index = 0;

        if (_currentSurah?.nomor == surah.nomor && _isPlaying) {
          await _audioPlayerService.pause();
        } else if (_currentSurah?.nomor == surah.nomor && !_isPlaying) {
          await _audioPlayerService.play();
        } else {
          _currentSurah = surah;
          notifyListeners();
          await _audioPlayerService.seek(Duration.zero, index: index);
          await _audioPlayerService.play();
        }
      } else {
        bool isSameSurah = _currentSurah?.nomor == surah.nomor;

        if (!isSameSurah) {
          await _audioPlayerService.stop();
          _isPlaying = false; // Hindari race condition
          _currentSurah = surah;
          _isPlaylistBuilt = false;
          notifyListeners();
        }

        if (isSameSurah && _isPlaying) {
          await _audioPlayerService.pause();
          return;
        } else if (isSameSurah && !_isPlaying && _isPlaylistBuilt && _builtQoriId == _selectedQoriId) {
          await _audioPlayerService.play();
          return;
        }

        _isBuffering = true;
        notifyListeners();

        // Menonaktifkan mode per-ayat untuk Qori 05 (Mishary Rashid) sesuai permintaan, 
        // sehingga semua (05, 07, 09) memutar full surah.
        bool canPlayAyah = ayahs != null && ayahs.isNotEmpty && int.parse(_selectedQoriId) <= 6 && _selectedQoriId != '05';
        
        // Jika tidak mendukung per-ayat, putar full surah
        if (!canPlayAyah) {
          await _playlistManager.buildSingleSurahPlaylist(surah, _selectedQoriId);
        } else {
          // Play Per Ayat
          await _playlistManager.buildAyahPlaylist(surah, ayahs, _selectedQoriId);
          
          final state = loopModeState;
          if (state == LoopModeState.repeatOne) {
            await _audioPlayerService.setShuffleModeEnabled(false);
            await _audioPlayerService.setLoopMode(LoopMode.all);
          } else {
            await _audioPlayerService.setShuffleModeEnabled(false);
            await _audioPlayerService.setLoopMode(LoopMode.off);
          }
        }
        
        _isPlaylistBuilt = true;
        _builtQoriId = _selectedQoriId;
        
        if (!_isPlaying) {
            await _audioPlayerService.play();
        }
      } 
    } catch (e) {
        debugPrint('Error playing audio: $e');
        _isBuffering = false;
        _isPlaying = false;
        notifyListeners();
        throw Exception('Koneksi internet terputus atau audio gagal dimuat.');
      }
    }

  Future<void> toggleLoopMode() async {
    final currentState = loopModeState;
    LoopModeState nextState;

    switch (currentState) {
      case LoopModeState.playOnce:
        nextState = LoopModeState.sequential;
        await _audioPlayerService.setLoopMode(LoopMode.off);
        break;
      case LoopModeState.sequential:
        nextState = LoopModeState.repeatOne;
        await _audioPlayerService.setLoopMode(LoopMode.all); 
        break;
      case LoopModeState.repeatOne:
        nextState = LoopModeState.shuffle;
        await _audioPlayerService.setLoopMode(LoopMode.off); 
        break;
      case LoopModeState.shuffle:
        nextState = LoopModeState.playOnce;
        await _audioPlayerService.setLoopMode(LoopMode.off);
        break;
    }
    
    _audioPlayerService.customLoopModeNotifier.value = nextState;
  }

  Future<void> pauseAudio() async {
    await _audioPlayerService.pause();
  }

  Future<void> resumeAudio() async {
    await _audioPlayerService.play();
  }

  Future<void> stopAudio() async {
    await _audioPlayerService.stop();
    _isPlaying = false;
    _currentSurah = null;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayerService.seek(position);
  }

  Future<void> setSpeed(double speed) async {
    _playbackRate = speed;
    await _audioPlayerService.setSpeed(speed);
    notifyListeners();
  }

  String? getAudioUrl(Surah surah, String qoriId) {
    return QoriAudioResolver.getAudioUrl(surah, qoriId);
  }
}
