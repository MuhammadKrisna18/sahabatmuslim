import 'package:adhan_reminder/features/quran/domain/entities/download_item.dart';
import 'package:adhan_reminder/features/quran/data/models/surah_model.dart';

class DownloadItemModel extends DownloadItem {
  DownloadItemModel({
    required super.surah,
    required super.qoriId,
    required super.localPath,
  });

  factory DownloadItemModel.fromJson(Map<String, dynamic> json) {
    return DownloadItemModel(
      surah: SurahModel.fromJson(json['surah']).toEntity(),
      qoriId: json['qoriId'],
      localPath: json['localPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surah': SurahModel.fromEntity(surah).toJson(),
      'qoriId': qoriId,
      'localPath': localPath,
    };
  }

  factory DownloadItemModel.fromEntity(DownloadItem entity) {
    return DownloadItemModel(
      surah: entity.surah,
      qoriId: entity.qoriId,
      localPath: entity.localPath,
    );
  }

  DownloadItem toEntity() {
    return DownloadItem(
      surah: surah,
      qoriId: qoriId,
      localPath: localPath,
    );
  }
}
