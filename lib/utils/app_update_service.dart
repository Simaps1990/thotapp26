import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint, defaultTargetPlatform, TargetPlatform;
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_update/in_app_update.dart';

class AppUpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final Uri storeUrl;

  const AppUpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.storeUrl,
  });
}

class AppUpdateService {
  static const Duration _minCheckInterval = Duration(hours: 6);
  static DateTime? _lastCheckAt;
  // Cached result – returned when throttled so callers always see the last
  // known update without an extra network round-trip.
  static AppUpdateInfo? _cachedUpdate;

  static Future<AppUpdateInfo?> checkForUpdate({bool force = false}) async {

    if (!force && _lastCheckAt != null) {
      final elapsed = DateTime.now().difference(_lastCheckAt!);
      if (elapsed < _minCheckInterval) {
        return _cachedUpdate; // return cached result instead of null
      }
    }

    _lastCheckAt = DateTime.now();

    final packageInfo = await PackageInfo.fromPlatform();
    final packageName = packageInfo.packageName;
    final currentVersion = packageInfo.version.trim();

    AppUpdateInfo? result;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      result = await _checkIos(
        packageName: packageName,
        currentVersion: currentVersion,
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      result = await _checkAndroid(
        packageName: packageName,
        currentVersion: currentVersion,
      );
    }

    _cachedUpdate = result; // null = app is up-to-date, clears the cache
    return result;
  }

  static Future<AppUpdateInfo?> _checkIos({
    required String packageName,
    required String currentVersion,
  }) async {
    try {
      final lookupUri = Uri.parse(
        'https://itunes.apple.com/lookup?bundleId=$packageName',
      );
      final response = await http.get(lookupUri);
      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      final results = decoded['results'];
      if (results is! List || results.isEmpty) return null;

      final first = results.first;
      if (first is! Map<String, dynamic>) return null;

      final latestVersion = (first['version'] as String? ?? '').trim();
      final trackViewUrl = (first['trackViewUrl'] as String? ?? '').trim();

      if (latestVersion.isEmpty || trackViewUrl.isEmpty) return null;
      if (_compareVersions(latestVersion, currentVersion) <= 0) return null;

      final storeUri = Uri.tryParse(trackViewUrl);
      if (storeUri == null) return null;

      return AppUpdateInfo(
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        storeUrl: storeUri,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<AppUpdateInfo?> _checkAndroid({
    required String packageName,
    required String currentVersion,
  }) async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (kDebugMode) {
          debugPrint(
            '[AppUpdateService] Android update available via in_app_update',
          );
        }
        return AppUpdateInfo(
          currentVersion: currentVersion,
          latestVersion:
              'Update Available', // in_app_update doesn't provide the exact version string
          storeUrl: Uri.parse('market://details?id=$packageName'),
        );
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '[AppUpdateService] in_app_update failed: $e. Falling back to null.',
        );
      }
      return null;
    }
  }

  static Future<void> openStore(AppUpdateInfo info) async {
    final url = info.storeUrl;

    if (defaultTargetPlatform == TargetPlatform.android) {
      final packageName = url.queryParameters['id'];
      if (packageName != null && packageName.isNotEmpty) {
        final marketUri = Uri.parse('market://details?id=$packageName');
        final openedMarket = await launchUrl(
          marketUri,
          mode: LaunchMode.externalApplication,
        );
        if (openedMarket) return;
      }
    }

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  static int _compareVersions(String a, String b) {
    final aParts = _numericVersionParts(a);
    final bParts = _numericVersionParts(b);
    final maxLen = aParts.length > bParts.length
        ? aParts.length
        : bParts.length;

    for (var i = 0; i < maxLen; i++) {
      final av = i < aParts.length ? aParts[i] : 0;
      final bv = i < bParts.length ? bParts[i] : 0;
      if (av != bv) return av > bv ? 1 : -1;
    }

    return 0;
  }

  static List<int> _numericVersionParts(String raw) {
    final cleaned = raw.split(RegExp(r'[^0-9.]')).first;
    return cleaned
        .split('.')
        .where((p) => p.isNotEmpty)
        .map((p) => int.tryParse(p) ?? 0)
        .toList(growable: false);
  }
}
