import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show kDebugMode, debugPrint, defaultTargetPlatform, TargetPlatform;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/data/exercise_step.dart';
import 'models.dart';
import 'material_types.dart';
import '../utils/achievement_definitions.dart';
import '../utils/dashboard_widget_service.dart';
import '../utils/maintenance_notifications.dart';
import 'thot_file_store.dart';
import 'thot_premium_service.dart';
import 'thot_security_service.dart';
import '../utils/image_storage.dart';
import '../utils/crash_logger.dart';

enum WeightUnit { gram, grain, ounce }

enum DistanceUnit { meter, yard }

enum VelocityUnit { metersPerSecond, feetPerSecond }

enum UnitProfile { metric, imperial, custom }

double gramsToGrains(double grams) => grams * 15.4324;
double grainsToGrams(double grains) => grains / 15.4324;
double gramsToOunces(double grams) => grams / 28.3495;
double ouncesToGrams(double ounces) => ounces * 28.3495;
double metersToYards(double meters) => meters * 1.09361;
double yardsToMeters(double yards) => yards / 1.09361;
double mpsToFps(double mps) => mps * 3.28084;
double fpsToMps(double fps) => fps / 3.28084;

class DomainImportPreview {
  final int platforms;
  final int ammos;
  final int accessories;
  final int sessions;
  final int diagnostics;
  final int shootingTables;

  const DomainImportPreview({
    required this.platforms,
    required this.ammos,
    required this.accessories,
    required this.sessions,
    required this.diagnostics,
    required this.shootingTables,
  });
}

class ThotProvider extends ChangeNotifier {
  late final ThotPremiumService _premiumService = ThotPremiumService(
    onChanged: notifyListeners,
  );

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;
  bool _domainDataLoadCompleted = false;

  Future<void>? _initializeFuture;
  Timer? _saveDebounce;
  Timer? _widgetSyncDebounce;

  /// Schedule a debounced sync of Android home-screen widgets.
  /// Only fires after domain data has been loaded (to avoid empty syncs)
  /// and ignores errors silently (e.g. in test environment).
  void _scheduleWidgetSync() {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    if (!_domainDataLoadCompleted) return;
    _widgetSyncDebounce?.cancel();
    _widgetSyncDebounce = Timer(const Duration(milliseconds: 600), () {
      try {
        unawaited(
          DashboardWidgetService.sync(
            sessions: _sessions,
            platforms: platforms,
            ammos: ammos,
            accessories: accessories,
            userDocuments: _userDocuments,
          ),
        );
      } catch (_) {
        // Silently ignore — widget sync is best-effort.
      }
    });
  }

  // ============================================================
  // FREEMIUM MACHINERY
  // ============================================================
  //
  // THOT v1.3.3 ships with the freemium ENTIRELY DISABLED via the flag below.
  // The full set of limits and the matching `isXLockedForFree(...)` getters
  // are implemented for the day a Pro plan is reactivated. To turn the
  // freemium back ON, change `_kFreeLimitsDisabled` to `false` and ensure
  // the RevenueCat product IDs in `thot_premium_service.dart` are correct.
  //
  // NEVER call the limits checks bypassing the `_kFreeLimitsDisabled` guard
  // at the top of each helper — UI stays consistent that way.
  // ============================================================

  // TEMPORARY: Free plan limits disabled - all users get premium access
  static const bool _kFreeLimitsDisabled = true;
  static const bool _kForceFreeModeForTesting = false;
  bool get isFreeLimitsDisabled => _kFreeLimitsDisabled;

  /// Bump this when the JSON layout of `_buildDomainDataMap()` changes in a
  /// way that requires migration. The previous version is preserved for one
  /// release, then migration code can be retired.
  // schemaVersion 2: dropped redundant 'pdfPaths' key (always present
  // alongside 'documents' since v1). Reading still falls back to
  // 'pdfPaths' for older data files.
  static const int kCurrentSchemaVersion = 2;

  // ----- Premium status -----
  bool get isPremium {
    if (_kForceFreeModeForTesting) return false;
    if (_kFreeLimitsDisabled) return true;
    return _premiumService.isPremium;
  }

  bool get purchaseAvailable => _premiumService.purchaseAvailable;
  bool get purchasePending => _premiumService.purchasePending;
  String? get purchaseError => _premiumService.purchaseError;

  // Localized prices for Pro offers (from store / RevenueCat)
  String? get yearlyPrice => _premiumService.yearlyPrice;
  String? get monthlyPrice => _premiumService.monthlyPrice;

  Future<void> purchaseYearly() => _premiumService.purchaseYearly();
  Future<void> purchaseMonthly() => _premiumService.purchaseMonthly();

  // Sauvegarde système : iOS (iCloud Backup) inclut Application Support
  // par défaut. Android : sauvegarde sélective configurée dans
  // android/app/src/main/res/xml/backup_rules.xml et
  // data_extraction_rules.xml (fichier domain + photos + user_documents).
  // Limite Auto Backup Android : 25 MB par app — au-delà, le backup est
  // silencieusement ignoré côté système.
  bool get cloudBackupEnabled => true;

