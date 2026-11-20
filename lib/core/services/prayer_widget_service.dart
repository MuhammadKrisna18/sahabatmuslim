import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

abstract class PrayerWidgetService {
  Future<void> updateWidgetData({
    required String nextAdhanName,
    required String nextAdhanTime,
    required String locationName,
  });
}

class PrayerWidgetServiceImpl implements PrayerWidgetService {
  @override
  Future<void> updateWidgetData({
    required String nextAdhanName,
    required String nextAdhanTime,
    required String locationName,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('next_adhan_name', nextAdhanName);
      await HomeWidget.saveWidgetData<String>('next_adhan_time', nextAdhanTime);
      await HomeWidget.saveWidgetData<String>('location_name', locationName);
      await HomeWidget.updateWidget(androidName: 'PrayerWidgetProvider');
    } catch (e) {
      debugPrint('Error updating home widget: $e');
    }
  }
}
