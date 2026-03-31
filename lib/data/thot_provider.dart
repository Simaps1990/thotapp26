import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, debugPrint;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:convert';
import 'dart:async';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/data/exercise_step.dart';
import 'models.dart';
import '../utils/achievement_definitions.dart';
import '../utils/maintenance_notifications.dart';
import 'thot_encrypted_file_store.dart';
import 'thot_premium_service.dart';
import 'thot_security_service.dart';

class ThotProvider extends ChangeNotifier {
  static const String _weaponTypePistolSemiAuto = 'Pistolet semi-auto';
  static const String _weaponTypePistolSemiAutomatiqueLegacy = 'Pistolet semi-automatique';
  late final ThotPremiumService _premiumService =
      ThotPremiumService(onChanged: notifyListeners);

  final bool _bypassLimits = kDebugMode;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void>? _initializeFuture;
  Timer? _saveDebounce;
  
  // TODO(FreeLimits): when restoring real limits, replace this with the
  // actual premium status:
  //   bool get isPremium => _bypassLimits || _premiumService.isPremium;
  // For now, always treat user as premium to disable all free-plan limits.
  bool get isPremium => true;
  bool get purchaseAvailable => _premiumService.purchaseAvailable;
  bool get purchasePending => _premiumService.purchasePending;
  String? get purchaseError => _premiumService.purchaseError;

  // Localized prices for Pro offers (from store / RevenueCat)
  String? get yearlyPrice => _premiumService.yearlyPrice;
  String? get monthlyPrice => _premiumService.monthlyPrice;

  Future<void> purchaseYearly() => _premiumService.purchaseYearly();
  Future<void> purchaseMonthly() => _premiumService.purchaseMonthly();
  
  // Sauvegarde native appareil : toujours autorisée par conception
bool get cloudBackupEnabled => false;

  // Security
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  late final ThotEncryptedFileStore _domainStore =
      ThotEncryptedFileStore(secureStorage: _secureStorage);

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
  // Limits for free version
  static const int maxWeaponsFree = 1;
  static const int maxAmmosFree = 1;
  static const int maxAccessoriesFree = 1;
  static const int maxSessionsFree = 5;
  static const int maxDocumentsPerItemFree = 1;
  
