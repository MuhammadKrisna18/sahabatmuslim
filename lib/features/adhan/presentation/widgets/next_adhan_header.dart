import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:adhan_reminder/core/widgets/glass_card.dart';
import 'package:adhan_reminder/core/constants/app_colors.dart';
import 'package:adhan_reminder/core/theme/theme_ext.dart';

class NextAdhanHeader extends StatelessWidget {
  final String timeString;
  final String nextAdhanText;
  final bool isDark;
  final VoidCallback onSettingsPressed;

  const NextAdhanHeader({
    super.key,
    required this.timeString,
    required this.nextAdhanText,
    required this.isDark,
    required this.onSettingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 16, right: 16, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  'SahabatMuslim',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(color: AppColors.primary, fontSize: 26, letterSpacing: 2, fontWeight: FontWeight.bold),
                ).animate().fade(duration: 800.ms).slideY(begin: -0.2, end: 0, curve: Curves.easeOut),
              ),
              Positioned(
                right: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.volume_up_rounded, color: context.backgroundColor, size: 28),
                      tooltip: 'Pengaturan Volume Global',
                      onPressed: onSettingsPressed,
                    ).animate().fade(delay: 200.ms).scale(),
                    IconButton(
                      icon: Icon(Icons.settings, color: context.backgroundColor, size: 28),
                      tooltip: 'Pengaturan Aplikasi',
                      onPressed: () {
                        context.push('/settings');
                      },
                    ).animate().fade(delay: 300.ms).scale(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            timeString,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.backgroundColor,
              fontSize: 60,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ).animate(onPlay: (controller) => controller.repeat())
           .shimmer(duration: 3000.ms, color: context.textSecondaryColor),
          const SizedBox(height: 5),
          Builder(
            builder: (context) {
              final now = DateTime.now();
              final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
              final months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
              final dateString = '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';

              return Text(
                dateString,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.textSecondaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fade(delay: 300.ms);
            }
          ),
          const SizedBox(height: 15),
          GlassCard(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Text(
                nextAdhanText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ).animate().fade(delay: 400.ms, duration: 600.ms).scale(curve: Curves.easeOutBack),
        ],
      ),
    );
  }
}
