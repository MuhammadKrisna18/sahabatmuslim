import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:adhan_reminder/features/adhan/domain/entities/adhan_schedule.dart';
import 'package:adhan_reminder/core/widgets/glass_card.dart';
import 'package:adhan_reminder/core/constants/app_colors.dart';

class AdhanScheduleCard extends StatelessWidget {
  final AdhanSchedule schedule;
  final bool isDark;
  final int index;
  final Function(String id, bool isActive) onToggle;
  final Function(AdhanSchedule) onSettingsPressed;
  final bool isNext;

  const AdhanScheduleCard({
    super.key,
    required this.schedule,
    required this.isDark,
    required this.index,
    required this.onToggle,
    required this.onSettingsPressed,
    this.isNext = false,
  });

  Future<bool> _showConfirmation(BuildContext context, bool willActivate) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.textPrimaryLight : AppColors.backgroundDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Konfirmasi',
            style: TextStyle(
              color: isDark ? AppColors.backgroundDark : AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin ${willActivate ? "mengaktifkan" : "menonaktifkan"} adzan untuk ${schedule.id}?',
            style: TextStyle(
              color: isDark ? AppColors.primary.withOpacity(0.3) : AppColors.textSecondaryLight,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.backgroundDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Ya'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSettingsPressed(schedule),
      child: GlassCard(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        borderColor: isNext ? AppColors.primary : null,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isNext
                      ? AppColors.primary.withOpacity(0.3)
                      : (schedule.isActive
                          ? AppColors.primary.withOpacity(0.15)
                          : AppColors.textSecondaryLight.withOpacity(0.1)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mosque,
                  color: schedule.isActive ? AppColors.textPrimaryLight : AppColors.textSecondaryLight,
                  size: 28,
                ),
              ).animate(target: isNext ? 1 : 0, onPlay: (controller) => controller.repeat(reverse: true))
               .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1.seconds, curve: Curves.easeInOut),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      schedule.id,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isNext ? AppColors.primary : (schedule.isActive ? AppColors.textPrimaryLight : AppColors.textSecondaryLight),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      schedule.formattedTime,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: schedule.isActive ? AppColors.textPrimaryLight : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: schedule.isActive,
                onChanged: (val) async {
                  bool confirm = await _showConfirmation(context, val);
                  if (confirm) {
                    onToggle(schedule.id, val);
                  }
                },
                activeColor: AppColors.backgroundLight,
                activeTrackColor: AppColors.primary.withOpacity(0.8),
                inactiveThumbColor: AppColors.textSecondaryLight,
                inactiveTrackColor: AppColors.textSecondaryLight.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    ).animate()
     .fade(delay: (100 * index).ms, duration: 600.ms)
     .slideX(begin: 0.1, end: 0, curve: Curves.easeOut);
  }
}
