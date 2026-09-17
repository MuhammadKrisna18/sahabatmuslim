import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adhan_reminder/features/quran/domain/entities/ayah.dart';
import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';
import 'package:adhan_reminder/core/widgets/glass_card.dart';
import 'package:adhan_reminder/features/settings/presentation/providers/settings_provider.dart';
import 'package:adhan_reminder/core/constants/app_colors.dart';
import 'package:adhan_reminder/core/theme/theme_ext.dart';

class AyahCard extends StatelessWidget {
  final Ayah ayah;
  final Surah surah;
  final SettingsProvider settings;
  final int? bookmarkedAyah;
  final Function(Ayah) onSaveBookmark;

  const AyahCard({
    super.key,
    required this.ayah,
    required this.surah,
    required this.settings,
    required this.bookmarkedAyah,
    required this.onSaveBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Ayat ${ayah.nomorAyat}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        bookmarkedAyah == ayah.nomorAyat ? Icons.bookmark : Icons.bookmark_add_outlined,
                        color: bookmarkedAyah == ayah.nomorAyat ? Colors.amber : context.textPrimaryColor
                      ),
                      onPressed: () => onSaveBookmark(ayah),
                      tooltip: 'Tandai terakhir dibaca',
                    ),
                    PopupMenuButton<int>(
                      icon: const Icon(Icons.copy, size: 20, color: Colors.grey),
                      onSelected: (value) async {
                        String header = '[QS. ${surah.namaLatin}: ${ayah.nomorAyat}]\n\n';
                        String copyText = '';
                        if (value == 1) {
                          copyText = '$header${ayah.teksArab}';
                        } else if (value == 2) {
                          copyText = '$header${ayah.teksIndonesia}';
                        } else if (value == 3) {
                          copyText = '$header${ayah.teksArab}\n\n${ayah.teksIndonesia}';
                        }

                        await Clipboard.setData(ClipboardData(text: copyText));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Teks berhasil disalin')),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 1, child: Text('Salin Ayat (Arab)')),
                        const PopupMenuItem(value: 2, child: Text('Salin Terjemahan')),
                        const PopupMenuItem(value: 3, child: Text('Salin Keduanya')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            if (settings.showArabic) ...[
              const SizedBox(height: 16),
              Text(
                ayah.teksArab,
                textAlign: TextAlign.right,
                style: GoogleFonts.amiri(
                  color: context.textPrimaryColor,
                  fontSize: settings.arabicFontSize,
                  height: 2.2,
                ),
              ),
            ],
            if (settings.showLatin) ...[
              const SizedBox(height: 16),
              Text(
                ayah.teksLatinSanitized,
                style: TextStyle(
                  color: AppColors.primary,
                  fontStyle: FontStyle.italic,
                  fontSize: settings.latinFontSize,
                  height: 1.5,
                ),
              ),
            ],
            if (settings.showTranslation) ...[
              const SizedBox(height: 12),
              Text(
                ayah.teksIndonesia,
                style: TextStyle(
                  color: context.textPrimaryColor,
                  fontSize: settings.latinFontSize,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
