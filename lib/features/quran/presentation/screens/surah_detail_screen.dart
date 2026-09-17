import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:adhan_reminder/features/quran/presentation/providers/quran_audio_provider.dart';
import 'package:adhan_reminder/features/quran/presentation/providers/quran_download_provider.dart';
import 'package:adhan_reminder/features/quran/presentation/providers/quran_provider.dart';
import 'package:adhan_reminder/features/quran/domain/entities/surah.dart';
import 'package:adhan_reminder/features/quran/domain/entities/ayah.dart';
import 'package:adhan_reminder/core/widgets/glass_card.dart';
import 'package:adhan_reminder/features/quran/presentation/widgets/ayah_card.dart';
import 'package:adhan_reminder/features/settings/presentation/widgets/typography_settings_sheet.dart';
import 'package:adhan_reminder/features/adhan/presentation/providers/adhan_provider.dart';
import 'package:adhan_reminder/core/widgets/dynamic_scaffold.dart';
import 'package:adhan_reminder/features/quran/presentation/widgets/surah_audio_player_bottom_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:adhan_reminder/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:adhan_reminder/core/constants/app_colors.dart';
class SurahDetailScreen extends StatefulWidget {
  final Surah surah;
  final int? initialAyah;
  final List<Surah>? allSurahs;

