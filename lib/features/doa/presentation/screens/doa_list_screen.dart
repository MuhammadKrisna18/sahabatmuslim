import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adhan_reminder/core/widgets/glass_card.dart';
import 'package:adhan_reminder/features/settings/presentation/widgets/typography_settings_sheet.dart';
import 'package:adhan_reminder/features/settings/presentation/providers/settings_provider.dart';
import 'package:adhan_reminder/features/doa/presentation/providers/doa_provider.dart';
import 'package:provider/provider.dart';
import 'package:adhan_reminder/core/widgets/dynamic_scaffold.dart';
import 'package:shimmer/shimmer.dart';
import 'package:expandable/expandable.dart';
import 'package:adhan_reminder/core/constants/app_colors.dart';
import 'package:adhan_reminder/core/theme/theme_ext.dart';

class DoaListScreen extends StatefulWidget {
  const DoaListScreen({super.key});

  @override
  State<DoaListScreen> createState() => _DoaListScreenState();
}

class _DoaListScreenState extends State<DoaListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoaProvider>().loadDoaList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DynamicScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.textPrimaryColor),
        title: Text(
          'Doa & Dzikir',
          style: GoogleFonts.poppins(
            color: context.textPrimaryColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.text_format, color: context.textPrimaryColor),
            tooltip: 'Pengaturan Teks',
            onPressed: () => TypographySettingsSheet.show(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<DoaProvider>().loadDoaList();
        },
        color: AppColors.primary,
        child: Consumer<DoaProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.doaList.isEmpty) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: context.backgroundColor.withOpacity(0.1),
                    highlightColor: context.backgroundColor.withOpacity(0.3),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      height: 65,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
              );
            }

            if (provider.errorMessage != null && provider.doaList.isEmpty) {
              return Center(
                child: Text(
                  provider.errorMessage ?? 'Gagal memuat doa',
                  style: TextStyle(color: context.textPrimaryColor),
                ),
              );
            }

            final doaList = provider.doaList;
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 130),
              itemCount: doaList.length,
              itemBuilder: (context, index) {
                final doa = doaList[index];
                return Consumer<SettingsProvider>(
                  builder: (context, settings, child) {
                    return GlassCard(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpandablePanel(
                        theme: const ExpandableThemeData(
                          headerAlignment: ExpandablePanelHeaderAlignment.center,
                          iconColor: AppColors.primary,
                          iconPadding: EdgeInsets.all(16),
                          hasIcon: true,
                        ),
                        header: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            doa.title,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        collapsed: const SizedBox.shrink(),
                        expanded: Container(
                          margin: const EdgeInsets.only(
                              left: 16.0, right: 16.0, bottom: 16.0),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.1)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                doa.arab,
                                textAlign: TextAlign.right,
                                style: GoogleFonts.amiri(
                                  color: context.textPrimaryColor,
                                  fontSize: settings.arabicFontSize,
                                  height: 2.0,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                doa.latin,
                                style: TextStyle(
                                  color: context.textPrimaryColor,
                                  fontStyle: FontStyle.italic,
                                  fontSize: settings.latinFontSize,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Arti:\n${doa.arti}",
                                style: TextStyle(
                                  color: context.textSecondaryColor,
                                  fontSize: settings.latinFontSize,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fade(delay: (index * 100).ms).slideX(begin: 0.2, end: 0);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
