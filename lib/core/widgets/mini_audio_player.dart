import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhan_reminder/features/quran/presentation/providers/quran_audio_provider.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import 'package:adhan_reminder/core/constants/app_colors.dart';
import 'package:adhan_reminder/core/theme/theme_ext.dart';

class MiniAudioPlayer extends StatelessWidget {
  const MiniAudioPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final quranAudio = context.watch<QuranAudioProvider>();

    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuart,
      child: quranAudio.currentSurah == null
          ? const SizedBox.shrink()
          : GestureDetector(


      onTap: () {
        if (quranAudio.currentSurah != null) {
          final surah = quranAudio.currentSurah!;
          context.push('/surah/${surah.nomor}?name=${surah.namaLatin}', extra: {'surah': surah});
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.1),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [

                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.music_note, color: AppColors.primary),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Surah ${quranAudio.currentSurah!.namaLatin}',
                        style: TextStyle(
                          color: context.textPrimaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        quranAudio.qoriNames[quranAudio.selectedQoriId] ?? 'Qori',
                        style: TextStyle(
                          color: context.textSecondaryColor,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                if (quranAudio.isBuffering)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                else
                  IconButton(
                    icon: Icon(
                      quranAudio.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      color: context.textPrimaryColor,
                      size: 32,
                    ),
                    onPressed: () {
                      if (quranAudio.isPlaying) {
                        quranAudio.pauseAudio();
                      } else {
                        quranAudio.resumeAudio();
                      }
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: context.textSecondaryColor,
                    size: 24,
                  ),
                  onPressed: () => quranAudio.stopAudio(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ),
      ),
      ),
      ),
    );
  }
}
