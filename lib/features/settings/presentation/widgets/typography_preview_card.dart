import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adhan_reminder/core/theme/theme_ext.dart';

class TypographyPreviewCard extends StatelessWidget {
  final double arabicFontSize;
  final double latinFontSize;

  const TypographyPreviewCard({
    super.key,
    required this.arabicFontSize,
    required this.latinFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Preview',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: context.textSecondaryColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            textAlign: TextAlign.right,
            style: GoogleFonts.amiri(
              fontSize: arabicFontSize,
              fontWeight: FontWeight.bold,
              color: context.textPrimaryColor,
              height: 1.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang.',
            style: TextStyle(
              fontSize: latinFontSize,
              color: context.textSecondaryColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
