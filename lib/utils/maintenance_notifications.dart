import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../data/models.dart';

class MaintenanceNotifications {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const _channelId = 'thot_maintenance';
  static const _channelName = 'Maintenance armes';

  static Future<void> init() async {
    if (kIsWeb || _initialized) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
    _initialized = true;
  }

  static Future<void> requestPermission() async {
    if (kIsWeb) return;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Vérifie toutes les armes et envoie une notification si seuil >= 90%.
  static Future<void> checkAndNotify(List<Weapon> weapons) async {
    if (kIsWeb || !_initialized) return;

    for (final weapon in weapons) {
      if (weapon.trackCleanliness && weapon.cleaningProgress >= 0.9) {
        await _notify(
          id: weapon.id.hashCode & 0x7FFFFFFF,
          title: '🔧 ${weapon.name} — Entretien recommandé',
          body:
              '${weapon.roundsSinceCleaning} coups depuis le dernier nettoyage (seuil : ${weapon.cleaningRoundsThreshold}).',
        );
      }

      if (weapon.trackWear && weapon.revisionProgress >= 0.9) {
        await _notify(
          id: (weapon.id + '_rev').hashCode & 0x7FFFFFFF,
          title: '⚙️ ${weapon.name} — Révision recommandée',
          body:
              '${weapon.roundsSinceRevision} coups depuis la dernière révision (seuil : ${weapon.wearRoundsThreshold}).',
        );
      }
    }
  }

  static Future<void> _notify({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }
}