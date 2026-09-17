import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:adhan_reminder/features/main_menu/presentation/screens/splash_screen.dart';
import 'package:adhan_reminder/features/main_menu/presentation/screens/main_menu_screen.dart';
import 'package:adhan_reminder/features/settings/presentation/screens/settings_screen.dart';
import 'package:adhan_reminder/features/quran/presentation/screens/surah_detail_screen.dart';
import 'package:adhan_reminder/features/quran/presentation/screens/downloaded_audio_screen.dart';
import 'package:adhan_reminder/features/adhan/presentation/screens/doa_screen.dart';
import 'package:adhan_reminder/features/adhan/presentation/screens/add_schedule_screen.dart';
import 'package:adhan_reminder/features/adhan/domain/entities/adhan_schedule.dart';
import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/main',
        name: 'main',
        builder: (context, state) => const MainMenuScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/surah/:id',
        name: 'surah_detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return SurahDetailScreen(
            surah: extra?['surah'] as Surah,
            initialAyah: extra?['initialAyah'] as int?,
            allSurahs: extra?['allSurahs'] as List<Surah>?,
          );
        },
      ),
      GoRoute(
        path: '/downloaded-audio',
        name: 'downloaded_audio',
        builder: (context, state) => const DownloadedAudioScreen(),
      ),
      GoRoute(
        path: '/edit-schedule',
        name: 'edit_schedule',
        pageBuilder: (context, state) {
          final schedule = state.extra as AdhanSchedule;
          return CustomTransitionPage(
            key: state.pageKey,
            child: AddScheduleScreen(existingSchedule: schedule),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
          );
        },
      ),
      GoRoute(
        path: '/doa',
        name: 'doa',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: DoaScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeOutCubic));
              return SlideTransition(position: animation.drive(tween), child: child);
            },
          );
        },
      ),
    ],
  );
}
