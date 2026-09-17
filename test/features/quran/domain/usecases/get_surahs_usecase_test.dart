import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';
import 'package:adhan_reminder/features/quran/domain/repositories/quran_repository.dart';
import 'package:adhan_reminder/features/quran/domain/usecases/get_surahs_usecase.dart';

class MockQuranRepository extends Mock implements QuranRepository {}

void main() {
  late GetSurahsUseCase usecase;
  late MockQuranRepository mockQuranRepository;

  setUp(() {
    mockQuranRepository = MockQuranRepository();
    usecase = GetSurahsUseCase(mockQuranRepository);
  });

  final tSurah = Surah(
    nomor: 1,
    nama: 'Al-Fatihah',
    namaLatin: 'Al-Fatihah',
    jumlahAyat: 7,
    tempatTurun: 'Mekah',
    arti: 'Pembukaan',
    deskripsi: 'Deskripsi singkat',
    audioUrls: {'05': 'url_05'},
  );
  
  final tSurahs = [tSurah];

  test('should get list of surahs from the repository', () async {
    // arrange
    when(() => mockQuranRepository.getSurahList())
        .thenAnswer((_) async => Right(tSurahs));
    
    // act
    final result = await usecase.execute();
    
    // assert
    expect(result, Right(tSurahs));
    verify(() => mockQuranRepository.getSurahList()).called(1);
    verifyNoMoreInteractions(mockQuranRepository);
  });

  test('should return cache failure when repository fails', () async {
    // arrange
    when(() => mockQuranRepository.getSurahList())
        .thenAnswer((_) async => const Left(CacheFailure('Error loading surahs')));
    
    // act
    final result = await usecase.execute();
    
    // assert
    expect(result, const Left(CacheFailure('Error loading surahs')));
    verify(() => mockQuranRepository.getSurahList()).called(1);
    verifyNoMoreInteractions(mockQuranRepository);
  });
}
