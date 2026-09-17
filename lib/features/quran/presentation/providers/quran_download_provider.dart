import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';
import 'package:adhan_reminder/features/quran/data/models/surah_model.dart';

class DownloadItem {
  final Surah surah;
  final String qoriId;
  final String localPath;

  DownloadItem({
    required this.surah,
    required this.qoriId,
    required this.localPath,
  });

  Map<String, dynamic> toJson() => {
        'surah': SurahModel.fromEntity(surah).toJson(),
        'qoriId': qoriId,
        'localPath': localPath,
      };

  factory DownloadItem.fromJson(Map<String, dynamic> json) {
    return DownloadItem(
      surah: SurahModel.fromJson(json['surah']).toEntity(),
      qoriId: json['qoriId'],
      localPath: json['localPath'],
    );
  }
}

class QuranDownloadProvider with ChangeNotifier {
  final Dio _dio = Dio();
  List<DownloadItem> _downloadedItems = [];


  final Map<String, double> _downloadProgress = {};


  final Map<String, CancelToken> _cancelTokens = {};

  List<DownloadItem> get downloadedItems => _downloadedItems;
  Map<String, double> get downloadProgress => _downloadProgress;

  QuranDownloadProvider() {
    _loadDownloadedItems();
  }

  Future<void> _loadDownloadedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('downloaded_quran');
    if (data != null) {
      final List<dynamic> decoded = json.decode(data);
      _downloadedItems = decoded.map((e) => DownloadItem.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveDownloadedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _downloadedItems.map((e) => e.toJson()).toList();
    await prefs.setString('downloaded_quran', json.encode(data));
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
    _cancelTokens[downloadKey] = CancelToken();
    notifyListeners();

    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/surah_${surah.nomor}_qori_$qoriId.mp3';

      await _dio.download(
        audioUrl,
        savePath,
        cancelToken: _cancelTokens[downloadKey],
        onReceiveProgress: (received, total) {
          if (total != -1) {
            _downloadProgress[downloadKey] = received / total;
            notifyListeners();
          }
        },
      );

      _downloadProgress.remove(downloadKey);
      _cancelTokens.remove(downloadKey);

      _downloadedItems.add(DownloadItem(
        surah: surah,
        qoriId: qoriId,
        localPath: savePath,
      ));

      await _saveDownloadedItems();
      notifyListeners();
    } catch (e) {
      if (e is DioException && e.type == DioExceptionType.cancel) {
        debugPrint('Download cancelled: $downloadKey');
      }
      _downloadProgress.remove(downloadKey);
      _cancelTokens.remove(downloadKey);
      notifyListeners();
    }
  }

  void cancelDownload(int surahNomor, String qoriId) {
    final downloadKey = '${surahNomor}_$qoriId';
    if (_cancelTokens.containsKey(downloadKey)) {
      _cancelTokens[downloadKey]?.cancel('Dibatalkan oleh pengguna');
      _cancelTokens.remove(downloadKey);
      _downloadProgress.remove(downloadKey);
      notifyListeners();
    }
  }

  Future<void> deleteDownload(int surahNomor, String qoriId) async {
    final index = _downloadedItems.indexWhere((item) => item.surah.nomor == surahNomor && item.qoriId == qoriId);
    if (index != -1) {
      final file = File(_downloadedItems[index].localPath);
      if (await file.exists()) {
        await file.delete();
      }
      _downloadedItems.removeAt(index);
      await _saveDownloadedItems();
      notifyListeners();
    }
  }
}
