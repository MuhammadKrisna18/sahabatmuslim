import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';
import 'package:adhan_reminder/features/quran/domain/entities/download_item.dart';

abstract class QuranDownloadRepository {
  Future<Either<Failure, List<DownloadItem>>> getDownloadedItems();
  Future<Either<Failure, void>> deleteDownloadedItem(int surahNomor, String qoriId);
  Stream<double> downloadSurah(Surah surah, String qoriId, String audioUrl);
  void cancelDownload(int surahNomor, String qoriId);
}
