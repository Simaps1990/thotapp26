import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode, kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../data/models.dart';

class MaintenanceNotifications {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;
  static bool _timezoneInitialized = false;

  static const _docChannelId = 'thot_documents';
  static const _scheduledDocIdsKey = 'scheduled_document_notification_ids_v1';
  /// IDs of document reminders that have already been scheduled (and therefore
  /// will fire exactly once). Persisted across launches so that subsequent
  /// sync passes don't re-queue a "catch-up" reminder for a document whose
  /// notification has already been shown. Cleared entries for a given doc
  /// only come back naturally when the doc itself changes (the uniqueKey —
  /// and therefore the hashed id — depends on expiryDate + notifyBeforeDays).
  static const _firedDocIdsKey = 'fired_document_notification_ids_v1';

  static Future<void> init() async {
    if (kIsWeb || _initialized) return;

    if (!_timezoneInitialized) {
      tz_data.initializeTimeZones();
      try {
        final tzInfo = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
      }
      _timezoneInitialized = true;
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // One-shot migration: clear obsolete fired ids set computed with the old
    // String.hashCode algorithm (it does not match the new MD5-based ids).
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('fired_doc_ids_migrated_md5') ?? false)) {
      await _plugin.cancelAll();
      await prefs.remove(_firedDocIdsKey);
      await prefs.remove(_scheduledDocIdsKey);
      await prefs.setBool('fired_doc_ids_migrated_md5', true);
    }

