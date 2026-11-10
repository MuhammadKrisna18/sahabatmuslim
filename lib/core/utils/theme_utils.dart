import 'package:flutter/material.dart';

import 'package:adhan_reminder/features/adhan/domain/entities/adhan_schedule.dart';

class ThemeUtils {
  static BoxDecoration getDynamicBackground(DateTime time, {List<AdhanSchedule>? schedules}) {
    return const BoxDecoration(
      color: Colors.white,
    );
  }
}
