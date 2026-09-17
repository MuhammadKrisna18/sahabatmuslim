import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:adhan_reminder/features/qibla/presentation/providers/qibla_provider.dart';
import 'package:adhan_reminder/core/widgets/dynamic_scaffold.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:adhan_reminder/core/constants/app_colors.dart';
import 'package:adhan_reminder/core/theme/theme_ext.dart';
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});
  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  bool _wasAligned = false;

  @override
  Widget build(BuildContext context) {
    return DynamicScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.backgroundColor),
        automaticallyImplyLeading: false,
        title: Text(
          'Arah Kiblat',
          style: GoogleFonts.poppins(
            color: context.backgroundColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Consumer<QiblaProvider>(
        builder: (context, qiblaProvider, child) {
          return RefreshIndicator(
            onRefresh: () => qiblaProvider.fetchQiblaDirection(),
            color: AppColors.primary,
            child: (!qiblaProvider.hasPermissions || qiblaProvider.errorMessage.isNotEmpty)
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 200),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            qiblaProvider.errorMessage.isEmpty 
                              ? 'Mohon izinkan akses lokasi\nuntuk menentukan arah Kiblat.' 
                              : qiblaProvider.errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: context.textSecondaryColor, fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => qiblaProvider.fetchQiblaDirection(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary.withOpacity(0.3),
                            foregroundColor: context.backgroundColor,
                          ),
                        ),
                      ),
                    ],
                  )
                : StreamBuilder<CompassEvent>(
                    stream: FlutterCompass.events,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: 200),
                            Center(
                              child: Text(
                                'Error membaca sensor kompas:\n${snapshot.error}', 
                                textAlign: TextAlign.center, 
                                style: TextStyle(color: context.backgroundColor)
                              )
                            ),
                          ],
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting || qiblaProvider.isLoading) {
                        return Center(child: CircularProgressIndicator(color: context.backgroundColor));
                      }

                      double? heading = snapshot.data?.heading;
                      if (heading == null) {
                        return ListView(
                          physics: AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: 200),
                            Center(
                              child: Text(
                                'Sensor kompas tidak ditemukan di perangkat ini.', 
                                style: TextStyle(color: context.backgroundColor)
                              )
                            ),
                          ],
                        );
                      }

                      if (qiblaProvider.qiblaDirection == null) {
                        return Center(child: CircularProgressIndicator(color: context.backgroundColor));
                      }

                      double diff = (heading - qiblaProvider.qiblaDirection!).abs() % 360;
                      if (diff > 180) diff = 360 - diff;
                      final bool isAligned = diff < 2.5;

                      if (isAligned && !_wasAligned) {
                        _wasAligned = true;
                        HapticFeedback.lightImpact();
                      } else if (!isAligned && _wasAligned) {
                        _wasAligned = false;
                      }

                      final qiblaAngle = (qiblaProvider.qiblaDirection! - heading) * (pi / 180);
                      final Color primaryColor = isAligned ? AppColors.success : AppColors.primary;

                      return Center(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 20),
                              Text(
                                'Arah Kiblat: ${qiblaProvider.qiblaDirection!.toStringAsFixed(1)}°',
                                style: TextStyle(
                                  color: context.backgroundColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ).animate().fade(duration: 800.ms),
                              const SizedBox(height: 30),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  ClipOval(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                      child: Container(
                                        width: 300,
                                        height: 300,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.primary.withOpacity(0.1),
                                          border: Border.all(
                                            color: primaryColor.withOpacity(isAligned ? 0.8 : 0.3),
                                            width: isAligned ? 4 : 2,
                                          ),
                                          boxShadow: isAligned ? [
                                            BoxShadow(
                                              color: primaryColor.withOpacity(0.5),
                                              blurRadius: 30,
                                              spreadRadius: 5,
                                            )
                                          ] : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Transform.rotate(
                                    angle: heading * (pi / 180) * -1,
                                    child: SvgPicture.asset(
                                      'assets/svg/compass_dial.svg',
                                      width: 260,
                                      height: 260,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: 260,
                                          height: 260,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
                                          ),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Positioned(top: 10, child: Text('U', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20))),
                                              Positioned(bottom: 10, child: Text('S', style: TextStyle(color: context.backgroundColor, fontWeight: FontWeight.bold, fontSize: 20))),
                                              Positioned(right: 10, child: Text('T', style: TextStyle(color: context.backgroundColor, fontWeight: FontWeight.bold, fontSize: 20))),
                                              Positioned(left: 10, child: Text('B', style: TextStyle(color: context.backgroundColor, fontWeight: FontWeight.bold, fontSize: 20))),
                                              Container(width: 4, height: 260, color: AppColors.primary.withOpacity(0.05)),
                                              Container(width: 260, height: 4, color: AppColors.primary.withOpacity(0.05)),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  AnimatedRotation(
                                    turns: qiblaAngle / (2 * pi),
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeOutBack,
                                    child: SvgPicture.asset(
                                      'assets/svg/qibla_needle.svg',
                                      width: 220,
                                      height: 220,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Transform.translate(
                                          offset: const Offset(0, -60),
                                          child: Icon(
                                            Icons.navigation,
                                            size: 100,
                                            color: primaryColor,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 40),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: primaryColor.withOpacity(0.5)),
                                ),
                                child: Text(
                                  isAligned ? 'Kiblat Ditemukan!' : 'Putar HP Anda',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                               ).animate(target: isAligned ? 1 : 0, onPlay: (controller) => controller.repeat(reverse: true))
                                .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 1.seconds, curve: Curves.easeInOut),
                               
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          );
        }
      ),
    );
  }
}
