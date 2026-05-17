import 'package:home_widget/home_widget.dart';
import 'package:thot/data/models.dart';

class DashboardWidgetService {
  static const String iosAppGroupId = 'group.fr.thotbook.app';

  static const String _androidStatsProvider = 'ThotStatsWidgetProvider';
  static const String _androidMaintenanceProvider =
      'ThotMaintenanceWidgetProvider';
  static const String _androidDocumentsProvider = 'ThotDocumentsWidgetProvider';
  static const String _androidActivityProvider = 'ThotActivityWidgetProvider';

  static const String _iosStatsKind = 'ThotStatsWidget';
  static const String _iosMaintenanceKind = 'ThotMaintenanceWidget';
  static const String _iosDocumentsKind = 'ThotDocumentsWidget';
  static const String _iosActivityKind = 'ThotActivityWidget';

  static Future<void> sync({
    required List<Session> sessions,
    required List<Platform> platforms,
    required List<Ammo> ammos,
    required List<Accessory> accessories,
    required List<UserDocument> userDocuments,
  }) async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(const Duration(days: 6));

    final sessionsToday = sessions.where((s) => !s.date.isBefore(todayStart));
    final sessionsThisWeek = sessions.where((s) => !s.date.isBefore(weekStart));

    final shotsToday = sessionsToday.fold<int>(
      0,
      (sum, s) => sum + s.totalRounds,
    );
    final totalSessions = sessions.length;
    final totalShots = sessions.fold<int>(0, (sum, s) => sum + s.totalRounds);

    final lastSession = sessions.isEmpty
        ? null
        : sessions.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
    final lastActivityDays = lastSession == null
        ? -1
        : todayStart
              .difference(
                DateTime(
                  lastSession.date.year,
                  lastSession.date.month,
                  lastSession.date.day,
                ),
              )
              .inDays;

    final sessionsWithPrecision = sessions
        .where((s) => s.hasCountedPrecision)
        .toList();
    final avgPrecision = sessionsWithPrecision.isEmpty
        ? 0.0
        : sessionsWithPrecision.fold<double>(
                0,
                (sum, s) => sum + s.averagePrecision,
              ) /
              sessionsWithPrecision.length;

    final wearProgress = <double>[
      ...platforms.where((p) => p.trackWear).map((p) => p.revisionProgress),
      ...accessories.where((a) => a.trackWear).map((a) => a.revisionProgress),
    ];

    final foulingProgress = <double>[
      ...platforms
          .where((p) => p.trackCleanliness)
          .map((p) => p.cleaningProgress),
      ...accessories
          .where((a) => a.trackCleanliness)
          .map((a) => a.cleaningProgress),
    ];

    final stockProgress = ammos.where((a) => a.trackStock).map((a) {
      final threshold = a.lowStockThreshold.toDouble();
      final initial = a.initialQuantity.toDouble();
      final current = a.quantity.toDouble();
      if (initial <= threshold) {
        return current <= threshold ? 1.0 : 0.0;
      }
      return (1.0 - ((current - threshold) / (initial - threshold))).clamp(
        0.0,
        1.0,
      );
    }).toList();

    double avg(List<double> list) {
      if (list.isEmpty) return 0.0;
      return list.reduce((a, b) => a + b) / list.length;
    }

    // Stable, language-agnostic codes. The native widget code (Android
    // strings.xml or iOS Localizable.strings) is responsible for mapping
    // these to localized labels. NEVER send a French-only label here:
    // the widget runs on the system home screen and may be shown to a
    // user whose system locale differs from the app's selected locale.
    String level(double value) {
      if (value >= 1.0) return 'critical';
      if (value >= 0.8) return 'warning';
      return 'ok';
    }

    final wearAvg = avg(wearProgress);
    final foulingAvg = avg(foulingProgress);
    final stockAvg = avg(stockProgress);

    final docsDueSoon = <int>[];

