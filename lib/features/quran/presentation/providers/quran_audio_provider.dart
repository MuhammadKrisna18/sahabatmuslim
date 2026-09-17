import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'dart:io';
import 'dart:math';
import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';
import 'package:adhan_reminder/features/quran/domain/entities/ayah.dart';
import 'package:adhan_reminder/features/quran/presentation/providers/quran_download_provider.dart';
import 'package:adhan_reminder/features/quran/presentation/providers/quran_provider.dart';

import 'package:adhan_reminder/features/quran/data/services/audio_player_service.dart';

class QuranAudioProvider with ChangeNotifier {
  LoopModeState get loopModeState => _audioPlayerService.customLoopModeNotifier.value;
  
  List<Ayah> _currentAyahs = [];

  final AudioPlayerService _audioPlayerService;
  final QuranProvider _quranProvider;
  final QuranDownloadProvider _quranDownloadProvider;

  Surah? _currentSurah;
  String _selectedQoriId = '05';

  bool _isPlaying = false;
  bool _isBuffering = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _playbackRate = 1.0;
  Uri? _artUriCache;

  Future<Uri?> _getArtUri() async {
    return await _audioPlayerService.getArtUri();
  }

  final Map<String, String> qoriNames = {
    '05': 'Mishary Rashid Alafasy',
    '07': 'Saad Al Ghamdi',
    '09': 'Alaa Aqel',
  };

  Surah? get currentSurah => _currentSurah;
  String get selectedQoriId => _selectedQoriId;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  Duration get duration => _duration;
  Duration get position => _position;
  double get playbackRate => _playbackRate;
  List<Ayah> get currentAyahs => _currentAyahs;

  QuranAudioProvider({
    required AudioPlayerService audioPlayerService,
    required QuranProvider quranProvider,
    required QuranDownloadProvider quranDownloadProvider,
  })  : _audioPlayerService = audioPlayerService,
        _quranProvider = quranProvider,
        _quranDownloadProvider = quranDownloadProvider {
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
      return; // Already stopped
    }
    
    final surahList = _quranProvider.surahList;
    if (surahList.isEmpty || _currentSurah == null) return;

