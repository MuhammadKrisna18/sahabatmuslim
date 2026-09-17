import 'package:flutter/foundation.dart';
import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';
import 'package:adhan_reminder/features/quran/domain/entities/ayah.dart';
import 'package:adhan_reminder/core/services/storage_service.dart';
import 'package:adhan_reminder/features/quran/domain/usecases/get_surahs_usecase.dart';
import 'package:adhan_reminder/features/quran/domain/usecases/get_surah_detail_usecase.dart';

class QuranProvider with ChangeNotifier {
  final GetSurahsUseCase _getSurahsUseCase;
  final GetSurahDetailUseCase _getSurahDetailUseCase;
  final StorageService _storage;

  QuranProvider({
    required GetSurahsUseCase getSurahsUseCase,
    required GetSurahDetailUseCase getSurahDetailUseCase,
    required StorageService storageService,
  })  : _getSurahsUseCase = getSurahsUseCase,
        _getSurahDetailUseCase = getSurahDetailUseCase,
        _storage = storageService;

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
    String? bSurahNomorStr = _storage.getString('bookmarked_surah_nomor');
    String? bSurahNamaStr = _storage.getString('bookmarked_surah_nama');
    String? bAyahNomorStr = _storage.getString('bookmarked_ayah_nomor');

    _bookmarkedSurahNomor = bSurahNomorStr != null ? int.parse(bSurahNomorStr) : null;
    _bookmarkedSurahNama = bSurahNamaStr;
    _bookmarkedAyahNomor = bAyahNomorStr != null ? int.parse(bAyahNomorStr) : null;
    
    notifyListeners();
  }

  Future<void> saveBookmark(Surah surah, Ayah ayah) async {
    if (_bookmarkedAyahNomor == ayah.nomorAyat && _bookmarkedSurahNomor == surah.nomor) {
      await _storage.remove('bookmarked_surah_nomor');
      await _storage.remove('bookmarked_surah_nama');
      await _storage.remove('bookmarked_ayah_nomor');
      _bookmarkedSurahNomor = null;
      _bookmarkedSurahNama = null;
      _bookmarkedAyahNomor = null;
    } else {
      await _storage.setString('bookmarked_surah_nomor', surah.nomor.toString());
      await _storage.setString('bookmarked_surah_nama', surah.namaLatin);
      await _storage.setString('bookmarked_ayah_nomor', ayah.nomorAyat.toString());
      _bookmarkedSurahNomor = surah.nomor;
      _bookmarkedSurahNama = surah.namaLatin;
      _bookmarkedAyahNomor = ayah.nomorAyat;
    }
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
