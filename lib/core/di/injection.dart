import 'package:get_it/get_it.dart';
import 'package:adhan_reminder/features/quran/data/services/playlist_manager.dart';
import 'package:adhan_reminder/features/adhan/data/repositories/prayer_time_repository_impl.dart';
import 'package:adhan_reminder/features/adhan/domain/repositories/prayer_time_repository.dart';
import 'package:adhan_reminder/features/adhan/domain/usecases/get_prayer_times_usecase.dart';
import 'package:adhan_reminder/features/quran/data/repositories/quran_repository_impl.dart';
import 'package:adhan_reminder/features/quran/domain/repositories/quran_repository.dart';
import 'package:adhan_reminder/features/quran/domain/usecases/get_surahs_usecase.dart';
import 'package:adhan_reminder/features/quran/domain/usecases/get_surah_detail_usecase.dart';

import 'package:adhan_reminder/features/quran/data/datasources/bookmark_local_data_source.dart';
import 'package:adhan_reminder/features/quran/data/repositories/bookmark_repository_impl.dart';
import 'package:adhan_reminder/features/quran/domain/repositories/bookmark_repository.dart';
import 'package:adhan_reminder/features/quran/domain/usecases/get_bookmark_usecase.dart';
import 'package:adhan_reminder/features/quran/domain/usecases/save_bookmark_usecase.dart';
import 'package:adhan_reminder/features/quran/domain/usecases/delete_bookmark_usecase.dart';

import 'package:adhan_reminder/features/quran/data/repositories/quran_download_repository_impl.dart';
import 'package:adhan_reminder/features/quran/domain/repositories/quran_download_repository.dart';
import 'package:adhan_reminder/features/quran/domain/usecases/get_downloaded_audio_usecase.dart';
import 'package:adhan_reminder/features/quran/domain/usecases/download_audio_usecase.dart';
import 'package:adhan_reminder/features/quran/domain/usecases/delete_downloaded_audio_usecase.dart';
import 'package:adhan_reminder/features/quran/domain/usecases/cancel_download_usecase.dart';

import 'package:adhan_reminder/features/doa/data/repositories/doa_repository_impl.dart';
import 'package:adhan_reminder/features/doa/domain/repositories/doa_repository.dart';
import 'package:adhan_reminder/features/doa/domain/usecases/get_doa_list_usecase.dart';
import 'package:adhan_reminder/features/doa/presentation/providers/doa_provider.dart';

import 'package:adhan_reminder/features/sholat/data/repositories/sholat_repository_impl.dart';
import 'package:adhan_reminder/features/sholat/domain/repositories/sholat_repository.dart';
import 'package:adhan_reminder/features/sholat/domain/usecases/get_cara_sholat_usecase.dart';
import 'package:adhan_reminder/features/sholat/presentation/providers/sholat_provider.dart';

import 'package:adhan_reminder/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:adhan_reminder/features/settings/domain/repositories/settings_repository.dart';
import 'package:adhan_reminder/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:adhan_reminder/features/settings/domain/usecases/save_settings_usecase.dart';

