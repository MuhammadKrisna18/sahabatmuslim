import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/quran/domain/entities/ayah.dart';
import 'package:adhan_reminder/features/quran/domain/repositories/quran_repository.dart';
import 'package:adhan_reminder/features/quran/domain/usecases/get_surah_detail_usecase.dart';

class MockQuranRepository extends Mock implements QuranRepository {}

void main() {
  late GetSurahDetailUseCase usecase;
  late MockQuranRepository mockQuranRepository;

  setUp(() {
    mockQuranRepository = MockQuranRepository();
    usecase = GetSurahDetailUseCase(mockQuranRepository);
  });

  final tNomor = 1;
  final tAyah = Ayah(
    nomorAyat: 1,
    teksArab: 'بسم الله',
    teksLatin: 'Bismillah',
    teksIndonesia: 'Dengan nama Allah',
    audioUrls: {'05': 'url'},
  );
  final tAyahs = [tAyah];

  test('should get list of ayahs from the repository', () async {
    // arrange
    when(() => mockQuranRepository.getSurahDetail(tNomor))
        .thenAnswer((_) async => Right(tAyahs));
    
    // act
    final result = await usecase.execute(tNomor);
    
    // assert
    expect(result, Right(tAyahs));
    verify(() => mockQuranRepository.getSurahDetail(tNomor)).called(1);
    verifyNoMoreInteractions(mockQuranRepository);
  });

  test('should return cache failure when repository fails', () async {
    // arrange
    when(() => mockQuranRepository.getSurahDetail(tNomor))
        .thenAnswer((_) async => const Left(CacheFailure('Error loading ayah')));
    
    // act
    final result = await usecase.execute(tNomor);
    
    // assert
    expect(result, const Left(CacheFailure('Error loading ayah')));
    verify(() => mockQuranRepository.getSurahDetail(tNomor)).called(1);
    verifyNoMoreInteractions(mockQuranRepository);
  });
}
