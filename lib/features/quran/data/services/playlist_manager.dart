import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';
import 'package:adhan_reminder/features/quran/domain/entities/ayah.dart';
import 'package:adhan_reminder/features/quran/data/services/audio_player_service.dart';
import 'package:adhan_reminder/features/quran/presentation/providers/quran_download_provider.dart';
import 'package:adhan_reminder/features/quran/data/services/qori_audio_resolver.dart';

class PlaylistManager {
  final AudioPlayerService _audioPlayerService;
  final QuranDownloadProvider _quranDownloadProvider;

  PlaylistManager({
    required AudioPlayerService audioPlayerService,
    required QuranDownloadProvider quranDownloadProvider,
  })  : _audioPlayerService = audioPlayerService,
        _quranDownloadProvider = quranDownloadProvider;

  Future<void> buildFullPlaylist(List<Surah> surahs, String qoriId) async {
    if (surahs.isEmpty) return;
    
    final artUri = await _audioPlayerService.getArtUri();
    final children = <AudioSource>[];

    for (var s in surahs) {
      final audioUrl = QoriAudioResolver.getAudioUrl(s, qoriId);

      if (audioUrl != null && audioUrl.isNotEmpty) {
        final localPath = _quranDownloadProvider.getLocalPath(s.nomor, qoriId);
        final bool isLocal = localPath != null && File(localPath).existsSync();
        final expectedId = '${s.nomor}-$qoriId-${DateTime.now().millisecondsSinceEpoch}';
        final qoriName = QoriAudioResolver.getQoriName(qoriId);

        children.add(
          isLocal
              ? AudioSource.uri(
                  Uri.file(localPath),
                  tag: MediaItem(
                    id: expectedId,
                    album: 'Murottal SahabatMuslim',
                    title: 'Surah ${s.namaLatin} (Offline)',
                    artist: qoriName,
                    artUri: artUri,
                  ),
                )
              : AudioSource.uri(
                  Uri.parse(audioUrl),
                  tag: MediaItem(
                    id: expectedId,
                    album: 'Murottal SahabatMuslim',
                    title: 'Surah ${s.namaLatin}',
                    artist: qoriName,
                    artUri: artUri,
                  ),
                ),
        );
      }
    }

    await _audioPlayerService.setAudioSource(
      ConcatenatingAudioSource(children: children),
    );
  }

  Future<void> buildSingleSurahPlaylist(Surah surah, String qoriId) async {
    final audioUrl = QoriAudioResolver.getAudioUrl(surah, qoriId);
    if (audioUrl == null || audioUrl.isEmpty) {
      throw Exception('Audio url not found');
    }
    
    final localPath = _quranDownloadProvider.getLocalPath(surah.nomor, qoriId);
    final bool isLocal = localPath != null && File(localPath).existsSync();
    
    final artUri = await _audioPlayerService.getArtUri();
    final expectedId = '${surah.nomor}-$qoriId-${DateTime.now().millisecondsSinceEpoch}';
    final qoriName = QoriAudioResolver.getQoriName(qoriId);

    final source = isLocal
        ? AudioSource.uri(
            Uri.file(localPath),
            tag: MediaItem(
              id: expectedId,
              album: 'Murottal SahabatMuslim',
              title: 'Surah ${surah.namaLatin} (Offline)',
              artist: qoriName,
              artUri: artUri,
            ),
          )
        : AudioSource.uri(
            Uri.parse(audioUrl),
            tag: MediaItem(
              id: expectedId,
              album: 'Murottal SahabatMuslim',
              title: 'Surah ${surah.namaLatin}',
              artist: qoriName,
              artUri: artUri,
            ),
          );
          
    await _audioPlayerService.setAudioSource(source);
  }

  Future<void> buildAyahPlaylist(Surah surah, List<Ayah> ayahs, String qoriId) async {
    List<AudioSource> children = [];
    final artUri = await _audioPlayerService.getArtUri();
    final qoriName = QoriAudioResolver.getQoriName(qoriId);
    
    for (var ayah in ayahs) {
      String? ayahAudioUrl = ayah.audioUrls[qoriId];
      if (ayahAudioUrl != null) {
        children.add(
          AudioSource.uri(
            Uri.parse(ayahAudioUrl),
            tag: MediaItem(
              id: '${surah.nomor}-${ayah.nomorAyat}-$qoriId',
              album: 'Surah ${surah.namaLatin}',
              title: 'Ayat ${ayah.nomorAyat}',
              artist: qoriName,
              artUri: artUri,
            ),
          )
        );
      }
    }
    
    if (children.isEmpty) {
      throw Exception('Audio ayat tidak tersedia.');
    }

    await _audioPlayerService.setAudioSource(ConcatenatingAudioSource(children: children));
  }
}
