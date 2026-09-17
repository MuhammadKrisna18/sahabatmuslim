package com.example.adhan_reminder

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class PrayerWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.prayer_widget).apply {
                // Get data saved from Flutter
                val adhanName = widgetData.getString("next_adhan_name", "Memuat...")
                val adhanTime = widgetData.getString("next_adhan_time", "--:--")
                val location = widgetData.getString("location_name", "Memuat lokasi...")

                setTextViewText(R.id.widget_adhan_name, adhanName)
                setTextViewText(R.id.widget_adhan_time, adhanTime)
                setTextViewText(R.id.widget_location, location)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
