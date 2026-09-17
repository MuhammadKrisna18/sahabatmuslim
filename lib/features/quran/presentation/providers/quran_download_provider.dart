import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';
import 'package:adhan_reminder/features/quran/domain/entities/download_item.dart';
import 'package:adhan_reminder/features/quran/domain/usecases/get_downloaded_audio_usecase.dart';
import 'package:adhan_reminder/features/quran/domain/usecases/download_audio_usecase.dart';
import 'package:adhan_reminder/features/quran/domain/usecases/delete_downloaded_audio_usecase.dart';
import 'package:adhan_reminder/features/quran/domain/usecases/cancel_download_usecase.dart';

class QuranDownloadProvider with ChangeNotifier {
  final GetDownloadedAudioUseCase _getDownloadedAudioUseCase;
  final DownloadAudioUseCase _downloadAudioUseCase;
  final DeleteDownloadedAudioUseCase _deleteDownloadedAudioUseCase;
  final CancelDownloadUseCase _cancelDownloadUseCase;

  List<DownloadItem> _downloadedItems = [];
  final Map<String, double> _downloadProgress = {};
  final Map<String, StreamSubscription> _downloadSubscriptions = {};

  List<DownloadItem> get downloadedItems => _downloadedItems;
  Map<String, double> get downloadProgress => _downloadProgress;

  QuranDownloadProvider({
    required GetDownloadedAudioUseCase getDownloadedAudioUseCase,
    required DownloadAudioUseCase downloadAudioUseCase,
    required DeleteDownloadedAudioUseCase deleteDownloadedAudioUseCase,
    required CancelDownloadUseCase cancelDownloadUseCase,
  })  : _getDownloadedAudioUseCase = getDownloadedAudioUseCase,
        _downloadAudioUseCase = downloadAudioUseCase,
        _deleteDownloadedAudioUseCase = deleteDownloadedAudioUseCase,
        _cancelDownloadUseCase = cancelDownloadUseCase {
    _loadDownloadedItems();
  }

  Future<void> _loadDownloadedItems() async {
    final result = await _getDownloadedAudioUseCase.execute();
    result.fold(
      (failure) {},
      (items) {
        _downloadedItems = items;
        notifyListeners();
      },
    );
  }

  bool isDownloaded(int surahNomor, String qoriId) {
    return _downloadedItems.any((item) => item.surah.nomor == surahNomor && item.qoriId == qoriId);
  }

  bool isDownloading(int surahNomor, String qoriId) {
    return _downloadProgress.containsKey('${surahNomor}_$qoriId');
  }

  double getProgress(int surahNomor, String qoriId) {
    return _downloadProgress['${surahNomor}_$qoriId'] ?? 0.0;
  }

  String? getLocalPath(int surahNomor, String qoriId) {
    final index = _downloadedItems.indexWhere((item) => item.surah.nomor == surahNomor && item.qoriId == qoriId);
    if (index != -1) {
      return _downloadedItems[index].localPath;
    }
    return null;
  }

  Future<void> downloadSurah(Surah surah, String qoriId, String audioUrl) async {
    final downloadKey = '${surah.nomor}_$qoriId';
    if (isDownloaded(surah.nomor, qoriId) || isDownloading(surah.nomor, qoriId)) return;

    _downloadProgress[downloadKey] = 0.0;
    notifyListeners();

    final stream = _downloadAudioUseCase.execute(surah, qoriId, audioUrl);
    
    _downloadSubscriptions[downloadKey] = stream.listen(
      (progress) {
        if (progress >= 1.0) {
          _downloadProgress.remove(downloadKey);
          _downloadSubscriptions.remove(downloadKey);
          _loadDownloadedItems(); // Refresh items
        } else {
          _downloadProgress[downloadKey] = progress;
        }
        notifyListeners();
      },
      onError: (error) {
        _downloadProgress.remove(downloadKey);
        _downloadSubscriptions.remove(downloadKey);
        notifyListeners();
      },
      cancelOnError: true,
    );
  }

  void cancelDownload(int surahNomor, String qoriId) {
    final downloadKey = '${surahNomor}_$qoriId';
    if (_downloadProgress.containsKey(downloadKey)) {
      _cancelDownloadUseCase.execute(surahNomor, qoriId);
      _downloadSubscriptions[downloadKey]?.cancel();
      _downloadSubscriptions.remove(downloadKey);
      _downloadProgress.remove(downloadKey);
      notifyListeners();
    }
  }

  Future<void> deleteDownload(int surahNomor, String qoriId) async {
    await _deleteDownloadedAudioUseCase.execute(surahNomor, qoriId);
    await _loadDownloadedItems();
  }
}
