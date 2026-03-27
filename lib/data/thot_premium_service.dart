import 'package:flutter/foundation.dart' show VoidCallback, kDebugMode, kIsWeb, debugPrint;
import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThotPremiumService {
  ThotPremiumService({required VoidCallback onChanged}) : _onChanged = onChanged;

  static const String proEntitlementId = 'THOT Pro';
  static const String _lastPremiumValidationAtKey = 'last_premium_validation_at';

  // Grace period: offline fallback.
  static const Duration _premiumGracePeriod = Duration(days: 35);

  final VoidCallback _onChanged;

  bool _purchaseAvailable = false;
  bool _purchasePending = false;
  String? _purchaseError;

  bool _isPremium = false;
  String? _lastPremiumValidationAt;
  bool _allowGracePeriodFallback = true;

  bool get purchaseAvailable => _purchaseAvailable;
  bool get purchasePending => _purchasePending;
  String? get purchaseError => _purchaseError;

  // Localized prices from the current store offering
  String? _yearlyPrice;
  String? _monthlyPrice;

  String? get yearlyPrice => _yearlyPrice;
  String? get monthlyPrice => _monthlyPrice;

  Future<void> purchaseYearly() => _purchase(PackageType.annual);
  Future<void> purchaseMonthly() => _purchase(PackageType.monthly);

  Future<void> _purchase(PackageType type) async {
    if (kIsWeb) return;

    try {
      _purchaseError = null;
      _purchasePending = true;
      _onChanged();

      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) {
        throw StateError('No current offering');
      }

      final package =
          current.availablePackages.where((p) => p.packageType == type).firstOrNull;
      if (package == null) {
        throw StateError('No package found for $type');
      }

      final result = await Purchases.purchasePackage(package);
      // Refresh cached prices in case something changed on the store side
      await _loadCurrentOfferingPrices();
      await _updatePremiumStatus(result.customerInfo);
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode != PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('❌ RevenueCat purchase failed: $e');
        _purchaseError = e.toString();
      }
    } catch (e) {
      debugPrint('❌ RevenueCat purchase failed: $e');
      _purchaseError = e.toString();
    } finally {
      _purchasePending = false;
      _onChanged();
    }
  }

  bool _isWithinGracePeriod() {
    if (_lastPremiumValidationAt == null || _lastPremiumValidationAt!.isEmpty) return false;
    final date = DateTime.tryParse(_lastPremiumValidationAt!);
    if (date == null) return false;
    return DateTime.now().difference(date) < _premiumGracePeriod;
  }

  bool get isPremium => _isPremium || (_allowGracePeriodFallback && _isWithinGracePeriod());

  void loadMetadataFromPrefs(SharedPreferences prefs) {
    _lastPremiumValidationAt = prefs.getString(_lastPremiumValidationAtKey);
    _isPremium = false;
    _allowGracePeriodFallback = true;
  }

  Future<void> init() async {
    try {
      if (kIsWeb) {
        _purchaseAvailable = false;
        _onChanged();
        return;
      }

      _purchaseAvailable = true;

      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _updatePremiumStatus(customerInfo);
      });

      final prefs = await SharedPreferences.getInstance();
      loadMetadataFromPrefs(prefs);

      // Prefetch current offerings to expose localized prices
      await _loadCurrentOfferingPrices();

      final customerInfo = await Purchases.getCustomerInfo();
      await _updatePremiumStatus(customerInfo);

      _onChanged();
    } catch (e) {
      debugPrint('❌ Failed to init RevenueCat: $e');
      _purchaseError = e.toString();
      _purchaseAvailable = false;
      _allowGracePeriodFallback = true;
      _onChanged();
    }
  }

  Future<void> restorePurchases() async {
    try {
      _purchaseError = null;
      _purchasePending = true;
      _onChanged();

      final customerInfo = await Purchases.restorePurchases();
      await _updatePremiumStatus(customerInfo);
    } catch (e) {
      debugPrint('❌ RevenueCat restore failed: $e');
      _purchaseError = e.toString();
    } finally {
      _purchasePending = false;
      _onChanged();
    }
  }

  Future<void> _updatePremiumStatus(CustomerInfo customerInfo) async {
    final isPro = customerInfo.entitlements.all[proEntitlementId]?.isActive ?? false;

    if (isPro) {
      _isPremium = true;
      _lastPremiumValidationAt = DateTime.now().toIso8601String();
      _allowGracePeriodFallback = true;
      await _persistPremiumMetadata();
    } else {
      _isPremium = false;
      _lastPremiumValidationAt = null;
      _allowGracePeriodFallback = false;
      await _persistPremiumMetadata();
    }

    _purchasePending = false;
    _purchaseError = null;

    if (kDebugMode) {
      debugPrint('✅ Premium status updated: isPremium=$isPremium');
    }

    _onChanged();
  }

  Future<void> _persistPremiumMetadata() async {
    final prefs = await SharedPreferences.getInstance();
    if (_lastPremiumValidationAt == null) {
      await prefs.remove(_lastPremiumValidationAtKey);
    } else {
      await prefs.setString(_lastPremiumValidationAtKey, _lastPremiumValidationAt!);
    }
  }

  Future<void> _loadCurrentOfferingPrices() async {
    try {
      if (kIsWeb) {
        _yearlyPrice = null;
        _monthlyPrice = null;
        return;
      }

      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) {
        _yearlyPrice = null;
        _monthlyPrice = null;
        return;
      }

      final yearlyPackage = current.availablePackages
          .where((p) => p.packageType == PackageType.annual)
          .firstOrNull;
      final monthlyPackage = current.availablePackages
          .where((p) => p.packageType == PackageType.monthly)
          .firstOrNull;

      _yearlyPrice = yearlyPackage?.storeProduct.priceString;
      _monthlyPrice = monthlyPackage?.storeProduct.priceString;

      if (kDebugMode) {
        debugPrint('💰 Loaded prices: yearly=$_yearlyPrice, monthly=$_monthlyPrice');
      }
    } catch (e) {
      // Non bloquant : en cas d’erreur on garde simplement les valeurs nulles
      debugPrint('⚠️ Failed to load offering prices: $e');
      _yearlyPrice = null;
      _monthlyPrice = null;
    }
  }

  Future<void> clearLocalCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastPremiumValidationAtKey);
    _isPremium = false;
    _lastPremiumValidationAt = null;
    _allowGracePeriodFallback = false;
    _purchasePending = false;
    _purchaseError = null;
    _onChanged();
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