  // Security
  static FlutterSecureStorage _buildSecureStorage() {
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return const FlutterSecureStorage(
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock,
          synchronizable: true,
        ),
      );
    }
    return const FlutterSecureStorage();
  }

  final FlutterSecureStorage _secureStorage = _buildSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  late final ThotFileStore _domainStore = ThotFileStore(
    secureStorage: _secureStorage,
  );

  late final ThotSecurityService _securityService = ThotSecurityService(
    secureStorage: _secureStorage,
    localAuth: _localAuth,
    onChanged: notifyListeners,
  );

  static const int pinLength = ThotSecurityService.pinLength;
  static const int maxPinAttempts = ThotSecurityService.maxPinAttempts;
  static const Duration pinLockDuration = ThotSecurityService.pinLockDuration;

  bool get pinEnabled => _securityService.pinEnabled;
  bool get biometricEnabled => _securityService.biometricEnabled;
  bool get isAuthenticated => _securityService.isAuthenticated;
  Future<bool> get isPinLocked async => _securityService.isCurrentlyLocked();
  // ----- Limits -----
  static const int maxPlatformsFree = 1;
  static const int maxAmmosFree = 1;
  static const int maxAccessoriesFree = 1;
  static const int maxDocumentsPerItemFree = 1;
  static const int maxUserDocumentsFree = 1;
  // Sessions: unlimited even on free plan.

  // Theme State
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    _scheduleSave();
    notifyListeners();
  }

  Future<bool> ensureDocumentReminderEnabled({
    required int notifyBeforeDays,
  }) async {
    if (notifyBeforeDays <= 0) return true;
    if (_documentExpiryPushEnabled) return true;

    await setDocumentExpiryPushEnabled(true);
    return _documentExpiryPushEnabled;
  }

  ShootingAdjustmentTable? adjustmentTableById(String tableId) {
    try {
      return _shootingAdjustmentTables.firstWhere((t) => t.id == tableId);
    } catch (_) {
      return null;
    }
  }

  List<ShootingAdjustmentTable> shootingTablesSortedByUpdatedAt() {
    final tables = [..._shootingAdjustmentTables];
    tables.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return tables;
  }

  ShootingAdjustmentTable createAdjustmentTable({
    required String name,
    required String platformId,
    String? customPlatformName,
    String? ammoId,
    String? customAmmoName,
    List<String>? accessoryIds,
    List<String>? customAccessoryNames,
    bool accessoriesCustomized = false,
    List<ShootingAdjustmentEntry> entries = const [],
    bool isDope = false,
  }) {
    final now = DateTime.now();
    final table = ShootingAdjustmentTable(
      id: 'adj-${now.microsecondsSinceEpoch}',
      name: name.trim(),
      platformId: platformId,
      customPlatformName: customPlatformName,
      ammoId: ammoId,
      customAmmoName: customAmmoName,
      accessoriesCustomized: accessoriesCustomized,
      accessoryIds: accessoryIds ?? const [],
      customAccessoryNames: customAccessoryNames ?? const [],
      entries: [...entries]..sort((a, b) => a.distance.compareTo(b.distance)),
      createdAt: now,
      updatedAt: now,
      isDope: isDope,
    );
    _shootingAdjustmentTables.insert(0, table);
    _scheduleSave();
    notifyListeners();
    return table;
  }

  void updateAdjustmentTableById({
    required String tableId,
    String? name,
    String? platformId,
    String? customPlatformName,
    String? ammoId,
    String? customAmmoName,
    bool clearAmmoId = false,
    List<String>? accessoryIds,
    List<String>? customAccessoryNames,
    bool? accessoriesCustomized,
    List<ShootingAdjustmentEntry>? entries,
    bool? isDope,
  }) {
    final index = _shootingAdjustmentTables.indexWhere((t) => t.id == tableId);
    if (index == -1) return;
    final current = _shootingAdjustmentTables[index];
    _shootingAdjustmentTables[index] = current.copyWith(
      name: name ?? current.name,
      platformId: platformId ?? current.platformId,
      customPlatformName: customPlatformName,
      ammoId: ammoId,
      customAmmoName: customAmmoName,
      clearAmmoId: clearAmmoId,
      accessoryIds: accessoryIds ?? current.accessoryIds,
      customAccessoryNames: customAccessoryNames,
      accessoriesCustomized:
          accessoriesCustomized ?? current.accessoriesCustomized,
      entries: entries != null
          ? ([...entries]..sort((a, b) => a.distance.compareTo(b.distance)))
          : current.entries,
      updatedAt: DateTime.now(),
      isDope: isDope ?? current.isDope,
    );
    _scheduleSave();
    notifyListeners();
  }

  void deleteAdjustmentTableById(String tableId) {
    final before = _shootingAdjustmentTables.length;
    _shootingAdjustmentTables.removeWhere((t) => t.id == tableId);
    if (_shootingAdjustmentTables.length == before) return;
    _scheduleSave();
    notifyListeners();
  }

  void importShootingAdjustmentTable(ShootingAdjustmentTable table) {
    final existingIndex = _shootingAdjustmentTables.indexWhere(
      (t) => t.id == table.id,
    );
    if (existingIndex == -1) {
      _shootingAdjustmentTables.insert(0, table);
    } else {
      _shootingAdjustmentTables[existingIndex] = table;
    }
    _scheduleSave();
    notifyListeners();
  }

  List<String> adjustmentAccessoryIdsForTable(String tableId) {
    final table = adjustmentTableById(tableId);
    if (table == null) return const [];
    final validAccessoryIds = accessories.map((a) => a.id).toSet();
    return table.accessoryIds
        .where((id) => validAccessoryIds.contains(id))
        .toList(growable: false);
  }

  List<ShootingAdjustmentEntry> adjustmentEntriesForTable(String tableId) {
    final table = adjustmentTableById(tableId);
    if (table == null) return const [];
    final entries = [...table.entries]
      ..sort((a, b) => a.distance.compareTo(b.distance));
    return entries;
  }

  void addAdjustmentEntryToTable({
    required String tableId,
    required ShootingAdjustmentEntry entry,
  }) {
    final table = adjustmentTableById(tableId);
    if (table == null) return;
    updateAdjustmentTableById(
      tableId: tableId,
      entries: [...table.entries, entry],
    );
  }

  void updateAdjustmentEntryInTable({
    required String tableId,
    required ShootingAdjustmentEntry entry,
  }) {
    final table = adjustmentTableById(tableId);
    if (table == null) return;
    final entryIndex = table.entries.indexWhere((e) => e.id == entry.id);
    if (entryIndex == -1) return;
    final updated = [...table.entries];
    updated[entryIndex] = entry;
    updateAdjustmentTableById(tableId: tableId, entries: updated);
  }

  void deleteAdjustmentEntryFromTable({
    required String tableId,
    required String entryId,
  }) {
    final table = adjustmentTableById(tableId);
    if (table == null) return;
    final updated = table.entries
        .where((e) => e.id != entryId)
        .toList(growable: false);
    updateAdjustmentTableById(tableId: tableId, entries: updated);
  }

  List<String> adjustmentAccessoryIdsForPlatform(String platformId) {
    final existing = adjustmentTableForPlatform(platformId);
    final selectedIds = (existing != null && existing.accessoriesCustomized)
        ? existing.accessoryIds
        : linkedAccessoriesForPlatform(
            platformId,
          ).map((a) => a.id).toList(growable: false);
    final validAccessoryIds = accessories.map((a) => a.id).toSet();
    return selectedIds
        .where((id) => validAccessoryIds.contains(id))
        .toList(growable: false);
  }

  ShootingAdjustmentTable? adjustmentTableForPlatform(String platformId) {
    try {
      return _shootingAdjustmentTables.firstWhere(
        (t) => t.platformId == platformId,
      );
    } catch (_) {
      return null;
    }
  }

  ShootingAdjustmentTable ensureAdjustmentTable({
    required String platformId,
    String? ammoId,
    List<String>? accessoryIds,
  }) {
    final existing = adjustmentTableForPlatform(platformId);
    if (existing != null) {
      return existing;
    }

    final initialAccessoryIds =
        accessoryIds ??
        linkedAccessoriesForPlatform(
          platformId,
        ).map((a) => a.id).toList(growable: false);

    final now = DateTime.now();
    final table = ShootingAdjustmentTable(
      id: 'adj-${now.microsecondsSinceEpoch}',
      platformId: platformId,
      ammoId: ammoId,
      accessoriesCustomized: accessoryIds != null,
      accessoryIds: initialAccessoryIds,
      createdAt: now,
      updatedAt: now,
    );
    _shootingAdjustmentTables.add(table);
    _scheduleSave();
    notifyListeners();
    return table;
  }

  void updateAdjustmentTableContext({
    required String platformId,
    String? ammoId,
    bool clearAmmoId = false,
    List<String>? accessoryIds,
  }) {
    final index = _shootingAdjustmentTables.indexWhere(
      (t) => t.platformId == platformId,
    );
    if (index == -1) {
      ensureAdjustmentTable(
        platformId: platformId,
        ammoId: clearAmmoId ? null : ammoId,
        accessoryIds: accessoryIds,
      );
      return;
    }

    final current = _shootingAdjustmentTables[index];
    _shootingAdjustmentTables[index] = current.copyWith(
      ammoId: ammoId,
      clearAmmoId: clearAmmoId,
      accessoriesCustomized: accessoryIds != null
          ? true
          : current.accessoriesCustomized,
      accessoryIds: accessoryIds ?? current.accessoryIds,
      updatedAt: DateTime.now(),
    );
    _scheduleSave();
    notifyListeners();
  }

  void addAdjustmentEntry({
    required String platformId,
    required ShootingAdjustmentEntry entry,
  }) {
    final table = ensureAdjustmentTable(platformId: platformId);
    final index = _shootingAdjustmentTables.indexWhere((t) => t.id == table.id);
    if (index == -1) return;

    final updatedEntries = [...table.entries, entry]
      ..sort((a, b) => a.distance.compareTo(b.distance));

    _shootingAdjustmentTables[index] = table.copyWith(
      entries: updatedEntries,
      updatedAt: DateTime.now(),
    );
    _scheduleSave();
    notifyListeners();
  }

  void updateAdjustmentEntry({
    required String platformId,
    required ShootingAdjustmentEntry entry,
  }) {
    final index = _shootingAdjustmentTables.indexWhere(
      (t) => t.platformId == platformId,
    );
    if (index == -1) return;

    final table = _shootingAdjustmentTables[index];
    final entryIndex = table.entries.indexWhere((e) => e.id == entry.id);
    if (entryIndex == -1) return;

    final updatedEntries = [...table.entries];
    updatedEntries[entryIndex] = entry;
    updatedEntries.sort((a, b) => a.distance.compareTo(b.distance));

    _shootingAdjustmentTables[index] = table.copyWith(
      entries: updatedEntries,
      updatedAt: DateTime.now(),
    );
    _scheduleSave();
    notifyListeners();
  }

  void deleteAdjustmentEntry({
    required String platformId,
    required String entryId,
  }) {
    final index = _shootingAdjustmentTables.indexWhere(
      (t) => t.platformId == platformId,
    );
    if (index == -1) return;

    final table = _shootingAdjustmentTables[index];
    final updatedEntries = table.entries
        .where((e) => e.id != entryId)
        .toList(growable: false);

    _shootingAdjustmentTables[index] = table.copyWith(
      entries: updatedEntries,
      updatedAt: DateTime.now(),
    );
    _scheduleSave();
    notifyListeners();
  }

  Future<void> setDocumentExpiryPushEnabled(bool enabled) async {
    if (_documentExpiryPushEnabled == enabled) return;

    if (enabled) {
      final granted = await MaintenanceNotifications.requestPermission();
      if (!granted) {
        notifyListeners();
        return;
      }
    }

    _documentExpiryPushEnabled = enabled;
    _scheduleSave();

    if (enabled) {
      await _syncDocumentExpiryReminders();
    } else {
      await MaintenanceNotifications.cancelDocumentReminders();
    }

    notifyListeners();
  }

  void deleteExerciseFromSession({
    required String sessionId,
    required String exerciseId,
  }) {
    final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) return;

    final session = _sessions[sessionIndex];
    final updatedExercises = session.exercises
        .where((e) => e.id != exerciseId)
        .toList();
    if (updatedExercises.length == session.exercises.length) return;

    updateSession(session.copyWith(exercises: updatedExercises));
  }

  void saveExerciseTemplate(ExerciseTemplate template) {
    final baseName = template.name.trim();
    String finalName = baseName;
    int suffix = 2;
    while (_exerciseTemplates.any(
      (t) => t.name == finalName && t.id != template.id,
    )) {
      finalName = '$baseName ($suffix)';
      suffix++;
    }
    final existing = _exerciseTemplates.indexWhere((t) => t.id == template.id);
    final saved = ExerciseTemplate(
      id: template.id,
      name: finalName,
      createdAt: template.createdAt,
      shotsFired: template.shotsFired,
      distance: template.distance,
      detailedMode: template.detailedMode,
      steps: template.steps,
      observations: template.observations,
    );
    if (existing >= 0) {
      _exerciseTemplates[existing] = saved;
    } else {
      _exerciseTemplates.add(saved);
    }
    _scheduleSave();
    notifyListeners();
  }

  void deleteExerciseTemplate(String id) {
    _exerciseTemplates.removeWhere((t) => t.id == id);
    _scheduleSave();
    notifyListeners();
  }

  void recordPlatformPartChange({
    required String platformId,
    required String partName,
    required DateTime date,
    String? comment,
    int? roundsAtChange,
  }) {
    final index = _platforms.indexWhere((w) => w.id == platformId);
    if (index == -1) return;
    final current = _platforms[index];
    final idSeed = DateTime.now().microsecondsSinceEpoch;
    final entry = PlatformHistoryEntry(
      id: 'piece-$idSeed',
      date: date,
      type: PlatformHistoryType.partReplacement,
      data: {
        PlatformHistoryDataKey.partName: partName,
      },
      // Comment is stored on PlatformReplacementPart itself; we leave the
      // history entry's legacy details empty.
    );
    final part = PlatformReplacementPart(
      id: 'part-$idSeed',
      name: partName.trim(),
      changedAt: date,
      roundsAtChange: roundsAtChange ?? 0,
      platformRoundsAtChange: current.totalRounds,
      comment: (comment ?? '').trim(),
    );
    _platforms[index] = current.copyWith(
      history: [...current.history, entry],
      replacementParts: [...current.replacementParts, part],
    );
    _scheduleSave();
    notifyListeners();
  }

  void updatePlatformReplacementPart({
    required String platformId,
    required PlatformReplacementPart part,
  }) {
    final index = _platforms.indexWhere((w) => w.id == platformId);
    if (index == -1) return;
    final current = _platforms[index];
    if (!current.replacementParts.any((p) => p.id == part.id)) return;

    // Extract idSeed from partId ('part-$idSeed') to find linked history entry
    final idSeed = part.id.startsWith('part-') ? part.id.substring(5) : '';
    final historyId = 'piece-$idSeed';

    // Update the part and sync the history entry with the new name
    _platforms[index] = current.copyWith(
      replacementParts: current.replacementParts
          .map((p) => p.id == part.id ? part : p)
          .toList(growable: false),
      history: current.history.map((h) {
        if (h.id == historyId) {
          return h.copyWith(
            data: {
              ...h.data,
              PlatformHistoryDataKey.partName: part.name,
            },
          );
        }
        return h;
      }).toList(growable: false),
    );
    _scheduleSave();
    notifyListeners();
  }

  void deletePlatformReplacementPart({
    required String platformId,
    required String partId,
  }) {
    final index = _platforms.indexWhere((w) => w.id == platformId);
    if (index == -1) return;
    final current = _platforms[index];
    if (!current.replacementParts.any((p) => p.id == partId)) return;

    // Extract idSeed from partId ('part-$idSeed') to find linked history entry
    final idSeed = partId.startsWith('part-') ? partId.substring(5) : '';
    final historyId = 'piece-$idSeed';

    _platforms[index] = current.copyWith(
      replacementParts: current.replacementParts
          .where((p) => p.id != partId)
          .toList(growable: false),
      // Also remove the corresponding history entry
      history: current.history
          .where((h) => h.id != historyId)
          .toList(growable: false),
    );
    _scheduleSave();
    notifyListeners();
  }

  // Onboarding State
  bool _hasSeenOnboarding = false;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  bool _onboardingDismissedForSession = false;
  bool get onboardingDismissedForSession => _onboardingDismissedForSession;

  int _onboardingPageIndex = 0;
  int get onboardingPageIndex => _onboardingPageIndex;

  void dismissOnboardingForSession() {
    _onboardingDismissedForSession = true;
    notifyListeners();
  }

  Future<void> setOnboardingPageIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _onboardingPageIndex = index;
    await prefs.setInt('thot_onboarding_page_index', index);
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('thot_has_seen_onboarding', true);
    _hasSeenOnboarding = true;
    notifyListeners();
  }

  // Achievements Queue
  Set<String> _unlockedAchievements = {};
  List<AchievementDefinition> _achievementQueue = [];
  Map<String, DateTime> _achievementUnlockDates = {};

  Set<String> get unlockedAchievements => _unlockedAchievements;
  List<AchievementDefinition> get achievementQueue =>
      List.unmodifiable(_achievementQueue);
  DateTime? achievementUnlockDate(String id) => _achievementUnlockDates[id];

  bool _openReflexesToolRequested = false;

  void requestOpenReflexesTool() {
    _openReflexesToolRequested = true;
  }

  bool consumeOpenReflexesToolRequest() {
    final requested = _openReflexesToolRequested;
    _openReflexesToolRequested = false;
    return requested;
  }

  void popAchievement() {
    if (_achievementQueue.isNotEmpty) {
      _achievementQueue.removeAt(0);
      notifyListeners();
    }
  }

  void checkAchievements() {
    _checkAchievements();
    notifyListeners();
  }

  void _checkAchievements() {
    for (final achievement in achievementDefinitions) {
      if (!_unlockedAchievements.contains(achievement.id)) {
        if (achievement.progress(this) >= achievement.target) {
          _unlockedAchievements.add(achievement.id);
          _achievementUnlockDates[achievement.id] = DateTime.now();
          _achievementQueue.add(achievement);
        }
      }
    }
    // No need to notifyListeners immediately here since `_checkAchievements()`
    // is called right before `notifyListeners()` during state mutations or init.
  }

  // User Profile & Preferences
  String _userName = '';
  String _licenseNumber = '';
  String _userEmail = '';
  bool _useMetric = true;
  WeightUnit _weightUnit = WeightUnit.gram;
  DistanceUnit _distanceUnit = DistanceUnit.meter;
  VelocityUnit _velocityUnit = VelocityUnit.metersPerSecond;
  String _dateFormatPreference = 'day_month_year';
  String? _localeCode; // null = suivre la langue du système
  bool _documentExpiryPushEnabled = false;
  List<UserDocument> _userDocuments = [];

  String get userName => _userName;
  String get licenseNumber => _licenseNumber;
  String get userEmail => _userEmail;
  bool get useMetric => _useMetric;
  WeightUnit get weightUnit => _weightUnit;
  DistanceUnit get distanceUnit => _distanceUnit;
  VelocityUnit get velocityUnit => _velocityUnit;
  UnitProfile get unitProfile {
    if (_useMetric &&
        _weightUnit == WeightUnit.gram &&
        _distanceUnit == DistanceUnit.meter &&
        _velocityUnit == VelocityUnit.metersPerSecond) {
      return UnitProfile.metric;
    }
    if (!_useMetric &&
        _weightUnit == WeightUnit.grain &&
        _distanceUnit == DistanceUnit.yard &&
        _velocityUnit == VelocityUnit.feetPerSecond) {
      return UnitProfile.imperial;
    }
    return UnitProfile.custom;
  }

  String get dateFormatPreference => _dateFormatPreference;
  String? get localeCode => _localeCode;
  bool get documentExpiryPushEnabled => _documentExpiryPushEnabled;
  Locale? get appLocale =>
      _localeCode == null || _localeCode!.isEmpty ? null : Locale(_localeCode!);
  List<UserDocument> get userDocuments => _userDocuments;

  /// Returns an [AppStrings] instance for the current locale, for use in
  /// provider methods that don't have a [BuildContext].
  AppStrings get _currentStrings {
    final locale = _localeCode == null || _localeCode!.isEmpty
        ? const Locale('fr')
        : Locale(_localeCode!);
    return AppStrings.forLocale(locale);
  }

  void updateUserProfile({String? name, String? license, String? email}) {
    if (name != null) _userName = name;
    if (license != null) _licenseNumber = license;
    if (email != null) _userEmail = email;
    _scheduleSave();
    notifyListeners();
  }

  void setUnitSystem(bool metric) {
    setUnitProfile(metric ? UnitProfile.metric : UnitProfile.imperial);
  }

  void setUnitProfile(UnitProfile profile) {
    if (profile == UnitProfile.custom) return;
    final metric = profile == UnitProfile.metric;
    _useMetric = metric;
    _distanceUnit = metric ? DistanceUnit.meter : DistanceUnit.yard;
    _velocityUnit = metric
        ? VelocityUnit.metersPerSecond
        : VelocityUnit.feetPerSecond;
    _weightUnit = metric ? WeightUnit.gram : WeightUnit.grain;
    _scheduleSave();
    notifyListeners();
  }

  void setWeatherUnitSystem(bool metric) {
    if (_useMetric == metric) return;
    _useMetric = metric;
    _scheduleSave();
    notifyListeners();
  }

  void setWeightUnit(WeightUnit unit) {
    if (_weightUnit == unit) return;
    _weightUnit = unit;
    _scheduleSave();
    notifyListeners();
  }

  void setDistanceUnit(DistanceUnit unit) {
    if (_distanceUnit == unit) return;
    _distanceUnit = unit;
    _scheduleSave();
    notifyListeners();
  }

  void setVelocityUnit(VelocityUnit unit) {
    if (_velocityUnit == unit) return;
    _velocityUnit = unit;
    _scheduleSave();
    notifyListeners();
  }

  void setDateFormatPreference(String value) {
    if (_dateFormatPreference == value) return;
    _dateFormatPreference = value;
    _scheduleSave();
    notifyListeners();
  }

  void setLocaleCode(String? code) {
    // Normalise: empty string -> null (suit la langue du système)
    final normalized = (code == null || code.trim().isEmpty)
        ? null
        : code.trim();
    if (_localeCode == normalized) return;
    _localeCode = normalized;
    _scheduleSave();
    notifyListeners();
  }

  void addUserDocument(UserDocument document) {
    _userDocuments.add(document);
    _scheduleSave();
    notifyListeners();
  }

  void deleteUserDocument(String id) async {
    // Find document and delete physical file before removing from list
    final doc = _userDocuments.firstWhere(
      (d) => d.id == id,
      orElse: () => UserDocument(
        id: '',
        name: '',
        type: '',
        filePath: '',
        addedDate: DateTime.now(),
      ),
    );

    // Delete physical file if it exists and we're not on web
    if (doc.id.isNotEmpty &&
        doc.filePath.isNotEmpty) {
      try {
        final file = File(doc.filePath);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        // File may not exist or path may be invalid - log but don't fail
        debugPrint('[deleteUserDocument] Failed to delete file: $e');
      }
    }

    _userDocuments.removeWhere((d) => d.id == id);
    _scheduleSave();
    notifyListeners();
  }

  void updateUserDocument(UserDocument updated) {
    final index = _userDocuments.indexWhere((d) => d.id == updated.id);
    if (index == -1) return;
    _userDocuments[index] = updated;
    _scheduleSave();
    notifyListeners();
  }

  Future<void> clearAllLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    _hasSeenOnboarding = false;
    _userName = '';
    _licenseNumber = '';
    _userEmail = '';
    _useMetric = true;
    _weightUnit = WeightUnit.gram;
    _distanceUnit = DistanceUnit.meter;
    _velocityUnit = VelocityUnit.metersPerSecond;
    _dateFormatPreference = 'day_month_year';
    _localeCode = null;
    _documentExpiryPushEnabled = false;
    _userDocuments = [];

    _platforms = [];
    _ammos = [];
    _accessories = [];
    _shootingAdjustmentTables = [];
    _sessions = [];
    _diagnostics = [];

    _unlockedAchievements = {};
    _achievementUnlockDates = {};
    _achievementQueue = [];
    _quickActions = ['new_session', 'new_platform', 'new_ammo', 'toggle_theme'];
    _themeMode = ThemeMode.light;

    await prefs.remove('thot_has_seen_onboarding');
    await prefs.remove('userName');
    await prefs.remove('licenseNumber');
    await prefs.remove('userEmail');
    await prefs.remove('useMetric');
    await prefs.remove('weightUnit');
    await prefs.remove('distanceUnit');
    await prefs.remove('velocityUnit');
    await prefs.remove('dateFormatPreference');
    await prefs.remove('themeMode');
    await prefs.remove('quickActions');
    await prefs.remove('localeCode');
    await prefs.remove('documentExpiryPushEnabled');
    await prefs.remove('thot_unlocked_achievements');
    await prefs.remove('thot_unlocked_achievement_dates');
    await prefs.remove('thot_domain_data');
    await prefs.remove('thot_domain_data_backup');

    await prefs.remove('userDocuments');
    await prefs.remove('platforms');
    await prefs.remove('ammos');
    await prefs.remove('accessories');
    await prefs.remove('sessions');
    await prefs.remove('diagnostics');

    // Tool histories and local caches persisted outside provider domain storage
    await prefs.remove('reflexes_training_history_v1');
    await prefs.remove('reflexes_benchmark_history_v1');
    await prefs.remove('cognitive_drill_score_history');
    await prefs.remove('maintenance_alerts_v1');
    await prefs.remove('maintenance_alerts_deleted_v1');
    await prefs.remove('scheduled_document_notification_ids_v1');
    await prefs.remove('fired_document_notification_ids_v1');
    await prefs.remove('home_tutorial_completed_v1');
    await prefs.remove('home_tutorial_never_show_again_v1');

    await _domainStore.clearDomainData();
    await _domainStore.clearEncryptionKeys();
    await _securityService.clearAllSecurityData();
    await _premiumService.clearLocalCache();

    // Annuler toutes les notifications de maintenance
    await MaintenanceNotifications.cancelAll();

    // Wipe physical files (photos and uploaded PDFs).
    await ImageStorage.wipeAll();
    await ImageStorage.wipeUserDocuments();

    // Clear crash log.
    await CrashLogger.clear();

    notifyListeners();
  }

  // ── JSON data backup/restore ───────────────────────────────────────────────

  /// Build a complete JSON backup of all user data (domain + preferences).
  Map<String, dynamic> exportDomainAsJson() {
    final domain = _buildDomainDataMap();
    return {
      'exportVersion': 1,
      'exportDate': DateTime.now().toUtc().toIso8601String(),
      'preferences': {
        'userName': _userName,
        'licenseNumber': _licenseNumber,
        'userEmail': _userEmail,
        'useMetric': _useMetric,
        'weightUnit': _weightUnit.name,
        'distanceUnit': _distanceUnit.name,
        'velocityUnit': _velocityUnit.name,
        'dateFormatPreference': _dateFormatPreference,
        'localeCode': _localeCode,
        'themeMode': _themeMode == ThemeMode.dark
            ? 'dark'
            : (_themeMode == ThemeMode.system ? 'system' : 'light'),
        'quickActions': _quickActions,
      },
      'domain': domain,
    };
  }

  DomainImportPreview previewDomainImport(Map<String, dynamic> backup) {
    final domain = backup['domain'] as Map<String, dynamic>?;
    if (domain == null) {
      throw ArgumentError('Missing "domain" key in backup');
    }

    int countList(String key) {
      final value = domain[key];
      if (value is List) return value.length;
      return 0;
    }

    return DomainImportPreview(
      platforms: countList('platforms'),
      ammos: countList('ammos'),
      accessories: countList('accessories'),
      sessions: countList('sessions'),
      diagnostics: countList('diagnostics'),
      shootingTables: countList('shootingAdjustmentTables'),
    );
  }

  /// Restore all user data from a JSON backup produced by [exportDomainAsJson].
  Future<void> importDomainFromJson(Map<String, dynamic> backup) async {
    final domain = backup['domain'] as Map<String, dynamic>?;
    if (domain == null) throw ArgumentError('Missing "domain" key in backup');

    // Restore domain (platforms, ammos, accessories, sessions, etc.)
    _loadDomainDataFromMap(domain);

    // Restore preferences if present.
    final prefs = backup['preferences'] as Map<String, dynamic>?;
    if (prefs != null) {
      _userName = (prefs['userName'] as String?) ?? _userName;
      _licenseNumber = (prefs['licenseNumber'] as String?) ?? _licenseNumber;
      _userEmail = (prefs['userEmail'] as String?) ?? _userEmail;
      _useMetric = (prefs['useMetric'] as bool?) ?? _useMetric;
      _weightUnit = WeightUnit.values.firstWhere(
        (unit) => unit.name == prefs['weightUnit'],
        orElse: () => _weightUnit,
      );
      _distanceUnit = DistanceUnit.values.firstWhere(
        (unit) => unit.name == prefs['distanceUnit'],
        orElse: () => _distanceUnit,
      );
      _velocityUnit = VelocityUnit.values.firstWhere(
        (unit) => unit.name == prefs['velocityUnit'],
        orElse: () => _velocityUnit,
      );
      _dateFormatPreference =
          (prefs['dateFormatPreference'] as String?) ?? _dateFormatPreference;
      final rawLocale = prefs['localeCode'] as String?;
      _localeCode = (rawLocale == null || rawLocale.isEmpty) ? null : rawLocale;
      final rawTheme = prefs['themeMode'] as String?;
      _themeMode = rawTheme == 'dark'
          ? ThemeMode.dark
          : rawTheme == 'system'
          ? ThemeMode.system
          : ThemeMode.light;
      final rawQuickActions = prefs['quickActions'] as List<dynamic>?;
      if (rawQuickActions != null) {
        _quickActions = rawQuickActions.cast<String>();
      }
    }

    // Persist everything.
    _domainDataLoadCompleted = true;
    await _scheduleSaveImmediate();
    notifyListeners();
  }

  Future<void> _scheduleSaveImmediate() async {
    _saveDebounce?.cancel();
    await _saveToLocal();
  }

  Future<void> toggleCloudBackup(bool enabled) async {
    // Sauvegarde native laissée au système.
    // Cette méthode reste uniquement pour compatibilité,
    // mais ne pilote plus rien côté runtime.
    notifyListeners();
  }

  // Quick Actions (IDs of selected actions)
  static const List<String> _allowedQuickActionIds = [
    'new_session',
    'new_platform',
    'new_ammo',
    'new_accessory',
    'toggle_theme',
    'diagnostic',
    'millieme',
    'timer',
    'shooting_tables',
    'visual_stimuli',
    'reaction_exercises',
    'calculation_tools',
  ];

  static const List<String> _defaultQuickActions = [
    'new_session',
    'new_platform',
    'new_ammo',
    'toggle_theme',
  ];

  List<String> _quickActions = [
    'new_session',
    'new_platform',
    'new_ammo',
    'toggle_theme',
  ];
  List<String> get quickActions => _quickActions;

  List<String> _sanitizeQuickActions(Iterable<String>? ids) {
    final source = ids ?? _defaultQuickActions;
    final result = <String>[];
    for (final id in source) {
      if (_allowedQuickActionIds.contains(id) && !result.contains(id)) {
        result.add(id);
      }
      if (result.length == 4) break;
    }
    return result.isEmpty ? List<String>.from(_defaultQuickActions) : result;
  }

  void toggleQuickAction(String actionId) {
    if (!_allowedQuickActionIds.contains(actionId)) {
      return;
    }
    _quickActions = _sanitizeQuickActions(_quickActions);
    if (_quickActions.contains(actionId)) {
      _quickActions.remove(actionId);
    } else {
      if (_quickActions.length < 4) {
        _quickActions.add(actionId);
      }
    }
    _scheduleSave();
    notifyListeners();
  }

  // Inventory
  List<Platform> _platforms = [];
  List<Ammo> _ammos = [];
  List<Accessory> _accessories = [];

  List<Platform> get platforms => _platforms.where((w) => !w.isHidden).toList();
  List<Ammo> get ammos => _ammos.where((a) => !a.isHidden).toList();
  List<Accessory> get accessories =>
      _accessories.where((a) => !a.isHidden).toList();

  String? get primaryPlatformId =>
      platforms.isEmpty ? null : platforms.first.id;
  String? get primaryAmmoId => ammos.isEmpty ? null : ammos.first.id;
  String? get primaryAccessoryId =>
      accessories.isEmpty ? null : accessories.first.id;

  bool canUsePlatformId(String id) => true;
  bool canUseAmmoId(String id) => true;
  bool canUseAccessoryId(String id) => true;

  // ----- isXLockedForFree (used to grey-out items past the quota) -----
  bool isPlatformLockedForFree(Platform platform, int index) {
    if (_kFreeLimitsDisabled || isPremium) return false;
    return index >= maxPlatformsFree;
  }

  bool isAmmoLockedForFree(Ammo ammo, int index) {
    if (_kFreeLimitsDisabled || isPremium) return false;
    return index >= maxAmmosFree;
  }

  bool isAccessoryLockedForFree(Accessory accessory, int index) {
    if (_kFreeLimitsDisabled || isPremium) return false;
    return index >= maxAccessoriesFree;
  }

  bool isSessionLockedForFree(Session session, int index) {
    // Sessions never locked — unlimited on free plan.
    return false;
  }

  bool isItemDocumentLockedForFree({required int documentIndex}) {
    if (_kFreeLimitsDisabled || isPremium) return false;
    return documentIndex >= maxDocumentsPerItemFree;
  }

  bool isUserDocumentLockedForFree({required int documentIndex}) {
    if (_kFreeLimitsDisabled || isPremium) return false;
    return documentIndex >= maxUserDocumentsFree;
  }

  // Sessions
  List<ExerciseTemplate> _exerciseTemplates = [];
  List<ExerciseTemplate> get exerciseTemplates =>
      List.unmodifiable(_exerciseTemplates);

  // Shooting adjustment tables
  List<ShootingAdjustmentTable> _shootingAdjustmentTables = [];
  List<ShootingAdjustmentTable> get shootingAdjustmentTables =>
      List.unmodifiable(_shootingAdjustmentTables);

  List<Session> _sessions = [];
  List<Session> get sessions => _sessions;

  // Diagnostics
  List<Diagnostic> _diagnostics = [];
  List<Diagnostic> get diagnostics => _diagnostics;

  ThotProvider() {
    // Initialization is explicitly awaited by SplashScreen via `initializeApp()`.
  }

  Future<void> initializeApp() {
    if (_isInitialized) {
      return Future.value();
    }

    final existing = _initializeFuture;
    if (existing != null) {
      return existing;
    }

    _initializeFuture = _initializeAppInternal();
    return _initializeFuture!;
  }

  Future<void> _initializeAppInternal() async {
    try {
      await _loadFromLocal();
      await DashboardWidgetService.sync(
        sessions: _sessions,
        platforms: platforms,
        ammos: ammos,
        accessories: accessories,
        userDocuments: _userDocuments,
      );

      try {
        await _securityService.loadSettings();
      } catch (_) {}

      try {
        await _premiumService.init();
      } catch (_) {}
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  int get _activePlatformsCount => _platforms.where((w) => !w.isHidden).length;
  int get _activeAmmosCount => _ammos.where((a) => !a.isHidden).length;
  int get _activeAccessoriesCount =>
      _accessories.where((a) => !a.isHidden).length;

  // ----- canAddX guards (used by add buttons) -----
  bool canAddPlatform() {
    if (_kFreeLimitsDisabled || isPremium) return true;
    return _activePlatformsCount < maxPlatformsFree;
  }

  bool canAddAmmo() {
    if (_kFreeLimitsDisabled || isPremium) return true;
    return _activeAmmosCount < maxAmmosFree;
  }

  bool canAddAccessory() {
    if (_kFreeLimitsDisabled || isPremium) return true;
    return _activeAccessoriesCount < maxAccessoriesFree;
  }

  bool canAddSession() {
    // Sessions are always unlimited, even on the free plan.
    return true;
  }

  bool canAddDocumentToItem({required int currentDocumentsCount}) {
    if (_kFreeLimitsDisabled || isPremium) return true;
    return currentDocumentsCount < maxDocumentsPerItemFree;
  }

  bool canAddUserDocument({required int currentUserDocumentsCount}) {
    if (_kFreeLimitsDisabled || isPremium) return true;
    return currentUserDocumentsCount < maxUserDocumentsFree;
  }

  // ----- Feature gating (timer modes, reflexes, color pod) -----

  /// Timer modes free on the free plan: simple + startAndMic (chronomètre).
  /// Pro: parTime, repeat, randomDelay, startAndShots.
  bool isTimerModeLockedForFree(String modeName) {
    if (_kFreeLimitsDisabled || isPremium) return false;
    const free = {'simple', 'startAndMic'};
    return !free.contains(modeName);
  }

  /// Reflexes / training drills free: visual only.
  /// Pro: auditory, math, memory, stroop, mot, dissociation.
  bool isReflexesModeLockedForFree(String modeName) {
    if (_kFreeLimitsDisabled || isPremium) return false;
    const free = {'visual'};
    return !free.contains(modeName);
  }

  /// Color Pod sub-modes free: 'colors', 'direction'.
  /// Pro: 'shapes', 'letters', 'numbers'.
  bool isColorPodSubModeLockedForFree(String subModeKey) {
    if (_kFreeLimitsDisabled || isPremium) return false;
    const free = {'colors', 'direction'};
    return !free.contains(subModeKey);
  }

  /// Tool screens locked behind Pro entirely.
  /// Pro: cognitive drills, shooting tables (DOPE), diagnostics.
  /// Free: ballistic calc (millième + hit factor + power factor), color pod.
  bool isToolLockedForFree(String toolKey) {
    if (_kFreeLimitsDisabled || isPremium) return false;
    const proOnly = {'cognitive_drills', 'shooting_tables', 'diagnostics'};
    return proOnly.contains(toolKey);
  }

  String getLimitMessage(String type) {
    final strings = AppStrings.forLocale(appLocale ?? const Locale('fr'));
    switch (type) {
      case 'platform':
        return strings.premiumLimitMessage(
          '$_activePlatformsCount',
          '$maxPlatformsFree',
          strings.premiumItemPlatforms,
        );
      case 'ammo':
        return strings.premiumLimitMessage(
          '$_activeAmmosCount',
          '$maxAmmosFree',
          strings.premiumItemAmmos,
        );
      case 'accessory':
        return strings.premiumLimitMessage(
          '$_activeAccessoriesCount',
          '$maxAccessoriesFree',
          strings.premiumItemAccessories,
        );
      case 'session':
        // Sessions are unlimited on the free plan.
        return '';
      default:
        return '';
    }
  }

  Future<void> restorePurchases() async {
    await _premiumService.restorePurchases();
  }

  /// Forces a synchronous flush of any pending save. Call this from app
  /// lifecycle handlers (paused/detached) so we don't lose the last 400 ms
  /// of edits if the OS kills the process.
  Future<void> flushPendingSave() async {
    if (_saveDebounce?.isActive ?? false) {
      _saveDebounce!.cancel();
      await _saveToLocal();
    }
  }

  @override
  void dispose() {
    if (_saveDebounce?.isActive ?? false) {
      _saveDebounce!.cancel();
      // Best-effort flush. dispose() can't be async.
      unawaited(_saveToLocal());
    }
    super.dispose();
  }

  // --- Actions ---

  void addSession(Session session) {
    _sessions.insert(0, session);
    _applyMaterialFromSession(session);
    _scheduleSave();
    notifyListeners();
  }

  void updateSession(Session session) {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index == -1) return;

    // Critical: keep counters stable when editing a session.
    // 1) reverse the previous material impact
    // 2) replace the session
    // 3) apply the new material impact
    // 4) recalculate lastUsed for every material touched by old or new version
    final previous = _sessions[index];

    final impactedPlatformIds = <String>{
      ...previous.platformImpact.keys,
      ...session.platformImpact.keys,
    };

    final impactedAmmoIds = <String>{
      ...previous.ammoImpact.keys,
      ...session.ammoImpact.keys,
    };

    final impactedAccessoryIds = <String>{
      ...previous.equipmentImpact.keys,
      ...session.equipmentImpact.keys,
    };

    _reverseMaterialFromSession(previous);

    _sessions[index] = session;

    _applyMaterialFromSession(session);

    _recalculateLastUsedForMaterialIds(
      platformIds: impactedPlatformIds,
      ammoIds: impactedAmmoIds,
      accessoryIds: impactedAccessoryIds,
    );

    _scheduleSave();
    notifyListeners();
  }

  void toggleExercisePrecisionEnabled({
    required String sessionId,
    required String exerciseId,
  }) {
    final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) return;

    final session = _sessions[sessionIndex];
    final exIndex = session.exercises.indexWhere((e) => e.id == exerciseId);
    if (exIndex == -1) return;

    final ex = session.exercises[exIndex];
    if (ex.precision == null) return; // nothing to toggle

    final updatedEx = ex.copyWith(precisionEnabled: !ex.precisionEnabled);
    final updatedExercises = [...session.exercises];
    updatedExercises[exIndex] = updatedEx;

    _sessions[sessionIndex] = session.copyWith(exercises: updatedExercises);

    _scheduleSave();
    notifyListeners();
  }

  void _applyMaterialFromSession(Session session) {
    // Update platform + ammo counters based on attributed impacts.
    for (final exercise in session.exercises) {
      for (final entry in exercise.platformShotImpact.entries) {
        final platformIndex = _platforms.indexWhere((w) => w.id == entry.key);
        if (platformIndex == -1) continue;
        final current = _platforms[platformIndex];
        _platforms[platformIndex] = current.copyWith(
          totalRounds: current.totalRounds + entry.value,
          lastUsed: session.date,
          history: [
            ...current.history,
            PlatformHistoryEntry(
              id: '${session.id}-${exercise.id}-tir-${entry.key}',
              date: session.date,
              type: PlatformHistoryType.shot,
              data: {
                PlatformHistoryDataKey.sessionName: session.name,
                PlatformHistoryDataKey.shotCount: entry.value,
              },
            ),
          ],
        );
      }

      for (final entry in exercise.ammoShotImpact.entries) {
        final ammoIndex = _ammos.indexWhere((a) => a.id == entry.key);
        if (ammoIndex == -1) continue;
        final ammo = _ammos[ammoIndex];
        final updatedQuantity = (ammo.quantity - entry.value).clamp(0, 1 << 30);
        _ammos[ammoIndex] = ammo.copyWith(
          quantity: updatedQuantity,
          lastUsed: session.date,
        );
      }

      for (final entry in exercise.equipmentShotImpact.entries) {
        final accIndex = _accessories.indexWhere((a) => a.id == entry.key);
        if (accIndex == -1) continue;
        final accessory = _accessories[accIndex];
        _accessories[accIndex] = accessory.copyWith(
          lastUsed: session.date,
          totalRounds: accessory.totalRounds + entry.value,
        );
      }
    }
  }

  void _reverseMaterialFromSession(Session session) {
    // Reverse platform + ammo counters based on exercises.
    for (final entry in session.platformImpact.entries) {
      final platformIndex = _platforms.indexWhere((w) => w.id == entry.key);
      if (platformIndex == -1) continue;

      final platform = _platforms[platformIndex];
      final updatedTotalRounds = (platform.totalRounds - entry.value).clamp(
        0,
        1 << 30,
      );

      var updatedRoundsAtLastCleaning = platform.roundsAtLastCleaning;
      var updatedRoundsAtLastRevision = platform.roundsAtLastRevision;

      if (updatedRoundsAtLastCleaning > updatedTotalRounds) {
        updatedRoundsAtLastCleaning = updatedTotalRounds;
      }
      if (updatedRoundsAtLastRevision > updatedTotalRounds) {
        updatedRoundsAtLastRevision = updatedTotalRounds;
      }

      _platforms[platformIndex] = platform.copyWith(
        totalRounds: updatedTotalRounds,
        roundsAtLastCleaning: updatedRoundsAtLastCleaning,
        roundsAtLastRevision: updatedRoundsAtLastRevision,
        history: platform.history
            .where((h) => !h.id.startsWith('${session.id}-'))
            .toList(),
      );
    }

    for (final entry in session.ammoImpact.entries) {
      final ammoIndex = _ammos.indexWhere((a) => a.id == entry.key);
      if (ammoIndex == -1) continue;
      final ammo = _ammos[ammoIndex];
      _ammos[ammoIndex] = ammo.copyWith(quantity: ammo.quantity + entry.value);
    }

    for (final entry in session.equipmentImpact.entries) {
      final accIndex = _accessories.indexWhere((a) => a.id == entry.key);
      if (accIndex == -1) continue;

      final accessory = _accessories[accIndex];
      final updatedTotalRounds = (accessory.totalRounds - entry.value).clamp(
        0,
        1 << 30,
      );

      var updatedRoundsAtLastCleaning = accessory.roundsAtLastCleaning;
      var updatedRoundsAtLastRevision = accessory.roundsAtLastRevision;

      if (updatedRoundsAtLastCleaning > updatedTotalRounds) {
        updatedRoundsAtLastCleaning = updatedTotalRounds;
      }
      if (updatedRoundsAtLastRevision > updatedTotalRounds) {
        updatedRoundsAtLastRevision = updatedTotalRounds;
      }

      _accessories[accIndex] = accessory.copyWith(
        totalRounds: updatedTotalRounds,
        roundsAtLastCleaning: updatedRoundsAtLastCleaning,
        roundsAtLastRevision: updatedRoundsAtLastRevision,
      );
    }
  }

  void _recalculateLastUsedForMaterialIds({
    Set<String> platformIds = const {},
    Set<String> ammoIds = const {},
    Set<String> accessoryIds = const {},
  }) {
    DateTime? latestForPlatform(String id) {
      DateTime? latest;
      for (final session in _sessions) {
        if (!session.platformImpact.containsKey(id)) continue;
        if (latest == null || session.date.isAfter(latest)) {
          latest = session.date;
        }
      }
      return latest;
    }

    DateTime? latestForAmmo(String id) {
      DateTime? latest;
      for (final session in _sessions) {
        if (!session.ammoImpact.containsKey(id)) continue;
        if (latest == null || session.date.isAfter(latest)) {
          latest = session.date;
        }
      }
      return latest;
    }

    DateTime? latestForAccessory(String id) {
      DateTime? latest;
      for (final session in _sessions) {
        if (!session.equipmentImpact.containsKey(id)) continue;
        if (latest == null || session.date.isAfter(latest)) {
          latest = session.date;
        }
      }
      return latest;
    }

    for (final id in platformIds) {
      final index = _platforms.indexWhere((p) => p.id == id);
      if (index != -1) {
        _platforms[index].lastUsed = latestForPlatform(id);
      }
    }

    for (final id in ammoIds) {
      final index = _ammos.indexWhere((a) => a.id == id);
      if (index != -1) {
        _ammos[index].lastUsed = latestForAmmo(id);
      }
    }

    for (final id in accessoryIds) {
      final index = _accessories.indexWhere((a) => a.id == id);
      if (index != -1) {
        _accessories[index].lastUsed = latestForAccessory(id);
      }
    }
  }

  void addPlatform(Platform platform) {
    if (!canAddPlatform()) {
      debugPrint('❌ Free limit reached: cannot add more platforms.');
      return;
    }
    _platforms.add(platform);
    _scheduleSave();
    notifyListeners();
  }

  void updatePlatform(Platform platform) {
    final index = _platforms.indexWhere((w) => w.id == platform.id);
    if (index != -1) {
      _platforms[index] = platform;
      _scheduleSave();
      notifyListeners();
    }
  }

  List<Accessory> linkedAccessoriesForPlatform(String platformId) {
    final platform = getPlatformById(platformId);
    if (platform == null) return const [];
    final ids = platform.linkedAccessoryIds.toSet();
    return accessories.where((a) => ids.contains(a.id)).toList(growable: false);
  }

  List<Platform> linkedPlatformsForAccessory(String accessoryId) {
    final accessory = getAccessoryById(accessoryId);
    if (accessory == null) return const [];
    final ids = accessory.linkedPlatformIds.toSet();
    return platforms.where((w) => ids.contains(w.id)).toList(growable: false);
  }

  void linkPlatformToAccessory({
    required String platformId,
    required String accessoryId,
  }) {
    final wIndex = _platforms.indexWhere((w) => w.id == platformId);
    final aIndex = _accessories.indexWhere((a) => a.id == accessoryId);
    if (wIndex == -1 || aIndex == -1) return;

    final platform = _platforms[wIndex];
    final accessory = _accessories[aIndex];

    final platformLinks = platform.linkedAccessoryIds.toSet()..add(accessoryId);
    final accessoryLinks = accessory.linkedPlatformIds.toSet()..add(platformId);

    _platforms[wIndex] = platform.copyWith(
      linkedAccessoryIds: platformLinks.toList(growable: false),
    );
    _accessories[aIndex] = accessory.copyWith(
      linkedPlatformIds: accessoryLinks.toList(growable: false),
    );
    _scheduleSave();
    notifyListeners();
  }

  void unlinkPlatformFromAccessory({
    required String platformId,
    required String accessoryId,
  }) {
    final wIndex = _platforms.indexWhere((w) => w.id == platformId);
    final aIndex = _accessories.indexWhere((a) => a.id == accessoryId);
    if (wIndex == -1 || aIndex == -1) return;

    final platform = _platforms[wIndex];
    final accessory = _accessories[aIndex];

    final platformLinks = platform.linkedAccessoryIds.toSet()
      ..remove(accessoryId);
    final accessoryLinks = accessory.linkedPlatformIds.toSet()
      ..remove(platformId);

    _platforms[wIndex] = platform.copyWith(
      linkedAccessoryIds: platformLinks.toList(growable: false),
    );
    _accessories[aIndex] = accessory.copyWith(
      linkedPlatformIds: accessoryLinks.toList(growable: false),
    );
    _scheduleSave();
    notifyListeners();
  }

  void deletePlatform(String id) async {
    final index = _platforms.indexWhere((w) => w.id == id);
    if (index == -1) return;
    final platform = _platforms[index];

    // Delete photo if exists
    if (platform.photoPath != null && platform.photoPath!.isNotEmpty) {
      await ImageStorage.deletePersisted(platform.photoPath);
    }

    _platforms[index] = platform.copyWith(
      name: _currentStrings.suffixDeleted(platform.name),
      isHidden: true,
      clearPhotoPath: true,
    );
    _scheduleSave();
    notifyListeners();
  }

  bool duplicatePlatform(Platform platform) {
    if (!canAddPlatform()) {
      debugPrint('❌ Free limit reached: cannot duplicate platform.');
      return false;
    }
    final now = DateTime.now();
    final newPlatform = Platform(
      id: now.microsecondsSinceEpoch.toString(),
      name: _currentStrings.suffixCopy(platform.name),
      model: platform.model,
      comment: platform.comment,
      type: platform.type,
      caliber: platform.caliber,
      serialNumber: platform.serialNumber,
      weight: platform.weight,
      totalRounds: 0,
      lastCleaned: now,
      lastRevised: now,
      lastUsed: now,
      imageUrl: platform.imageUrl,
      category: platform.category,
      documents: platform.documents,
      photoPath: platform.photoPath,
      trackWear: platform.trackWear,
      trackCleanliness: platform.trackCleanliness,
      trackRounds: platform.trackRounds,
      cleaningRoundsThreshold: platform.cleaningRoundsThreshold,
      wearRoundsThreshold: platform.wearRoundsThreshold,
      roundsAtLastCleaning: 0,
      roundsAtLastRevision: 0,
    );
    _platforms.add(newPlatform);
    _scheduleSave();
    notifyListeners();
    return true;
  }

  void recordPlatformCleaning(String platformId) {
    final index = _platforms.indexWhere((w) => w.id == platformId);
    if (index == -1) return;
    final now = DateTime.now();
    final current = _platforms[index];
    // Important: when recording a cleaning, ONLY reset cleaning-related counters.
    // Keep revision data intact.
    _platforms[index] = current.copyWith(
      lastCleaned: now,
      roundsAtLastCleaning: current.totalRounds,
      // Preserve revision state explicitly (defensive against constructor defaults).
      lastRevised: current.lastRevised,
      roundsAtLastRevision: current.roundsAtLastRevision,
      history: [
        ...current.history,
        PlatformHistoryEntry(
          id: 'entretien-${now.microsecondsSinceEpoch}',
          date: now,
          type: PlatformHistoryType.cleaning,
        ),
      ],
    );
    _scheduleSave();
    notifyListeners();
  }

  void recordPlatformRevision(String platformId) {
    final index = _platforms.indexWhere((w) => w.id == platformId);
    if (index == -1) return;
    final now = DateTime.now();
    final current = _platforms[index];
    // Important: when recording a revision, ONLY reset revision-related counters.
    // Keep cleaning data intact.
    _platforms[index] = current.copyWith(
      lastRevised: now,
      roundsAtLastRevision: current.totalRounds,
      // Preserve cleaning state explicitly (defensive against constructor defaults).
      lastCleaned: current.lastCleaned,
      roundsAtLastCleaning: current.roundsAtLastCleaning,
      history: [
        ...current.history,
        PlatformHistoryEntry(
          id: 'revision-${now.microsecondsSinceEpoch}',
          date: now,
          type: PlatformHistoryType.revision,
        ),
      ],
    );
    _scheduleSave();
    notifyListeners();
  }

  void addAmmo(Ammo ammo) {
    if (!canAddAmmo()) {
      debugPrint('❌ Free limit reached: cannot add more ammos.');
      return;
    }
    // Ensure history is never null (guard against hot-reload artifacts)
    final safeAmmo = ammo.copyWith(history: ammo.safeHistory);
    _ammos.add(safeAmmo);
    _scheduleSave();
    notifyListeners();
  }

  void updateAmmo(Ammo ammo) {
    final index = _ammos.indexWhere((a) => a.id == ammo.id);
    if (index != -1) {
      // Ensure history is never null (guard against hot-reload artifacts)
      _ammos[index] = ammo.copyWith(history: ammo.safeHistory);
      _scheduleSave();
      notifyListeners();
    }
  }

  /// Adds [addQty] to the ammo stock and records a restock history entry.
  void restockAmmo({
    required String ammoId,
    required int addQty,
    String? comment,
  }) {
    final index = _ammos.indexWhere((a) => a.id == ammoId);
    if (index == -1) return;
    final ammo = _ammos[index];
    final now = DateTime.now();
    final entry = AmmoHistoryEntry(
      id: now.microsecondsSinceEpoch.toString(),
      date: now,
      type: 'restock',
      label: '+$addQty',
      quantity: addQty,
      comment: comment,
    );
    _ammos[index] = ammo.copyWith(
      quantity: ammo.quantity + addQty,
      initialQuantity: ammo.quantity + addQty,
      history: [...ammo.safeHistory, entry],
    );
    _scheduleSave();
    notifyListeners();
  }

  void deleteAmmoHistoryEntry(String ammoId, String entryId) {
    final ammoIndex = _ammos.indexWhere((a) => a.id == ammoId);
    if (ammoIndex == -1) return;
    final ammo = _ammos[ammoIndex];

    final entryIndex = ammo.safeHistory.indexWhere((e) => e.id == entryId);
    if (entryIndex == -1) return;
    final entry = ammo.safeHistory[entryIndex];

    int newQuantity = ammo.quantity;
    int newInitialQuantity = ammo.initialQuantity;

    if (entry.type == 'restock') {
      // If we delete a restock, we remove the added quantity.
      newQuantity -= entry.quantity;
      newInitialQuantity -= entry.quantity;
    } else if (entry.type == 'consumption') {
      // If we delete a consumption (rare but possible), we re-inject the consumed quantity.
      newQuantity += entry.quantity;
    }

    final newHistory = List<AmmoHistoryEntry>.from(ammo.safeHistory)
      ..removeAt(entryIndex);

    _ammos[ammoIndex] = ammo.copyWith(
      quantity: newQuantity,
      initialQuantity: newInitialQuantity,
      history: newHistory,
    );

    _scheduleSave();
    notifyListeners();
  }

  void deleteAmmo(String id) async {
    final index = _ammos.indexWhere((a) => a.id == id);
    if (index == -1) return;
    final ammo = _ammos[index];

    // Delete photo if exists
    if (ammo.photoPath != null && ammo.photoPath!.isNotEmpty) {
      await ImageStorage.deletePersisted(ammo.photoPath);
    }

    _ammos[index] = ammo.copyWith(
      name: _currentStrings.suffixDeleted(ammo.name),
      isHidden: true,
      clearPhotoPath: true,
    );
    _scheduleSave();
    notifyListeners();
  }

  bool duplicateAmmo(Ammo ammo) {
    if (!canAddAmmo()) {
      debugPrint('❌ Free limit reached: cannot duplicate ammo.');
      return false;
    }
    final now = DateTime.now();
    final newAmmo = Ammo(
      id: now.microsecondsSinceEpoch.toString(),
      name: _currentStrings.suffixCopy(ammo.name),
      brand: ammo.brand,
      caliber: ammo.caliber,
      comment: ammo.comment,
      projectileType: ammo.projectileType,
      quantity: ammo.quantity,
      initialQuantity: ammo.initialQuantity,
      imageUrl: ammo.imageUrl,
      lastUsed: now,
      trackStock: ammo.trackStock,
      lowStockThreshold: ammo.lowStockThreshold,
      documents: ammo.documents,
      photoPath: ammo.photoPath,
      unitPrice: ammo.unitPrice,
      currency: ammo.currency,
    );
    _ammos.add(newAmmo);
    _scheduleSave();
    notifyListeners();
    return true;
  }

  void addAccessory(Accessory accessory) {
    if (!canAddAccessory()) {
      debugPrint('❌ Free limit reached: cannot add more accessories.');
      return;
    }
    _accessories.add(accessory);
    _scheduleSave();
    notifyListeners();
  }

  void updateAccessory(Accessory accessory) {
    final index = _accessories.indexWhere((a) => a.id == accessory.id);
    if (index != -1) {
      _accessories[index] = accessory;
      _scheduleSave();
      notifyListeners();
    }
  }

  void recordAccessoryCleaning(String accessoryId) {
    final index = _accessories.indexWhere((a) => a.id == accessoryId);
    if (index == -1) return;
    final now = DateTime.now();
    final current = _accessories[index];

    _accessories[index] = current.copyWith(
      lastCleaned: now,
      roundsAtLastCleaning: current.totalRounds,
      lastRevised: current.lastRevised,
      roundsAtLastRevision: current.roundsAtLastRevision,
    );
    _scheduleSave();
    notifyListeners();
  }

  void recordAccessoryRevision(String accessoryId) {
    final index = _accessories.indexWhere((a) => a.id == accessoryId);
    if (index == -1) return;
    final now = DateTime.now();
    final current = _accessories[index];

    _accessories[index] = current.copyWith(
      lastRevised: now,
      roundsAtLastRevision: current.totalRounds,
      lastCleaned: current.lastCleaned,
      roundsAtLastCleaning: current.roundsAtLastCleaning,
    );
    _scheduleSave();
    notifyListeners();
  }

  void deleteAccessory(String id) async {
    final index = _accessories.indexWhere((a) => a.id == id);
    if (index == -1) return;
    final accessory = _accessories[index];

    // Delete photo if exists
    if (accessory.photoPath != null && accessory.photoPath!.isNotEmpty) {
      await ImageStorage.deletePersisted(accessory.photoPath);
    }

    _accessories[index] = accessory.copyWith(
      name: _currentStrings.suffixDeletedMasc(accessory.name),
      isHidden: true,
      clearPhotoPath: true,
    );
    _scheduleSave();
    notifyListeners();
  }

  bool duplicateAccessory(Accessory accessory) {
    if (!canAddAccessory()) {
      debugPrint('❌ Free limit reached: cannot duplicate accessory.');
      return false;
    }
    final now = DateTime.now();
    final newAccessory = Accessory(
      id: now.microsecondsSinceEpoch.toString(),
      name: _currentStrings.suffixCopy(accessory.name),
      brand: accessory.brand,
      model: accessory.model,
      type: accessory.type,
      comment: accessory.comment,
      imageUrl: accessory.imageUrl,
      lastUsed: now,
      lastCleaned: now,
      lastRevised: now,
      trackWear: accessory.trackWear,
      trackCleanliness: accessory.trackCleanliness,
      cleaningRoundsThreshold: accessory.cleaningRoundsThreshold,
      wearRoundsThreshold: accessory.wearRoundsThreshold,
      roundsAtLastCleaning: 0,
      roundsAtLastRevision: 0,
      batteryChangedAt: accessory.batteryChangedAt,
      trackBattery: accessory.trackBattery,
      documents: accessory.documents,
      photoPath: accessory.photoPath,
    );
    _accessories.add(newAccessory);
    _scheduleSave();
    notifyListeners();
    return true;
  }

  void deleteSession(String id) {
    final index = _sessions.indexWhere((s) => s.id == id);
    if (index == -1) return;

    final session = _sessions[index];

    final impactedPlatformIds = session.platformImpact.keys.toSet();
    final impactedAmmoIds = session.ammoImpact.keys.toSet();
    final impactedAccessoryIds = session.equipmentImpact.keys.toSet();

    // Reverse material impacts before removing the session.
    _reverseMaterialFromSession(session);

    _sessions.removeAt(index);

    _recalculateLastUsedForMaterialIds(
      platformIds: impactedPlatformIds,
      ammoIds: impactedAmmoIds,
      accessoryIds: impactedAccessoryIds,
    );

    _scheduleSave();
    notifyListeners();
  }

  bool duplicateSession(Session session) {
    if (!canAddSession()) {
      debugPrint('❌ Free limit reached: cannot duplicate session.');
      return false;
    }
    final now = DateTime.now();
    // Defensive copy: do not share Exercise instances/ids between sessions.
    final copiedExercises = session.exercises
        .map((e) => e.copyWith(id: '${now.microsecondsSinceEpoch}-${e.id}'))
        .toList(growable: false);
    final newSession = session.copyWith(
      id: now.microsecondsSinceEpoch.toString(),
      name: _currentStrings.suffixCopy(session.name),
      date: now,
      exercises: copiedExercises,
      platformIds: List<String>.from(session.platformIds),
    );
    _sessions.insert(0, newSession);

    // Apply impacts like any newly created session. This makes delete symmetric,
    // and keeps revision/cleaning + stock counters consistent.
    _applyMaterialFromSession(newSession);

    _scheduleSave();
    notifyListeners();
    return true;
  }

  void addDiagnostic(Diagnostic diagnostic) {
    _diagnostics.insert(0, diagnostic);
    _scheduleSave();
    notifyListeners();
  }

  void deleteDiagnostic(String id) {
    _diagnostics.removeWhere((d) => d.id == id);
    _scheduleSave();
    notifyListeners();
  }

  // Helpers
  Platform? getPlatformById(String id) {
    try {
      return _platforms.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }

  List<ShootingAdjustmentEntry> adjustmentEntriesForPlatform(
    String platformId,
  ) {
    final table = adjustmentTableForPlatform(platformId);
    if (table == null) return const [];
    final entries = [...table.entries]
      ..sort((a, b) => a.distance.compareTo(b.distance));
    return entries;
  }

  Ammo? getAmmoById(String id) {
    try {
      return _ammos.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  Accessory? getAccessoryById(String id) {
    try {
      return _accessories.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  // Stats Logic
  int get totalSessions => _sessions.length;

  int get totalRoundsFired {
    return _sessions.fold(0, (sum, s) => sum + s.totalRounds);
  }

  /// Précision moyenne par jour sur les 7 derniers jours (données réelles).
  /// Index 0 = il y a 6 jours, index 6 = aujourd'hui.
  /// Retourne 0.0 pour les jours sans session avec précision mesurée.
  List<double> get weeklyPrecision {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final dayStart = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - i));
      final dayEnd = dayStart.add(const Duration(days: 1));
      final daySessions = _sessions
          .where(
            (s) =>
                s.date.isAfter(
                  dayStart.subtract(const Duration(milliseconds: 1)),
                ) &&
                s.date.isBefore(dayEnd) &&
                s.hasCountedPrecision,
          )
          .toList();
      if (daySessions.isEmpty) return 0.0;
      final total = daySessions.fold(0.0, (sum, s) => sum + s.averagePrecision);
      return total / daySessions.length;
    });
  }
  // NOTE: domain encrypted file storage is delegated to `_domainStore`.

  Map<String, dynamic> _buildDomainDataMap() {
    return {
      'schemaVersion': kCurrentSchemaVersion,
      'exerciseTemplates': _exerciseTemplates.map((t) => t.toJson()).toList(),
      'userDocuments': _userDocuments
          .map(
            (d) => {
              'id': d.id,
              'name': d.name,
              'type': d.type,
              'filePath': d.filePath,
              'addedDate': d.addedDate.toIso8601String(),
              if (d.expiryDate != null)
                'expiryDate': d.expiryDate!.toIso8601String(),
              'notifyBeforeDays': d.notifyBeforeDays,
            },
          )
          .toList(),
      'platforms': _platforms
          .map(
            (w) => {
              'id': w.id,
              'name': w.name,
              'model': w.model,
              'comment': w.comment,
              'type': w.type,
              'caliber': w.caliber,
              'serialNumber': w.serialNumber,
              'weight': w.weight,
              'totalRounds': w.totalRounds,
              'lastCleaned': w.lastCleaned.toIso8601String(),
              'lastRevised': w.lastRevised.toIso8601String(),
              'lastUsed': w.lastUsed?.toIso8601String(),
              'trackWear': w.trackWear,
              'trackCleanliness': w.trackCleanliness,
              'trackRounds': w.trackRounds,
              'cleaningRoundsThreshold': w.cleaningRoundsThreshold,
              'wearRoundsThreshold': w.wearRoundsThreshold,
              'roundsAtLastCleaning': w.roundsAtLastCleaning,
              'roundsAtLastRevision': w.roundsAtLastRevision,
              'documents': w.documents.map((d) => d.toJson()).toList(),
              'history': w.history.map((h) => h.toJson()).toList(),
              'replacementParts': w.replacementParts
                  .map((p) => p.toJson())
                  .toList(),
              'photoPath': w.photoPath,
              'isHidden': w.isHidden,
              'linkedAccessoryIds': w.linkedAccessoryIds,
            },
          )
          .toList(),
      'ammos': _ammos
          .map(
            (a) => {
              'id': a.id,
              'name': a.name,
              'brand': a.brand,
              'caliber': a.caliber,
              'comment': a.comment,
              'projectileType': a.projectileType,
              'quantity': a.quantity,
              'initialQuantity': a.initialQuantity,
              'lastUsed': a.lastUsed?.toIso8601String(),
              'trackStock': a.trackStock,
              'lowStockThreshold': a.lowStockThreshold,
              'documents': a.documents.map((d) => d.toJson()).toList(),
              'photoPath': a.photoPath,
              'isHidden': a.isHidden,
              if (a.unitPrice != null) 'unitPrice': a.unitPrice,
              'currency': a.currency,
              'history': a.safeHistory.map((h) => h.toJson()).toList(),
            },
          )
          .toList(),
      'accessories': _accessories
          .map(
            (ac) => {
              'id': ac.id,
              'name': ac.name,
              'brand': ac.brand,
              'model': ac.model,
              'comment': ac.comment,
              'type': ac.type,
              'imageUrl': ac.imageUrl,
              'lastUsed': ac.lastUsed?.toIso8601String(),
              'totalRounds': ac.totalRounds,
              'lastCleaned': ac.lastCleaned.toIso8601String(),
              'lastRevised': ac.lastRevised.toIso8601String(),
              'trackWear': ac.trackWear,
              'trackCleanliness': ac.trackCleanliness,
              'cleaningRoundsThreshold': ac.cleaningRoundsThreshold,
              'wearRoundsThreshold': ac.wearRoundsThreshold,
              'roundsAtLastCleaning': ac.roundsAtLastCleaning,
              'roundsAtLastRevision': ac.roundsAtLastRevision,
              'batteryChangedAt': ac.batteryChangedAt?.toIso8601String(),
              'trackBattery': ac.trackBattery,
              'documents': ac.documents.map((d) => d.toJson()).toList(),
              'photoPath': ac.photoPath,
              'isHidden': ac.isHidden,
              'linkedPlatformIds': ac.linkedPlatformIds,
            },
          )
          .toList(),
      'shootingAdjustmentTables': _shootingAdjustmentTables
          .map((t) => t.toJson())
          .toList(),
      'sessions': _sessions
          .map(
            (s) => {
              'id': s.id,
              'name': s.name,
              'date': s.date.toIso8601String(),
              'location': s.location,
              'shootingDistance': s.shootingDistance,
              'locationLatitude': s.locationLatitude,
              'locationLongitude': s.locationLongitude,
              'sessionType': s.sessionType,
              'weatherEnabled': s.weatherEnabled,
              'temperature': s.temperature,
              'wind': s.wind,
              'humidity': s.humidity,
              'pressure': s.pressure,
              'temperatureEnabled': s.temperatureEnabled,
              'windEnabled': s.windEnabled,
              'humidityEnabled': s.humidityEnabled,
              'pressureEnabled': s.pressureEnabled,
              'platformIds': s.platformIds,
              'exercises': s.exercises
                  .map(
                    (e) => {
                      'id': e.id,
                      'name': e.name,
                      'platformId': e.platformId,
                      'platformLabel': e.platformLabel,
                      'ammoId': e.ammoId,
                      'ammoLabel': e.ammoLabel,
                      'equipmentIds': e.equipmentIds,
                      'equipmentId': e.equipmentIds.isEmpty
                          ? null
                          : e.equipmentIds.first,
                      'targetName': e.targetName,
                      'targetPhotos': e.targetPhotos
                          .map((p) => p.toJson())
                          .toList(),
                      'shotsFired': e.shotsFired,
                      'distance': e.distance,
                      'precision': e.precision,
                      'precisionEnabled': e.precisionEnabled,
                      'observations': e.observations,
                      'platformAssignments': e.platformAssignments
                          .map(
                            (a) => {
                              'platformId': a.platformId,
                              'platformLabel': a.platformLabel,
                              'ammoIds': a.ammoIds,
                              'accessoryIds': a.accessoryIds,
                            },
                          )
                          .toList(),
                      'shotAllocations': e.shotAllocations
                          .map(
                            (a) => {
                              'platformId': a.platformId,
                              'ammoId': a.ammoId,
                              'shots': a.shots,
                            },
                          )
                          .toList(),
                      if (e.steps != null)
                        'steps': e.steps!.map((st) => st.toJson()).toList(),
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
      'diagnostics': _diagnostics
          .map(
            (d) => {
              'id': d.id,
              'date': d.date.toIso8601String(),
              'platformId': d.platformId,
              'platformNameSnapshot': d.platformNameSnapshot,
              'platformTypeSnapshot': d.platformTypeSnapshot,
              'responses': d.responses,
              'incidentKey': d.incidentKey,
              'suspectedIssueKey': d.suspectedIssueKey,
              'riskLevelKey': d.riskLevelKey,
              'probabilities': d.probabilities,
              'finalDecision': d.finalDecision,
              'summary': d.summary,
            },
          )
          .toList(),
    };
  }

  void _loadDomainDataFromMap(Map<String, dynamic> data) {
    try {
      final readVersion = (data['schemaVersion'] as int?) ?? 0;
      if (readVersion > kCurrentSchemaVersion) {
        // Data was written by a newer version of the app — best effort: load
        // anyway but log a warning.
        debugPrint(
          '[ThotProvider] WARNING: data file schema version $readVersion is '
          'newer than current $kCurrentSchemaVersion. Some fields may be lost.',
        );
      }
      // Future migration code goes here:
      // final data2 = readVersion < 2 ? _migrateV1ToV2(data) : data;

      final templatesList = (data['exerciseTemplates'] as List?) ?? const [];
      _exerciseTemplates = templatesList
          .whereType<Map>()
          .map((t) {
            try {
              return ExerciseTemplate.fromJson(t.cast<String, dynamic>());
            } catch (e) {
              debugPrint('Failed to load exercise template: $e');
              return null;
            }
          })
          .whereType<ExerciseTemplate>()
          .toList();

      final userDocsList = (data['userDocuments'] as List?) ?? const [];
      _userDocuments = userDocsList
          .whereType<Map>()
          .map((d) {
            try {
              return UserDocument.fromJson(d.cast<String, dynamic>());
            } catch (e) {
              debugPrint('Failed to load user document: $e');
              return null;
            }
          })
          .whereType<UserDocument>()
          .toList();

      final platformsList = (data['platforms'] as List?) ?? const [];
      _platforms = platformsList
          .whereType<Map>()
          .map((w) {
            try {
              return Platform(
                id: w['id'] as String,
                name: w['name'] as String,
                model: w['model'] as String,
                comment: (w['comment'] ?? '') as String,
                type: MaterialTypeMigration.resolve(
                  (w['type'] ?? 'other') as String,
                  MaterialTypeMigration.platform,
                  PlatformTypeKey.all,
                ),
                caliber: w['caliber'] as String,
                serialNumber: w['serialNumber'] as String,
                weight: (w['weight'] as num?)?.toDouble() ?? 0.0,
                totalRounds: (w['totalRounds'] ?? 0) as int,
                lastCleaned:
                    DateTime.tryParse(w['lastCleaned'] as String? ?? '') ??
                    DateTime.now(),
                lastRevised: w['lastRevised'] != null
                    ? DateTime.tryParse(w['lastRevised'] as String) ??
                          DateTime.now()
                    : DateTime.tryParse(w['lastCleaned'] as String? ?? '') ??
                          DateTime.now(),
                lastUsed: DateTime.tryParse(w['lastUsed'] as String? ?? ''),
                trackWear: w['trackWear'] as bool? ?? true,
                trackCleanliness: w['trackCleanliness'] as bool? ?? true,
                trackRounds: w['trackRounds'] as bool? ?? true,
                cleaningRoundsThreshold:
                    (w['cleaningRoundsThreshold'] as num?)?.toInt() ?? 500,
                wearRoundsThreshold:
                    (w['wearRoundsThreshold'] as num?)?.toInt() ?? 10000,
                roundsAtLastCleaning: _migrateRoundsAtLastCleaning(w),
                roundsAtLastRevision: _migrateRoundsAtLastRevision(w),
                documents: _decodeItemDocuments(
                  w['documents'] ?? w['pdfPaths'] ?? const [],
                ),
                history: ((w['history'] as List?) ?? const [])
                    .map((h) {
                      try {
                        return PlatformHistoryEntry.fromJson(h);
                      } catch (_) {
                        return null;
                      }
                    })
                    .whereType<PlatformHistoryEntry>()
                    .toList(),
                replacementParts: ((w['replacementParts'] as List?) ?? const [])
                    .map((p) {
                      try {
                        return PlatformReplacementPart.fromJson(p);
                      } catch (_) {
                        return null;
                      }
                    })
                    .whereType<PlatformReplacementPart>()
                    .toList(),
                photoPath: w['photoPath'] as String?,
                isHidden: w['isHidden'] as bool? ?? false,
                linkedAccessoryIds:
                    ((w['linkedAccessoryIds'] as List?) ?? const [])
                        .whereType<String>()
                        .toList(),
              );
            } catch (e) {
              debugPrint('Failed to load platform: $e');
              return null;
            }
          })
          .whereType<Platform>()
          .toList();

      final ammosList = (data['ammos'] as List?) ?? const [];
      _ammos = ammosList
          .whereType<Map>()
          .map((a) {
            try {
              final qty = (a['quantity'] ?? 0) as int;
              final rawInitial =
                  (a['initialQuantity'] ?? a['quantity'] ?? 0) as int;
              final effectiveInitial = (rawInitial <= 0 && qty > 0)
                  ? qty
                  : rawInitial;

              return Ammo(
                id: a['id'] as String,
                name: a['name'] as String,
                brand: a['brand'] as String,
                caliber: a['caliber'] as String,
                comment: (a['comment'] ?? '') as String,
                projectileType: MaterialTypeMigration.resolve(
                  (a['projectileType'] ?? a['bulletType'] ?? '') as String,
                  MaterialTypeMigration.ammo,
                  AmmoTypeKey.all,
                ),
                quantity: qty,
                initialQuantity: effectiveInitial,
                lastUsed: DateTime.tryParse(a['lastUsed'] as String? ?? ''),
                trackStock: a['trackStock'] as bool? ?? true,
                lowStockThreshold:
                    (a['lowStockThreshold'] as num?)?.toInt() ?? 50,
                documents: _decodeItemDocuments(
                  a['documents'] ?? a['pdfPaths'] ?? const [],
                ),
                photoPath: a['photoPath'] as String?,
                isHidden: a['isHidden'] as bool? ?? false,
                unitPrice: (a['unitPrice'] as num?)?.toDouble(),
                currency: (a['currency'] as String?) ?? 'EUR',
                history: (() {
                  try {
                    final raw = a['history'];
                    if (raw is! List) return <AmmoHistoryEntry>[];
                    return raw
                        .map((h) {
                          try {
                            return AmmoHistoryEntry.fromJson(
                              Map<String, dynamic>.from(h as Map),
                            );
                          } catch (_) {
                            return null;
                          }
                        })
                        .whereType<AmmoHistoryEntry>()
                        .toList();
                  } catch (_) {
                    return <AmmoHistoryEntry>[];
                  }
                })(),
              );
            } catch (e) {
              debugPrint('Failed to load ammo: $e');
              return null;
            }
          })
          .whereType<Ammo>()
          .toList();

      final accessoriesList = (data['accessories'] as List?) ?? const [];
      _accessories = accessoriesList
          .whereType<Map>()
          .map((ac) {
            try {
              final lastUsed = DateTime.tryParse(
                ac['lastUsed'] as String? ?? '',
              );
              final totalRounds = (ac['totalRounds'] ?? 0) as int;
              final lastCleaned = ac['lastCleaned'] != null
                  ? DateTime.tryParse(ac['lastCleaned'] as String)
                  : null;
              final lastRevised = ac['lastRevised'] != null
                  ? DateTime.tryParse(ac['lastRevised'] as String)
                  : null;

              final roundsAtLastCleaning =
                  (ac['roundsAtLastCleaning'] as num?)?.toInt() ?? totalRounds;
              final roundsAtLastRevision =
                  (ac['roundsAtLastRevision'] as num?)?.toInt() ?? totalRounds;

              return Accessory(
                id: ac['id'] as String,
                name: ac['name'] as String,
                brand: (ac['brand'] ?? '') as String,
                model: (ac['model'] ?? '') as String,
                comment: (ac['comment'] ?? '') as String,
                type: MaterialTypeMigration.resolve(
                  (ac['type'] ?? '') as String,
                  MaterialTypeMigration.accessory,
                  AccessoryTypeKey.all,
                ),
                imageUrl: (ac['imageUrl'] ?? '') as String,
                lastUsed: lastUsed,
                totalRounds: totalRounds,
                lastCleaned: lastCleaned ?? DateTime.now(),
                lastRevised: lastRevised ?? lastCleaned ?? DateTime.now(),
                trackWear: (ac['trackWear'] ?? false) as bool,
                trackCleanliness: (ac['trackCleanliness'] ?? false) as bool,
                cleaningRoundsThreshold:
                    (ac['cleaningRoundsThreshold'] as num?)?.toInt() ?? 500,
                wearRoundsThreshold:
                    (ac['wearRoundsThreshold'] as num?)?.toInt() ?? 10000,
                roundsAtLastCleaning: roundsAtLastCleaning,
                roundsAtLastRevision: roundsAtLastRevision,
                batteryChangedAt: ac['batteryChangedAt'] != null
                    ? DateTime.tryParse(ac['batteryChangedAt'] as String)
                    : null,
                trackBattery: (ac['trackBattery'] ?? false) as bool,
                documents: _decodeItemDocuments(ac['documents'] ?? const []),
                photoPath: ac['photoPath'] as String?,
                isHidden: (ac['isHidden'] ?? false) as bool,
                linkedPlatformIds:
                    ((ac['linkedPlatformIds'] as List?) ?? const [])
                        .whereType<String>()
                        .toList(),
              );
            } catch (e) {
              debugPrint('Failed to load accessory: $e');
              return null;
            }
          })
          .whereType<Accessory>()
          .toList();

      final adjustmentTablesRaw =
          (data['shootingAdjustmentTables'] as List?) ?? const [];
      _shootingAdjustmentTables = adjustmentTablesRaw
          .whereType<Map>()
          .map((t) {
            try {
              return ShootingAdjustmentTable.fromJson(
                t.cast<String, dynamic>(),
              );
            } catch (_) {
              return null;
            }
          })
          .whereType<ShootingAdjustmentTable>()
          .where((t) => t.platformId.trim().isNotEmpty)
          .toList();

      final sessionsList = (data['sessions'] as List?) ?? const [];
      _sessions = sessionsList
          .whereType<Map>()
          .map((s) {
            try {
              final exercisesList = (s['exercises'] as List?) ?? const [];
              final exercises = exercisesList
                  .whereType<Map>()
                  .map((raw) {
                    try {
                      final e = raw;
                      final stepsRaw = (e['steps'] as List?) ?? const [];
                      final assignmentsRaw =
                          (e['platformAssignments'] as List?) ?? const [];
                      final shotAllocationsRaw =
                          (e['shotAllocations'] as List?) ?? const [];

                      return Exercise(
                        id: e['id'] as String,
                        name: (e['name'] ?? '') as String,
                        platformId: (e['platformId'] ?? '') as String,
                        platformLabel: (e['platformLabel'] as String?),
                        ammoId: (e['ammoId'] ?? '') as String,
                        ammoLabel: (e['ammoLabel'] as String?),
                        equipmentIds: _decodeEquipmentIds(e),
                        targetName: e['targetName'] as String?,
                        targetPhotos: ((e['targetPhotos'] as List?) ?? const [])
                            .map((p) {
                              try {
                                return ExercisePhoto.fromJson(
                                  Map<String, dynamic>.from(p as Map),
                                );
                              } catch (_) {
                                return null;
                              }
                            })
                            .whereType<ExercisePhoto>()
                            .toList(),
                        shotsFired: (e['shotsFired'] as num?)?.toInt() ?? 0,
                        distance: (e['distance'] as num?)?.toInt() ?? 0,
                        precision: e['precision'] != null
                            ? (e['precision'] as num).toDouble()
                            : null,
                        precisionEnabled:
                            (e['precisionEnabled'] ?? true) as bool,
                        observations: e['observations'] as String? ?? '',
                        platformAssignments: assignmentsRaw
                            .whereType<Map>()
                            .map((m) => Map<String, dynamic>.from(m))
                            .map((m) {
                              try {
                                return ExercisePlatformAssignment(
                                  platformId: (m['platformId'] ?? '') as String,
                                  platformLabel: m['platformLabel'] as String?,
                                  ammoIds: ((m['ammoIds'] as List?) ?? const [])
                                      .whereType<String>()
                                      .toList(),
                                  accessoryIds:
                                      ((m['accessoryIds'] as List?) ?? const [])
                                          .whereType<String>()
                                          .toList(),
                                );
                              } catch (_) {
                                return null;
                              }
                            })
                            .whereType<ExercisePlatformAssignment>()
                            .where((a) => a.platformId.trim().isNotEmpty)
                            .toList(),
                        shotAllocations: shotAllocationsRaw
                            .whereType<Map>()
                            .map((m) => Map<String, dynamic>.from(m))
                            .map((m) {
                              try {
                                return ExerciseShotAllocation(
                                  platformId: (m['platformId'] ?? '') as String,
                                  ammoId: (m['ammoId'] ?? '') as String,
                                  shots: (m['shots'] as num?)?.toInt() ?? 0,
                                );
                              } catch (_) {
                                return null;
                              }
                            })
                            .whereType<ExerciseShotAllocation>()
                            .where(
                              (a) =>
                                  a.platformId.trim().isNotEmpty &&
                                  a.ammoId.trim().isNotEmpty &&
                                  a.shots > 0,
                            )
                            .toList(),
                        steps: stepsRaw
                            .whereType<Map>()
                            .map((m) {
                              try {
                                return ExerciseStep.fromJson(
                                  Map<String, dynamic>.from(m),
                                );
                              } catch (_) {
                                return null;
                              }
                            })
                            .whereType<ExerciseStep>()
                            .toList(),
                      );
                    } catch (_) {
                      return null;
                    }
                  })
                  .whereType<Exercise>()
                  .toList();

              return Session(
                id: s['id'] as String,
                name: s['name'] as String,
                date:
                    DateTime.tryParse(s['date'] as String? ?? '') ??
                    DateTime.now(),
                location: (s['location'] as String?) ?? '',
                shootingDistance: (s['shootingDistance'] as String?) ?? '',
                locationLatitude: (s['locationLatitude'] as num?)?.toDouble(),
                locationLongitude: (s['locationLongitude'] as num?)?.toDouble(),
                sessionType: s['sessionType'] as String,
                weatherEnabled: s['weatherEnabled'] as bool? ?? false,
                temperature: s['temperature'] as String? ?? '',
                wind: s['wind'] as String? ?? '',
                humidity: s['humidity'] as String? ?? '',
                pressure: s['pressure'] as String? ?? '',
                temperatureEnabled: s['temperatureEnabled'] as bool? ?? true,
                windEnabled: s['windEnabled'] as bool? ?? true,
                humidityEnabled: s['humidityEnabled'] as bool? ?? true,
                pressureEnabled: s['pressureEnabled'] as bool? ?? true,
                platformIds: ((s['platformIds'] as List?) ?? const [])
                    .whereType<String>()
                    .toList(),
                exercises: exercises,
              );
            } catch (e) {
              debugPrint('Failed to load session: $e');
              return null;
            }
          })
          .whereType<Session>()
          .toList();

      final diagnosticsList = (data['diagnostics'] as List?) ?? const [];
      _diagnostics = diagnosticsList
          .whereType<Map<String, dynamic>>()
          .map((d) {
            try {
              return Diagnostic(
                id: d['id'] as String,
                date:
                    DateTime.tryParse(d['date'] as String? ?? '') ??
                    DateTime.now(),
                platformId: d['platformId'] as String,
                platformNameSnapshot:
                    (d['platformNameSnapshot'] ?? '') as String,
                platformTypeSnapshot:
                    (d['platformTypeSnapshot'] ?? '') as String,
                responses: Map<String, dynamic>.from(
                  d['responses'] as Map? ?? const {},
                ),
                incidentKey: (d['incidentKey'] ?? 'incident_unknown') as String,
                suspectedIssueKey:
                    (d['suspectedIssueKey'] ?? 'multiple_possible') as String,
                riskLevelKey: (d['riskLevelKey'] ?? 'medium') as String,
                probabilities: Map<String, int>.from(
                  d['probabilities'] as Map? ?? const {},
                ),
                finalDecision: (d['finalDecision'] ?? '') as String,
                summary: (d['summary'] ?? '') as String,
              );
            } catch (e) {
              debugPrint('Failed to load diagnostic: $e');
              return null;
            }
          })
          .whereType<Diagnostic>()
          .toList();
    } catch (e) {
      debugPrint('Critical error in _loadDomainDataFromMap: $e');
    }
  }

  // Local Storage Methods
  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 400), _saveToLocal);
  }

  Future<Map<String, dynamic>?> _loadFromSafeBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('thot_domain_data_backup');
      if (raw == null || raw.isEmpty) return null;

      // Tenter le JSON brut (backup legacy en SharedPreferences)
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    } catch (e) {
      debugPrint('Error loading safe backup: $e');
    }
    return null;
  }

  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!_domainDataLoadCompleted) {
        if (kDebugMode) {
          debugPrint('Skip domain save: local domain data not loaded yet.');
        }
        return;
      }

      // Check recent achievements
      _checkAchievements();

      // Save achievements
      await prefs.setStringList(
        'thot_unlocked_achievements',
        _unlockedAchievements.toList(),
      );
      // Save unlock dates as id|iso8601 list
      final datesList = _achievementUnlockDates.entries
          .map((e) => '${e.key}|${e.value.toIso8601String()}')
          .toList();
      await prefs.setStringList('thot_unlocked_achievement_dates', datesList);

      // Petits réglages seulement
      await prefs.setString('userName', _userName);
      await prefs.setString('licenseNumber', _licenseNumber);
      await prefs.setString('userEmail', _userEmail);
      await prefs.setBool('useMetric', _useMetric);
      await prefs.setString('weightUnit', _weightUnit.name);
      await prefs.setString('distanceUnit', _distanceUnit.name);
      await prefs.setString('velocityUnit', _velocityUnit.name);
      await prefs.setString('dateFormatPreference', _dateFormatPreference);
      await prefs.setString('themeMode', _themeMode.toString());
      await prefs.setStringList('quickActions', _quickActions);
      await prefs.setString('localeCode', _localeCode ?? '');
      await prefs.setBool(
        'documentExpiryPushEnabled',
        _documentExpiryPushEnabled,
      );

      final data = _buildDomainDataMap();
      final rawJson = jsonEncode(data);

      await _domainStore.writeDomainData(rawJson);

      unawaited(_syncDocumentExpiryReminders());
      unawaited(
        DashboardWidgetService.sync(
          sessions: _sessions,
          platforms: platforms,
          ammos: ammos,
          accessories: accessories,
          userDocuments: _userDocuments,
        ),
      );

      if (kDebugMode) {
        debugPrint('Data saved to local storage.');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving local data.');
      }
    }
  }

  Future<void> _syncDocumentExpiryReminders() async {
    await MaintenanceNotifications.syncDocumentExpiryReminders(
      enabled: _documentExpiryPushEnabled,
      localeCode: _localeCode,
      platforms: _platforms.where((w) => !w.isHidden).toList(),
      ammos: _ammos.where((a) => !a.isHidden).toList(),
      accessories: _accessories.where((a) => !a.isHidden).toList(),
      userDocuments: _userDocuments,
    );
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final unlockedList =
          prefs.getStringList('thot_unlocked_achievements') ?? [];
      _unlockedAchievements = unlockedList.toSet();
      // Load unlock dates
      _achievementUnlockDates = {};
      final rawDates =
          prefs.getStringList('thot_unlocked_achievement_dates') ?? const [];
      for (final entry in rawDates) {
        final idx = entry.indexOf('|');
        if (idx > 0) {
          final id = entry.substring(0, idx);
          final iso = entry.substring(idx + 1);
          try {
            _achievementUnlockDates[id] = DateTime.parse(iso);
          } catch (_) {}
        }
      }
      // Ensure all unlocked have a date
      for (final id in _unlockedAchievements) {
        _achievementUnlockDates.putIfAbsent(id, () => DateTime.now());
      }

      // Petits réglages
      _hasSeenOnboarding = prefs.getBool('thot_has_seen_onboarding') ?? false;
      _onboardingPageIndex = prefs.getInt('thot_onboarding_page_index') ?? 0;
      _userName = prefs.getString('userName') ?? '';
      _licenseNumber = prefs.getString('licenseNumber') ?? '';
      _userEmail = prefs.getString('userEmail') ?? '';
      _useMetric = prefs.getBool('useMetric') ?? true;
      _weightUnit = WeightUnit.values.firstWhere(
        (unit) => unit.name == prefs.getString('weightUnit'),
        orElse: () => WeightUnit.gram,
      );
      _distanceUnit = DistanceUnit.values.firstWhere(
        (unit) => unit.name == prefs.getString('distanceUnit'),
        orElse: () => _useMetric ? DistanceUnit.meter : DistanceUnit.yard,
      );
      _velocityUnit = VelocityUnit.values.firstWhere(
        (unit) => unit.name == prefs.getString('velocityUnit'),
        orElse: () => _useMetric
            ? VelocityUnit.metersPerSecond
            : VelocityUnit.feetPerSecond,
      );
      _dateFormatPreference =
          prefs.getString('dateFormatPreference') ?? 'day_month_year';
      _premiumService.loadMetadataFromPrefs(prefs);

      final themeModeStr = prefs.getString('themeMode');
      if (themeModeStr != null) {
        _themeMode = themeModeStr.contains('dark')
            ? ThemeMode.dark
            : ThemeMode.light;
      }

      _quickActions = _sanitizeQuickActions(
        prefs.getStringList('quickActions'),
      );
      _documentExpiryPushEnabled =
          prefs.getBool('documentExpiryPushEnabled') ?? false;
      final rawLocale = prefs.getString('localeCode');
      _localeCode = (rawLocale == null || rawLocale.trim().isEmpty)
          ? null
          : rawLocale.trim();

      Map<String, dynamic>? domainData;

      domainData = await _domainStore.readDomainData();

      if (domainData != null) {
        _loadDomainDataFromMap(domainData);
        _domainDataLoadCompleted = true;
      } else {
        // ÉCHEC de lecture du stockage principal.
        // Tenter la restauration via le backup legacy en SharedPreferences.
        domainData = await _loadFromSafeBackup();

        if (domainData != null) {
          _loadDomainDataFromMap(domainData);
          _domainDataLoadCompleted = true;
          if (kDebugMode) {
            debugPrint(
              '⚠️ Données restaurées depuis le backup SharedPreferences.',
            );
          }
          // Réécrire immédiatement pour restaurer le fichier .dat en clair.
          await _saveToLocal();
        } else {
          // ÉCHEC du backup : fallback migration legacy (anciennes clés SharedPreferences).
          final legacyData = <String, dynamic>{};

          final userDocsStr = prefs.getString('userDocuments');
          if (userDocsStr != null && userDocsStr.isNotEmpty) {
            try {
              legacyData['userDocuments'] = jsonDecode(userDocsStr);
            } catch (_) {}
          }

          final platformsStr = prefs.getString('platforms');
          if (platformsStr != null && platformsStr.isNotEmpty) {
            try {
              legacyData['platforms'] = jsonDecode(platformsStr);
            } catch (_) {}
          }

          final ammosStr = prefs.getString('ammos');
          if (ammosStr != null && ammosStr.isNotEmpty) {
            try {
              legacyData['ammos'] = jsonDecode(ammosStr);
            } catch (_) {}
          }

          final accessoriesStr = prefs.getString('accessories');
          if (accessoriesStr != null && accessoriesStr.isNotEmpty) {
            try {
              legacyData['accessories'] = jsonDecode(accessoriesStr);
            } catch (_) {}
          }

          final sessionsStr = prefs.getString('sessions');
          if (sessionsStr != null && sessionsStr.isNotEmpty) {
            try {
              legacyData['sessions'] = jsonDecode(sessionsStr);
            } catch (_) {}
          }

          final diagnosticsStr = prefs.getString('diagnostics');
          if (diagnosticsStr != null && diagnosticsStr.isNotEmpty) {
            try {
              legacyData['diagnostics'] = jsonDecode(diagnosticsStr);
            } catch (_) {}
          }

          if (legacyData.isNotEmpty) {
            _loadDomainDataFromMap(legacyData);
            _domainDataLoadCompleted = true;
            await _saveToLocal();
          } else {
            // Aucun backup, aucune donnée legacy : initialisation vide.
            _loadDomainDataFromMap(const {});
            _domainDataLoadCompleted = true;
          }
        }
      }

      final migratedPhotoPaths = await _migrateItemPhotoPaths();
      if (migratedPhotoPaths) {
        await _saveToLocal();
      }

      if (kDebugMode) {
        debugPrint('Data loaded from local storage.');
      }

      await _syncDocumentExpiryReminders();

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading local data: $e');
      }
      _domainDataLoadCompleted = false;
      notifyListeners();
    }
  }

  Future<bool> _migrateItemPhotoPaths() async {
    var changed = false;

    for (var i = 0; i < _platforms.length; i++) {
      final current = _platforms[i];
      final migrated = await ImageStorage.persistFromPath(current.photoPath);
      if (migrated != null && migrated != current.photoPath) {
        _platforms[i] = current.copyWith(photoPath: migrated);
        changed = true;
      }
    }

    for (var i = 0; i < _ammos.length; i++) {
      final current = _ammos[i];
      final migrated = await ImageStorage.persistFromPath(current.photoPath);
      if (migrated != null && migrated != current.photoPath) {
        _ammos[i] = current.copyWith(photoPath: migrated);
        changed = true;
      }
    }

    for (var i = 0; i < _accessories.length; i++) {
      final current = _accessories[i];
      final migrated = await ImageStorage.persistFromPath(current.photoPath);
      if (migrated != null && migrated != current.photoPath) {
        _accessories[i] = current.copyWith(photoPath: migrated);
        changed = true;
      }
    }

    return changed;
  }

  List<ItemDocument> _decodeItemDocuments(dynamic raw) {
    try {
      if (raw is List) {
        final docs = raw
            .map(ItemDocument.fromJson)
            .where((d) => d.path.isNotEmpty)
            .toList();
        return docs;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to decode item documents.');
      }
    }
    return const [];
  }

  List<String> _decodeEquipmentIds(dynamic exerciseJson) {
    try {
      if (exerciseJson is! Map) return const [];

      final rawList = exerciseJson['equipmentIds'];
      if (rawList is List) {
        return rawList
            .whereType<String>()
            .where((id) => id.trim().isNotEmpty)
            .toList();
      }

      // Backward compatibility: older builds stored a single equipmentId
      final legacy = exerciseJson['equipmentId'];
      if (legacy is String && legacy.trim().isNotEmpty) return [legacy];
    } catch (e) {
      debugPrint('Failed to decode equipmentIds: $e');
    }
    return const [];
  }

  int _migrateRoundsAtLastCleaning(dynamic platformJson) {
    try {
      if (platformJson is Map && platformJson['roundsAtLastCleaning'] != null) {
        return (platformJson['roundsAtLastCleaning'] as num).toInt();
      }

      // Legacy migration from normalized cleanlinessLevel (1.0 = clean, 0.0 = dirty)
      if (platformJson is Map && platformJson['cleanlinessLevel'] != null) {
        final totalRounds = (platformJson['totalRounds'] as num?)?.toInt() ?? 0;
        final threshold =
            (platformJson['cleaningRoundsThreshold'] as num?)?.toInt() ?? 500;
        final cleanlinessLevel = (platformJson['cleanlinessLevel'] as num)
            .toDouble();
        final dirtProgress = (1.0 - cleanlinessLevel).clamp(0.0, 1.0);
        final roundsSince = (dirtProgress * threshold).round();
        return (totalRounds - roundsSince).clamp(0, 1 << 30);
      }
    } catch (e) {
      debugPrint('Failed to migrate roundsAtLastCleaning: $e');
    }
    final totalRounds =
        (platformJson is Map && platformJson['totalRounds'] != null)
        ? (platformJson['totalRounds'] as num).toInt()
        : 0;
    return totalRounds;
  }

  int _migrateRoundsAtLastRevision(dynamic platformJson) {
    try {
      if (platformJson is Map && platformJson['roundsAtLastRevision'] != null) {
        return (platformJson['roundsAtLastRevision'] as num).toInt();
      }

      // Legacy migration from normalized wearLevel (0.0 = new, 1.0 = worn)
      if (platformJson is Map && platformJson['wearLevel'] != null) {
        final totalRounds = (platformJson['totalRounds'] as num?)?.toInt() ?? 0;
        final threshold =
            (platformJson['wearRoundsThreshold'] as num?)?.toInt() ?? 10000;
        final wearLevel = (platformJson['wearLevel'] as num).toDouble().clamp(
          0.0,
          1.0,
        );
        final roundsSince = (wearLevel * threshold).round();
        return (totalRounds - roundsSince).clamp(0, 1 << 30);
      }
    } catch (e) {
      debugPrint('Failed to migrate roundsAtLastRevision: $e');
    }
    final totalRounds =
        (platformJson is Map && platformJson['totalRounds'] != null)
        ? (platformJson['totalRounds'] as num).toInt()
        : 0;
    return totalRounds;
  }

  // Platform type migration is now handled by MaterialTypeMigration.resolve()
  // in _loadDomainDataFromMap.

  Future<void> lockSession() async {
    await _securityService.lockSession();
  }

  Future<bool> verifyPin(String enteredPin) async {
    return _securityService.verifyPin(enteredPin);
  }

  Future<bool> authenticateWithBiometric({String? localizedReason}) async {
    return _securityService.authenticateWithBiometric(
      localizedReason: localizedReason,
    );
  }

  Future<void> setPinCode(String pin) async {
    await _securityService.setPinCode(pin);
  }

  Future<void> togglePinEnabled(bool enabled) async {
    await _securityService.togglePinEnabled(enabled);
  }

  Future<void> toggleBiometricEnabled(bool enabled) async {
    await _securityService.toggleBiometricEnabled(enabled);
  }

  // --- Cost Calculation Methods ---

  /// Calculate total fired cost for a specific ammo.
  /// Returns null if unitPrice is not set.
  double? getAmmoTotalShotCost(String ammoId) {
    final ammo = ammos.firstWhere(
      (a) => a.id == ammoId,
      orElse: () => Ammo(id: '', name: '', brand: '', caliber: '', quantity: 0),
    );
    if (ammo.unitPrice == null) return null;

    int totalShotsFired = 0;
    for (final session in sessions) {
      for (final exercise in session.exercises) {
        totalShotsFired += exercise.ammoShotImpact[ammoId] ?? 0;
      }
    }

    return totalShotsFired * ammo.unitPrice!;
  }

  /// Calculate remaining stock cost for a specific ammo.
  /// Returns null if unitPrice is not set.
  double? getAmmoRemainingStockCost(String ammoId) {
    final ammo = ammos.firstWhere(
      (a) => a.id == ammoId,
      orElse: () => Ammo(id: '', name: '', brand: '', caliber: '', quantity: 0),
    );
    if (ammo.unitPrice == null) return null;

    return ammo.quantity * ammo.unitPrice!;
  }

  /// Calculate estimated cost for a specific session.
  /// Returns null if no ammo with price is used.
  double? getSessionEstimatedCost(String sessionId) {
    final session = sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => Session(
        id: '',
        name: '',
        date: DateTime.now(),
        location: '',
        exercises: [],
      ),
    );

    double totalCost = 0;
    bool hasPricedAmmo = false;

    for (final exercise in session.exercises) {
      for (final entry in exercise.ammoShotImpact.entries) {
        final ammo = ammos.firstWhere(
          (a) => a.id == entry.key,
          orElse: () =>
              Ammo(id: '', name: '', brand: '', caliber: '', quantity: 0),
        );
        if (ammo.unitPrice != null) {
          hasPricedAmmo = true;
          totalCost += entry.value * ammo.unitPrice!;
        }
      }
    }

    return hasPricedAmmo ? totalCost : null;
  }

  /// Get monthly costs for the last N months.
  /// Returns a list of {month, totalCost} for each month.
  List<Map<String, dynamic>> getMonthlyCosts(int lastNMonths) {
    final now = DateTime.now();
    final results = <Map<String, dynamic>>[];

    for (int i = lastNMonths - 1; i >= 0; i--) {
      final monthStart = DateTime(now.year, now.month - i);
      final monthEnd = i == 0
          ? now
          : DateTime(now.year, now.month - i + 1, 0)
                .add(const Duration(days: 1))
                .subtract(const Duration(milliseconds: 1));

      double monthlyCost = 0;

      for (final session in sessions) {
        if (session.date.isAfter(monthStart) &&
            session.date.isBefore(monthEnd)) {
          final sessionCost = getSessionEstimatedCost(session.id);
          if (sessionCost != null) {
            monthlyCost += sessionCost;
          }
        }
      }

      results.add({'month': monthStart, 'cost': monthlyCost});
    }

    return results;
  }

  /// Get top ammos by cost over the last N months.
  /// Returns a map {ammoId: totalCost} sorted by cost descending.
  Map<String, double> getTopAmmosByCost(int months) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month - months + 1);
    final costs = <String, double>{};

    for (final session in sessions) {
      if (session.date.isAfter(monthStart)) {
        for (final exercise in session.exercises) {
          for (final entry in exercise.ammoShotImpact.entries) {
            final ammo = ammos.firstWhere(
              (a) => a.id == entry.key,
              orElse: () =>
                  Ammo(id: '', name: '', brand: '', caliber: '', quantity: 0),
            );
            if (ammo.unitPrice != null) {
              costs[entry.key] =
                  (costs[entry.key] ?? 0) + (entry.value * ammo.unitPrice!);
            }
          }
        }
      }
    }

    // Sort by cost descending
    final sortedEntries = costs.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  Future<void> logout() async {
    await _securityService.logout();
  }
}
