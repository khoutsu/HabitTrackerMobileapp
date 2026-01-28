package com.example.loop_habit_tracker

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class HomeWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            // Get the data from the HomeWidget plugin
            val widgetData = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.home_widget_layout).apply {
                // Get the habit list string from the widget data
                val habitListString = widgetData.getString("habit_list", "No Habits")
                // For now, just set the full string to the title.
                // A more complex implementation would dynamically add views to the list.
                setTextViewText(R.id.widget_title, habitListString)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
