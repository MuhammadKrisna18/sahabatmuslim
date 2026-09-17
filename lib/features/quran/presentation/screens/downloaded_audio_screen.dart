import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adhan_reminder/features/quran/presentation/providers/quran_download_provider.dart';
import 'package:adhan_reminder/features/quran/presentation/providers/quran_audio_provider.dart';
import 'package:go_router/go_router.dart';

class DownloadedAudioScreen extends StatelessWidget {
  const DownloadedAudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unduhan Murottal'),
        centerTitle: true,
      ),
      body: Consumer2<QuranDownloadProvider, QuranAudioProvider>(
        builder: (context, downloadProvider, audioProvider, child) {
          final items = downloadProvider.downloadedItems;

          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada audio yang diunduh.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 20),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final surah = item.surah;
              final qoriName = audioProvider.qoriNames[item.qoriId] ?? "Qori";

              final isPlayingThis = audioProvider.currentSurah?.nomor == surah.nomor &&
                  audioProvider.selectedQoriId == item.qoriId &&
                  audioProvider.isPlaying;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Text(
                      surah.nomor.toString(),
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  title: Text(surah.namaLatin, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(qoriName, style: const TextStyle(fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          isPlayingThis ? Icons.stop_circle : Icons.play_circle_fill,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                        onPressed: () async {
                          if (isPlayingThis) {
                            audioProvider.stopAudio();
                          } else {
                            audioProvider.setQori(item.qoriId);

                            final allDownloadedSurahs = items
                                .where((i) => i.qoriId == item.qoriId)
                                .map((i) => i.surah)
                                .toList();

                            allDownloadedSurahs.sort((a, b) => a.nomor.compareTo(b.nomor));

                            try {
                              await audioProvider.toggleAudio(surah, allSurahs: allDownloadedSurahs);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString().replaceAll('Exception: ', '')),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Hapus Audio?'),
                              content: Text('Anda yakin ingin menghapus audio ${surah.namaLatin} oleh $qoriName dari memori HP?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Batal'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    downloadProvider.deleteDownload(surah.nomor, item.qoriId);
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    context.push('/surah/${surah.nomor}?name=${surah.namaLatin}', extra: {'surah': surah});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
