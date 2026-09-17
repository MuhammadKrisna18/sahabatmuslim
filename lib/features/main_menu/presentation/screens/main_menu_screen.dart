import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:adhan_reminder/features/adhan/presentation/screens/home_screen.dart';
import 'package:adhan_reminder/features/doa/presentation/screens/doa_list_screen.dart';
import 'package:adhan_reminder/features/qibla/presentation/screens/qibla_screen.dart';
import 'package:adhan_reminder/features/sholat/presentation/screens/cara_sholat_screen.dart';
import 'package:adhan_reminder/features/quran/presentation/screens/quran_list_screen.dart';
import 'package:adhan_reminder/core/widgets/mini_audio_player.dart';
import 'package:adhan_reminder/core/constants/app_colors.dart';
import 'package:adhan_reminder/core/theme/theme_ext.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const QiblaScreen(),
    const DoaListScreen(),
    const CaraSholatScreen(),
    const QuranListScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [

          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/watermark.png',
                fit: BoxFit.cover,
                color: context.textPrimaryColor,
                colorBlendMode: BlendMode.srcATop,
              ),
            ),
          ),

          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MiniAudioPlayer(),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(Icons.access_time_filled, 'Jadwal', 0, const Key('nav_jadwal')),
                    _buildNavItem(Icons.explore, 'Kiblat', 1, const Key('nav_kiblat')),
                    _buildNavItem(Icons.menu_book, 'Doa', 2, const Key('nav_doa')),
                    _buildNavItem(Icons.accessibility_new, 'Panduan', 3, const Key('nav_panduan')),
                    _buildNavItem(Icons.import_contacts, 'Qur\'an', 4, const Key('nav_quran')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, Key? key) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.primary : context.textSecondaryColor;
    return GestureDetector(
      key: key,
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
