import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:adhan_reminder/features/adhan/presentation/providers/adhan_provider.dart';
import 'package:adhan_reminder/features/quran/presentation/providers/quran_audio_provider.dart';
import 'package:adhan_reminder/features/quran/presentation/providers/quran_provider.dart';

import 'package:adhan_reminder/features/quran/presentation/providers/quran_download_provider.dart';
import 'package:adhan_reminder/features/settings/presentation/providers/settings_provider.dart';
import 'package:adhan_reminder/features/qibla/presentation/providers/qibla_provider.dart';
import 'package:adhan_reminder/core/di/injection.dart';
import 'package:adhan_reminder/core/services/notification_service.dart';
import 'package:adhan_reminder/core/services/alarm_service.dart';
import 'package:adhan_reminder/core/theme/app_theme.dart';
import 'package:adhan_reminder/core/constants/app_colors.dart';
import 'package:adhan_reminder/core/constants/app_strings.dart';
import 'package:adhan_reminder/core/routes/app_router.dart';
import 'package:adhan_reminder/features/quran/data/services/audio_player_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupInjection();

  await getIt<AudioPlayerService>().initAudioService();

  await getIt<NotificationService>().initialize();
  await getIt<AlarmService>().initialize();

  runApp(const AdhanReminderApp());
}

class AdhanReminderApp extends StatelessWidget {
  const AdhanReminderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: getIt<AdhanProvider>()),
        ChangeNotifierProvider.value(value: getIt<QuranAudioProvider>()),
        ChangeNotifierProvider.value(value: getIt<QuranProvider>()..loadSurahs()),

        ChangeNotifierProvider.value(value: getIt<QuranDownloadProvider>()),
        ChangeNotifierProvider.value(value: getIt<SettingsProvider>()),
        ChangeNotifierProvider.value(value: getIt<QiblaProvider>()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp.router(
            routerConfig: AppRouter.router,
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            themeMode: settingsProvider.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
          );
        },
      ),
    );
  }
}
