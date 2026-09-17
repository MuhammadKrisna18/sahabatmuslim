import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';
import 'package:adhan_reminder/core/widgets/glass_card.dart';
import 'package:adhan_reminder/core/constants/app_colors.dart';
import 'package:adhan_reminder/core/theme/theme_ext.dart';

class BookmarkCard extends StatelessWidget {
  final int bookmarkedSurahNomor;
  final String bookmarkedSurahNama;
  final int bookmarkedAyahNomor;
  final List<Surah> surahList;
  final VoidCallback onReturn;

  const BookmarkCard({
    super.key,
    required this.bookmarkedSurahNomor,
    required this.bookmarkedSurahNama,
    required this.bookmarkedAyahNomor,
    required this.surahList,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            try {
              final surah = surahList.firstWhere((s) => s.nomor == bookmarkedSurahNomor);
              context.push(
                '/surah/${surah.nomor}?name=${surah.namaLatin}',
                extra: {
                  'surah': surah,
                  'initialAyah': bookmarkedAyahNomor,
                  'allSurahs': surahList,
                },
              ).then((_) => onReturn());
            } catch (e) {
              debugPrint('Error navigating to bookmark: $e');
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.menu_book, color: context.textPrimaryColor, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Terakhir Dibaca', style: TextStyle(color: context.textSecondaryColor, fontSize: 13)),
                      SizedBox(height: 4),
                      Text('Surah $bookmarkedSurahNama', style: TextStyle(color: context.textPrimaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Ayat $bookmarkedAyahNomor', style: TextStyle(color: context.textPrimaryColor, fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: context.textPrimaryColor, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
