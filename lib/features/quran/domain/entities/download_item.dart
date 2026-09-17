import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';

class DownloadItem {
  final Surah surah;
  final String qoriId;
  final String localPath;

  DownloadItem({
    required this.surah,
    required this.qoriId,
    required this.localPath,
  });
}
