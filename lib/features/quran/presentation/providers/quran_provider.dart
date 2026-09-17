import 'package:flutter/foundation.dart';
import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';
import 'package:adhan_reminder/features/quran/domain/entities/ayah.dart';
import 'package:adhan_reminder/features/quran/domain/entities/bookmark.dart';
import 'package:adhan_reminder/features/quran/domain/usecases/get_surahs_usecase.dart';
import 'package:adhan_reminder/features/quran/domain/usecases/get_surah_detail_usecase.dart';
import 'package:adhan_reminder/features/quran/domain/usecases/get_bookmark_usecase.dart';
import 'package:adhan_reminder/features/quran/domain/usecases/save_bookmark_usecase.dart';
import 'package:adhan_reminder/features/quran/domain/usecases/delete_bookmark_usecase.dart';

class QuranProvider with ChangeNotifier {
  final GetSurahsUseCase _getSurahsUseCase;
  final GetSurahDetailUseCase _getSurahDetailUseCase;
  final GetBookmarkUseCase _getBookmarkUseCase;
  final SaveBookmarkUseCase _saveBookmarkUseCase;
  final DeleteBookmarkUseCase _deleteBookmarkUseCase;

  QuranProvider({
    required GetSurahsUseCase getSurahsUseCase,
    required GetSurahDetailUseCase getSurahDetailUseCase,
    required GetBookmarkUseCase getBookmarkUseCase,
    required SaveBookmarkUseCase saveBookmarkUseCase,
    required DeleteBookmarkUseCase deleteBookmarkUseCase,
  })  : _getSurahsUseCase = getSurahsUseCase,
        _getSurahDetailUseCase = getSurahDetailUseCase,
        _getBookmarkUseCase = getBookmarkUseCase,
        _saveBookmarkUseCase = saveBookmarkUseCase,
        _deleteBookmarkUseCase = deleteBookmarkUseCase;

  List<Surah> _surahList = [];
  List<Surah> get surahList => _surahList;

  bool _isLoadingSurahs = false;
  bool get isLoadingSurahs => _isLoadingSurahs;

  String? _errorSurahs;
  String? get errorSurahs => _errorSurahs;

  String? _errorAyahs;
  String? get errorAyahs => _errorAyahs;

  final Map<int, List<Ayah>> _ayahCache = {};

  bool _isLoadingAyahs = false;
  bool get isLoadingAyahs => _isLoadingAyahs;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  int? _bookmarkedSurahNomor;
  int? get bookmarkedSurahNomor => _bookmarkedSurahNomor;

  String? _bookmarkedSurahNama;
  String? get bookmarkedSurahNama => _bookmarkedSurahNama;

  int? _bookmarkedAyahNomor;
  int? get bookmarkedAyahNomor => _bookmarkedAyahNomor;

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Surah> get filteredSurahList {
    if (_searchQuery.isEmpty) return _surahList;
    return _surahList.where((surah) {
      return surah.namaLatin.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> loadBookmark() async {
    final result = await _getBookmarkUseCase.execute();
    result.fold(
      (failure) {
        _bookmarkedSurahNomor = null;
        _bookmarkedSurahNama = null;
        _bookmarkedAyahNomor = null;
      },
      (bookmark) {
        if (bookmark != null) {
          _bookmarkedSurahNomor = bookmark.surahNomor;
          _bookmarkedSurahNama = bookmark.surahNama;
          _bookmarkedAyahNomor = bookmark.ayahNomor;
        } else {
          _bookmarkedSurahNomor = null;
          _bookmarkedSurahNama = null;
          _bookmarkedAyahNomor = null;
        }
      },
    );
    notifyListeners();
  }

  Future<void> saveBookmark(Surah surah, Ayah ayah) async {
    if (_bookmarkedAyahNomor == ayah.nomorAyat && _bookmarkedSurahNomor == surah.nomor) {
      await _deleteBookmarkUseCase.execute();
      _bookmarkedSurahNomor = null;
      _bookmarkedSurahNama = null;
      _bookmarkedAyahNomor = null;
    } else {
      final bookmark = Bookmark(
        surahNomor: surah.nomor,
        surahNama: surah.namaLatin,
        ayahNomor: ayah.nomorAyat,
      );
      await _saveBookmarkUseCase.execute(bookmark);
      _bookmarkedSurahNomor = surah.nomor;
      _bookmarkedSurahNama = surah.namaLatin;
      _bookmarkedAyahNomor = ayah.nomorAyat;
    }
    notifyListeners();
  }

  Future<void> saveSurahBookmark(Surah surah) async {
    final bookmark = Bookmark(
      surahNomor: surah.nomor,
      surahNama: surah.namaLatin,
      ayahNomor: 1,
    );
    await _saveBookmarkUseCase.execute(bookmark);
    _bookmarkedSurahNomor = surah.nomor;
    _bookmarkedSurahNama = surah.namaLatin;
    _bookmarkedAyahNomor = 1;
    notifyListeners();
  }

  Future<void> loadSurahs() async {
    if (_surahList.isNotEmpty) return;

    _isLoadingSurahs = true;
    _errorSurahs = null;
    notifyListeners();

    final result = await _getSurahsUseCase.execute();

    result.fold(
      (failure) => _errorSurahs = failure.message,
      (surahs) => _surahList = surahs,
    );

    _isLoadingSurahs = false;
    notifyListeners();
  }

  Future<void> loadAyahs(int surahNumber) async {
    if (_ayahCache.containsKey(surahNumber)) return;

    _isLoadingAyahs = true;
    _errorAyahs = null;
    notifyListeners();

    final result = await _getSurahDetailUseCase.execute(surahNumber);

    result.fold(
      (failure) {
        _errorAyahs = failure.message;
      },
      (ayahs) {
        _ayahCache[surahNumber] = ayahs;
      },
    );

    _isLoadingAyahs = false;
    notifyListeners();
  }

  List<Ayah>? getAyahs(int surahNumber) {
    return _ayahCache[surahNumber];
  }
}
