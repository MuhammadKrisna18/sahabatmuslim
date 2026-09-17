import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adhan_reminder/features/adhan/domain/entities/adhan_schedule.dart';
import 'package:adhan_reminder/core/constants/app_colors.dart';
import 'package:adhan_reminder/core/theme/theme_ext.dart';

class AlarmDialog extends StatelessWidget {
  final AdhanSchedule schedule;
  final VoidCallback onStopAndPray;

  const AlarmDialog({
    super.key,
    required this.schedule,
    required this.onStopAndPray,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      title: Text(
        'Waktunya Adzan!',
        textAlign: TextAlign.center,
        style: GoogleFonts.amiri(
          color: AppColors.primary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.mosque, size: 70, color: AppColors.primary)
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 2000.ms, color: context.textSecondaryColor)
              .scaleXY(begin: 0.95, end: 1.05, duration: 1000.ms, curve: Curves.easeInOut)
              .then()
              .scaleXY(begin: 1.05, end: 0.95, duration: 1000.ms, curve: Curves.easeInOut),
          SizedBox(height: 20),
          Text(
            'Jadwal sholat ${schedule.id} (${schedule.formattedTime}) telah tiba.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: context.textSecondaryColor),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: context.backgroundColor,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 5,
          ),
          onPressed: onStopAndPray,
          child: const Text('HENTIKAN & LIHAT DOA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        )
      ],
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }
}