  // Theme State
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _scheduleSave();
    notifyListeners();
  }

  void deleteExerciseFromSession({required String sessionId, required String exerciseId}) {
    final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex == -1) return;

    final session = _sessions[sessionIndex];
    final updatedExercises = session.exercises.where((e) => e.id != exerciseId).toList();
    if (updatedExercises.length == session.exercises.length) return;

    updateSession(Session(
      id: session.id,
      name: session.name,
      date: session.date,
      location: session.location,
      shootingDistance: session.shootingDistance,
      sessionType: session.sessionType,
      exercises: updatedExercises,
      weatherEnabled: session.weatherEnabled,
      temperature: session.temperature,
      wind: session.wind,
      humidity: session.humidity,
      pressure: session.pressure,
      temperatureEnabled: session.temperatureEnabled,
      windEnabled: session.windEnabled,
      humidityEnabled: session.humidityEnabled,
      pressureEnabled: session.pressureEnabled,
      weaponIds: session.weaponIds,
    ));
  }

  void saveExerciseTemplate(ExerciseTemplate template) {
    final baseName = template.name.trim();
    String finalName = baseName;
    int suffix = 2;
    while (_exerciseTemplates.any((t) => t.name == finalName && t.id != template.id)) {
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

  void recordWeaponPartChange({
    required String weaponId,
    required String partName,
    required DateTime date,
    String? comment,
  }) {
    final index = _weapons.indexWhere((w) => w.id == weaponId);
    if (index == -1) return;
    final current = _weapons[index];
    final entry = WeaponHistoryEntry(
      id: 'piece-${date.microsecondsSinceEpoch}',
      date: date,
      type: 'piece',
      label: 'Changement de pièce: $partName',
      details: (comment ?? '').trim().isEmpty ? null : comment,
    );
    _weapons[index] = current.copyWith(
      history: [...current.history, entry],
    );
    _scheduleSave();
    notifyListeners();
  }

  // Onboarding State
  bool _hasSeenOnboarding = false;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  bool _onboardingDismissedForSession = false;
  bool get onboardingDismissedForSession => _onboardingDismissedForSession;

  void dismissOnboardingForSession() {
    _onboardingDismissedForSession = true;
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
  List<AchievementDefinition> get achievementQueue => List.unmodifiable(_achievementQueue);
  DateTime? achievementUnlockDate(String id) => _achievementUnlockDates[id];

  void popAchievement() {
    if (_achievementQueue.isNotEmpty) {
      _achievementQueue.removeAt(0);
      notifyListeners();
    }
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
  String _userName = "";
  String _licenseNumber = "";
  String _userEmail = "";
  bool _useMetric = true;
  String _dateFormatPreference = 'day_month_year';
  String? _localeCode; // null = suivre la langue du système
  List<UserDocument> _userDocuments = [];
  
  String get userName => _userName;
  String get licenseNumber => _licenseNumber;
  String get userEmail => _userEmail;
  bool get useMetric => _useMetric;
  String get dateFormatPreference => _dateFormatPreference;
  String? get localeCode => _localeCode;
  Locale? get appLocale =>
      _localeCode == null || _localeCode!.isEmpty ? null : Locale(_localeCode!);
  List<UserDocument> get userDocuments => _userDocuments;
  
  void updateUserProfile({String? name, String? license, String? email}) {
    if (name != null) _userName = name;
    if (license != null) _licenseNumber = license;
    if (email != null) _userEmail = email;
    _scheduleSave();
    notifyListeners();
  }
  
  void setUnitSystem(bool metric) {
    _useMetric = metric;
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
  
  void deleteUserDocument(String id) {
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
    _dateFormatPreference = 'day_month_year';
    _localeCode = null;
    _userDocuments = [];

    _weapons = [];
    _ammos = [];
    _accessories = [];
    _sessions = [];
    _diagnostics = [];

    _unlockedAchievements = {};
    _achievementUnlockDates = {};
    _achievementQueue = [];
    _quickActions = ['new_session', 'new_weapon', 'new_ammo', 'toggle_theme'];
    _themeMode = ThemeMode.light;

    await prefs.remove('thot_has_seen_onboarding');
    await prefs.remove('userName');
    await prefs.remove('licenseNumber');
    await prefs.remove('userEmail');
    await prefs.remove('useMetric');
    await prefs.remove('dateFormatPreference');
    await prefs.remove('themeMode');
    await prefs.remove('quickActions');
    await prefs.remove('localeCode');
    await prefs.remove('thot_unlocked_achievements');
    await prefs.remove('thot_unlocked_achievement_dates');
    await prefs.remove('thot_domain_data');

    await prefs.remove('userDocuments');
    await prefs.remove('weapons');
    await prefs.remove('ammos');
    await prefs.remove('accessories');
    await prefs.remove('sessions');
    await prefs.remove('diagnostics');

    await _domainStore.clearDomainData();
    await _domainStore.clearEncryptionKeys();
    await _securityService.clearAllSecurityData();
    await _premiumService.clearLocalCache();

    notifyListeners();
  }
  
  
Future<void> toggleCloudBackup(bool enabled) async {
  // Sauvegarde native laissée au système.
  // Cette méthode reste uniquement pour compatibilité,
  // mais ne pilote plus rien côté runtime.
  notifyListeners();
}

  // Quick Actions (IDs of selected actions)
  List<String> _quickActions = ['new_session', 'new_weapon', 'new_ammo', 'toggle_theme'];
  List<String> get quickActions => _quickActions;
  
  void toggleQuickAction(String actionId) {
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
  List<Weapon> _weapons = [];
  List<Ammo> _ammos = [];
  List<Accessory> _accessories = [];

  List<Weapon> get weapons => _weapons.where((w) => !w.isHidden).toList();
  List<Ammo> get ammos => _ammos.where((a) => !a.isHidden).toList();
  List<Accessory> get accessories => _accessories.where((a) => !a.isHidden).toList();

  String? get primaryWeaponId => weapons.isEmpty ? null : weapons.first.id;
  String? get primaryAmmoId => ammos.isEmpty ? null : ammos.first.id;
  String? get primaryAccessoryId => accessories.isEmpty ? null : accessories.first.id;

  // TODO(FreeLimits): restore the real checks below when re-enabling limits.
  //  bool canUseWeaponId(String id) =>
  //      isPremium || (primaryWeaponId != null && id == primaryWeaponId);
  //  bool canUseAmmoId(String id) =>
  //      isPremium || (primaryAmmoId != null && id == primaryAmmoId);
  //  bool canUseAccessoryId(String id) =>
  //      isPremium || (primaryAccessoryId != null && id == primaryAccessoryId);

  // TEMP: everyone can use any material for sessions while limits are disabled.
  bool canUseWeaponId(String id) => true;
  bool canUseAmmoId(String id) => true;
  bool canUseAccessoryId(String id) => true;

  // --- Free plan locking helpers -------------------------------------------------
  // Ces méthodes ne modifient rien, elles dérivent seulement l'état "verrouillé Pro"
  // à partir de l'abonnement et des quotas gratuits. L'UI peut les utiliser pour
  // griser les éléments et limiter les actions.

  bool isSessionLockedForFree(Session session, int index) {
    // TODO(FreeLimits): restore index-based locking when re-enabling limits.
    // if (isPremium) return false;
    // return index >= maxSessionsFree;
    return false;
  }

  bool isWeaponLockedForFree(Weapon weapon, int index) {
    // TODO(FreeLimits): restore first-weapon-only behaviour when re-enabling
    // limits.
    // if (isPremium) return false;
    // return index >= maxWeaponsFree;
    return false;
  }

  bool isAmmoLockedForFree(Ammo ammo, int index) {
    // TODO(FreeLimits): restore first-ammo-only behaviour when re-enabling
    // limits.
    // if (isPremium) return false;
    // return index >= maxAmmosFree;
    return false;
  }

  bool isAccessoryLockedForFree(Accessory accessory, int index) {
    // TODO(FreeLimits): restore first-accessory-only behaviour when
    // re-enabling limits.
    // if (isPremium) return false;
    // return index >= maxAccessoriesFree;
    return false;
  }

  /// Documents côté item (arme, munition, accessoire).
  /// [currentDocumentsCount] est typiquement `item.documents.length`.
  bool isItemDocumentLockedForFree({required int documentIndex}) {
    // TODO(FreeLimits): restore per-document locking when re-enabling limits.
    // if (isPremium) return false;
    // return documentIndex >= maxDocumentsPerItemFree;
    return false;
  }

  // Sessions
  List<ExerciseTemplate> _exerciseTemplates = [];
  List<ExerciseTemplate> get exerciseTemplates => List.unmodifiable(_exerciseTemplates);

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
  
  int get _activeWeaponsCount => _weapons.where((w) => !w.isHidden).length;
  int get _activeAmmosCount => _ammos.where((a) => !a.isHidden).length;
  int get _activeAccessoriesCount =>
      _accessories.where((a) => !a.isHidden).length;

  // Check if user can add more items (free version limits)
  // TODO(FreeLimits): restore real limits by re-enabling the checks below.
  //  bool canAddWeapon() => isPremium || _activeWeaponsCount < maxWeaponsFree;
  //  bool canAddAmmo() => isPremium || _activeAmmosCount < maxAmmosFree;
  //  bool canAddAccessory() =>
  //      isPremium || _activeAccessoriesCount < maxAccessoriesFree;
  //  bool canAddSession() => isPremium || _sessions.length < maxSessionsFree;
  //
  //  bool canAddDocumentToItem({required int currentDocumentsCount}) =>
  //      isPremium || currentDocumentsCount < maxDocumentsPerItemFree;

  // TEMP: free limits fully disabled for testing (treat everyone as unlimited)
  bool canAddWeapon() => true;
  bool canAddAmmo() => true;
  bool canAddAccessory() => true;
  bool canAddSession() => true;

  bool canAddDocumentToItem({required int currentDocumentsCount}) => true;
  
  String getLimitMessage(String type) {
    final strings = AppStrings.forLocale(appLocale ?? const Locale('fr'));
    if (type == 'weapon') {
      return strings.premiumLimitMessage(
        '$_activeWeaponsCount',
        '$maxWeaponsFree',
        'armes',
      );
    } else if (type == 'ammo') {
      return strings.premiumLimitMessage(
        '$_activeAmmosCount',
        '$maxAmmosFree',
        'munitions',
      );
    } else if (type == 'accessory') {
      return strings.premiumLimitMessage(
        '$_activeAccessoriesCount',
        '$maxAccessoriesFree',
        'accessoires',
      );
    } else if (type == 'session') {
      return strings.premiumLimitMessage(
        '${_sessions.length}',
        '$maxSessionsFree',
        'séances',
      ).replaceFirst('ajouter des séances', 'créer des séances');
    }
    return '';
  }

  Future<void> restorePurchases() async {
    await _premiumService.restorePurchases();
  }





  @override
  void dispose() {
    super.dispose();
  }

  // --- Actions ---

  void addSession(Session session) {
    // TODO(FreeLimits): re-enable guard below when restoring free limits.
    // if (!canAddSession()) {
    //   debugPrint('❌ Free limit reached: cannot add more sessions.');
    //   return;
    // }
    _sessions.insert(0, session);
    _applyMaterialFromSession(session);
    _scheduleSave();
    notifyListeners();
  }
  
  void updateSession(Session session) {
    final index = _sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      // Critical: keep counters stable when editing a session.
      // 1) reverse the previous material impact
      // 2) apply the new one
      final previous = _sessions[index];
      _reverseMaterialFromSession(previous);

      _sessions[index] = session;
      _applyMaterialFromSession(session);
      _scheduleSave();
      notifyListeners();
    }
  }

  void toggleExercisePrecisionEnabled({required String sessionId, required String exerciseId}) {
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

    _sessions[sessionIndex] = Session(
      id: session.id,
      name: session.name,
      date: session.date,
      location: session.location,
      shootingDistance: session.shootingDistance,
      sessionType: session.sessionType,
      exercises: updatedExercises,
      weatherEnabled: session.weatherEnabled,
      temperature: session.temperature,
      wind: session.wind,
      humidity: session.humidity,
      pressure: session.pressure,
      temperatureEnabled: session.temperatureEnabled,
      windEnabled: session.windEnabled,
      humidityEnabled: session.humidityEnabled,
      pressureEnabled: session.pressureEnabled,
      weaponIds: session.weaponIds,
    );

    _scheduleSave();
    notifyListeners();
  }
  
  void _applyMaterialFromSession(Session session) {
    // Update weapon + ammo counters based on attributed impacts.
    for (final exercise in session.exercises) {
      for (final entry in exercise.weaponShotImpact.entries) {
        final weaponIndex = _weapons.indexWhere((w) => w.id == entry.key);
        if (weaponIndex == -1) continue;
        final current = _weapons[weaponIndex];
        _weapons[weaponIndex] = current.copyWith(
          totalRounds: current.totalRounds + entry.value,
          lastUsed: session.date,
          history: [
            ...current.history,
            WeaponHistoryEntry(
              id: '${session.id}-${exercise.id}-tir-${entry.key}',
              date: session.date,
              type: 'tir',
              label: 'Séance : ${session.name}',
              details: '${entry.value} coups',
            ),
          ],
        );
      }

      for (final entry in exercise.ammoShotImpact.entries) {
        final ammoIndex = _ammos.indexWhere((a) => a.id == entry.key);
        if (ammoIndex == -1) continue;
        _ammos[ammoIndex].quantity -= entry.value;
        if (_ammos[ammoIndex].quantity < 0) _ammos[ammoIndex].quantity = 0;
        _ammos[ammoIndex].lastUsed = session.date;
      }

      for (final entry in exercise.equipmentShotImpact.entries) {
        final accIndex = _accessories.indexWhere((a) => a.id == entry.key);
        if (accIndex == -1) continue;
        _accessories[accIndex].lastUsed = session.date;
        _accessories[accIndex].totalRounds += entry.value;
      }
    }
  }

  void _reverseMaterialFromSession(Session session) {
    // Reverse weapon + ammo counters based on exercises.
    // Note: lastUsed is not recalculated here; it is cosmetic and would require a full scan.
    for (final entry in session.weaponImpact.entries) {
      final weaponIndex = _weapons.indexWhere((w) => w.id == entry.key);
      if (weaponIndex == -1) continue;

      final weapon = _weapons[weaponIndex];
      final updatedTotalRounds =
          (weapon.totalRounds - entry.value).clamp(0, 1 << 30);

      var updatedRoundsAtLastCleaning = weapon.roundsAtLastCleaning;
      var updatedRoundsAtLastRevision = weapon.roundsAtLastRevision;

      if (updatedRoundsAtLastCleaning > updatedTotalRounds) {
        updatedRoundsAtLastCleaning = updatedTotalRounds;
      }
      if (updatedRoundsAtLastRevision > updatedTotalRounds) {
        updatedRoundsAtLastRevision = updatedTotalRounds;
      }

      _weapons[weaponIndex] = weapon.copyWith(
        totalRounds: updatedTotalRounds,
        roundsAtLastCleaning: updatedRoundsAtLastCleaning,
        roundsAtLastRevision: updatedRoundsAtLastRevision,
        history: weapon.history.where((h) => !h.id.startsWith('${session.id}-')).toList(),
      );
    }

    for (final entry in session.ammoImpact.entries) {
      final ammoIndex = _ammos.indexWhere((a) => a.id == entry.key);
      if (ammoIndex == -1) continue;
      _ammos[ammoIndex].quantity += entry.value;
    }

    for (final entry in session.equipmentImpact.entries) {
      final accIndex = _accessories.indexWhere((a) => a.id == entry.key);
      if (accIndex == -1) continue;

      final accessory = _accessories[accIndex];
      final updatedTotalRounds =
          (accessory.totalRounds - entry.value).clamp(0, 1 << 30);

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

  void addWeapon(Weapon weapon) {
    if (!canAddWeapon()) {
      debugPrint('❌ Free limit reached: cannot add more weapons.');
      return;
    }
    _weapons.add(weapon);
    _scheduleSave();
    notifyListeners();
  }
  
  void updateWeapon(Weapon weapon) {
    final index = _weapons.indexWhere((w) => w.id == weapon.id);
    if (index != -1) {
      _weapons[index] = weapon;
      _scheduleSave();
      notifyListeners();
    }
  }

  List<Accessory> linkedAccessoriesForWeapon(String weaponId) {
    final weapon = getWeaponById(weaponId);
    if (weapon == null) return const [];
    final ids = weapon.linkedAccessoryIds.toSet();
    return accessories.where((a) => ids.contains(a.id)).toList(growable: false);
  }

  List<Weapon> linkedWeaponsForAccessory(String accessoryId) {
    final accessory = getAccessoryById(accessoryId);
    if (accessory == null) return const [];
    final ids = accessory.linkedWeaponIds.toSet();
    return weapons.where((w) => ids.contains(w.id)).toList(growable: false);
  }

  void linkWeaponToAccessory({
    required String weaponId,
    required String accessoryId,
  }) {
    final wIndex = _weapons.indexWhere((w) => w.id == weaponId);
    final aIndex = _accessories.indexWhere((a) => a.id == accessoryId);
    if (wIndex == -1 || aIndex == -1) return;

    final weapon = _weapons[wIndex];
    final accessory = _accessories[aIndex];

    final weaponLinks = weapon.linkedAccessoryIds.toSet()..add(accessoryId);
    final accessoryLinks = accessory.linkedWeaponIds.toSet()..add(weaponId);

    _weapons[wIndex] = weapon.copyWith(
      linkedAccessoryIds: weaponLinks.toList(growable: false),
    );
    _accessories[aIndex] = accessory.copyWith(
      linkedWeaponIds: accessoryLinks.toList(growable: false),
    );
    _scheduleSave();
    notifyListeners();
  }

  void unlinkWeaponFromAccessory({
    required String weaponId,
    required String accessoryId,
  }) {
    final wIndex = _weapons.indexWhere((w) => w.id == weaponId);
    final aIndex = _accessories.indexWhere((a) => a.id == accessoryId);
    if (wIndex == -1 || aIndex == -1) return;

    final weapon = _weapons[wIndex];
    final accessory = _accessories[aIndex];

    final weaponLinks = weapon.linkedAccessoryIds.toSet()..remove(accessoryId);
    final accessoryLinks = accessory.linkedWeaponIds.toSet()..remove(weaponId);

    _weapons[wIndex] = weapon.copyWith(
      linkedAccessoryIds: weaponLinks.toList(growable: false),
    );
    _accessories[aIndex] = accessory.copyWith(
      linkedWeaponIds: accessoryLinks.toList(growable: false),
    );
    _scheduleSave();
    notifyListeners();
  }
  
  void deleteWeapon(String id) {
    final index = _weapons.indexWhere((w) => w.id == id);
    if (index == -1) return;
    _weapons[index] = _weapons[index].copyWith(
      name: '${_weapons[index].name} (supprimée)', 
      isHidden: true,
    );
    _scheduleSave();
    notifyListeners();
  }
  
  bool duplicateWeapon(Weapon weapon) {
    if (!canAddWeapon()) {
      debugPrint('❌ Free limit reached: cannot duplicate weapon.');
      return false;
    }
    final now = DateTime.now();
    final newWeapon = Weapon(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${weapon.name} (copie)',
      model: weapon.model,
      comment: weapon.comment,
      type: weapon.type,
      caliber: weapon.caliber,
      serialNumber: weapon.serialNumber,
      weight: weapon.weight,
      totalRounds: 0,
      lastCleaned: now,
      lastRevised: now,
      lastUsed: now,
      imageUrl: weapon.imageUrl,
      category: weapon.category,
      documents: weapon.documents,
      history: const [],
      photoPath: weapon.photoPath,
      trackWear: weapon.trackWear,
      trackCleanliness: weapon.trackCleanliness,
      trackRounds: weapon.trackRounds,
      cleaningRoundsThreshold: weapon.cleaningRoundsThreshold,
      wearRoundsThreshold: weapon.wearRoundsThreshold,
      roundsAtLastCleaning: 0,
      roundsAtLastRevision: 0,
    );
    _weapons.add(newWeapon);
    _scheduleSave();
    notifyListeners();
    return true;
  }

  void recordWeaponCleaning(String weaponId) {
    final index = _weapons.indexWhere((w) => w.id == weaponId);
    if (index == -1) return;
    final now = DateTime.now();
    final current = _weapons[index];
    // Important: when recording a cleaning, ONLY reset cleaning-related counters.
    // Keep revision data intact.
    _weapons[index] = current.copyWith(
      lastCleaned: now,
      roundsAtLastCleaning: current.totalRounds,
      // Preserve revision state explicitly (defensive against constructor defaults).
      lastRevised: current.lastRevised,
      roundsAtLastRevision: current.roundsAtLastRevision,
      history: [
        ...current.history,
        WeaponHistoryEntry(
          id: 'entretien-${now.microsecondsSinceEpoch}',
          date: now,
          type: 'entretien',
          label: 'Entretien enregistré',
          details: 'Compteur entretien remis à zéro',
        ),
      ],
    );
    _scheduleSave();
    notifyListeners();
  }

  void recordWeaponRevision(String weaponId) {
    final index = _weapons.indexWhere((w) => w.id == weaponId);
    if (index == -1) return;
    final now = DateTime.now();
    final current = _weapons[index];
    // Important: when recording a revision, ONLY reset revision-related counters.
    // Keep cleaning data intact.
    _weapons[index] = current.copyWith(
      lastRevised: now,
      roundsAtLastRevision: current.totalRounds,
      // Preserve cleaning state explicitly (defensive against constructor defaults).
      lastCleaned: current.lastCleaned,
      roundsAtLastCleaning: current.roundsAtLastCleaning,
      history: [
        ...current.history,
        WeaponHistoryEntry(
          id: 'revision-${now.microsecondsSinceEpoch}',
          date: now,
          type: 'revision',
          label: 'Révision enregistrée',
          details: 'Compteur révision remis à zéro',
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
    _ammos.add(ammo);
    _scheduleSave();
    notifyListeners();
  }
  
  void updateAmmo(Ammo ammo) {
    final index = _ammos.indexWhere((a) => a.id == ammo.id);
    if (index != -1) {
      _ammos[index] = ammo;
      _scheduleSave();
      notifyListeners();
    }
  }
  
  void deleteAmmo(String id) {
    final index = _ammos.indexWhere((a) => a.id == id);
    if (index == -1) return;
    _ammos[index] = _ammos[index].copyWith(
      name: '${_ammos[index].name} (supprimée)', 
      isHidden: true,
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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${ammo.name} (copie)',
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
  
  void deleteAccessory(String id) {
    final index = _accessories.indexWhere((a) => a.id == id);
    if (index == -1) return;
    _accessories[index] = _accessories[index].copyWith(
      name: '${_accessories[index].name} (supprimé)', 
      isHidden: true,
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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '${accessory.name} (copie)',
      brand: accessory.brand,
      model: accessory.model,
      type: accessory.type,
      comment: accessory.comment,
      imageUrl: accessory.imageUrl,
      lastUsed: now,
      totalRounds: 0,
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

    // Reverse material impacts (wear/cleanliness + stock) so critical indicators stay accurate.
    _reverseMaterialFromSession(session);

    _sessions.removeAt(index);
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
    final newSession = Session(
      id: now.millisecondsSinceEpoch.toString(),
      name: '${session.name} (copie)',
      date: now,
      location: session.location,
      shootingDistance: session.shootingDistance,
      sessionType: session.sessionType,
      exercises: copiedExercises,
      weatherEnabled: session.weatherEnabled,
      temperature: session.temperature,
      wind: session.wind,
      humidity: session.humidity,
      pressure: session.pressure,
      temperatureEnabled: session.temperatureEnabled,
      windEnabled: session.windEnabled,
      humidityEnabled: session.humidityEnabled,
      pressureEnabled: session.pressureEnabled,
      weaponIds: List<String>.from(session.weaponIds),
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
  Weapon? getWeaponById(String id) {
    try {
      return _weapons.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
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
  /// Retourne 0.0 pour les jours sans séance avec précision mesurée.
  List<double> get weeklyPrecision {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final dayStart = DateTime(
        now.year, now.month, now.day,
      ).subtract(Duration(days: 6 - i));
      final dayEnd = dayStart.add(const Duration(days: 1));
      final daySessions = _sessions.where((s) =>
        s.date.isAfter(dayStart.subtract(const Duration(milliseconds: 1))) &&
        s.date.isBefore(dayEnd) &&
        s.hasCountedPrecision,
      ).toList();
      if (daySessions.isEmpty) return 0.0;
      final total = daySessions.fold(0.0, (sum, s) => sum + s.averagePrecision);
      return total / daySessions.length;
    });
  }
  // NOTE: domain encrypted file storage is delegated to `_domainStore`.

Map<String, dynamic> _buildDomainDataMap() {
  return {
    'schemaVersion': 1,
    'exerciseTemplates': _exerciseTemplates.map((t) => t.toJson()).toList(),
    'userDocuments': _userDocuments.map((d) => {
      'id': d.id,
      'name': d.name,
      'type': d.type,
      'filePath': d.filePath,
      'addedDate': d.addedDate.toIso8601String(),
    }).toList(),
    'weapons': _weapons.map((w) => {
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
      'lastUsed': w.lastUsed.toIso8601String(),
      'trackWear': w.trackWear,
      'trackCleanliness': w.trackCleanliness,
      'trackRounds': w.trackRounds,
      'cleaningRoundsThreshold': w.cleaningRoundsThreshold,
      'wearRoundsThreshold': w.wearRoundsThreshold,
      'roundsAtLastCleaning': w.roundsAtLastCleaning,
      'roundsAtLastRevision': w.roundsAtLastRevision,
      'documents': w.documents.map((d) => d.toJson()).toList(),
      'history': w.history.map((h) => h.toJson()).toList(),
      'pdfPaths': w.documents.map((d) => d.path).toList(),
      'photoPath': w.photoPath,
      'isHidden': w.isHidden,
      'linkedAccessoryIds': w.linkedAccessoryIds,
    }).toList(),
    'ammos': _ammos.map((a) => {
      'id': a.id,
      'name': a.name,
      'brand': a.brand,
      'caliber': a.caliber,
      'comment': a.comment,
      'projectileType': a.projectileType,
      'quantity': a.quantity,
      'initialQuantity': a.initialQuantity,
      'lastUsed': a.lastUsed.toIso8601String(),
      'trackStock': a.trackStock,
      'lowStockThreshold': a.lowStockThreshold,
      'documents': a.documents.map((d) => d.toJson()).toList(),
      'pdfPaths': a.documents.map((d) => d.path).toList(),
      'photoPath': a.photoPath,
      'isHidden': a.isHidden,
    }).toList(),
    'accessories': _accessories.map((ac) => {
      'id': ac.id,
      'name': ac.name,
      'brand': ac.brand,
      'model': ac.model,
      'comment': ac.comment,
      'type': ac.type,
      'imageUrl': ac.imageUrl,
      'lastUsed': ac.lastUsed.toIso8601String(),
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
      'linkedWeaponIds': ac.linkedWeaponIds,
    }).toList(),
    'sessions': _sessions.map((s) => {
      'id': s.id,
      'name': s.name,
      'date': s.date.toIso8601String(),
      'location': s.location,
      'shootingDistance': s.shootingDistance,
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
      'weaponIds': s.weaponIds,
      'exercises': s.exercises.map((e) => {
        'id': e.id,
        'name': e.name,
        'weaponId': e.weaponId,
        'weaponLabel': e.weaponLabel,
        'ammoId': e.ammoId,
        'ammoLabel': e.ammoLabel,
        'equipmentIds': e.equipmentIds,
        'equipmentId': e.equipmentIds.isEmpty ? null : e.equipmentIds.first,
        'targetName': e.targetName,
        'targetPhotos': e.targetPhotos.map((p) => p.toJson()).toList(),
        'shotsFired': e.shotsFired,
        'distance': e.distance,
        'precision': e.precision,
        'precisionEnabled': e.precisionEnabled,
        'observations': e.observations,
        'weaponAssignments': e.weaponAssignments.map((a) => {
          'weaponId': a.weaponId,
          'weaponLabel': a.weaponLabel,
          'ammoIds': a.ammoIds,
          'accessoryIds': a.accessoryIds,
        }).toList(),
        'shotAllocations': e.shotAllocations.map((a) => {
          'weaponId': a.weaponId,
          'ammoId': a.ammoId,
          'shots': a.shots,
        }).toList(),
        if (e.steps != null)
          'steps': e.steps!.map((st) => st.toJson()).toList(),
      }).toList(),
    }).toList(),
    'diagnostics': _diagnostics.map((d) => {
      'id': d.id,
      'date': d.date.toIso8601String(),
      'weaponId': d.weaponId,
      'responses': d.responses,
      'finalDecision': d.finalDecision,
      'summary': d.summary,
    }).toList(),
  };
}

void _loadDomainDataFromMap(Map<String, dynamic> data) {
  final templatesList = (data['exerciseTemplates'] as List?) ?? const [];
  _exerciseTemplates = templatesList
      .whereType<Map>()
      .map((t) => ExerciseTemplate.fromJson(t.cast<String, dynamic>()))
      .toList();

  final userDocsList = (data['userDocuments'] as List?) ?? const [];
  _userDocuments = userDocsList
      .whereType<Map>()
      .map((d) => UserDocument.fromJson(d.cast<String, dynamic>()))
      .toList();

  final weaponsList = (data['weapons'] as List?) ?? const [];
  _weapons = weaponsList.map((w) => Weapon(
    id: w['id'],
    name: w['name'],
    model: w['model'],
    comment: (w['comment'] ?? '') as String,
    type: _migrateWeaponType((w['type'] ?? 'Arme') as String),
    caliber: w['caliber'],
    serialNumber: w['serialNumber'],
    weight: (w['weight'] as num).toDouble(),
    totalRounds: w['totalRounds'],
    lastCleaned: DateTime.parse(w['lastCleaned']),
    lastRevised: w['lastRevised'] != null
        ? DateTime.parse(w['lastRevised'])
        : DateTime.parse(w['lastCleaned']),
    lastUsed: DateTime.parse(w['lastUsed']),
    trackWear: w['trackWear'] ?? true,
    trackCleanliness: w['trackCleanliness'] ?? true,
    trackRounds: w['trackRounds'] ?? true,
    cleaningRoundsThreshold: w['cleaningRoundsThreshold'] ?? 500,
    wearRoundsThreshold: w['wearRoundsThreshold'] ?? 10000,
    roundsAtLastCleaning: _migrateRoundsAtLastCleaning(w),
    roundsAtLastRevision: _migrateRoundsAtLastRevision(w),
    documents: _decodeItemDocuments(w['documents'] ?? w['pdfPaths'] ?? const []),
    history: ((w['history'] as List?) ?? const [])
        .map((h) => WeaponHistoryEntry.fromJson(h))
        .toList(),
    photoPath: w['photoPath'],
    isHidden: w['isHidden'] ?? false,
    linkedAccessoryIds: ((w['linkedAccessoryIds'] as List?) ?? const [])
        .whereType<String>()
        .toList(),
  )).toList();

  final ammosList = (data['ammos'] as List?) ?? const [];
  _ammos = ammosList.map((a) {
    final qty = (a['quantity'] ?? 0) as int;
    final rawInitial = (a['initialQuantity'] ?? a['quantity'] ?? 0) as int;
    final effectiveInitial = (rawInitial <= 0 && qty > 0) ? qty : rawInitial;

    return Ammo(
      id: a['id'],
      name: a['name'],
      brand: a['brand'],
      caliber: a['caliber'],
      comment: (a['comment'] ?? '') as String,
      projectileType: (a['projectileType'] ?? a['bulletType'] ?? '') as String,
      quantity: qty,
      initialQuantity: effectiveInitial,
      lastUsed: DateTime.parse(a['lastUsed']),
      trackStock: a['trackStock'] ?? true,
      lowStockThreshold: a['lowStockThreshold'] ?? 50,
      documents: _decodeItemDocuments(a['documents'] ?? a['pdfPaths'] ?? const []),
      photoPath: a['photoPath'],
      isHidden: a['isHidden'] ?? false,
    );
  }).toList();

  final accessoriesList = (data['accessories'] as List?) ?? const [];
  _accessories = accessoriesList.map((ac) {
    final lastUsed = DateTime.parse(ac['lastUsed']);
    final totalRounds = (ac['totalRounds'] ?? 0) as int;
    final lastCleaned = ac['lastCleaned'] != null
        ? DateTime.parse(ac['lastCleaned'])
        : lastUsed;
    final lastRevised = ac['lastRevised'] != null
        ? DateTime.parse(ac['lastRevised'])
        : lastCleaned;

    final roundsAtLastCleaning =
        (ac['roundsAtLastCleaning'] as num?)?.toInt() ?? totalRounds;
    final roundsAtLastRevision =
        (ac['roundsAtLastRevision'] as num?)?.toInt() ?? totalRounds;

    return Accessory(
      id: ac['id'],
      name: ac['name'],
      brand: (ac['brand'] ?? '') as String,
      model: (ac['model'] ?? '') as String,
      comment: (ac['comment'] ?? '') as String,
      type: (ac['type'] ?? '') as String,
      imageUrl: (ac['imageUrl'] ?? '') as String,
      lastUsed: lastUsed,
      totalRounds: totalRounds,
      lastCleaned: lastCleaned,
      lastRevised: lastRevised,
      trackWear: (ac['trackWear'] ?? false) as bool,
      trackCleanliness: (ac['trackCleanliness'] ?? false) as bool,
      cleaningRoundsThreshold: (ac['cleaningRoundsThreshold'] as num?)?.toInt() ?? 500,
      wearRoundsThreshold: (ac['wearRoundsThreshold'] as num?)?.toInt() ?? 10000,
      roundsAtLastCleaning: roundsAtLastCleaning,
      roundsAtLastRevision: roundsAtLastRevision,
      batteryChangedAt: ac['batteryChangedAt'] != null
          ? DateTime.parse(ac['batteryChangedAt'])
          : null,
      trackBattery: (ac['trackBattery'] ?? false) as bool,
      documents: _decodeItemDocuments(ac['documents'] ?? const []),
      photoPath: ac['photoPath'] as String?,
      isHidden: (ac['isHidden'] ?? false) as bool,
      linkedWeaponIds: ((ac['linkedWeaponIds'] as List?) ?? const [])
          .whereType<String>()
          .toList(),
    );
  }).toList();

  final sessionsList = (data['sessions'] as List?) ?? const [];
  _sessions = sessionsList.map((s) {
    final exercisesList = (s['exercises'] as List?) ?? const [];
    final exercises = exercisesList.map((raw) {
      final e = raw as Map;
      final stepsRaw = (e['steps'] as List?) ?? const [];
      final assignmentsRaw = (e['weaponAssignments'] as List?) ?? const [];
      final shotAllocationsRaw = (e['shotAllocations'] as List?) ?? const [];

      return Exercise(
        id: e['id'],
        name: (e['name'] ?? '') as String,
        weaponId: e['weaponId'],
        weaponLabel: (e['weaponLabel'] as String?),
        ammoId: e['ammoId'],
        ammoLabel: (e['ammoLabel'] as String?),
        equipmentIds: _decodeEquipmentIds(e),
        targetName: e['targetName'],
        targetPhotos: ((e['targetPhotos'] as List?) ?? const [])
            .map((p) => ExercisePhoto.fromJson(Map<String, dynamic>.from(p as Map)))
            .toList(),
        shotsFired: e['shotsFired'],
        distance: e['distance'],
        precision: e['precision'] != null ? (e['precision'] as num).toDouble() : null,
        precisionEnabled: (e['precisionEnabled'] ?? true) as bool,
        observations: e['observations'] ?? '',
        weaponAssignments: assignmentsRaw
            .whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m))
            .map((m) => ExerciseWeaponAssignment(
                  weaponId: (m['weaponId'] ?? '') as String,
                  weaponLabel: m['weaponLabel'] as String?,
                  ammoIds: ((m['ammoIds'] as List?) ?? const [])
                      .whereType<String>()
                      .toList(),
                  accessoryIds: ((m['accessoryIds'] as List?) ?? const [])
                      .whereType<String>()
                      .toList(),
                ))
            .where((a) => a.weaponId.trim().isNotEmpty)
            .toList(),
        shotAllocations: shotAllocationsRaw
            .whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m))
            .map((m) => ExerciseShotAllocation(
                  weaponId: (m['weaponId'] ?? '') as String,
                  ammoId: (m['ammoId'] ?? '') as String,
                  shots: (m['shots'] as num?)?.toInt() ?? 0,
                ))
            .where((a) =>
                a.weaponId.trim().isNotEmpty &&
                a.ammoId.trim().isNotEmpty &&
                a.shots > 0)
            .toList(),
        steps: stepsRaw
            .whereType<Map>()
            .map((m) => ExerciseStep.fromJson(Map<String, dynamic>.from(m)))
            .toList(),
      );
    }).toList();

    return Session(
      id: s['id'],
      name: s['name'],
      date: DateTime.parse(s['date']),
      location: s['location'],
      shootingDistance: s['shootingDistance'],
      sessionType: s['sessionType'],
      weatherEnabled: s['weatherEnabled'],
      temperature: s['temperature'] ?? '',
      wind: s['wind'] ?? '',
      humidity: s['humidity'] ?? '',
      pressure: s['pressure'] ?? '',
      temperatureEnabled: s['temperatureEnabled'] ?? true,
      windEnabled: s['windEnabled'] ?? true,
      humidityEnabled: s['humidityEnabled'] ?? true,
      pressureEnabled: s['pressureEnabled'] ?? true,
      weaponIds: ((s['weaponIds'] as List?) ?? const [])
          .whereType<String>()
          .toList(),
      exercises: exercises,
    );
  }).toList();

  final diagnosticsList = (data['diagnostics'] as List?) ?? const [];
  _diagnostics = diagnosticsList.map((d) => Diagnostic(
    id: d['id'],
    date: DateTime.parse(d['date']),
    weaponId: d['weaponId'],
    responses: Map<String, dynamic>.from(d['responses']),
    finalDecision: d['finalDecision'],
    summary: d['summary'],
  )).toList();
}
  // Local Storage Methods
  void _scheduleSave() {
  _saveDebounce?.cancel();
  _saveDebounce = Timer(const Duration(milliseconds: 400), _saveToLocal);
}
Future<void> _saveToLocal() async {
  try {
    final prefs = await SharedPreferences.getInstance();

    // Check recent achievements
    _checkAchievements();
    
    // Save achievements
    await prefs.setStringList('thot_unlocked_achievements', _unlockedAchievements.toList());
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
    await prefs.setString('dateFormatPreference', _dateFormatPreference);
    await prefs.setString('themeMode', _themeMode.toString());
    await prefs.setStringList('quickActions', _quickActions);
    await prefs.setString('localeCode', _localeCode ?? '');

    final data = _buildDomainDataMap();
    final rawJson = jsonEncode(data);

    if (kIsWeb) {
      await prefs.setString('thot_domain_data', rawJson);
    } else {
      await _domainStore.writeDomainData(rawJson);
    }

    if (kDebugMode) {
      unawaited(MaintenanceNotifications.checkAndNotify(_weapons.where((w) => !w.isHidden).toList()));
      debugPrint('Data saved to local storage.');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Error saving local data.');
    }
  }
}

Future<void> _loadFromLocal() async {
  try {
    final prefs = await SharedPreferences.getInstance();

    final unlockedList = prefs.getStringList('thot_unlocked_achievements') ?? [];
    _unlockedAchievements = unlockedList.toSet();
    // Load unlock dates
    _achievementUnlockDates = {};
    final rawDates = prefs.getStringList('thot_unlocked_achievement_dates') ?? const [];
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
    _userName = prefs.getString('userName') ?? '';
    _licenseNumber = prefs.getString('licenseNumber') ?? '';
    _userEmail = prefs.getString('userEmail') ?? '';
    _useMetric = prefs.getBool('useMetric') ?? true;
    _dateFormatPreference =
        prefs.getString('dateFormatPreference') ?? 'day_month_year';
    _premiumService.loadMetadataFromPrefs(prefs);

    final themeModeStr = prefs.getString('themeMode');
    if (themeModeStr != null) {
      _themeMode =
          themeModeStr.contains('dark') ? ThemeMode.dark : ThemeMode.light;
    }

    _quickActions = prefs.getStringList('quickActions') ??
        ['new_session', 'new_weapon', 'new_ammo', 'toggle_theme'];

    Map<String, dynamic>? domainData;

    if (kIsWeb) {
      final raw = prefs.getString('thot_domain_data');
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          domainData = decoded;
        }
      }
} else {
  domainData = await _domainStore.readDomainData();
}

    if (domainData != null) {
      _loadDomainDataFromMap(domainData);
    } else {
      // fallback legacy SharedPreferences migration
      final legacyData = <String, dynamic>{};

      final userDocsStr = prefs.getString('userDocuments');
      if (userDocsStr != null && userDocsStr.isNotEmpty) {
        legacyData['userDocuments'] = jsonDecode(userDocsStr);
      }

      final weaponsStr = prefs.getString('weapons');
      if (weaponsStr != null && weaponsStr.isNotEmpty) {
        legacyData['weapons'] = jsonDecode(weaponsStr);
      }

      final ammosStr = prefs.getString('ammos');
      if (ammosStr != null && ammosStr.isNotEmpty) {
        legacyData['ammos'] = jsonDecode(ammosStr);
      }

      final accessoriesStr = prefs.getString('accessories');
      if (accessoriesStr != null && accessoriesStr.isNotEmpty) {
        legacyData['accessories'] = jsonDecode(accessoriesStr);
      }

      final sessionsStr = prefs.getString('sessions');
      if (sessionsStr != null && sessionsStr.isNotEmpty) {
        legacyData['sessions'] = jsonDecode(sessionsStr);
      }

      final diagnosticsStr = prefs.getString('diagnostics');
      if (diagnosticsStr != null && diagnosticsStr.isNotEmpty) {
        legacyData['diagnostics'] = jsonDecode(diagnosticsStr);
      }

      _loadDomainDataFromMap(legacyData);

      // migration immédiate vers le nouveau stockage
      await _saveToLocal();
    }

    if (kDebugMode) {
      debugPrint('Data loaded from local storage.');
    }
    notifyListeners();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Error loading local data.');
    }
    _userDocuments = [];
    _weapons = [];
    _ammos = [];
    _accessories = [];
    _sessions = [];
    _diagnostics = [];
    notifyListeners();
  }
}

  List<ItemDocument> _decodeItemDocuments(dynamic raw) {
    try {
      if (raw is List) {
        final docs = raw.map(ItemDocument.fromJson).where((d) => d.path.isNotEmpty).toList();
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
        return rawList.whereType<String>().where((id) => id.trim().isNotEmpty).toList();
      }

      // Backward compatibility: older builds stored a single equipmentId
      final legacy = exerciseJson['equipmentId'];
      if (legacy is String && legacy.trim().isNotEmpty) return [legacy];
    } catch (e) {
      debugPrint('Failed to decode equipmentIds: $e');
    }
    return const [];
  }

  int _migrateRoundsAtLastCleaning(dynamic weaponJson) {
    try {
      if (weaponJson is Map && weaponJson['roundsAtLastCleaning'] != null) {
        return (weaponJson['roundsAtLastCleaning'] as num).toInt();
      }

      // Legacy migration from normalized cleanlinessLevel (1.0 = clean, 0.0 = dirty)
      if (weaponJson is Map && weaponJson['cleanlinessLevel'] != null) {
        final totalRounds = (weaponJson['totalRounds'] as num?)?.toInt() ?? 0;
        final threshold = (weaponJson['cleaningRoundsThreshold'] as num?)?.toInt() ?? 500;
        final cleanlinessLevel = (weaponJson['cleanlinessLevel'] as num).toDouble();
        final dirtProgress = (1.0 - cleanlinessLevel).clamp(0.0, 1.0);
        final roundsSince = (dirtProgress * threshold).round();
        return (totalRounds - roundsSince).clamp(0, 1 << 30);
      }
    } catch (e) {
      debugPrint('Failed to migrate roundsAtLastCleaning: $e');
    }
    final totalRounds = (weaponJson is Map && weaponJson['totalRounds'] != null)
        ? (weaponJson['totalRounds'] as num).toInt()
        : 0;
    return totalRounds;
  }

  int _migrateRoundsAtLastRevision(dynamic weaponJson) {
    try {
      if (weaponJson is Map && weaponJson['roundsAtLastRevision'] != null) {
        return (weaponJson['roundsAtLastRevision'] as num).toInt();
      }

      // Legacy migration from normalized wearLevel (0.0 = new, 1.0 = worn)
      if (weaponJson is Map && weaponJson['wearLevel'] != null) {
        final totalRounds = (weaponJson['totalRounds'] as num?)?.toInt() ?? 0;
        final threshold = (weaponJson['wearRoundsThreshold'] as num?)?.toInt() ?? 10000;
        final wearLevel = (weaponJson['wearLevel'] as num).toDouble().clamp(0.0, 1.0);
        final roundsSince = (wearLevel * threshold).round();
        return (totalRounds - roundsSince).clamp(0, 1 << 30);
      }
    } catch (e) {
      debugPrint('Failed to migrate roundsAtLastRevision: $e');
    }
    final totalRounds = (weaponJson is Map && weaponJson['totalRounds'] != null)
        ? (weaponJson['totalRounds'] as num).toInt()
        : 0;
    return totalRounds;
  }

  String _migrateWeaponType(String raw) {
    if (raw == _weaponTypePistolSemiAutomatiqueLegacy) return _weaponTypePistolSemiAuto;
    return raw;
  }

Future<void> restoreFromCloud() async {
  // Désactivé : pas de restauration cloud applicative dans THOT.
}

  Future<void> lockSession() async {
    await _securityService.lockSession();
  }

  Future<bool> verifyPin(String enteredPin) async {
    return _securityService.verifyPin(enteredPin);
  }
  Future<bool> authenticateWithBiometric() async {
    return _securityService.authenticateWithBiometric();
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
  
  Future<void> logout() async {
    await _securityService.logout();
  }
}
