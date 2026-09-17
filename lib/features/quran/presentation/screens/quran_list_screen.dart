import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adhan_reminder/core/widgets/dynamic_scaffold.dart';
import 'package:adhan_reminder/features/quran/presentation/providers/quran_provider.dart';
import 'package:adhan_reminder/features/quran/presentation/widgets/surah_card.dart';
import 'package:adhan_reminder/features/quran/presentation/widgets/bookmark_card.dart';
import 'package:adhan_reminder/core/constants/app_colors.dart';
import 'package:adhan_reminder/core/theme/theme_ext.dart';

class QuranListScreen extends StatefulWidget {
  const QuranListScreen({super.key});

  @override
  State<QuranListScreen> createState() => _QuranListScreenState();
}

class _QuranListScreenState extends State<QuranListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranProvider>().loadBookmark();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuranProvider>(
      builder: (context, quranProvider, child) {
        final surahList = quranProvider.surahList;
        final filteredSurahList = quranProvider.filteredSurahList;
        final isLoading = quranProvider.isLoadingSurahs;
        final error = quranProvider.errorSurahs;

        return DynamicScaffold(
          body: isLoading
              ? Center(child: CircularProgressIndicator(color: context.textPrimaryColor))
              : RefreshIndicator(
                  onRefresh: () => quranProvider.loadSurahs(),
                  color: AppColors.primary,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverAppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        automaticallyImplyLeading: false,
                        pinned: true,
                        title: Text(
                          'Al-Qur\'an',
                          style: GoogleFonts.poppins(
                            color: context.textPrimaryColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        centerTitle: false,
                        actions: [
                          IconButton(
                            icon: Icon(Icons.download_done, color: context.textPrimaryColor),
                            tooltip: 'Unduhan Audio',
                            onPressed: () {
                              context.push('/downloaded-audio');
                            },
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      if (quranProvider.bookmarkedSurahNomor != null && quranProvider.bookmarkedSurahNama != null && quranProvider.bookmarkedAyahNomor != null)
                        SliverToBoxAdapter(
                          child: BookmarkCard(
                            bookmarkedSurahNomor: quranProvider.bookmarkedSurahNomor!,
                            bookmarkedSurahNama: quranProvider.bookmarkedSurahNama!,
                            bookmarkedAyahNomor: quranProvider.bookmarkedAyahNomor!,
                            surahList: surahList,
                            onReturn: () => quranProvider.loadBookmark(),
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(color: context.textPrimaryColor),
                            onChanged: quranProvider.updateSearchQuery,
                            decoration: InputDecoration(
                              hintText: 'Cari surah (contoh: Al-Fatihah)',
                              hintStyle: TextStyle(color: context.textSecondaryColor),
                              prefixIcon: Icon(Icons.search, color: AppColors.primary),
                              suffixIcon: quranProvider.searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear, color: context.textSecondaryColor),
                                      onPressed: () {
                                        _searchController.clear();
                                        quranProvider.updateSearchQuery('');
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: AppColors.primary.withOpacity(0.05),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: AppColors.primary.withOpacity(0.1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: AppColors.primary.withOpacity(0.1)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (error != null)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, color: context.textSecondaryColor, size: 48),
                              SizedBox(height: 16),
                              Text(error, textAlign: TextAlign.center, style: TextStyle(color: context.textPrimaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                              SizedBox(height: 8),
                              Text('Pastikan koneksi internet Anda aktif.', textAlign: TextAlign.center, style: TextStyle(color: context.textSecondaryColor, fontSize: 13)),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => quranProvider.loadSurahs(),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Coba Lagi'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary.withOpacity(0.3),
                                  foregroundColor: context.backgroundColor,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (filteredSurahList.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text('Surah tidak ditemukan.', style: TextStyle(color: context.textPrimaryColor)),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: MediaQuery.of(context).padding.bottom + 100,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final surah = filteredSurahList[index];
                                return SurahCard(
                                  surah: surah,
                                  surahList: surahList,
                                  onReturn: () => quranProvider.loadBookmark(),
                                );
                              },
                              childCount: filteredSurahList.length,
                            ),
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
