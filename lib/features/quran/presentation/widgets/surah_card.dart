import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';
import 'package:adhan_reminder/core/widgets/glass_card.dart';
import 'package:adhan_reminder/core/constants/app_colors.dart';
import 'package:adhan_reminder/core/theme/theme_ext.dart';
import 'package:provider/provider.dart';
import 'package:adhan_reminder/features/quran/presentation/providers/quran_provider.dart';
import 'package:adhan_reminder/features/quran/presentation/providers/quran_audio_provider.dart';
import 'package:adhan_reminder/features/quran/presentation/providers/quran_download_provider.dart';

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

  void _showDownloadDialog(BuildContext context) {
    final quranAudio = context.read<QuranAudioProvider>();
    final downloadProvider = context.read<QuranDownloadProvider>();
    String tempSelectedQoriId = quranAudio.selectedQoriId;
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              backgroundColor: context.surfaceColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Download Murottal', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: quranAudio.qoriNames.keys.map((id) {
                    bool isAvailable = true;
                    if (id != '07' && id != '08' && id != '09') {
                      isAvailable = surah.audioUrls.containsKey(id);
                    }

                    return RadioListTile<String>(
                      title: Text(
                        quranAudio.qoriNames[id] ?? 'Qori $id',
                        style: TextStyle(
                          color: isAvailable ? context.textPrimaryColor : context.textSecondaryColor.withOpacity(0.5),
                          decoration: isAvailable ? TextDecoration.none : TextDecoration.lineThrough,
                        ),
                      ),
                      subtitle: isAvailable ? null : const Text('Tidak tersedia di Surah ini', style: TextStyle(color: Colors.red, fontSize: 12)),
                      value: id,
                      groupValue: tempSelectedQoriId,
                      onChanged: isAvailable ? (value) {
                        setState(() {
                          tempSelectedQoriId = value!;
                        });
                      } : null,
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Batal', style: TextStyle(color: context.textSecondaryColor)),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    String? audioUrl = quranAudio.getAudioUrl(surah, tempSelectedQoriId);
                    if (audioUrl != null) {
                      downloadProvider.downloadSurah(surah, tempSelectedQoriId, audioUrl);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Mengunduh Murottal ${surah.namaLatin}...')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Download', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: 'surah_arab_${surah.nomor}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(surah.nama, style: GoogleFonts.amiri(color: context.textPrimaryColor, fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: context.textSecondaryColor),
                    color: context.surfaceColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onSelected: (value) {
                      if (value == 'bookmark') {
                        context.read<QuranProvider>().saveSurahBookmark(surah);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Surah ${surah.namaLatin} ditandai'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else if (value == 'download') {
                        _showDownloadDialog(context);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'bookmark',
                        child: Row(
                          children: [
                            const Icon(Icons.bookmark_border, color: AppColors.primary, size: 20),
                            const SizedBox(width: 12),
                            Text('Tandai Surah', style: TextStyle(color: context.textPrimaryColor)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'download',
                        child: Row(
                          children: [
                            const Icon(Icons.download, color: AppColors.primary, size: 20),
                            const SizedBox(width: 12),
                            Text('Download Murottal', style: TextStyle(color: context.textPrimaryColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