    if (state == LoopModeState.sequential) {
      int nextIndex = surahList.indexWhere((s) => s.nomor == _currentSurah!.nomor) + 1;
      if (nextIndex < surahList.length) {
        final nextSurah = surahList[nextIndex];
        final nextAyahs = _quranProvider.getAyahs(nextSurah.nomor);
        // Delay slightly to ensure UI is ready and avoid race conditions
        Future.delayed(const Duration(milliseconds: 500), () {
          toggleAudio(nextSurah, null, ayahs: nextAyahs);
        });
      }
    } else if (state == LoopModeState.shuffle) {
      int randomIndex = Random().nextInt(surahList.length);
      final randomSurah = surahList[randomIndex];
      final randomAyahs = _quranProvider.getAyahs(randomSurah.nomor);
      Future.delayed(const Duration(milliseconds: 500), () {
        toggleAudio(randomSurah, null, ayahs: randomAyahs);
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
    final artUri = await _getArtUri();

    final children = <AudioSource>[];
    for (var s in _allSurahs) {
      String? audioUrl;
      if (_selectedQoriId == '07') {
        audioUrl = 'https://server7.mp3quran.net/s_gmd/${s.nomor.toString().padLeft(3, '0')}.mp3';
      } else if (_selectedQoriId == '09') {
        audioUrl = 'https://archive.org/download/AlaaAql/${s.nomor.toString().padLeft(3, '0')}.mp3';
      } else {
        audioUrl = s.audioUrls[_selectedQoriId];
        if (audioUrl == null && s.audioUrls.isNotEmpty) {
          audioUrl = s.audioUrls.values.first;
        }
      }

      if (audioUrl != null && audioUrl.isNotEmpty) {
        final localPath = _quranDownloadProvider.getLocalPath(s.nomor, _selectedQoriId);
        final bool isLocal = localPath != null && File(localPath).existsSync();

        children.add(
          isLocal
              ? AudioSource.uri(
                  Uri.file(localPath),
                  tag: MediaItem(
                    id: '${s.nomor}-$_selectedQoriId-${DateTime.now().millisecondsSinceEpoch}',
                    album: 'Murottal SahabatMuslim',
                    title: 'Surah ${s.namaLatin} (Offline)',
                    artist: qoriNames[_selectedQoriId] ?? "Qori",
                    artUri: artUri,
                  ),
                )
              : AudioSource.uri(
                  Uri.parse(audioUrl),
                  tag: MediaItem(
                    id: '${s.nomor}-$_selectedQoriId-${DateTime.now().millisecondsSinceEpoch}',
                    album: 'Murottal SahabatMuslim',
                    title: 'Surah ${s.namaLatin}',
                    artist: qoriNames[_selectedQoriId] ?? "Qori",
                    artUri: artUri,
                  ),
                ),
        );
      }
    }

    await _audioPlayerService.setAudioSource(
      ConcatenatingAudioSource(children: children),
    );
    _isPlaylistBuilt = true;
    _builtQoriId = _selectedQoriId;
  }

  Future<void> toggleAudio(Surah surah, BuildContext? context, {List<Surah>? allSurahs, List<Ayah>? ayahs}) async {
    if (allSurahs != null && allSurahs.isNotEmpty) {
      _allSurahs = allSurahs;
    } else if (ayahs != null) {
      _allSurahs = [];
      _isPlaylistBuilt = false;
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

        if (_currentSurah?.nomor != surah.nomor) {
          await _audioPlayerService.stop();
          _currentSurah = surah;
          if (ayahs != null) _currentAyahs = ayahs;
          notifyListeners();
        }

        if (_isPlaying) {
          await _audioPlayerService.pause();
          return;
        }

        _isBuffering = true;
        notifyListeners();

        // Cek apakah mode Ayah tersedia (Qori 01-06 memiliki audioUrls per ayat)
        bool canPlayAyah = ayahs != null && ayahs.isNotEmpty && int.parse(_selectedQoriId) <= 6;
        final localPath = _quranDownloadProvider.getLocalPath(surah.nomor, _selectedQoriId);
        final bool isLocal = localPath != null && File(localPath).existsSync();

        // Jika OFFLINE (sudah didownload) ATAU Qori > 05, paksa mode Full Surah
        if (isLocal || !canPlayAyah) {
          String? audioUrl;
          if (_selectedQoriId == '07') {
            audioUrl = 'https://server7.mp3quran.net/s_gmd/${surah.nomor.toString().padLeft(3, '0')}.mp3';
          } else if (_selectedQoriId == '09') {
            audioUrl = 'https://archive.org/download/AlaaAql/${surah.nomor.toString().padLeft(3, '0')}.mp3';
          } else {
            audioUrl = surah.audioUrls[_selectedQoriId] ?? (surah.audioUrls.isNotEmpty ? surah.audioUrls.values.first : null);
          }

          if (audioUrl == null || audioUrl.isEmpty) {
            if (context != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Audio tidak tersedia untuk surah ini.')));
            }
            _isBuffering = false;
            notifyListeners();
            return;
          }

          final expectedId = '${surah.nomor}-$_selectedQoriId-${DateTime.now().millisecondsSinceEpoch}';
          final artUri = await _getArtUri();

          await _audioPlayerService.setAudioSource(
            isLocal
                ? AudioSource.uri(
                    Uri.file(localPath),
                    tag: MediaItem(
                      id: expectedId,
                      album: 'Murottal SahabatMuslim',
                      title: 'Surah ${surah.namaLatin} (Offline)',
                      artist: qoriNames[_selectedQoriId] ?? "Qori",
                      artUri: artUri,
                    ),
                  )
                : AudioSource.uri(
                    Uri.parse(audioUrl),
                    tag: MediaItem(
                      id: expectedId,
                      album: 'Murottal SahabatMuslim',
                      title: 'Surah ${surah.namaLatin}',
                      artist: qoriNames[_selectedQoriId] ?? "Qori",
                      artUri: artUri,
                    ),
                  ),
          );
        } else {
          // Play Per Ayat
          List<AudioSource> children = [];
          final artUri = await _getArtUri();
          
          for (var ayah in ayahs!) {
            String? ayahAudioUrl = ayah.audioUrls[_selectedQoriId];
            if (ayahAudioUrl != null) {
              children.add(
                AudioSource.uri(
                  Uri.parse(ayahAudioUrl),
                  tag: MediaItem(
                    id: '${surah.nomor}-${ayah.nomorAyat}-$_selectedQoriId',
                    album: 'Surah ${surah.namaLatin}',
                    title: 'Ayat ${ayah.nomorAyat}',
                    artist: qoriNames[_selectedQoriId] ?? "Qori",
                    artUri: artUri,
                  ),
                )
              );
            }
          }
          
          if (children.isEmpty) {
            if (context != null && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Audio ayat tidak tersedia.')));
            }
            _isBuffering = false;
            notifyListeners();
            return;
          }

          await _audioPlayerService.setAudioSource(ConcatenatingAudioSource(children: children));
          
          // Apply current native loop mode based on custom state
          final state = loopModeState;
          if (state == LoopModeState.repeatOne) {
            await _audioPlayerService.setShuffleModeEnabled(false);
            await _audioPlayerService.setLoopMode(LoopMode.all);
          } else {
            // For playOnce, sequential, and shuffle, native loop mode is off
            await _audioPlayerService.setShuffleModeEnabled(false);
            await _audioPlayerService.setLoopMode(LoopMode.off);
          }

          if (!_isPlaying) {
            await _audioPlayerService.play();
          }
        }
      } // Closes else block from line 236
    } catch (e) {
        debugPrint('Error playing audio: $e');
        _isBuffering = false;
        _isPlaying = false;
        notifyListeners();
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Koneksi internet terputus atau audio gagal dimuat.'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
        await _audioPlayerService.setLoopMode(LoopMode.all); // Loop current surah natively
        break;
      case LoopModeState.repeatOne:
        nextState = LoopModeState.shuffle;
        await _audioPlayerService.setLoopMode(LoopMode.off); // Let custom logic handle next surah
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

  @override
  void dispose() {

    super.dispose();
  }

  String? getAudioUrl(Surah surah, String qoriId) {
    if (qoriId == '07') {
      return 'https://server7.mp3quran.net/s_gmd/${surah.nomor.toString().padLeft(3, '0')}.mp3';
    } else if (qoriId == '09') {
      return 'https://archive.org/download/AlaaAql/${surah.nomor.toString().padLeft(3, '0')}.mp3';
    } else {
      String? url = surah.audioUrls[qoriId];
      if (url == null && surah.audioUrls.isNotEmpty) {
        url = surah.audioUrls.values.first;
      }
      return url;
    }
  }
}
