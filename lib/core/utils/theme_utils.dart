import 'package:flutter/material.dart';

import 'package:adhan_reminder/features/adhan/domain/entities/adhan_schedule.dart';

class ThemeUtils {
  static BoxDecoration getDynamicBackground(DateTime time, {List<AdhanSchedule>? schedules}) {
    return const BoxDecoration(
      color: Colors.white,
    );
  }

  static int _getMinutes(List<AdhanSchedule> schedules, String id, int defaultMins) {
    try {
      final schedule = schedules.firstWhere((s) => s.id == id);
      return schedule.hour * 60 + schedule.minute;
    } catch (e) {
      return defaultMins;
    }
  }
}