import 'package:adhan_reminder/features/qibla/data/repositories/qibla_repository_impl.dart';
import 'package:adhan_reminder/features/qibla/domain/repositories/qibla_repository.dart';
import 'package:adhan_reminder/features/qibla/domain/usecases/get_qibla_direction_usecase.dart';

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
  // Services
  final storageService = StorageService();
  await storageService.init();
  getIt.registerSingleton<StorageService>(storageService);
  
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
  getIt.registerLazySingleton<AlarmService>(() => AlarmService());
  getIt.registerLazySingleton<AudioPlayerService>(() => AudioPlayerService());

  // Data Sources
  getIt.registerLazySingleton<BookmarkLocalDataSource>(
      () => BookmarkLocalDataSourceImpl(storageService: getIt<StorageService>()));

  // Repositories
  getIt.registerLazySingleton<PrayerTimeRepository>(() => PrayerTimeRepositoryImpl());
  getIt.registerLazySingleton<QuranRepository>(() => QuranRepositoryImpl());
  getIt.registerLazySingleton<DoaRepository>(() => DoaRepositoryImpl());
  getIt.registerLazySingleton<SholatRepository>(() => SholatRepositoryImpl());
  getIt.registerLazySingleton<QiblaRepository>(() => QiblaRepositoryImpl());
  getIt.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(getIt<StorageService>()));
  getIt.registerLazySingleton<BookmarkRepository>(
      () => BookmarkRepositoryImpl(localDataSource: getIt<BookmarkLocalDataSource>()));
  getIt.registerLazySingleton<QuranDownloadRepository>(
      () => QuranDownloadRepositoryImpl());

  // UseCases
  getIt.registerLazySingleton<GetPrayerTimesUseCase>(() => GetPrayerTimesUseCase(getIt<PrayerTimeRepository>()));
  getIt.registerLazySingleton<GetSurahsUseCase>(() => GetSurahsUseCase(getIt<QuranRepository>()));
  getIt.registerLazySingleton<GetSurahDetailUseCase>(() => GetSurahDetailUseCase(getIt<QuranRepository>()));
  getIt.registerLazySingleton<GetDoaListUseCase>(() => GetDoaListUseCase(getIt<DoaRepository>()));
  getIt.registerLazySingleton<GetCaraSholatUseCase>(() => GetCaraSholatUseCase(getIt<SholatRepository>()));
  getIt.registerLazySingleton<GetQiblaDirectionUseCase>(() => GetQiblaDirectionUseCase(getIt<QiblaRepository>()));
  getIt.registerLazySingleton<GetSettingsUseCase>(() => GetSettingsUseCase(getIt<SettingsRepository>()));
  getIt.registerLazySingleton<SaveSettingsUseCase>(() => SaveSettingsUseCase(getIt<SettingsRepository>()));
  
  getIt.registerLazySingleton<GetBookmarkUseCase>(() => GetBookmarkUseCase(getIt<BookmarkRepository>()));
  getIt.registerLazySingleton<SaveBookmarkUseCase>(() => SaveBookmarkUseCase(getIt<BookmarkRepository>()));
  getIt.registerLazySingleton<DeleteBookmarkUseCase>(() => DeleteBookmarkUseCase(getIt<BookmarkRepository>()));
  
  getIt.registerLazySingleton<GetDownloadedAudioUseCase>(() => GetDownloadedAudioUseCase(getIt<QuranDownloadRepository>()));
  getIt.registerLazySingleton<DownloadAudioUseCase>(() => DownloadAudioUseCase(getIt<QuranDownloadRepository>()));
  getIt.registerLazySingleton<DeleteDownloadedAudioUseCase>(() => DeleteDownloadedAudioUseCase(getIt<QuranDownloadRepository>()));
  getIt.registerLazySingleton<CancelDownloadUseCase>(() => CancelDownloadUseCase(getIt<QuranDownloadRepository>()));

  // Providers
  getIt.registerLazySingleton<QuranDownloadProvider>(() => QuranDownloadProvider(
        getDownloadedAudioUseCase: getIt<GetDownloadedAudioUseCase>(),
        downloadAudioUseCase: getIt<DownloadAudioUseCase>(),
        deleteDownloadedAudioUseCase: getIt<DeleteDownloadedAudioUseCase>(),
        cancelDownloadUseCase: getIt<CancelDownloadUseCase>(),
      ));
      
  getIt.registerLazySingleton<AdhanProvider>(() => AdhanProvider(
        getPrayerTimesUseCase: getIt<GetPrayerTimesUseCase>(),
        storageService: getIt<StorageService>(),
        alarmService: getIt<AlarmService>(),
      ));
  
  getIt.registerLazySingleton<QuranProvider>(() => QuranProvider(
        getSurahsUseCase: getIt<GetSurahsUseCase>(),
        getSurahDetailUseCase: getIt<GetSurahDetailUseCase>(),
        getBookmarkUseCase: getIt<GetBookmarkUseCase>(),
        saveBookmarkUseCase: getIt<SaveBookmarkUseCase>(),
        deleteBookmarkUseCase: getIt<DeleteBookmarkUseCase>(),
      ));

  getIt.registerLazySingleton<PlaylistManager>(() => PlaylistManager(
    audioPlayerService: getIt<AudioPlayerService>(),
    quranDownloadProvider: getIt<QuranDownloadProvider>(),
  ));

  getIt.registerLazySingleton<QuranAudioProvider>(() => QuranAudioProvider(
    audioPlayerService: getIt<AudioPlayerService>(),
    quranProvider: getIt<QuranProvider>(),
    playlistManager: getIt<PlaylistManager>(),
  ));

  getIt.registerLazySingleton<SettingsProvider>(() => SettingsProvider(
    getSettingsUseCase: getIt<GetSettingsUseCase>(),
    saveSettingsUseCase: getIt<SaveSettingsUseCase>(),
  ));
  
  getIt.registerLazySingleton<QiblaProvider>(() => QiblaProvider(
    getQiblaDirectionUseCase: getIt<GetQiblaDirectionUseCase>(),
  ));

  getIt.registerLazySingleton<DoaProvider>(() => DoaProvider(
    getDoaListUseCase: getIt<GetDoaListUseCase>(),
  ));

  getIt.registerLazySingleton<SholatProvider>(() => SholatProvider(
    getCaraSholatUseCase: getIt<GetCaraSholatUseCase>(),
  ));
}
