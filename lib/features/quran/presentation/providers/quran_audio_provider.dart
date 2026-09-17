import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'dart:io';
import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';
import 'package:adhan_reminder/core/di/injection.dart';
import 'package:adhan_reminder/features/quran/presentation/providers/quran_download_provider.dart';

import 'package:adhan_reminder/features/quran/data/services/audio_player_service.dart';

class QuranAudioProvider with ChangeNotifier {
  final AudioPlayerService _audioPlayerService = getIt<AudioPlayerService>();

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
    '01': 'Abdullah Al-Juhany',
    '02': 'Abdul Muhsin Al-Qasim',
    '03': 'Abdurrahman as-Sudais',
    '04': 'Ibrahim Al-Dawsari',
    '05': 'Mishary Rashid Alafasy',
    '06': 'Yasser Al-Dosari',
    '07': 'Saad Al Ghamdi',
    '08': 'Islam Sobhi (Alternatif)',
    '09': 'Alaa Aqel',
  };

  Surah? get currentSurah => _currentSurah;
  String get selectedQoriId => _selectedQoriId;
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  Duration get duration => _duration;
  Duration get position => _position;
  double get playbackRate => _playbackRate;

  QuranAudioProvider() {
    _audioPlayerService.playerStateStream.listen((state) {
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
        _audioPlayerService.pause();
        _audioPlayerService.seek(Duration.zero);
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
      if (index != null && _allSurahs.isNotEmpty && index < _allSurahs.length) {
        if (_currentSurah?.nomor != _allSurahs[index].nomor) {
          _currentSurah = _allSurahs[index];
          notifyListeners();
        }
      }
    });
  }

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
      } else if (_selectedQoriId == '08') {
        audioUrl = 'https://server14.mp3quran.net/islam/Rewayat-Hafs-A-n-Assem/${s.nomor.toString().padLeft(3, '0')}.mp3';
      } else if (_selectedQoriId == '09') {
        audioUrl = 'https://archive.org/download/AlaaAql/${s.nomor.toString().padLeft(3, '0')}.mp3';
      } else {
        audioUrl = s.audioUrls[_selectedQoriId];
        if (audioUrl == null && s.audioUrls.isNotEmpty) {
          audioUrl = s.audioUrls.values.first;
        }
      }

      if (audioUrl != null && audioUrl.isNotEmpty) {
        final downloadProvider = getIt<QuranDownloadProvider>();
        final localPath = downloadProvider.getLocalPath(s.nomor, _selectedQoriId);
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

  Future<void> toggleAudio(Surah surah, BuildContext context, {List<Surah>? allSurahs}) async {
    if (allSurahs != null && allSurahs.isNotEmpty) {
      _allSurahs = allSurahs;
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
          notifyListeners();
        }

        String? audioUrl;
        if (_selectedQoriId == '07') {
          audioUrl = 'https://server7.mp3quran.net/s_gmd/${surah.nomor.toString().padLeft(3, '0')}.mp3';
        } else if (_selectedQoriId == '08') {
          audioUrl = 'https://server14.mp3quran.net/islam/Rewayat-Hafs-A-n-Assem/${surah.nomor.toString().padLeft(3, '0')}.mp3';
        } else if (_selectedQoriId == '09') {
          audioUrl = 'https://archive.org/download/AlaaAql/${surah.nomor.toString().padLeft(3, '0')}.mp3';
        } else {
          audioUrl = surah.audioUrls[_selectedQoriId];
          if (audioUrl == null && surah.audioUrls.isNotEmpty) {
            audioUrl = surah.audioUrls.values.first;
          }
        }

        if (audioUrl == null || audioUrl.isEmpty) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Audio tidak tersedia untuk surah ini.')),
            );
          }
          return;
        }

        if (_isPlaying) {
          await _audioPlayerService.pause();
        } else {
          _isBuffering = true;
          notifyListeners();

          final currentTag = _audioPlayerService.sequenceState?.currentSource?.tag as MediaItem?;
          final expectedId = '${surah.nomor}-$_selectedQoriId-${DateTime.now().millisecondsSinceEpoch}';

          final downloadProvider = getIt<QuranDownloadProvider>();
          final localPath = downloadProvider.getLocalPath(surah.nomor, _selectedQoriId);
          final bool isLocal = localPath != null && File(localPath).existsSync();

          final artUri = await _getArtUri();

          if (currentTag?.id != expectedId) {
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
          }
          await _audioPlayerService.play();
        }
      }
    } catch (e) {
      _isBuffering = false;
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Koneksi internet terputus. Audio membutuhkan internet.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
    } else if (qoriId == '08') {
      return 'https://server14.mp3quran.net/islam/Rewayat-Hafs-A-n-Assem/${surah.nomor.toString().padLeft(3, '0')}.mp3';
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
