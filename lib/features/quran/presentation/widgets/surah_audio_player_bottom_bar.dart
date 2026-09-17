import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';
import 'package:adhan_reminder/features/quran/presentation/providers/quran_audio_provider.dart';
import 'package:adhan_reminder/core/constants/app_colors.dart';

class SurahAudioPlayerBottomBar extends StatelessWidget {
  final QuranAudioProvider quranAudio;
  final Surah surah;

  const SurahAudioPlayerBottomBar({
    super.key,
    required this.quranAudio,
    required this.surah,
  });

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(d.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(d.inSeconds.remainder(60));
    if (d.inHours > 0) {
      return '${d.inHours}:$twoDigitMinutes:$twoDigitSeconds';
    }
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    if (!quranAudio.isPlaying && quranAudio.position == Duration.zero) return const SizedBox.shrink();
    if (quranAudio.currentSurah?.nomor != surah.nomor) return const SizedBox.shrink();

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundDark.withOpacity(0.1),
            border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.1), width: 1.5)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        double newRate = quranAudio.playbackRate == 1.0 ? 1.5 : (quranAudio.playbackRate == 1.5 ? 2.0 : 1.0);
                        quranAudio.setSpeed(newRate);
                      },
                      child: Text('${quranAudio.playbackRate}x', style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.replay_5, color: AppColors.primary),
                      onPressed: () {
                        final newPosition = quranAudio.position - const Duration(seconds: 5);
                        quranAudio.seek(newPosition < Duration.zero ? Duration.zero : newPosition);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous, color: AppColors.primary),
                      onPressed: () => quranAudio.seek(Duration.zero),
                    ),
                    IconButton(
                      icon: Icon(quranAudio.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: AppColors.primary, size: 40),
                      onPressed: () {
                          if (quranAudio.isPlaying) {
                            quranAudio.pauseAudio();
                          } else {
                            quranAudio.resumeAudio();
                          }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: AppColors.primary),
                      onPressed: () => quranAudio.seek(quranAudio.duration),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(_formatDuration(quranAudio.position), style: const TextStyle(color: AppColors.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0, elevation: 4.0, pressedElevation: 8.0),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 10.0),
                          trackHeight: 1.5,
                          activeTrackColor: AppColors.primary.withOpacity(0.8),
                          thumbColor: AppColors.backgroundDark,
                        ),
                        child: Slider(
                          value: quranAudio.position.inMilliseconds.toDouble().clamp(0.0, quranAudio.duration.inMilliseconds > 0 ? quranAudio.duration.inMilliseconds.toDouble() : 1.0),
                          min: 0.0,
                          max: quranAudio.duration.inMilliseconds > 0 ? quranAudio.duration.inMilliseconds.toDouble() : 1.0,
                          activeColor: AppColors.backgroundDark,
                          inactiveColor: AppColors.primary.withOpacity(0.1),
                          onChanged: (value) {
                            quranAudio.seek(Duration(milliseconds: value.toInt()));
                          },
                        ),
                      ),
                    ),
                    Text(_formatDuration(quranAudio.duration), style: const TextStyle(color: AppColors.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
