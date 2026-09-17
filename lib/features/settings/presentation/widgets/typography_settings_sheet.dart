import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'package:adhan_reminder/features/settings/presentation/providers/settings_provider.dart';

class TypographySettingsSheet extends StatelessWidget {
  const TypographySettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pengaturan Teks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Ukuran Teks Arab'),
                  Slider(
                    value: settings.arabicFontSize,
                    min: 24.0,
                    max: 60.0,
                    divisions: 18,
                    label: settings.arabicFontSize.round().toString(),
                    onChanged: (value) {
                      settings.setArabicFontSize(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Ukuran Teks Latin & Terjemahan'),
                  Slider(
                    value: settings.latinFontSize,
                    min: 10.0,
                    max: 24.0,
                    divisions: 14,
                    label: settings.latinFontSize.round().toString(),
                    onChanged: (value) {
                      settings.setLatinFontSize(value);
                    },
                  ),
                  const SizedBox(height: 24),
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
