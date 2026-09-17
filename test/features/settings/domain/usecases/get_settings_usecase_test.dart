import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/settings/domain/entities/app_settings.dart';
import 'package:adhan_reminder/features/settings/domain/repositories/settings_repository.dart';
import 'package:adhan_reminder/features/settings/domain/usecases/get_settings_usecase.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late GetSettingsUseCase usecase;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    usecase = GetSettingsUseCase(mockRepository);
  });

  final tSettings = AppSettings(
    arabicFontSize: 24,
    latinFontSize: 16,
    showArabic: true,
    showLatin: true,
    showTranslation: true,
  );

  test('should get settings from the repository', () async {
    // arrange
    when(() => mockRepository.getSettings())
        .thenAnswer((_) async => Right(tSettings));
    
    // act
    final result = await usecase.execute();
    
    // assert
    expect(result, Right(tSettings));
    verify(() => mockRepository.getSettings()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return failure when repository fails', () async {
    // arrange
    when(() => mockRepository.getSettings())
        .thenAnswer((_) async => const Left(CacheFailure('Error')));
    
    // act
    final result = await usecase.execute();
    
    // assert
    expect(result, const Left(CacheFailure('Error')));
    verify(() => mockRepository.getSettings()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
