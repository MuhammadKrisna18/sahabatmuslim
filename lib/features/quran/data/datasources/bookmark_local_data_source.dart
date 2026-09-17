import 'package:adhan_reminder/core/services/storage_service.dart';
import 'package:adhan_reminder/features/quran/domain/entities/bookmark.dart';

abstract class BookmarkLocalDataSource {
  Future<Bookmark?> getBookmark();
  Future<void> saveBookmark(Bookmark bookmark);
  Future<void> deleteBookmark();
}

class BookmarkLocalDataSourceImpl implements BookmarkLocalDataSource {
  final StorageService _storageService;

  BookmarkLocalDataSourceImpl({required StorageService storageService})
      : _storageService = storageService;

  @override
  Future<Bookmark?> getBookmark() async {
    String? surahNomorStr = _storageService.getString('bookmarked_surah_nomor');
    String? surahNamaStr = _storageService.getString('bookmarked_surah_nama');
    String? ayahNomorStr = _storageService.getString('bookmarked_ayah_nomor');

    if (surahNomorStr != null && surahNamaStr != null && ayahNomorStr != null) {
      return Bookmark(
        surahNomor: int.parse(surahNomorStr),
        surahNama: surahNamaStr,
        ayahNomor: int.parse(ayahNomorStr),
      );
    }
    return null;
  }

  @override
  Future<void> saveBookmark(Bookmark bookmark) async {
    await _storageService.setString('bookmarked_surah_nomor', bookmark.surahNomor.toString());
    await _storageService.setString('bookmarked_surah_nama', bookmark.surahNama);
    await _storageService.setString('bookmarked_ayah_nomor', bookmark.ayahNomor.toString());
  }

  @override
  Future<void> deleteBookmark() async {
    await _storageService.remove('bookmarked_surah_nomor');
    await _storageService.remove('bookmarked_surah_nama');
    await _storageService.remove('bookmarked_ayah_nomor');
  }
}
