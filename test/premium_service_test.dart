import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thot/data/thot_premium_service.dart';

void main() {
  group('ThotPremiumService grace period', () {
    test('isPremium is true within grace period even when _isPremium is false', () async {
      final tenDaysAgo = DateTime.now().subtract(const Duration(days: 10));
      SharedPreferences.setMockInitialValues({
        'last_premium_validation_at': tenDaysAgo.toIso8601String(),
      });

      final prefs = await SharedPreferences.getInstance();
      final service = ThotPremiumService(onChanged: () {});
      service.loadMetadataFromPrefs(prefs);

      expect(service.isPremium, true);
    });

    test('isPremium is false when outside grace period and no active premium', () async {
      final fortyDaysAgo = DateTime.now().subtract(const Duration(days: 40));
      SharedPreferences.setMockInitialValues({
        'last_premium_validation_at': fortyDaysAgo.toIso8601String(),
      });

      final prefs = await SharedPreferences.getInstance();
      final service = ThotPremiumService(onChanged: () {});
      service.loadMetadataFromPrefs(prefs);

      expect(service.isPremium, false);
    });

    test('clearLocalCache removes grace period fallback', () async {
      final tenDaysAgo = DateTime.now().subtract(const Duration(days: 10));
      SharedPreferences.setMockInitialValues({
        'last_premium_validation_at': tenDaysAgo.toIso8601String(),
      });

      final prefs = await SharedPreferences.getInstance();
      final service = ThotPremiumService(onChanged: () {});
      service.loadMetadataFromPrefs(prefs);

      expect(service.isPremium, true);

      await service.clearLocalCache();

      expect(service.isPremium, false);
      expect(prefs.getString('last_premium_validation_at'), isNull);
    });
  });
}