  const SurahDetailScreen({super.key, required this.surah, this.initialAyah, this.allSurahs});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  int? bookmarkedAyah;
  bool isZenMode = false;
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  @override
  void initState() {
    super.initState();
    _loadBookmark();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuranProvider>(context, listen: false).loadAyahs(widget.surah.nomor).then((_) {
        if (widget.initialAyah != null) {
          _scrollToAyah(widget.initialAyah!);
        }
      });
    });
  }

  Future<void> _loadBookmark() async {
    final provider = context.read<QuranProvider>();
    await provider.loadBookmark();
    
    if (provider.bookmarkedSurahNomor == widget.surah.nomor) {
      if (provider.bookmarkedAyahNomor != null) {
        if (!mounted) return;
        setState(() {
          bookmarkedAyah = provider.bookmarkedAyahNomor;
        });
      }
    }
  }

  void _scrollToAyah(int ayahIndex) {
    if (itemScrollController.isAttached) {
      itemScrollController.jumpTo(index: ayahIndex);
    }
  }

  void _saveBookmark(Ayah ayah) async {
    final provider = context.read<QuranProvider>();
    await provider.saveBookmark(widget.surah, ayah);

    if (!mounted) return;
    if (bookmarkedAyah == ayah.nomorAyat) {
      setState(() {
        bookmarkedAyah = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanda terakhir dibaca dihapus'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      setState(() {
        bookmarkedAyah = ayah.nomorAyat;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ayat ${ayah.nomorAyat} ditandai sebagai terakhir dibaca'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggleAudio() async {
    final quranAudio = context.read<QuranAudioProvider>();
    await quranAudio.toggleAudio(widget.surah, context, allSurahs: widget.allSurahs);
  }

  void _showQoriSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final quranAudio = context.read<QuranAudioProvider>();
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Pilih Suara Qori',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                ...quranAudio.qoriNames.keys.map((id) {
                  bool isAvailable = true;
                  if (id != '07' && id != '09') {
                    isAvailable = widget.surah.audioUrls.containsKey(id);
                  }

                  return ListTile(
                    enabled: isAvailable,
                    title: Text(
                      quranAudio.qoriNames[id] ?? 'Qori $id',
                      style: TextStyle(
                        color: isAvailable ? AppColors.textPrimaryLight : AppColors.textSecondaryLight.withOpacity(0.5),
                        decoration: isAvailable ? TextDecoration.none : TextDecoration.lineThrough,
                      ),
                    ),
                    subtitle: isAvailable ? null : const Text('Tidak tersedia di Surah ini', style: TextStyle(color: Colors.red, fontSize: 12)),
                    trailing: quranAudio.selectedQoriId == id
                        ? const Icon(Icons.check_circle, color: Colors.blue)
                        : null,
                    onTap: () {
                      quranAudio.setQori(id);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleZenMode() {
    setState(() {
      isZenMode = !isZenMode;
    });
    if (isZenMode) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuranProvider>(
      builder: (context, quranProvider, child) {
        final ayahList = quranProvider.getAyahs(widget.surah.nomor);
        final isLoading = quranProvider.isLoadingAyahs;

        return DynamicScaffold(
          appBar: isZenMode ? null : AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Column(
              children: [
                Hero(
                  tag: 'surah_latin_${widget.surah.nomor}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      widget.surah.namaLatin,
                      style: const TextStyle(
                        color: AppColors.backgroundDark,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Text(
                  '${widget.surah.tempatTurun} • ${widget.surah.jumlahAyat} Ayat',
                  style: const TextStyle(
                    color: AppColors.textSecondaryLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            centerTitle: false,
            actions: [
              Consumer2<QuranDownloadProvider, QuranAudioProvider>(
                builder: (context, downloadProvider, audioProvider, child) {
                  final qoriId = audioProvider.selectedQoriId;
                  final isDownloaded = downloadProvider.isDownloaded(widget.surah.nomor, qoriId);
                  final isDownloading = downloadProvider.isDownloading(widget.surah.nomor, qoriId);
                  final progress = downloadProvider.getProgress(widget.surah.nomor, qoriId);

                  if (isDownloading) {
                    return GestureDetector(
                      onTap: () {
                        downloadProvider.cancelDownload(widget.surah.nomor, qoriId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Unduhan dibatalkan')),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        width: 24,
                        height: 24,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                            const Icon(Icons.close, size: 14, color: AppColors.primary),
                          ],
                        ),
                      ),
                    );
                  }

                  if (isDownloaded) {
                    return IconButton(
                      icon: const Icon(Icons.download_done, color: Colors.green),
                      tooltip: 'Sudah diunduh',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Audio sudah ada di HP Anda. Tahan ikon ini jika ingin menghapus.')),
                        );
                      },
                    );
                  }

                  return IconButton(
                    icon: const Icon(Icons.cloud_download_outlined, color: AppColors.primary),
                    tooltip: 'Download Audio',
                    onPressed: () {
                      String? audioUrl = audioProvider.getAudioUrl(widget.surah, qoriId);

                      if (audioUrl != null) {
                        downloadProvider.downloadSurah(widget.surah, qoriId, audioUrl);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Mengunduh audio...')),
                        );
                      }
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.text_format, color: AppColors.backgroundDark),
                tooltip: 'Pengaturan Teks',
                onPressed: () => TypographySettingsSheet.show(context),
              ),
              IconButton(
                icon: const Icon(Icons.settings_voice, color: AppColors.primary),
                onPressed: _showQoriSelection,
              ),
              Consumer<QuranAudioProvider>(
                builder: (context, quranAudio, child) {
                  return IconButton(
                    icon: quranAudio.isBuffering
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          )
                        : Icon(
                            quranAudio.isPlaying && quranAudio.currentSurah?.nomor == widget.surah.nomor
                                ? Icons.pause_circle_filled : Icons.play_circle_fill,
                            color: AppColors.primary,
                            size: 28,
                          ),
                    onPressed: quranAudio.isBuffering ? null : _toggleAudio,
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          bottomNavigationBar: isZenMode ? null : Consumer<QuranAudioProvider>(
            builder: (context, audioProvider, _) => SurahAudioPlayerBottomBar(
              quranAudio: audioProvider,
              surah: widget.surah,
            ),
          ),
          body: GestureDetector(
            onTap: _toggleZenMode,
            child: Stack(
            children: [
              Positioned(
                right: -50,
                bottom: 100,
                child: Opacity(
                  opacity: 0.1,
                  child: SvgPicture.asset(
                    'assets/svg/ornament.svg',
                    width: 350,
                    height: 350,
                  ),
                ),
              ),
              if (isLoading)
                Center(
                  child: Shimmer.fromColors(
                    baseColor: AppColors.backgroundDark.withOpacity(0.3),
                    highlightColor: AppColors.backgroundDark,
                    child: Text(
                      'اللّٰه',
                      style: GoogleFonts.amiri(
                        fontSize: 100,
                        color: AppColors.backgroundDark,
                      ),
                    ),
                  ),
                )
              else if (ayahList != null && ayahList.isNotEmpty)
                Positioned.fill(
                  child: ScrollablePositionedList.builder(
                    itemScrollController: itemScrollController,
                    itemCount: ayahList!.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return widget.surah.nomor != 1 && widget.surah.nomor != 9
                            ? Container(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                alignment: Alignment.center,
                                child: Text(
                                  'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم',
                                  style: GoogleFonts.amiri(
                                    fontSize: 28,
                                    color: AppColors.backgroundDark,
                                  ),
                                ),
                              )
                            : const SizedBox(height: 20);
                      }
                      final ayah = ayahList![index - 1];
                      return Consumer2<QuranAudioProvider, SettingsProvider>(
                        builder: (context, quranAudio, settings, _) {
                          return AyahCard(
                            ayah: ayah,
                            surah: widget.surah,
                            settings: settings,
                            bookmarkedAyah: bookmarkedAyah,
                            onSaveBookmark: _saveBookmark,
                          );
                        }
                      );
                    },
                  ),
                ),
            ],
          ),
          ),
        );
      },
    );
  }
}