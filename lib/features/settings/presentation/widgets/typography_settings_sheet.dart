import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:adhan_reminder/features/settings/presentation/providers/settings_provider.dart';
import 'package:adhan_reminder/features/settings/presentation/widgets/font_size_stepper.dart';
import 'package:adhan_reminder/features/settings/presentation/widgets/typography_preview_card.dart';
import 'package:adhan_reminder/core/theme/theme_ext.dart';

class TypographySettingsSheet extends StatelessWidget {
  const TypographySettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pengaturan Teks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: context.textPrimaryColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TypographyPreviewCard(
                    arabicFontSize: settings.arabicFontSize,
                    latinFontSize: settings.latinFontSize,
                  ),
                  const SizedBox(height: 16),
                  FontSizeStepper(
                    title: 'Ukuran Teks Arab',
                    currentSize: settings.arabicFontSize,
                    minSize: SettingsProvider.minArabicFontSize,
                    maxSize: SettingsProvider.maxArabicFontSize,
                    onDecrease: () => settings.decreaseArabicFontSize(),
                    onIncrease: () => settings.increaseArabicFontSize(),
                  ),
                  FontSizeStepper(
                    title: 'Ukuran Teks Latin & Terjemahan',
                    currentSize: settings.latinFontSize,
                    minSize: SettingsProvider.minLatinFontSize,
                    maxSize: SettingsProvider.maxLatinFontSize,
                    onDecrease: () => settings.decreaseLatinFontSize(),
                    onIncrease: () => settings.increaseLatinFontSize(),
                  ),
                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const TypographySettingsSheet(),
    );
  }
}
