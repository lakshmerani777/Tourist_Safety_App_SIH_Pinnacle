package com.example.tourist_safety_app_sih_pinnacle

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class SafetyWidgetProvider : AppWidgetProvider() {

    companion object {
        const val ACTION_UPDATE_WIDGET = "com.example.tourist_safety_app_sih_pinnacle.UPDATE_WIDGET"
        const val PREFS_NAME = "SafetyWidgetPrefs"
        const val KEY_IS_PROTECTED = "is_protected"

        fun updateAllWidgets(context: Context) {
            val intent = Intent(context, SafetyWidgetProvider::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            }
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val widgetIds = appWidgetManager.getAppWidgetIds(
                ComponentName(context, SafetyWidgetProvider::class.java)
            )
            intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, widgetIds)
            context.sendBroadcast(intent)
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (widgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, widgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_UPDATE_WIDGET) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val widgetIds = appWidgetManager.getAppWidgetIds(
                ComponentName(context, SafetyWidgetProvider::class.java)
            )
            onUpdate(context, appWidgetManager, widgetIds)
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int
    ) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val isProtected = prefs.getBoolean(KEY_IS_PROTECTED, true)

        val views = RemoteViews(context.packageName, R.layout.widget_safety)

        // Update status text and colors
        if (isProtected) {
            views.setTextViewText(R.id.widget_status_text, "PROTECTED")
            views.setTextColor(R.id.widget_status_text, context.getColor(R.color.widget_success))
            views.setImageViewResource(R.id.widget_status_dot, R.drawable.widget_status_dot_protected)
            views.setTextViewText(R.id.widget_status_subtitle, "You are safe")
        } else {
            views.setTextViewText(R.id.widget_status_text, "UNSAFE")
            views.setTextColor(R.id.widget_status_text, context.getColor(R.color.widget_alert_red))
            views.setImageViewResource(R.id.widget_status_dot, R.drawable.widget_status_dot_unsafe)
            views.setTextViewText(R.id.widget_status_subtitle, "Caution advised")
        }

        // PendingIntent: tap widget background → open home
        val homeIntent = Intent(context, MainActivity::class.java).apply {
            putExtra("route", "/home")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val homePendingIntent = PendingIntent.getActivity(
            context, 0, homeIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_status_area, homePendingIntent)

        // PendingIntent: tap SOS button → open SOS screen
        val sosIntent = Intent(context, MainActivity::class.java).apply {
            putExtra("route", "/sos")
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val sosPendingIntent = PendingIntent.getActivity(
            context, 1, sosIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_sos_button, sosPendingIntent)

        appWidgetManager.updateAppWidget(widgetId, views)
    }
}
