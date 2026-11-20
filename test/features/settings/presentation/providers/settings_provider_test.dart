import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:adhan_reminder/core/error/failures.dart';
import 'package:adhan_reminder/features/settings/domain/entities/app_settings.dart';
import 'package:adhan_reminder/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:adhan_reminder/features/settings/domain/usecases/save_settings_usecase.dart';
import 'package:adhan_reminder/features/settings/presentation/providers/settings_provider.dart';

class MockGetSettingsUseCase extends Mock implements GetSettingsUseCase {}
class MockSaveSettingsUseCase extends Mock implements SaveSettingsUseCase {}

void main() {
  late MockGetSettingsUseCase mockGetSettingsUseCase;
  late MockSaveSettingsUseCase mockSaveSettingsUseCase;

  setUpAll(() {
    registerFallbackValue(AppSettings());
  });

  setUp(() {
    mockGetSettingsUseCase = MockGetSettingsUseCase();
    mockSaveSettingsUseCase = MockSaveSettingsUseCase();

    when(() => mockSaveSettingsUseCase.execute(any()))
        .thenAnswer((_) async => const Right(null));
  });

  test('initializes with loaded settings when getSettingsUseCase succeeds', () async {
    when(() => mockGetSettingsUseCase.execute()).thenAnswer((_) async => Right(
      AppSettings(arabicFontSize: 28.0, latinFontSize: 16.0),
    ));

    final provider = SettingsProvider(
      getSettingsUseCase: mockGetSettingsUseCase,
      saveSettingsUseCase: mockSaveSettingsUseCase,
    );

    await Future.delayed(Duration.zero);

    expect(provider.arabicFontSize, 28.0);
    expect(provider.latinFontSize, 16.0);
  });

  test('initializes with fallback settings when getSettingsUseCase fails', () async {
    when(() => mockGetSettingsUseCase.execute())
        .thenAnswer((_) async => const Left(CacheFailure('Error')));

    final provider = SettingsProvider(
      getSettingsUseCase: mockGetSettingsUseCase,
      saveSettingsUseCase: mockSaveSettingsUseCase,
    );

    await Future.delayed(Duration.zero);

    expect(provider.arabicFontSize, 36.0);
    expect(provider.latinFontSize, 14.0);
  });

  test('increaseArabicFontSize increases font size and clamps at maximum', () async {
    when(() => mockGetSettingsUseCase.execute()).thenAnswer((_) async => Right(
      AppSettings(arabicFontSize: 54.0),
    ));

    final provider = SettingsProvider(
      getSettingsUseCase: mockGetSettingsUseCase,
      saveSettingsUseCase: mockSaveSettingsUseCase,
    );

    await Future.delayed(Duration.zero);

    await provider.increaseArabicFontSize(2.0);
    expect(provider.arabicFontSize, 56.0);

    await provider.increaseArabicFontSize(4.0);
    expect(provider.arabicFontSize, SettingsProvider.maxArabicFontSize);
    verify(() => mockSaveSettingsUseCase.execute(any())).called(2);
  });

  test('decreaseArabicFontSize decreases font size and clamps at minimum', () async {
    when(() => mockGetSettingsUseCase.execute()).thenAnswer((_) async => Right(
      AppSettings(arabicFontSize: 22.0),
    ));

    final provider = SettingsProvider(
      getSettingsUseCase: mockGetSettingsUseCase,
      saveSettingsUseCase: mockSaveSettingsUseCase,
    );

    await Future.delayed(Duration.zero);

    await provider.decreaseArabicFontSize(2.0);
    expect(provider.arabicFontSize, 20.0);

    await provider.decreaseArabicFontSize(5.0);
    expect(provider.arabicFontSize, SettingsProvider.minArabicFontSize);
    verify(() => mockSaveSettingsUseCase.execute(any())).called(2);
  });

  test('increaseLatinFontSize increases font size and clamps at maximum', () async {
    when(() => mockGetSettingsUseCase.execute()).thenAnswer((_) async => Right(
      AppSettings(latinFontSize: 23.0),
    ));

    final provider = SettingsProvider(
      getSettingsUseCase: mockGetSettingsUseCase,
      saveSettingsUseCase: mockSaveSettingsUseCase,
    );

    await Future.delayed(Duration.zero);

    await provider.increaseLatinFontSize(1.0);
    expect(provider.latinFontSize, 24.0);

    await provider.increaseLatinFontSize(2.0);
    expect(provider.latinFontSize, SettingsProvider.maxLatinFontSize);
  });

  test('decreaseLatinFontSize decreases font size and clamps at minimum', () async {
    when(() => mockGetSettingsUseCase.execute()).thenAnswer((_) async => Right(
      AppSettings(latinFontSize: 11.0),
    ));

    final provider = SettingsProvider(
      getSettingsUseCase: mockGetSettingsUseCase,
      saveSettingsUseCase: mockSaveSettingsUseCase,
    );

    await Future.delayed(Duration.zero);

    await provider.decreaseLatinFontSize(1.0);
    expect(provider.latinFontSize, 10.0);

    await provider.decreaseLatinFontSize(3.0);
    expect(provider.latinFontSize, SettingsProvider.minLatinFontSize);
  });
}
