import 'package:get_it/get_it.dart';
import 'package:adhan_reminder/features/adhan/data/repositories/prayer_time_repository_impl.dart';
import 'package:adhan_reminder/features/adhan/domain/repositories/prayer_time_repository.dart';
import 'package:adhan_reminder/features/adhan/domain/usecases/get_prayer_times_usecase.dart';
import 'package:adhan_reminder/features/quran/data/repositories/quran_repository_impl.dart';
import 'package:adhan_reminder/features/quran/domain/repositories/quran_repository.dart';
import 'package:adhan_reminder/features/quran/domain/usecases/get_surahs_usecase.dart';
import 'package:adhan_reminder/features/quran/domain/usecases/get_surah_detail_usecase.dart';

import 'package:adhan_reminder/features/quran/presentation/providers/quran_download_provider.dart';


import 'package:adhan_reminder/core/services/notification_service.dart';
import 'package:adhan_reminder/core/services/alarm_service.dart';
import 'package:adhan_reminder/features/quran/data/services/audio_player_service.dart';
import 'package:adhan_reminder/core/services/storage_service.dart';
import 'package:adhan_reminder/features/adhan/presentation/providers/adhan_provider.dart';
import 'package:adhan_reminder/features/quran/presentation/providers/quran_audio_provider.dart';
import 'package:adhan_reminder/features/quran/presentation/providers/quran_provider.dart';

import 'package:adhan_reminder/features/settings/presentation/providers/settings_provider.dart';

import 'package:adhan_reminder/features/qibla/presentation/providers/qibla_provider.dart';

final getIt = GetIt.instance;

Future<void> setupInjection() async {

  final storageService = StorageService();
  await storageService.init();
  getIt.registerSingleton<StorageService>(storageService);


  getIt.registerLazySingleton<PrayerTimeRepository>(() => PrayerTimeRepositoryImpl());
  getIt.registerLazySingleton<QuranRepository>(() => QuranRepositoryImpl());



  getIt.registerLazySingleton<GetPrayerTimesUseCase>(() => GetPrayerTimesUseCase(getIt<PrayerTimeRepository>()));
  getIt.registerLazySingleton<GetSurahsUseCase>(() => GetSurahsUseCase(getIt<QuranRepository>()));
  getIt.registerLazySingleton<GetSurahDetailUseCase>(() => GetSurahDetailUseCase(getIt<QuranRepository>()));




  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  getIt.registerLazySingleton<AlarmService>(() => AlarmService());
  getIt.registerLazySingleton<AudioPlayerService>(() => AudioPlayerService());


  getIt.registerLazySingleton<QuranDownloadProvider>(() => QuranDownloadProvider());
  getIt.registerLazySingleton<AdhanProvider>(() => AdhanProvider(
        getPrayerTimesUseCase: getIt<GetPrayerTimesUseCase>(),
        storageService: getIt<StorageService>(),
        alarmService: getIt<AlarmService>(),
      ));
  getIt.registerLazySingleton<QuranAudioProvider>(() => QuranAudioProvider());
  getIt.registerLazySingleton<QuranProvider>(() => QuranProvider(
        getSurahsUseCase: getIt<GetSurahsUseCase>(),
        getSurahDetailUseCase: getIt<GetSurahDetailUseCase>(),
        storageService: getIt<StorageService>(),
      ));

  getIt.registerLazySingleton<SettingsProvider>(() => SettingsProvider(
    storageService: getIt<StorageService>(),
  ));
  getIt.registerLazySingleton<QiblaProvider>(() => QiblaProvider());
}