    _initialized = true;
  }

  static String _getChannelName(String? localeCode) {
    final locale = (localeCode ?? '').toLowerCase();
    switch (locale) {
      case 'en':
        return 'Document reminders';
      case 'de':
        return 'Dokumenterinnerungen';
      case 'it':
        return 'Promemoria documenti';
      case 'es':
        return 'Recordatorios de documentos';
      default:
        return 'Rappels documents';
    }
  }

  static String _getChannelDescription(String? localeCode) {
    final locale = (localeCode ?? '').toLowerCase();
    switch (locale) {
      case 'en':
        return 'Document expiry reminders (permits, warranties...)';
      case 'de':
        return 'Erinnerungen an Dokumentabläufe (Erlaubnisse, Garantien...)';
      case 'it':
        return 'Promemoria scadenza documenti (permessi, garanzie...)';
      case 'es':
        return 'Recordatorios de vencimiento de documentos (permisos, garantías...)';
      default:
        return 'Rappels d\'expiration de documents (permis, garanties...)';
    }
  }

  static Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    await init();

    var granted = true;

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted = await android?.requestNotificationsPermission();
    if (androidGranted == false) {
      granted = false;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await ios?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
    if (iosGranted == false) {
      granted = false;
    }

    return granted;
  }

  static Future<void> syncDocumentExpiryReminders({
    required bool enabled,
    required String? localeCode,
    required List<Platform> platforms,
    required List<Ammo> ammos,
    required List<Accessory> accessories,
    required List<UserDocument> userDocuments,
  }) async {
    if (kIsWeb) return;
    await init();
    if (!_initialized) return;

    // Create or update the Android notification channel with localized strings
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        AndroidNotificationChannel(
          _docChannelId,
          _getChannelName(localeCode),
          description: _getChannelDescription(localeCode),
          importance: Importance.high,
        ),
      );
    }

    await _cancelScheduledDocumentReminders();

    if (!enabled) return;

    // Make sure OS permission is still granted — the user may have revoked
    // it in system settings since the toggle was first enabled. Without this
    // the plugin will silently accept schedules that will never be shown.
    await requestPermission();

    // We deliberately use INEXACT scheduling only.
    //  - Avoids declaring SCHEDULE_EXACT_ALARM / USE_EXACT_ALARM in the
    //    manifest (flagged as "restricted permissions" on the Play Store and
    //    requiring justification to reviewers).
    //  - For a daily reminder at 10:00, a Doze-induced drift of a few
    //    minutes (rarely more than 15) is acceptable.
    //  - `allowWhileIdle` ensures the notification still fires when the
    //    device is in Doze mode overnight.
    const scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;

    final now = DateTime.now();
    final scheduledIds = <int>[];
    // Persisted set of notification IDs we have already scheduled in past
    // sessions. Used to ensure a document only triggers one reminder ever
    // (identified by its stable id). A doc renewal produces a new id, so
    // renewal reminders still fire.
    final firedIds = await _getFiredDocIds();
    final newFiredIds = <int>{};
    var skippedPastExpired = 0;
    var scheduledCatchUp = 0;
    var skippedAlreadyFired = 0;

    Future<void> scheduleReminder({
      required String uniqueKey,
      required String documentName,
      required DateTime expiryDate,
      required int notifyBeforeDays,
      required String documentType,
    }) async {
      if (notifyBeforeDays <= 0) return;

      final targetDay = DateTime(
        expiryDate.year,
        expiryDate.month,
        expiryDate.day,
      ).subtract(Duration(days: notifyBeforeDays));

      var triggerAt = DateTime(
        targetDay.year,
        targetDay.month,
        targetDay.day,
        10,
      );

      final expiryDay = DateTime(
        expiryDate.year,
        expiryDate.month,
        expiryDate.day,
      );

      // Compute the stable id early so we can dedupe against past fires.
      // Same doc+expiry+notifyBeforeDays always maps to the same id; a
      // renewal (new expiry date) produces a different id naturally.
      final id = _stablePositiveId('doc:$uniqueKey');

      // Guarantee one-shot behaviour: if we've already scheduled (and thus
      // fired, since we use one-time zonedSchedule) a notification for this
      // document in a previous app session, don't queue another one.
      if (firedIds.contains(id)) {
        skippedAlreadyFired++;
        return;
      }

      // If the ideal trigger date is in the past BUT the document has not
      // yet expired, reschedule a catch-up notification ~1 minute from now.
      // This covers the common case where the user adds a document whose
      // notify window already started (e.g. expires in 3 days with a
      // 7-day notice) — they still deserve a reminder.
      if (!triggerAt.isAfter(now)) {
        if (expiryDay.isBefore(DateTime(now.year, now.month, now.day))) {
          // Already expired: skip.
          skippedPastExpired++;
          return;
        }
        triggerAt = now.add(const Duration(minutes: 1));
        scheduledCatchUp++;
      }

      // Title format: "Le document : <custom name>" (localised prefix).
      final rawName = documentName.trim().isEmpty
          ? _documentReminderTitle(localeCode, documentType)
          : documentName;
      final title = '${_documentReminderPrefix(localeCode)} $rawName';
      final body = _documentReminderBody(
        localeCode,
        documentName,
        documentType,
        expiryDate,
        notifyBeforeDays,
      );

      final androidDetails = AndroidNotificationDetails(
        _docChannelId,
        _getChannelName(localeCode),
        channelDescription: _getChannelDescription(localeCode),
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        category: AndroidNotificationCategory.reminder,
        visibility: NotificationVisibility.public,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final scheduledDate = tz.TZDateTime(
        tz.local,
        triggerAt.year,
        triggerAt.month,
        triggerAt.day,
        triggerAt.hour,
        triggerAt.minute,
      );

      try {
        await _plugin.zonedSchedule(
          id: id,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails:
              NotificationDetails(android: androidDetails, iOS: iosDetails),
          androidScheduleMode: scheduleMode,
          payload: 'document_expiry',
        );
        scheduledIds.add(id);
        newFiredIds.add(id);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('[MaintenanceNotifications] schedule failed for "$documentName": $e');
        }
      }
    }

    for (final platform in platforms) {
      for (final doc in platform.documents) {
        if (doc.expiryDate == null) continue;
        await scheduleReminder(
          uniqueKey:
              'platform:${platform.id}:${doc.path}:${doc.name}:${doc.expiryDate!.toIso8601String()}:${doc.notifyBeforeDays}',
          documentName: doc.name,
          expiryDate: doc.expiryDate!,
          notifyBeforeDays: doc.notifyBeforeDays,
          documentType: doc.type,
        );
      }
    }

    for (final ammo in ammos) {
      for (final doc in ammo.documents) {
        if (doc.expiryDate == null) continue;
        await scheduleReminder(
          uniqueKey:
              'ammo:${ammo.id}:${doc.path}:${doc.name}:${doc.expiryDate!.toIso8601String()}:${doc.notifyBeforeDays}',
          documentName: doc.name,
          expiryDate: doc.expiryDate!,
          notifyBeforeDays: doc.notifyBeforeDays,
          documentType: doc.type,
        );
      }
    }

    for (final accessory in accessories) {
      for (final doc in accessory.documents) {
        if (doc.expiryDate == null) continue;
        await scheduleReminder(
          uniqueKey:
              'accessory:${accessory.id}:${doc.path}:${doc.name}:${doc.expiryDate!.toIso8601String()}:${doc.notifyBeforeDays}',
          documentName: doc.name,
          expiryDate: doc.expiryDate!,
          notifyBeforeDays: doc.notifyBeforeDays,
          documentType: doc.type,
        );
      }
    }

    for (final doc in userDocuments) {
      if (doc.expiryDate == null) continue;
      await scheduleReminder(
        uniqueKey:
            'user:${doc.id}:${doc.filePath}:${doc.name}:${doc.expiryDate!.toIso8601String()}:${doc.notifyBeforeDays}',
        documentName: doc.name,
        expiryDate: doc.expiryDate!,
        notifyBeforeDays: doc.notifyBeforeDays,
        documentType: doc.type,
      );
    }

    await _saveScheduledDocumentIds(scheduledIds);
    // Persist the union of already-fired and newly-scheduled ids so we
    // never re-fire a reminder for the same document in a later sync.
    if (newFiredIds.isNotEmpty) {
      await _saveFiredDocIds(firedIds.union(newFiredIds));
    }

    if (kDebugMode) {
      debugPrint(
        '[MaintenanceNotifications] sync done: '
        'scheduled=${scheduledIds.length} '
        'catchUp=$scheduledCatchUp '
        'skippedExpired=$skippedPastExpired '
        'skippedAlreadyFired=$skippedAlreadyFired',
      );
    }
  }

  static Future<void> cancelDocumentReminders() async {
    if (kIsWeb || !_initialized) return;
    await _cancelScheduledDocumentReminders();
  }

  /// Fires an immediate notification used to diagnose whether the
  /// end-to-end pipeline (permission, channel, icon) is working.
  /// Returns true if the notification was emitted without error.
  static Future<bool> showTestNotification({String? localeCode}) async {
    if (kIsWeb) return false;
    await init();
    if (!_initialized) return false;

    // Create or update the Android notification channel with localized strings
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        AndroidNotificationChannel(
          _docChannelId,
          _getChannelName(localeCode),
          description: _getChannelDescription(localeCode),
          importance: Importance.high,
        ),
      );
    }

    // Make sure permission has been requested at least once.
    await requestPermission();

    final androidDetails = AndroidNotificationDetails(
      _docChannelId,
      _getChannelName(localeCode),
      channelDescription: _getChannelDescription(localeCode),
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final testTitle = _getTestNotificationTitle(localeCode);
    final testBody = _getTestNotificationBody(localeCode);

    try {
      await _plugin.show(
        id: _stablePositiveId('test_notification'),
        title: testTitle,
        body: testBody,
        notificationDetails:
            NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: 'test_notification',
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Test notification failed: $e');
      }
      return false;
    }
  }

  static String _getTestNotificationTitle(String? localeCode) {
    final locale = (localeCode ?? '').toLowerCase();
    switch (locale) {
      case 'en':
        return 'THOT test notification';
      case 'de':
        return 'THOT-Testbenachrichtigung';
      case 'it':
        return 'Notifica di test THOT';
      case 'es':
        return 'Notificación de prueba THOT';
      default:
        return 'Test de notification THOT';
    }
  }

  static String _getTestNotificationBody(String? localeCode) {
    final locale = (localeCode ?? '').toLowerCase();
    switch (locale) {
      case 'en':
        return 'If you see this message, notifications are working correctly.';
      case 'de':
        return 'Wenn Sie diese Nachricht sehen, funktionieren Benachrichtigungen korrekt.';
      case 'it':
        return 'Se vedi questo messaggio, le notifiche funzionano correttamente.';
      case 'es':
        return 'Si ve este mensaje, las notificaciones funcionan correctamente.';
      default:
        return 'Si vous voyez ce message, les notifications fonctionnent correctement.';
    }
  }



  /// Annule toutes les notifications de maintenance
  static Future<void> cancelAll() async {
    if (kIsWeb || !_initialized) return;
    await _plugin.cancelAll();
  }

  /// Returns the list of currently pending (scheduled) notifications.
  /// Useful for debugging – call this after syncDocumentExpiryReminders.
  static Future<List<PendingNotificationRequest>> pendingNotifications() async {
    if (kIsWeb) return [];
    await init();
    if (!_initialized) return [];
    return _plugin.pendingNotificationRequests();
  }

  /// Stable, deterministic positive int id derived from a string.
  /// Uses MD5 (cryptographic hash) which is fully deterministic across
  /// Dart/Flutter releases, unlike String.hashCode.
  static int _stablePositiveId(String input) {
    final bytes = md5.convert(utf8.encode(input)).bytes;
    return ((bytes[0] << 24) |
            (bytes[1] << 16) |
            (bytes[2] << 8) |
            bytes[3]) &
        0x7FFFFFFF;
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  static String _documentReminderTitle(String? localeCode, String documentType) {
    final locale = (localeCode ?? '').toLowerCase();
    final type = documentType.toLowerCase();
    
    // Permis et certificats - messages plus personnels
    if (type.contains('permis') || type.contains('permit') || type.contains('licence') || type.contains('license') || 
        type.contains('certificat') || type.contains('certificate')) {
      switch (locale) {
        case 'en':
          return 'Permit reminder';
        case 'de':
          return 'Erlaubnis-Erinnerung';
        case 'it':
          return 'Promemoria permesso';
        case 'es':
          return 'Recordatorio de permiso';
        default:
          return 'Rappel permis';
      }
    }
    
    // Garanties
    if (type.contains('garantie') || type.contains('warranty')) {
      switch (locale) {
        case 'en':
          return 'Warranty reminder';
        case 'de':
          return 'Garantie-Erinnerung';
        case 'it':
          return 'Promemoria garanzia';
        case 'es':
          return 'Recordatorio de garantía';
        default:
          return 'Rappel garantie';
      }
    }
    
    // Messages génériques pour autres types
    switch (locale) {
      case 'en':
        return 'Document reminder';
      case 'de':
        return 'Dokument-Erinnerung';
      case 'it':
        return 'Promemoria documento';
      case 'es':
        return 'Recordatorio de documento';
      default:
        return 'Rappel document';
    }
  }

  static String _documentReminderBody(
    String? localeCode,
    String documentName,
    String documentType,
    DateTime expiryDate,
    int notifyBeforeDays,
  ) {
    // The document name is already used as the notification title, so the
    // body focuses on the expiry date only — this avoids redundant text and
    // keeps the preview concise on small screens.
    final locale = (localeCode ?? '').toLowerCase();
    final date = _formatDate(expiryDate);

    switch (locale) {
      case 'en':
        return 'Expires on $date';
      case 'de':
        return 'Läuft am $date ab';
      case 'it':
        return 'Scade il $date';
      case 'es':
        return 'Vence el $date';
      default:
        return 'Expire le $date';
    }
  }

  /// Localized prefix used in the notification title, followed by the
  /// document's custom name: e.g. "Le document : Permis de chasse 2027".
  static String _documentReminderPrefix(String? localeCode) {
    switch ((localeCode ?? '').toLowerCase()) {
      case 'en':
        return 'Document:';
      case 'de':
        return 'Dokument:';
      case 'it':
        return 'Documento:';
      case 'es':
        return 'Documento:';
      default:
        return 'Le document :';
    }
  }

  static Future<Set<int>> _getFiredDocIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_firedDocIdsKey) ?? const [];
    return raw.map(int.tryParse).whereType<int>().toSet();
  }

  static Future<void> _saveFiredDocIds(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _firedDocIdsKey,
      ids.map((e) => e.toString()).toList(),
    );
  }

  static Future<void> _saveScheduledDocumentIds(List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _scheduledDocIdsKey,
      ids.map((e) => e.toString()).toList(),
    );
  }

  static Future<void> _cancelScheduledDocumentReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final rawIds = prefs.getStringList(_scheduledDocIdsKey) ?? const [];
    for (final raw in rawIds) {
      final id = int.tryParse(raw);
      if (id != null) {
        await _plugin.cancel(id: id);
      }
    }
    await prefs.remove(_scheduledDocIdsKey);
  }


}