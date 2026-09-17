import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/services.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/quran/data/models/surah_model.dart';
import 'package:adhan_reminder/features/quran/data/models/ayah_model.dart';
import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';
import 'package:adhan_reminder/features/quran/domain/entities/ayah.dart';
import 'package:adhan_reminder/features/quran/domain/repositories/quran_repository.dart';

class QuranRepositoryImpl implements QuranRepository {
  QuranRepositoryImpl();

  @override
  Future<Either<Failure, List<Surah>>> getSurahList() async {
    try {
      final jsonString = await rootBundle.loadString('assets/quran/surat.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> surahData = data['data'];
      final surahs = surahData.map((json) => SurahModel.fromJson(json).toEntity()).toList();
      return Right(surahs);
    } catch (e) {
      return const Left(ServerFailure('Gagal memuat data surah lokal'));
    }
  }

  @override
  Future<Either<Failure, List<Ayah>>> getSurahDetail(int nomorSurah) async {
    try {
      final jsonString = await rootBundle.loadString('assets/quran/surat_$nomorSurah.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> ayahData = data['data']['ayat'];
      final ayahs = ayahData.map((json) => AyahModel.fromJson(json).toEntity()).toList();
      return Right(ayahs);
    } catch (e) {
      return const Left(ServerFailure('Gagal memuat detail surah lokal'));
    }
  }
}
