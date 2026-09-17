import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';
import 'package:adhan_reminder/core/widgets/glass_card.dart';
import 'package:adhan_reminder/core/constants/app_colors.dart';
import 'package:adhan_reminder/core/theme/theme_ext.dart';

class SurahCard extends StatelessWidget {
  final Surah surah;
  final List<Surah> surahList;
  final VoidCallback onReturn;

  const SurahCard({
    super.key,
    required this.surah,
    required this.surahList,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          context.push(
            '/surah/${surah.nomor}?name=${surah.namaLatin}',
            extra: {
              'surah': surah,
              'allSurahs': surahList,
            },
          ).then((_) => onReturn());
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Transform.rotate(
                      angle: 0.785398,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Text('${surah.nomor}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Hero(
                      tag: 'surah_latin_${surah.nomor}',
                      child: Material(
                        color: Colors.transparent,
                        child: Text(surah.namaLatin, style: TextStyle(color: context.textPrimaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text('${surah.tempatTurun} • ${surah.jumlahAyat} Ayat', style: TextStyle(color: context.textSecondaryColor, fontSize: 12)),
                  ],
                ),
              ),
              Hero(
                tag: 'surah_arab_${surah.nomor}',
                child: Material(
                  color: Colors.transparent,
                  child: Text(surah.nama, style: GoogleFonts.amiri(color: context.textPrimaryColor, fontSize: 22, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