    for (final p in platforms) {
      for (final d in p.documents) {
        if (d.expiryDate == null || d.notifyBeforeDays <= 0) continue;
        final days = d.expiryDate!.difference(now).inDays;
        if (days <= d.notifyBeforeDays) docsDueSoon.add(days);
      }
    }

    for (final a in ammos) {
      for (final d in a.documents) {
        if (d.expiryDate == null || d.notifyBeforeDays <= 0) continue;
        final days = d.expiryDate!.difference(now).inDays;
        if (days <= d.notifyBeforeDays) docsDueSoon.add(days);
      }
    }

    for (final a in accessories) {
      for (final d in a.documents) {
        if (d.expiryDate == null || d.notifyBeforeDays <= 0) continue;
        final days = d.expiryDate!.difference(now).inDays;
        if (days <= d.notifyBeforeDays) docsDueSoon.add(days);
      }
    }

    for (final d in userDocuments) {
      if (d.expiryDate == null || d.notifyBeforeDays <= 0) continue;
      final days = d.expiryDate!.difference(now).inDays;
      if (days <= d.notifyBeforeDays) docsDueSoon.add(days);
    }

    final nextDocDueDays = docsDueSoon.isEmpty
        ? 9999
        : docsDueSoon.reduce((a, b) => a < b ? a : b);

    await HomeWidget.setAppGroupId(iosAppGroupId);

    await Future.wait([
      HomeWidget.saveWidgetData<int>('widget_total_sessions', totalSessions),
      HomeWidget.saveWidgetData<int>('widget_total_shots', totalShots),
      HomeWidget.saveWidgetData<int>(
        'widget_sessions_this_week',
        sessionsThisWeek.length,
      ),
      HomeWidget.saveWidgetData<int>('widget_shots_today', shotsToday),
      HomeWidget.saveWidgetData<double>(
        'widget_avg_precision',
        avgPrecision.clamp(0.0, 100.0),
      ),
      HomeWidget.saveWidgetData<double>('widget_wear_avg', wearAvg),
      HomeWidget.saveWidgetData<double>('widget_fouling_avg', foulingAvg),
      HomeWidget.saveWidgetData<double>('widget_stock_avg', stockAvg),
      HomeWidget.saveWidgetData<String>('widget_wear_level', level(wearAvg)),
      HomeWidget.saveWidgetData<String>(
        'widget_fouling_level',
        level(foulingAvg),
      ),
      HomeWidget.saveWidgetData<String>('widget_stock_level', level(stockAvg)),
      HomeWidget.saveWidgetData<int>(
        'widget_due_documents_count',
        docsDueSoon.length,
      ),
      HomeWidget.saveWidgetData<int>(
        'widget_next_doc_due_days',
        nextDocDueDays,
      ),
      HomeWidget.saveWidgetData<int>(
        'widget_total_platforms',
        platforms.length,
      ),
      HomeWidget.saveWidgetData<int>('widget_total_ammos', ammos.length),
      HomeWidget.saveWidgetData<int>(
        'widget_total_accessories',
        accessories.length,
      ),
      HomeWidget.saveWidgetData<int>(
        'widget_last_activity_days',
        lastActivityDays,
      ),
      HomeWidget.saveWidgetData<int>(
        'widget_last_sync_epoch_ms',
        now.millisecondsSinceEpoch,
      ),
    ]);

    await Future.wait([
      HomeWidget.updateWidget(
        name: _androidStatsProvider,
        iOSName: _iosStatsKind,
      ),
      HomeWidget.updateWidget(
        name: _androidMaintenanceProvider,
        iOSName: _iosMaintenanceKind,
      ),
      HomeWidget.updateWidget(
        name: _androidDocumentsProvider,
        iOSName: _iosDocumentsKind,
      ),
      HomeWidget.updateWidget(
        name: _androidActivityProvider,
        iOSName: _iosActivityKind,
      ),
    ]);
  }
}
