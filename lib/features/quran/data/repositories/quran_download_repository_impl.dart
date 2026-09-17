import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';
import 'package:adhan_reminder/features/quran/domain/entities/download_item.dart';
import 'package:adhan_reminder/features/quran/data/models/download_item_model.dart';
import 'package:adhan_reminder/features/quran/domain/repositories/quran_download_repository.dart';

class QuranDownloadRepositoryImpl implements QuranDownloadRepository {
  final Dio _dio = Dio();
  final Map<String, CancelToken> _cancelTokens = {};

  static const _prefKey = 'downloaded_quran';

  @override
  Future<Either<Failure, List<DownloadItem>>> getDownloadedItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_prefKey);
      if (data != null) {
        final List<dynamic> decoded = json.decode(data);
        final items = decoded.map((e) => DownloadItemModel.fromJson(e).toEntity()).toList();
        return Right(items);
      }
      return Right([]);
    } catch (e) {
      return Left(CacheFailure('Gagal memuat data unduhan: $e'));
    }
  }

  Future<void> _saveDownloadedItems(List<DownloadItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final data = items.map((e) => DownloadItemModel.fromEntity(e).toJson()).toList();
    await prefs.setString(_prefKey, json.encode(data));
  }

  @override
  Future<Either<Failure, void>> deleteDownloadedItem(int surahNomor, String qoriId) async {
    try {
      final itemsResult = await getDownloadedItems();
      return itemsResult.fold(
        (failure) => Left(failure),
        (items) async {
          final index = items.indexWhere((item) => item.surah.nomor == surahNomor && item.qoriId == qoriId);
          if (index != -1) {
            final file = File(items[index].localPath);
            if (await file.exists()) {
              await file.delete();
            }
            items.removeAt(index);
            await _saveDownloadedItems(items);
          }
          return const Right(null);
        }
      );
    } catch (e) {
      return Left(CacheFailure('Gagal menghapus unduhan: $e'));
    }
  }

  @override
  Stream<double> downloadSurah(Surah surah, String qoriId, String audioUrl) {
    late StreamController<double> controller;
    final downloadKey = '${surah.nomor}_$qoriId';
    
    _cancelTokens[downloadKey] = CancelToken();

    controller = StreamController<double>(
      onListen: () async {
        try {
          final dir = await getApplicationDocumentsDirectory();
          final savePath = '${dir.path}/surah_${surah.nomor}_qori_$qoriId.mp3';

          await _dio.download(
            audioUrl,
            savePath,
            cancelToken: _cancelTokens[downloadKey],
            onReceiveProgress: (received, total) {
              if (total != -1) {
                controller.add(received / total);
              }
            },
          );

          // Finished successfully, add to shared preferences
          final itemsResult = await getDownloadedItems();
          itemsResult.fold(
            (failure) {},
            (items) async {
              items.add(DownloadItem(
                surah: surah,
                qoriId: qoriId,
                localPath: savePath,
              ));
              await _saveDownloadedItems(items);
            }
          );
          
          controller.add(1.0); // complete
          await controller.close();
        } catch (e) {
          if (e is DioException && e.type == DioExceptionType.cancel) {
            controller.addError('cancelled');
          } else {
            controller.addError(e);
          }
          await controller.close();
        } finally {
          _cancelTokens.remove(downloadKey);
        }
      },
      onCancel: () {
        cancelDownload(surah.nomor, qoriId);
      },
    );

    return controller.stream;
  }

  @override
  void cancelDownload(int surahNomor, String qoriId) {
    final downloadKey = '${surahNomor}_$qoriId';
    if (_cancelTokens.containsKey(downloadKey)) {
      _cancelTokens[downloadKey]?.cancel('Dibatalkan oleh pengguna');
      _cancelTokens.remove(downloadKey);
    }
  }
}
