import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:adhan_reminder/features/adhan/presentation/providers/adhan_provider.dart';
import 'package:adhan_reminder/core/constants/app_colors.dart';

class GlobalVolumeSettingsSheet {
  static void show(BuildContext context, AdhanProvider provider) {
    final AudioPlayer previewPlayer = AudioPlayer();

    previewPlayer.setAudioContext(AudioContext(
      android: const AudioContextAndroid(
        usageType: AndroidUsageType.alarm,
        contentType: AndroidContentType.music,
        audioFocus: AndroidAudioFocus.gainTransient,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: const {AVAudioSessionOptions.duckOthers},
      ),
    ));
    final double initialVolume = provider.globalVolume;
    double tempVolume = initialVolume;

    previewPlayer.setVolume(tempVolume);
    previewPlayer.setReleaseMode(ReleaseMode.loop);
    previewPlayer.play(AssetSource('adzan_azzam_dweik.mp3'));

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pengaturan Volume',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${(tempVolume * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.primary.withOpacity(0.3),
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: tempVolume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 100,
                      onChanged: (val) {
                        setStateModal(() {
                          tempVolume = val;
                        });
                        previewPlayer.setVolume(val);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Pengaturan ini akan diterapkan ke semua jadwal sholat yang aktif.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AppColors.textSecondaryLight, fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                          ),
                          child: const Text('Batal',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            provider.setGlobalVolume(tempVolume);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.backgroundLight,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Simpan',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      previewPlayer.stop();
      previewPlayer.dispose();
    });
  }
}
