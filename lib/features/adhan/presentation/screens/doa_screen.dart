import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:adhan_reminder/core/widgets/glass_card.dart';
import 'package:adhan_reminder/core/utils/theme_utils.dart';
import 'package:provider/provider.dart';
import 'package:adhan_reminder/features/adhan/presentation/providers/adhan_provider.dart';
import 'package:adhan_reminder/core/widgets/dynamic_scaffold.dart';
import 'package:adhan_reminder/core/constants/app_colors.dart';
import 'package:adhan_reminder/core/theme/theme_ext.dart';

class DoaScreen extends StatelessWidget {
  DoaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.backgroundColor, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.mosque,
                  size: 80,
                  color: context.backgroundColor,
                )
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .scaleXY(begin: 1.0, end: 1.1, duration: 2.seconds, curve: Curves.easeInOut),
                const SizedBox(height: 20),
                Text(
                  'Doa Setelah Adzan',
                  style: GoogleFonts.amiri(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: context.backgroundColor,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fade(duration: 800.ms).slideY(begin: -0.2, end: 0),
                const SizedBox(height: 40),
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                  children: [
                    Text(
                      'اللّٰهُمَّ رَبَّ هٰذِهِ الدَّعْوَةِ التَّامَّةِ وَالصَّلَاةِ الْقَائِمَةِ، آتِ سَيِّدَنَا مُحَمَّدًا الْوَسِيْلَةَ وَالْفَضِيْلَةَ، وَابْعَثْهُ مَقَامًا مَحْمُوْدًا الَّذِيْ وَعَدْتَهُ',
                      style: GoogleFonts.amiri(
                        fontSize: 28,
                        color: context.backgroundColor,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Allaahumma rabba haadzihid da\'watit taammah, washshalaatil qaa-imah, aati sayyidanaa muhammadanil wasiilata wal fadhiilah, wab\'atshu maqaamam mahmuudanil ladzii wa\'adtah',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: context.backgroundColor,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: AppColors.primary.withOpacity(0.3), thickness: 1),
                    ),
                    Text(
                      '"Ya Allah, Tuhan yang memiliki seruan yang sempurna dan shalat yang tetap didirikan, karuniakanlah Nabi Muhammad wasilah (tempat yang luhur) dan keutamaan (derajat yang tinggi), dan bangkitkanlah beliau pada kedudukan yang terpuji yang telah Engkau janjikan kepadanya."',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: context.textSecondaryColor,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fade(delay: 400.ms, duration: 800.ms).scaleXY(begin: 0.9, end: 1.0, curve: Curves.easeOutBack),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.backgroundColor,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 8,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'SELESAI',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ).animate().fade(delay: 800.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
          ),
      ),
    );
  }
}
