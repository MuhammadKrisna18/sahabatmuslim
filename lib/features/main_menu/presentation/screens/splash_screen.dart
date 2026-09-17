import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:adhan_reminder/core/utils/theme_utils.dart';
import 'package:provider/provider.dart';
import 'package:adhan_reminder/features/adhan/presentation/providers/adhan_provider.dart';
import 'package:adhan_reminder/core/widgets/dynamic_scaffold.dart';
import 'package:adhan_reminder/core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/main');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DynamicScaffold(
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.mosque,
                size: 100,
                color: AppColors.primary,
              )
              .animate()
              .fade(duration: 800.ms)
              .scale(delay: 200.ms, duration: 600.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 20),
              Text(
                'SahabatMuslim',
                style: GoogleFonts.amiri(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              )
              .animate()
              .fade(delay: 600.ms, duration: 800.ms)
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOut)
              .shimmer(delay: 1500.ms, duration: 1500.ms, color: AppColors.primary.withOpacity(0.5)),
            ],
          ),
      ),
    );
  }
}
