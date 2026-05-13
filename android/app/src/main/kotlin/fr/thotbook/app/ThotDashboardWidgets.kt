package fr.thotbook.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import java.util.Locale

private fun launchPendingIntent(context: Context, route: String, requestCode: Int): PendingIntent? {
    val launchIntent = Intent(context, MainActivity::class.java).apply {
        action = Intent.ACTION_MAIN
        addCategory(Intent.CATEGORY_LAUNCHER)
        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        putExtra("thot_widget_route", route)
    }

    val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    } else {
        PendingIntent.FLAG_UPDATE_CURRENT
    }

    return PendingIntent.getActivity(context, requestCode, launchIntent, flags)
}

private fun prefInt(widgetData: android.content.SharedPreferences, key: String, defaultValue: Int): Int {
    return when (val raw = widgetData.all[key]) {
        is Int -> raw
        is Long -> raw.toInt()
        is Float -> raw.toInt()
        is Double -> raw.toInt()
        is String -> raw.toIntOrNull() ?: defaultValue
        else -> defaultValue
    }
}

private fun prefDouble(widgetData: android.content.SharedPreferences, key: String, defaultValue: Double): Double {
    return when (val raw = widgetData.all[key]) {
        is Double -> raw
        is Float -> raw.toDouble()
        is Int -> raw.toDouble()
        is Long -> raw.toDouble()
        is String -> raw.toDoubleOrNull() ?: defaultValue
        else -> defaultValue
    }
}

private fun prefString(widgetData: android.content.SharedPreferences, key: String, defaultValue: String): String {
    return when (val raw = widgetData.all[key]) {
        is String -> raw
        is Number -> raw.toString()
        else -> defaultValue
    }
}

private fun pct(value: Double): String {
    val percent = (value * 100.0).coerceIn(0.0, 100.0)
    return String.format(Locale.getDefault(), "%.0f%%", percent)
}

private fun isCompactWidget(appWidgetManager: AppWidgetManager, widgetId: Int): Boolean {
    val options = appWidgetManager.getAppWidgetOptions(widgetId)
    val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0)
    val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0)
    return minWidth in 1..179 || minHeight in 1..109
}

class ThotStatsWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_stats)
            val compact = isCompactWidget(appWidgetManager, widgetId)
            val shotsToday = prefInt(widgetData, "widget_shots_today", 0)
            val sessionsWeek = prefInt(widgetData, "widget_sessions_this_week", 0)
            val avgPrecision = prefDouble(widgetData, "widget_avg_precision", 0.0)

            views.setTextViewText(R.id.widget_title, context.getString(R.string.widget_stats_title))
            views.setTextViewText(
                R.id.widget_primary_value,
                String.format(Locale.getDefault(), context.getString(R.string.widget_stats_shots), shotsToday),
            )
            views.setTextViewText(
                R.id.widget_secondary_value,
                if (compact) {
                    String.format(Locale.getDefault(), context.getString(R.string.widget_stats_sessions_week_compact), sessionsWeek)
                } else {
                    String.format(Locale.getDefault(), context.getString(R.string.widget_stats_sessions_week), sessionsWeek)
                },
            )
            views.setTextViewText(
                R.id.widget_footer,
                String.format(Locale.getDefault(), context.getString(R.string.widget_stats_avg_precision), avgPrecision),
            )
            views.setProgressBar(R.id.widget_progress, 100, avgPrecision.coerceIn(0.0, 100.0).toInt(), false)
            views.setViewVisibility(
                R.id.widget_hint,
                if (compact) android.view.View.GONE else android.view.View.VISIBLE,
            )

            launchPendingIntent(context, "/", 1001)?.let { views.setOnClickPendingIntent(R.id.widget_root, it) }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

class ThotMaintenanceWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_maintenance)
            val compact = isCompactWidget(appWidgetManager, widgetId)
            val wear = prefDouble(widgetData, "widget_wear_avg", 0.0)
            val fouling = prefDouble(widgetData, "widget_fouling_avg", 0.0)
            val stock = prefDouble(widgetData, "widget_stock_avg", 0.0)

            val wearLevel = prefString(widgetData, "widget_wear_level", "OK")
            val foulingLevel = prefString(widgetData, "widget_fouling_level", "OK")
            val stockLevel = prefString(widgetData, "widget_stock_level", "OK")

            views.setTextViewText(R.id.widget_title, context.getString(R.string.widget_maintenance_title))
            views.setTextViewText(
                R.id.value_wear,
                String.format(Locale.getDefault(), context.getString(R.string.widget_maintenance_wear), pct(wear), wearLevel),
            )
            views.setTextViewText(
                R.id.value_fouling,
                String.format(Locale.getDefault(), context.getString(R.string.widget_maintenance_fouling), pct(fouling), foulingLevel),
            )
            views.setTextViewText(
                R.id.value_stock,
                String.format(Locale.getDefault(), context.getString(R.string.widget_maintenance_stock), pct(stock), stockLevel),
            )
            views.setProgressBar(R.id.progress_wear, 100, (wear.coerceIn(0.0, 1.0) * 100.0).toInt(), false)
            views.setProgressBar(R.id.progress_fouling, 100, (fouling.coerceIn(0.0, 1.0) * 100.0).toInt(), false)
            views.setProgressBar(R.id.progress_stock, 100, (stock.coerceIn(0.0, 1.0) * 100.0).toInt(), false)
            views.setViewVisibility(
                R.id.value_stock,
                if (compact) android.view.View.GONE else android.view.View.VISIBLE,
            )
            views.setViewVisibility(
                R.id.progress_stock,
                if (compact) android.view.View.GONE else android.view.View.VISIBLE,
            )
            views.setViewVisibility(
                R.id.widget_hint,
                if (compact) android.view.View.GONE else android.view.View.VISIBLE,
            )

            launchPendingIntent(context, "/inventory", 1002)?.let { views.setOnClickPendingIntent(R.id.widget_root, it) }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

class ThotDocumentsWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_documents)
            val compact = isCompactWidget(appWidgetManager, widgetId)
            val dueCount = prefInt(widgetData, "widget_due_documents_count", 0)
            val nextDueDays = prefInt(widgetData, "widget_next_doc_due_days", 9999)

            val subtitle = when {
                dueCount <= 0 -> context.getString(R.string.widget_documents_no_reminder)
                nextDueDays == 9999 -> context.getString(R.string.widget_documents_check_due)
                nextDueDays < 0 -> context.getString(R.string.widget_documents_expired)
                nextDueDays == 0 -> context.getString(R.string.widget_documents_due_today)
                else -> String.format(Locale.getDefault(), context.getString(R.string.widget_documents_due_days), nextDueDays)
            }

            views.setTextViewText(R.id.widget_title, context.getString(R.string.widget_documents_title))
            views.setTextViewText(
                R.id.widget_primary_value,
                if (compact) {
                    String.format(Locale.getDefault(), context.getString(R.string.widget_documents_count_compact), dueCount)
                } else {
                    String.format(Locale.getDefault(), context.getString(R.string.widget_documents_count), dueCount)
                },
            )
            views.setTextViewText(R.id.widget_footer, subtitle)
            views.setProgressBar(R.id.widget_progress, 100, (dueCount * 20).coerceIn(0, 100), false)
            views.setViewVisibility(
                R.id.widget_hint,
                if (compact) android.view.View.GONE else android.view.View.VISIBLE,
            )

            launchPendingIntent(context, "/settings", 1003)?.let { views.setOnClickPendingIntent(R.id.widget_root, it) }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

class ThotActivityWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_activity)
            val compact = isCompactWidget(appWidgetManager, widgetId)
            val days = prefInt(widgetData, "widget_last_activity_days", -1)
            val sessions = prefInt(widgetData, "widget_total_sessions", 0)

            val activity = when {
                days < 0 -> context.getString(R.string.widget_activity_no_session)
                days == 0 -> context.getString(R.string.widget_activity_today)
                days == 1 -> context.getString(R.string.widget_activity_yesterday)
                else -> String.format(Locale.getDefault(), context.getString(R.string.widget_activity_days_ago), days)
            }

            views.setTextViewText(R.id.widget_title, context.getString(R.string.widget_activity_title))
            views.setTextViewText(R.id.widget_primary_value, activity)
            views.setTextViewText(
                R.id.widget_footer,
                if (compact) {
                    String.format(Locale.getDefault(), context.getString(R.string.widget_activity_total_sessions_compact), sessions)
                } else {
                    String.format(Locale.getDefault(), context.getString(R.string.widget_activity_total_sessions), sessions)
                },
            )
            val activityScore = when {
                days < 0 -> 0
                days == 0 -> 100
                days == 1 -> 85
                else -> (100 - (days * 12)).coerceIn(0, 100)
            }
            views.setProgressBar(R.id.widget_progress, 100, activityScore, false)
            views.setViewVisibility(
                R.id.widget_hint,
                if (compact) android.view.View.GONE else android.view.View.VISIBLE,
            )

            launchPendingIntent(context, "/sessions", 1004)?.let { views.setOnClickPendingIntent(R.id.widget_root, it) }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
