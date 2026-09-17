import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:adhan_reminder/core/widgets/glass_card.dart';
import 'package:provider/provider.dart';
import 'package:adhan_reminder/features/settings/presentation/providers/settings_provider.dart';
import 'package:adhan_reminder/features/settings/presentation/widgets/typography_settings_sheet.dart';
import 'package:adhan_reminder/features/sholat/presentation/providers/sholat_provider.dart';
import 'package:adhan_reminder/core/widgets/dynamic_scaffold.dart';
import 'package:shimmer/shimmer.dart';
import 'package:expandable/expandable.dart';
import 'package:adhan_reminder/core/constants/app_colors.dart';
import 'package:adhan_reminder/core/theme/theme_ext.dart';

class CaraSholatScreen extends StatefulWidget {
  const CaraSholatScreen({super.key});

  @override
  State<CaraSholatScreen> createState() => _CaraSholatScreenState();
}

class _CaraSholatScreenState extends State<CaraSholatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SholatProvider>().loadCaraSholatList();
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
          'Panduan Sholat',
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
          await context.read<SholatProvider>().loadCaraSholatList();
        },
        color: AppColors.primary,
        child: Consumer<SholatProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.caraSholatList.isEmpty) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: context.backgroundColor.withOpacity(0.1),
                    highlightColor: context.backgroundColor.withOpacity(0.3),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
              );
            }

            if (provider.errorMessage != null && provider.caraSholatList.isEmpty) {
              return Center(
                child: Text(
                  provider.errorMessage ?? 'Gagal memuat panduan sholat',
                  style: TextStyle(color: context.textPrimaryColor),
                ),
              );
            }

            final steps = provider.caraSholatList;
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 130),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
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
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.primary.withOpacity(0.3)),
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  step.title,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        collapsed: const SizedBox.shrink(),
                        expanded: Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16.0, bottom: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.desc,
                                style: TextStyle(
                                  color: context.textPrimaryColor,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                              if (step.arab != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppColors.primary.withOpacity(0.1)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        step.arab!,
                                        textAlign: TextAlign.right,
                                        style: GoogleFonts.amiri(
                                          fontSize: settings.arabicFontSize,
                                          color: context.textPrimaryColor,
                                          height: 2.0,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      if (step.latin != null)
                                        Text(
                                          step.latin!,
                                          style: TextStyle(
                                            fontSize: settings.latinFontSize,
                                            fontStyle: FontStyle.italic,
                                            color: context.textPrimaryColor,
                                            height: 1.5,
                                          ),
                                        ),
                                      const SizedBox(height: 8),
                                      if (step.arti != null)
                                        Text(
                                          step.arti!,
                                          style: TextStyle(
                                            fontSize: settings.latinFontSize,
                                            color: context.textSecondaryColor,
                                            height: 1.5,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ).animate().fade(delay: (index * 100).ms).slideX(begin: 0.1, end: 0);
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

