import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:adhan_reminder/core/services/alarm_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:adhan_reminder/features/adhan/domain/entities/adhan_schedule.dart';
import 'package:go_router/go_router.dart';
import 'package:adhan_reminder/features/adhan/presentation/widgets/next_adhan_header.dart';
import 'package:adhan_reminder/features/adhan/presentation/widgets/adhan_schedule_card.dart';
import 'package:adhan_reminder/core/widgets/dynamic_scaffold.dart';

import 'package:adhan_reminder/features/adhan/presentation/widgets/alarm_dialog.dart';
import 'package:adhan_reminder/features/settings/presentation/widgets/global_volume_settings_sheet.dart';
import 'package:adhan_reminder/features/adhan/presentation/providers/adhan_provider.dart';
import 'package:adhan_reminder/core/di/injection.dart';
import 'package:adhan_reminder/core/services/notification_service.dart';
import 'package:adhan_reminder/core/constants/app_colors.dart';
import 'package:adhan_reminder/core/theme/theme_ext.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamSubscription<int>? ringSubscription;

  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      ringSubscription = getIt<AlarmService>().ringStream?.listen((alarmId) {
        _triggerAlarmDialog(alarmId);
      });
      _checkCurrentlyRinging();
    }
  }

  void _checkCurrentlyRinging() async {
    final ringingAlarms = await getIt<AlarmService>().getRingingAlarms();
    for (final alarmId in ringingAlarms) {
      _triggerAlarmDialog(alarmId);
      break;
    }
  }

  Timer? _adhanTimer;

  @override
  void dispose() {
    ringSubscription?.cancel();
    _adhanTimer?.cancel();
    super.dispose();
  }

  void _showPostAdhanNotification(String scheduleName) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'adhan_post_channel',
      'Pengingat Sholat',
      channelDescription: 'Notifikasi setelah adzan selesai',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    getIt<NotificationService>().flutterLocalNotificationsPlugin.show(
      scheduleName.hashCode,
      'Waktu Sholat Telah Masuk',
      'Adzan $scheduleName selesai. Yuk, segera tunaikan sholat!',
      platformChannelSpecifics,
      payload: 'doa_after_adhan',
    );
  }

  void _triggerAlarmDialog(int alarmId) async {
    if (!mounted) return;

    final adhanProvider = Provider.of<AdhanProvider>(context, listen: false);
    int scheduleIndex = alarmId - 1;

    if (scheduleIndex < 0 || scheduleIndex >= adhanProvider.schedules.length) return;

    final schedule = adhanProvider.schedules[scheduleIndex];

    _adhanTimer?.cancel();
    _adhanTimer = Timer(const Duration(minutes: 4), () {
      if (!kIsWeb) {
        getIt<AlarmService>().stopAlarm(alarmId);
        _showPostAdhanNotification(schedule.id);
        if (mounted && Navigator.of(context).canPop()) {
           Navigator.of(context).pop();
        }
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlarmDialog(
          schedule: schedule,
          onStopAndPray: () async {
            _adhanTimer?.cancel();
            if (!kIsWeb) {
              await getIt<AlarmService>().stopAlarm(alarmId);
              _showPostAdhanNotification(schedule.id);
            }
            await adhanProvider.fetchLocationAndCalculatePrayerTimes();

            if (!context.mounted) return;
            Navigator.of(context).pop();

            context.push('/doa');
          },
        );
      },
    );
  }

  void _navigateToAddSchedule({required AdhanSchedule schedule, required AdhanProvider adhanProvider}) async {
    final newSchedule = await context.push<AdhanSchedule>('/edit-schedule', extra: schedule);

    if (newSchedule != null) {
      adhanProvider.updateSchedule(newSchedule);
    }
  }

  void _showGlobalVolumeSettings(BuildContext context, AdhanProvider provider) {
    GlobalVolumeSettingsSheet.show(context, provider);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return DynamicScaffold(
      body: Consumer<AdhanProvider>(
        builder: (context, adhanProvider, child) {
          final String timeString =
              "${adhanProvider.currentTime.hour.toString().padLeft(2, '0')}:${adhanProvider.currentTime.minute.toString().padLeft(2, '0')}:${adhanProvider.currentTime.second.toString().padLeft(2, '0')}";

          return Column(
            children: [
              NextAdhanHeader(
                timeString: timeString,
                nextAdhanText: adhanProvider.getNextAdhanText(),
                isDark: isDark,
                onSettingsPressed: () => _showGlobalVolumeSettings(context, adhanProvider),
              ),
              const SizedBox(height: 10),
              child!,
            ],
          );
        },
        child: const _ScheduleListSection(),
      ),
    );
  }
}

class _ScheduleListSection extends StatelessWidget {
  const _ScheduleListSection();

  void _navigateToAddSchedule(BuildContext context, {required AdhanSchedule schedule, required AdhanProvider adhanProvider}) async {
    final newSchedule = await context.push<AdhanSchedule>('/edit-schedule', extra: schedule);

    if (newSchedule != null) {
      adhanProvider.updateSchedule(newSchedule);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final schedules = context.select<AdhanProvider, List<AdhanSchedule>>((p) => p.schedules);
    final nextScheduleId = context.select<AdhanProvider, String?>((p) => p.nextSchedule?.id);
    final errorMessage = context.select<AdhanProvider, String?>((p) => p.errorMessage);
    final adhanProvider = context.read<AdhanProvider>();

    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          await adhanProvider.fetchLocationAndCalculatePrayerTimes();
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(top: 10, bottom: MediaQuery.of(context).padding.bottom + 130),
          child: Column(
            children: [
              if (errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    border: Border.all(color: Colors.red.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_off, color: context.backgroundColor, size: 24),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: context.backgroundColor, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),
              if (schedules.isEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 50),
                  child: Text(
                    'Belum ada jadwal adzan.\nTekan pengaturan untuk menambahkan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: context.textSecondaryColor),
                  ),
                )
              else ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Jadwal Sholat Hari Ini',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.backgroundColor,
                      ),
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    var schedule = schedules[index];
                    return AdhanScheduleCard(
                      schedule: schedule,
                      isDark: isDark,
                      index: index,
                      isNext: nextScheduleId == schedule.id,
                      onToggle: (String id, bool isActive) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Text('Konfirmasi', style: TextStyle(fontWeight: FontWeight.bold)),
                              content: Text('Apakah Anda yakin ingin ${isActive ? "mengaktifkan" : "menonaktifkan"} adzan untuk sholat $id?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    adhanProvider.toggleSchedule(id, isActive);
                                  },
                                  child: const Text('Ya'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onSettingsPressed: (AdhanSchedule s) {
                        _navigateToAddSchedule(context, schedule: s, adhanProvider: adhanProvider);
                      },
                    );
                  },
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
