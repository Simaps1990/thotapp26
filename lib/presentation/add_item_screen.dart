import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform, Uint8List;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import '../data/thot_provider.dart';
import '../data/models.dart';
import '../theme.dart';
import '../widgets/cross_platform_image.dart';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/utils/app_date_formats.dart';
import 'package:thot/utils/image_storage.dart';
import 'package:thot/utils/web_document_opener.dart';
import 'package:thot/utils/native_picker.dart';

class AddItemScreen extends StatefulWidget {
  final String? itemId;
  final String? itemType;

  const AddItemScreen({Key? key, this.itemId, this.itemType}) : super(key: key);

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _ItemDocumentDraft {
  final PlatformFile file;
  final String name;
  final String type;
  final DateTime? expiryDate;
  final int notifyBeforeDays;

  const _ItemDocumentDraft({
    required this.file,
    required this.name,
    required this.type,
    this.expiryDate,
    this.notifyBeforeDays = 0,
  });
}

class _DocumentDetails {
  final String name;
  final String type;
  final DateTime? expiryDate;
  final int notifyBeforeDays;

  const _DocumentDetails({
    required this.name,
    required this.type,
    this.expiryDate,
    this.notifyBeforeDays = 0,
  });
}

class MaintenancePreset {
  const MaintenancePreset({
    required this.cleaningInterval,
    required this.revisionInterval,
  });

  final int cleaningInterval;
  final int revisionInterval;
}

MaintenancePreset maintenancePresetFor({
  required String type,
  required String caliber,
}) {
  final normalizedType = type.toLowerCase().trim();
  final normalizedCaliber = caliber.toLowerCase().trim();

  if (normalizedCaliber.contains('22lr') ||
      normalizedCaliber.contains('.22') ||
      normalizedCaliber.contains('22 lr')) {
    return const MaintenancePreset(
      cleaningInterval: 1000,
      revisionInterval: 50000,
    );
  }
  if (normalizedCaliber.contains('9mm') || normalizedCaliber.contains('9 mm')) {
    return const MaintenancePreset(
      cleaningInterval: 500,
      revisionInterval: 15000,
    );
  }
  if (normalizedCaliber.contains('.223') ||
      normalizedCaliber.contains('223') ||
      normalizedCaliber.contains('5.56') ||
      normalizedCaliber.contains('5,56')) {
    return const MaintenancePreset(
      cleaningInterval: 500,
      revisionInterval: 10000,
    );
  }
  if (normalizedCaliber.contains('.308') ||
      normalizedCaliber.contains('308') ||
      normalizedCaliber.contains('7.62') ||
      normalizedCaliber.contains('7,62')) {
    return const MaintenancePreset(
      cleaningInterval: 400,
      revisionInterval: 8000,
    );
  }
  if (normalizedCaliber.contains('12 gauge') ||
      normalizedCaliber.contains('calibre 12') ||
      normalizedCaliber == '12') {
    return const MaintenancePreset(
      cleaningInterval: 250,
      revisionInterval: 8000,
    );
  }
  if (normalizedCaliber.contains('.50') ||
      normalizedCaliber.contains('50 bmg')) {
    return const MaintenancePreset(
      cleaningInterval: 100,
      revisionInterval: 1000,
    );
  }
  if (normalizedType.contains('airsoft') ||
      normalizedCaliber.contains('airsoft')) {
    return const MaintenancePreset(
      cleaningInterval: 5000,
      revisionInterval: 20000,
    );
  }

  return const MaintenancePreset(
    cleaningInterval: 500,
    revisionInterval: 10000,
  );
}

class _AddItemScreenState extends State<AddItemScreen> {
  String _selectedCategory =
      'PLATEFORME'; // PLATEFORME, CONSOMMABLE, ACCESSOIRE
  bool _isEditMode = false;
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _caliberController = TextEditingController();
  final _serialController = TextEditingController();
  final _weightController = TextEditingController();
  final _initialRoundsController = TextEditingController(text: "0");
  final _typeController = TextEditingController();
  final _ammoTypeController = TextEditingController();
  final _quantityController = TextEditingController(text: "0");
  final _unitPriceController = TextEditingController();
  String _selectedCurrency = 'EUR';
  final _commentController = TextEditingController();
  final _lowStockThresholdController = TextEditingController(text: "50");
  final _cleaningRoundsThresholdController = TextEditingController(text: "500");
  final _wearRoundsThresholdController = TextEditingController(text: "10000");

  String? _photoPath;
  Uint8List? _photoBytes; // For web platform
  List<_ItemDocumentDraft> _documents = [];

  static const List<String> _documentTypes = [
    'Facture',
    'Révision',
    'Manuel',
    'Garantie',
    'Autre',
  ];

  static const List<String> _accessoryTypes = [
    'Optiques',
    'Lampes',
    'Lasers',
    'Holsters',
    'Sangles',
    'Chargeurs',
    'Porte-chargeurs',
    'Nettoyage',
    'SUPP',
    'Compensateurs',
    'Poignées',
    'Bipieds',
    'Montages',
    'Visée mécanique',
    'Crosses',
    'Détentes',
    'Pièces internes',
    'Transport',
    'Sécurité',
    'Protections',
    'Chronographes',
    'Timers',
    'Cibles',
    'Supports de tir',
    'Outils',
    'Divers',
  ];

  static const List<String> _platformTypes = [
    'PA',
    'Révolver',
    'PM',
    'FA',
    'FM',
    'Carabine',
    'FAP',
    'Fusil de chasse',
    'FP',
    'Autre',
  ];

  static const List<String> _ammoProjectileTypes = [
    'FMJ',
    'TMJ',
    'Pointe creuse (JHP)',
    'Gold Dot',
    'Soft Point',
    'Plomb',
    'Subsonique',
    'Traçante',
    'Autre',
  ];

  List<String> getDocumentTypes(BuildContext context) {
    final strings = AppStrings.of(context);
    return [
      strings.documentTypeInvoice,
      strings.documentTypeRevision,
      strings.documentTypeMaintenance,
      strings.documentTypeManual,
      strings.documentTypeWarranty,
      strings.documentTypeOther,
    ];
  }

  List<String> getAccessoryTypes(BuildContext context) {
    final strings = AppStrings.of(context);
    return [
      strings.accessoryTypeOptics,
      strings.accessoryTypeLights,
      strings.accessoryTypeLasers,
      strings.accessoryTypeHolsters,
      strings.accessoryTypeSlings,
      strings.accessoryTypeMagazines,
      strings.accessoryTypeMagazinePouches,
      strings.accessoryTypeCleaning,
      strings.accessoryTypeSuppressor,
      strings.accessoryTypeCompensators,
      strings.accessoryTypeGrips,
      strings.accessoryTypeBipods,
      strings.accessoryTypeMounts,
      strings.accessoryTypeIronSights,
      strings.accessoryTypeStocks,
      strings.accessoryTypeTriggers,
      strings.accessoryTypeInternalParts,
      strings.accessoryTypeTransport,
      strings.accessoryTypeSafety,
      strings.accessoryTypeProtection,
      strings.accessoryTypeChronographs,
      strings.accessoryTypeTimers,
      strings.accessoryTypeTargets,
      strings.accessoryTypeShootingStands,
      strings.accessoryTypeTools,
      strings.accessoryTypeMisc,
    ];
  }

  List<String> getPlatformTypes(BuildContext context) {
    final strings = AppStrings.of(context);
    return [
      strings.platformTypePA,
      strings.platformTypeRevolver,
      strings.platformTypePM,
      strings.platformTypeFA,
      strings.platformTypeFM,
      strings.platformTypeCarbine,
      strings.platformTypeFAP,
      strings.platformTypeShotgun,
      strings.platformTypeFP,
      strings.platformTypeOther,
    ];
  }

  List<String> getAmmoProjectileTypes(BuildContext context) {
    final strings = AppStrings.of(context);
    return [
      strings.ammoTypeFMJ,
      strings.ammoTypeTMJ,
      strings.ammoTypeJHP,
      strings.ammoTypeGoldDot,
      strings.ammoTypeSoftPoint,
      strings.ammoTypeLead,
      strings.ammoTypeSubsonic,
      strings.ammoTypeTracer,
      strings.documentTypeOther,
    ];
  }

  String _selectedAccessoryType = _accessoryTypes.first;
  bool _isAccessoryTypeCustom = false;

  String _selectedPlatformType = _platformTypes.first;

  String _selectedAmmoProjectileType = _ammoProjectileTypes.first;
  bool _isAmmoProjectileTypeCustom = false;

  // Tracking toggles
  bool _trackWear = true;
  bool _trackCleanliness = true;
  bool _trackRounds = true;
  bool _trackStock = true;
  bool _trackBattery = false;
  DateTime? _batteryChangedAt;

  static const Set<String> _accessoryWearEnabledTypes = {
    'Optiques',
    'Lampes',
    'Lasers',
    'SUPP',
    'Compensateurs',
    'Montages',
    'Détentes',
    'Pièces internes',
  };

  static const Set<String> _accessoryCleanlinessEnabledTypes = {
    'SUPP',
    'Compensateurs',
  };

  static const Set<String> _accessoryBatteryEnabledTypes = {
    'Optiques',
    'Lampes',
    'Lasers',
    'Chronographes',
    'Timers',
  };

  String get _trackingAccessoryType =>
      _isAccessoryTypeCustom ? '__custom__' : _selectedAccessoryType.trim();

  bool _canTrackAccessoryWear(String type) {
    return type == '__custom__' ||
        type == 'Divers' ||
        _accessoryWearEnabledTypes.contains(type);
  }

  bool _canTrackAccessoryCleanliness(String type) {
    return type == '__custom__' ||
        type == 'Divers' ||
        _accessoryCleanlinessEnabledTypes.contains(type);
  }

  bool _canTrackAccessoryBattery(String type) {
    return type == '__custom__' ||
        type == 'Divers' ||
        _accessoryBatteryEnabledTypes.contains(type);
  }

  bool _shouldShowTrackingOptions() {
    if (_selectedCategory == 'PLATEFORME') {
      return _trackWear || _trackCleanliness || _trackRounds;
    }
    if (_selectedCategory == 'CONSOMMABLE') {
      return _trackStock;
    }
    if (_selectedCategory == 'ACCESSOIRE') {
      final batteryEligible = _canTrackAccessoryBattery(_trackingAccessoryType);
      final wearEligible = _canTrackAccessoryWear(_trackingAccessoryType);
      final cleanlinessEligible = _canTrackAccessoryCleanliness(
        _trackingAccessoryType,
      );
      return (batteryEligible && _trackBattery) ||
          (wearEligible && _trackWear) ||
          (cleanlinessEligible && _trackCleanliness);
    }
    return false;
  }

  void _applyRecommendedMaintenancePresetIfDefault() {
    if (_selectedCategory != 'PLATEFORME') return;
    final cleaningValue = _cleaningRoundsThresholdController.text.trim();
    final revisionValue = _wearRoundsThresholdController.text.trim();
    if (cleaningValue != '500' || revisionValue != '10000') return;

    final preset = maintenancePresetFor(
      type: _selectedPlatformType,
      caliber: _caliberController.text,
    );
    _cleaningRoundsThresholdController.text = preset.cleaningInterval
        .toString();
    _wearRoundsThresholdController.text = preset.revisionInterval.toString();
  }

  final _primaryNameFieldKey = GlobalKey();
  final _caliberFieldKey = GlobalKey();
  final _platformTypeFieldKey = GlobalKey();
  final _ammoQuantityFieldKey = GlobalKey();
  final _accessoryTypeFieldKey = GlobalKey();
  final _batteryDateFieldKey = GlobalKey();

  bool _primaryNameError = false;
  bool _caliberError = false;
  bool _platformTypeError = false;
  bool _ammoQuantityError = false;
  bool _accessoryTypeError = false;
  bool _batteryDateError = false;
  final Set<String> _linkedAccessoryIds = {};
  final Set<String> _linkedPlatformIds = {};

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.itemId != null;
    if (_isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadItem();
      });
    }
    if (widget.itemType != null) {
      _selectedCategory = widget.itemType!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _caliberController.dispose();
    _serialController.dispose();
    _weightController.dispose();
    _initialRoundsController.dispose();
    _typeController.dispose();
    _ammoTypeController.dispose();
    _quantityController.dispose();
    _unitPriceController.dispose();
    _commentController.dispose();
    _lowStockThresholdController.dispose();
    _cleaningRoundsThresholdController.dispose();
    _wearRoundsThresholdController.dispose();
    super.dispose();
  }

  void _loadItem() {
    final provider = Provider.of<ThotProvider>(context, listen: false);

    if (_selectedCategory == 'PLATEFORME') {
      final platform = provider.platforms
          .where((w) => w.id == widget.itemId)
          .firstOrNull;
      if (platform == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.of(context).itemNotFound),
            duration: const Duration(seconds: 3),
          ),
        );
        context.pop();
        return;
      }
      setState(() {
        _nameController.text = platform.name;
        _brandController.text = platform.model;
        _caliberController.text = platform.caliber;
        _serialController.text = platform.serialNumber;
        _weightController.text = platform.weight == 0
            ? ''
            : platform.weight.toString();
        _initialRoundsController.text = platform.totalRounds.toString();
        _commentController.text = platform.comment;
        _selectedPlatformType = _platformTypes.contains(platform.type)
            ? platform.type
            : _platformTypes.first;
        _photoPath = platform.photoPath;
        _documents = platform.documents
            .map(
              (d) => _ItemDocumentDraft(
                name: d.name,
                type: d.type,
                file: PlatformFile(name: d.name, path: d.path, size: 0),
              ),
            )
            .toList();
        _trackWear = platform.trackWear;
        _trackCleanliness = platform.trackCleanliness;
        _trackRounds = platform.trackRounds;
        _cleaningRoundsThresholdController.text = platform
            .cleaningRoundsThreshold
            .toString();
        _wearRoundsThresholdController.text = platform.wearRoundsThreshold
            .toString();
        _linkedAccessoryIds
          ..clear()
          ..addAll(platform.linkedAccessoryIds);
      });
    } else if (_selectedCategory == 'CONSOMMABLE') {
      final ammo = provider.ammos
          .where((a) => a.id == widget.itemId)
          .firstOrNull;
      if (ammo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.of(context).itemNotFound),
            duration: const Duration(seconds: 3),
          ),
        );
        context.pop();
        return;
      }
      setState(() {
        _nameController.text = ammo.name;
        _brandController.text = ammo.brand;
        _caliberController.text = ammo.caliber;
        _quantityController.text = ammo.quantity.toString();
        _initialRoundsController.text = ammo.initialQuantity.toString();
        _unitPriceController.text = ammo.unitPrice?.toString() ?? '';
        _selectedCurrency = ammo.currency;
        _commentController.text = ammo.comment;
        _lowStockThresholdController.text = ammo.lowStockThreshold.toString();
        _photoPath = ammo.photoPath;
        _documents = ammo.documents
            .map(
              (d) => _ItemDocumentDraft(
                name: d.name,
                type: d.type,
                file: PlatformFile(name: d.name, path: d.path, size: 0),
              ),
            )
            .toList();
        _trackStock = ammo.trackStock;
        final known = _ammoProjectileTypes.contains(ammo.projectileType)
            ? ammo.projectileType
            : _ammoProjectileTypes.first;
        _isAmmoProjectileTypeCustom =
            ammo.projectileType.isNotEmpty &&
            !_ammoProjectileTypes.contains(ammo.projectileType);
        _selectedAmmoProjectileType = _isAmmoProjectileTypeCustom
            ? _ammoProjectileTypes.first
            : known;
        _ammoTypeController.text = _isAmmoProjectileTypeCustom
            ? ammo.projectileType
            : '';
      });
    } else {
      final accessory = provider.accessories
          .where((a) => a.id == widget.itemId)
          .firstOrNull;
      if (accessory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.of(context).itemNotFound),
            duration: const Duration(seconds: 3),
          ),
        );
        context.pop();
        return;
      }
      setState(() {
        _nameController.text = accessory.model.isNotEmpty
            ? accessory.model
            : accessory.name;
        _brandController.text = accessory.brand;
        _commentController.text = accessory.comment;

        // Prefer a known dropdown option when possible, otherwise fall back to custom.
        final known = _accessoryTypes.contains(accessory.type)
            ? accessory.type
            : 'Divers';
        _selectedAccessoryType = known;
        _isAccessoryTypeCustom = !_accessoryTypes.contains(accessory.type);
        _typeController.text = _isAccessoryTypeCustom ? accessory.type : '';

        _photoPath = accessory.photoPath;
        _documents = accessory.documents
            .map(
              (d) => _ItemDocumentDraft(
                name: d.name,
                type: d.type,
                file: PlatformFile(name: d.name, path: d.path, size: 0),
              ),
            )
            .toList();
        _trackBattery = accessory.trackBattery;
        _batteryChangedAt = accessory.batteryChangedAt;

        _trackWear = accessory.trackWear;
        _trackCleanliness = accessory.trackCleanliness;
        _cleaningRoundsThresholdController.text = accessory
            .cleaningRoundsThreshold
            .toString();
        _wearRoundsThresholdController.text = accessory.wearRoundsThreshold
            .toString();
        _linkedPlatformIds
          ..clear()
          ..addAll(accessory.linkedPlatformIds);
      });
    }
  }

  void _syncPlatformAccessoryLinks({
    required ThotProvider provider,
    required String platformId,
    required Set<String> desiredAccessoryIds,
  }) {
    final currentAccessoryIds = provider
        .linkedAccessoriesForPlatform(platformId)
        .map((a) => a.id)
        .toSet();

    for (final accessoryId in desiredAccessoryIds) {
      final accessory = provider.getAccessoryById(accessoryId);
      final linkedOnPlatform = currentAccessoryIds.contains(accessoryId);
      final linkedOnAccessory =
          accessory != null && accessory.linkedPlatformIds.contains(platformId);

      if (!linkedOnPlatform || !linkedOnAccessory) {
        provider.linkPlatformToAccessory(
          platformId: platformId,
          accessoryId: accessoryId,
        );
      }
    }

    for (final accessoryId in currentAccessoryIds.difference(
      desiredAccessoryIds,
    )) {
      provider.unlinkPlatformFromAccessory(
        platformId: platformId,
        accessoryId: accessoryId,
      );
    }
  }

  void _syncAccessoryPlatformLinks({
    required ThotProvider provider,
    required String accessoryId,
    required Set<String> desiredPlatformIds,
  }) {
    final currentPlatformIds = provider
        .linkedPlatformsForAccessory(accessoryId)
        .map((w) => w.id)
        .toSet();

    for (final platformId in desiredPlatformIds) {
      final platform = provider.getPlatformById(platformId);
      final linkedOnAccessory = currentPlatformIds.contains(platformId);
      final linkedOnPlatform =
          platform != null && platform.linkedAccessoryIds.contains(accessoryId);

      if (!linkedOnAccessory || !linkedOnPlatform) {
        provider.linkPlatformToAccessory(
          platformId: platformId,
          accessoryId: accessoryId,
        );
      }
    }

    for (final platformId in currentPlatformIds.difference(
      desiredPlatformIds,
    )) {
      provider.unlinkPlatformFromAccessory(
        platformId: platformId,
        accessoryId: accessoryId,
      );
    }
  }

  Future<bool> _confirmUnlink() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(AppStrings.of(ctx).unlinkConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppStrings.of(ctx).cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(AppStrings.of(ctx).confirm),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<void> _editLinkedAccessories(ThotProvider provider) async {
    final updated = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ItemLinkMultiSelectSheet(
        title: AppStrings.of(context).linkAccessories,
        items: provider.accessories,
        initialSelection: _linkedAccessoryIds,
        labelOf: (a) => a.name,
        subtitleOf: (a) => [
          if (a.type.trim().isNotEmpty) a.type,
          if (a.brand.trim().isNotEmpty) a.brand,
        ].join(' • '),
        idOf: (a) => a.id,
        icon: Icons.inventory_2_rounded,
      ),
    );
    if (!mounted || updated == null) return;

    setState(() {
      _linkedAccessoryIds
        ..clear()
        ..addAll(updated);
    });

    if (!_isEditMode || widget.itemId == null) {
      return;
    }

    // En édition, synchroniser immédiatement les liaisons bidirectionnelles.
    if (_selectedCategory == 'PLATEFORME') {
      _syncPlatformAccessoryLinks(
        provider: provider,
        platformId: widget.itemId!,
        desiredAccessoryIds: updated,
      );
    } else if (_selectedCategory == 'ACCESSOIRE') {
      _syncAccessoryPlatformLinks(
        provider: provider,
        accessoryId: widget.itemId!,
        desiredPlatformIds: updated,
      );
    }
  }

  Future<void> _editLinkedPlatforms(ThotProvider provider) async {
    final updated = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ItemLinkMultiSelectSheet(
        title: AppStrings.of(context).linkPlatforms,
        items: provider.platforms,
        initialSelection: _linkedPlatformIds,
        labelOf: (w) => w.name,
        subtitleOf: (w) => [
          if (w.type.trim().isNotEmpty) w.type,
          if (w.caliber.trim().isNotEmpty) w.caliber,
        ].join(' • '),
        idOf: (w) => w.id,
        icon: Icons.link_rounded,
      ),
    );
    if (!mounted || updated == null) return;

    setState(() {
      _linkedPlatformIds
        ..clear()
        ..addAll(updated);
    });

    if (!_isEditMode || widget.itemId == null) {
      return;
    }

    // En édition, synchroniser immédiatement les liaisons bidirectionnelles.
    if (_selectedCategory == 'PLATEFORME') {
      _syncPlatformAccessoryLinks(
        provider: provider,
        platformId: widget.itemId!,
        desiredAccessoryIds: updated,
      );
    } else if (_selectedCategory == 'ACCESSOIRE') {
      _syncAccessoryPlatformLinks(
        provider: provider,
        accessoryId: widget.itemId!,
        desiredPlatformIds: updated,
      );
    }
  }

  Future<void> _pickBatteryChangedDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _batteryChangedAt ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    setState(
      () => _batteryChangedAt = DateTime(picked.year, picked.month, picked.day),
    );
  }

  String _pageTitle() {
    return AppStrings.of(context).itemPageTitle(_selectedCategory, _isEditMode);
  }

  String _sentenceCase(String value) {
    final v = value.trim();
    if (v.isEmpty) return v;
    final isAllCaps = v == v.toUpperCase();
    final normalized = isAllCaps ? v.toLowerCase() : v;
    return '${normalized[0].toUpperCase()}${normalized.substring(1)}';
  }

  String _headerTitle(AppStrings strings) {
    return _pageTitle().toUpperCase();
  }

  String _primaryNameLabel() =>
      AppStrings.of(context).itemPrimaryNameLabel(_selectedCategory);

  String _primaryNameHint() =>
      AppStrings.of(context).itemPrimaryNameHint(_selectedCategory);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: colors.surface,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: baseBackground,
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    defaultTargetPlatform == TargetPlatform.iOS
                        ? (MediaQuery.paddingOf(context).top / 2 + 20)
                        : (MediaQuery.paddingOf(context).top + 20),
                    20,
                    8,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border(bottom: BorderSide(color: colors.outline)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 48),
                      Expanded(
                        child: Text(
                          _headerTitle(strings),
                          textAlign: TextAlign.center,
                          style: textStyles.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        color: colors.onSurface,
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Form
                        Row(
                          children: [
                            Icon(Icons.edit_note_rounded, size: 18),
                            const Gap(8),
                            Text(
                              _primaryNameLabel().toUpperCase(),
                              style: textStyles.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: colors.onSurface,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                        const Gap(8),
                        Container(
                          key: _primaryNameFieldKey,
                          child: TextField(
                            controller: _nameController,
                            onChanged: (_) {
                              if (_primaryNameError &&
                                  _nameController.text.trim().isNotEmpty) {
                                setState(() => _primaryNameError = false);
                              }
                            },
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              hintText: _primaryNameHint(),
                              hintStyle: textStyles.bodyMedium?.copyWith(
                                color: colors.onSurface.withAlpha(100),
                              ),
                              helperText: _primaryNameError
                                  ? strings.requiredFieldError
                                  : null,
                              helperStyle: textStyles.bodySmall?.copyWith(
                                color: colors.error,
                              ),
                              filled: true,
                              fillColor: colors.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                                borderSide: BorderSide(color: colors.outline),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                                borderSide: BorderSide(color: colors.outline),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                                borderSide: BorderSide(
                                  color: colors.primary,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Gap(AppSpacing.lg),

                        // Category-specific fields
                        if (_selectedCategory == 'PLATEFORME') ...[
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.sell_rounded,
                                          size: 18,
                                          color: colors.primary,
                                        ),
                                        const Gap(8),
                                        Text(
                                          strings.brandModelLabel.toUpperCase(),
                                          style: textStyles.labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                color: colors.onSurface,
                                                letterSpacing: 1.1,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const Gap(8),
                                    TextField(
                                      controller: _brandController,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                        hintText: strings.itemPlatformBrandHint,
                                        hintStyle: textStyles.bodyMedium
                                            ?.copyWith(
                                              color: colors.onSurface.withAlpha(
                                                100,
                                              ),
                                            ),
                                        filled: true,
                                        fillColor: colors.surface,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          borderSide: BorderSide(
                                            color: colors.outline,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          borderSide: BorderSide(
                                            color: colors.outline,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          borderSide: BorderSide(
                                            color: colors.primary,
                                            width: 1.6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/images/pointe.svg',
                                          width: 18,
                                          height: 18,
                                          colorFilter: ColorFilter.mode(
                                            colors.primary,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                        const Gap(8),
                                        Text(
                                          strings.caliberLabel.toUpperCase(),
                                          style: textStyles.labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                color: colors.onSurface,
                                                letterSpacing: 1.1,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const Gap(8),
                                    TextField(
                                      controller: _caliberController,
                                      onChanged: (_) {
                                        if (_caliberError &&
                                            _caliberController.text
                                                .trim()
                                                .isNotEmpty) {
                                          setState(() => _caliberError = false);
                                        }
                                      },
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                        hintText: strings.itemCaliberHint,
                                        hintStyle: textStyles.bodyMedium
                                            ?.copyWith(
                                              color: colors.onSurface.withAlpha(
                                                100,
                                              ),
                                            ),
                                        helperText: _caliberError
                                            ? strings.requiredFieldError
                                            : null,
                                        helperStyle: textStyles.bodySmall
                                            ?.copyWith(color: colors.error),
                                        filled: true,
                                        fillColor: colors.surface,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          borderSide: BorderSide(
                                            color: colors.outline,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          borderSide: BorderSide(
                                            color: colors.outline,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          borderSide: BorderSide(
                                            color: colors.primary,
                                            width: 1.6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Gap(AppSpacing.lg),
                          Row(
                            children: [
                              Icon(
                                Icons.category_rounded,
                                size: 18,
                                color: colors.primary,
                              ),
                              const Gap(8),
                              Text(
                                strings.typeLabel.toUpperCase(),
                                style: textStyles.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: colors.onSurface,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                          const Gap(8),
                          Container(
                            key: _platformTypeFieldKey,
                            child: DropdownButtonFormField<String>(
                              value: _selectedPlatformType,
                              decoration: InputDecoration(
                                helperText: _platformTypeError
                                    ? strings.requiredFieldError
                                    : null,
                                helperStyle: textStyles.bodySmall?.copyWith(
                                  color: colors.error,
                                ),
                                filled: true,
                                fillColor: colors.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                  borderSide: BorderSide(color: colors.outline),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                  borderSide: BorderSide(color: colors.outline),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                  borderSide: BorderSide(color: colors.outline),
                                ),
                              ),
                              items: _platformTypes
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(
                                        strings.itemPlatformTypeLabel(t),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() {
                                  _selectedPlatformType = v;
                                  _platformTypeError = false;
                                });
                                _applyRecommendedMaintenancePresetIfDefault();
                              },
                            ),
                          ),
                          const Gap(AppSpacing.lg),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.confirmation_number_rounded,
                                          size: 18,
                                          color: colors.primary,
                                        ),
                                        const Gap(8),
                                        Text(
                                          strings.serialNumberLabel
                                              .toUpperCase(),
                                          style: textStyles.labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                color: colors.onSurface,
                                                letterSpacing: 1.1,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const Gap(8),
                                    TextField(
                                      controller: _serialController,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                        hintText: strings.itemSerialNumberHint,
                                        hintStyle: textStyles.bodyMedium
                                            ?.copyWith(
                                              color: colors.onSurface.withAlpha(
                                                100,
                                              ),
                                            ),
                                        filled: true,
                                        fillColor: colors.surface,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          borderSide: BorderSide(
                                            color: colors.outline,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          borderSide: BorderSide(
                                            color: colors.outline,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          borderSide: BorderSide(
                                            color: colors.primary,
                                            width: 1.6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.scale_rounded,
                                          size: 18,
                                          color: colors.primary,
                                        ),
                                        const Gap(8),
                                        Text(
                                          strings.weightGramsLabel
                                              .toUpperCase(),
                                          style: textStyles.labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                color: colors.onSurface,
                                                letterSpacing: 1.1,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const Gap(8),
                                    TextField(
                                      controller: _weightController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                        hintText: strings.itemWeightHint,
                                        hintStyle: textStyles.bodyMedium
                                            ?.copyWith(
                                              color: colors.onSurface.withAlpha(
                                                100,
                                              ),
                                            ),
                                        filled: true,
                                        fillColor: colors.surface,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          borderSide: BorderSide(
                                            color: colors.outline,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          borderSide: BorderSide(
                                            color: colors.outline,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          borderSide: BorderSide(
                                            color: colors.primary,
                                            width: 1.6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],

                        if (_selectedCategory == 'CONSOMMABLE') ...[
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.sell_rounded,
                                          size: 18,
                                          color: colors.primary,
                                        ),
                                        const Gap(8),
                                        Text(
                                          strings.brandLabel.toUpperCase(),
                                          style: textStyles.labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                color: colors.onSurface,
                                                letterSpacing: 1.1,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const Gap(8),
                                    TextField(
                                      controller: _brandController,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                        hintText: strings.itemAmmoBrandHint,
                                        hintStyle: textStyles.bodyMedium
                                            ?.copyWith(
                                              color: colors.onSurface.withAlpha(
                                                100,
                                              ),
                                            ),
                                        filled: true,
                                        fillColor: colors.surface,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          borderSide: BorderSide(
                                            color: colors.outline,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          borderSide: BorderSide(
                                            color: colors.outline,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          borderSide: BorderSide(
                                            color: colors.primary,
                                            width: 1.6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/images/pointe.svg',
                                          width: 18,
                                          height: 18,
                                          colorFilter: ColorFilter.mode(
                                            colors.primary,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                        const Gap(8),
                                        Text(
                                          strings.caliberLabel.toUpperCase(),
                                          style: textStyles.labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                color: colors.onSurface,
                                                letterSpacing: 1.1,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const Gap(8),
                                    TextField(
                                      controller: _caliberController,
                                      onChanged: (_) {
                                        if (_caliberError &&
                                            _caliberController.text
                                                .trim()
                                                .isNotEmpty) {
                                          setState(() => _caliberError = false);
                                        }
                                      },
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                        hintText: strings.itemCaliberHint,
                                        hintStyle: textStyles.bodyMedium
                                            ?.copyWith(
                                              color: colors.onSurface.withAlpha(
                                                100,
                                              ),
                                            ),
                                        helperText: _caliberError
                                            ? strings.requiredFieldError
                                            : null,
                                        helperStyle: textStyles.bodySmall
                                            ?.copyWith(color: colors.error),
                                        filled: true,
                                        fillColor: colors.surface,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          borderSide: BorderSide(
                                            color: colors.outline,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          borderSide: BorderSide(
                                            color: colors.outline,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          borderSide: BorderSide(
                                            color: colors.primary,
                                            width: 1.6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Gap(AppSpacing.lg),
                          Row(
                            children: [
                              Icon(
                                Icons.category_rounded,
                                size: 18,
                                color: colors.primary,
                              ),
                              const Gap(8),
                              Text(
                                strings.typeLabel.toUpperCase(),
                                style: textStyles.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: colors.onSurface,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                          const Gap(8),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _isAmmoProjectileTypeCustom
                                  ? '__custom__'
                                  : _selectedAmmoProjectileType,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: colors.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                  borderSide: BorderSide(color: colors.outline),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                  borderSide: BorderSide(color: colors.outline),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                  borderSide: BorderSide(color: colors.outline),
                                ),
                              ),
                              items: [
                                ..._ammoProjectileTypes
                                    .where((t) => t != 'Autre')
                                    .map(
                                      (t) => DropdownMenuItem(
                                        value: t,
                                        child: Text(
                                          strings.itemProjectileTypeLabel(t),
                                        ),
                                      ),
                                    ),
                                DropdownMenuItem(
                                  value: '__custom__',
                                  child: Text(strings.customOtherLabel),
                                ),
                              ],
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() {
                                  if (v == '__custom__') {
                                    _isAmmoProjectileTypeCustom = true;
                                    _selectedAmmoProjectileType =
                                        _ammoProjectileTypes.first;
                                  } else {
                                    _isAmmoProjectileTypeCustom = false;
                                    _selectedAmmoProjectileType = v;
                                    _ammoTypeController.clear();
                                  }
                                });
                              },
                            ),
                          ),
                          if (_isAmmoProjectileTypeCustom) ...[
                            const Gap(12),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                                border: Border.all(
                                  color: colors.outline.withValues(alpha: 0.25),
                                  width: 1.4,
                                ),
                              ),
                              child: TextField(
                                controller: _ammoTypeController,
                                decoration: InputDecoration(
                                  hintText: strings.itemProjectileCustomHint,
                                  hintStyle: textStyles.bodyMedium?.copyWith(
                                    color: colors.onSurface.withAlpha(100),
                                  ),
                                  filled: true,
                                  fillColor: colors.surface,
                                  border: InputBorder.none,
                                  contentPadding: AppSpacing.paddingMd,
                                ),
                              ),
                            ),
                          ],
                          const Gap(AppSpacing.lg),
                          Row(
                            children: [
                              Icon(
                                Icons.inventory_2_rounded,
                                size: 18,
                                color: colors.primary,
                              ),
                              const Gap(8),
                              Text(
                                strings.initialQuantityLabel.toUpperCase(),
                                style: textStyles.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: colors.onSurface,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                          const Gap(8),
                          Container(
                            key: _ammoQuantityFieldKey,
                            child: TextField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              onTap: () {
                                // Effacer le zéro si c'est la seule valeur
                                if (_quantityController.text == "0") {
                                  _quantityController.clear();
                                }
                              },
                              onChanged: (_) {
                                final qty = int.tryParse(
                                  _quantityController.text.trim(),
                                );
                                if (_ammoQuantityError && (qty ?? 0) > 0) {
                                  setState(() => _ammoQuantityError = false);
                                }
                              },
                              decoration: InputDecoration(
                                hintText: strings.itemQuantityHint,
                                hintStyle: textStyles.bodyMedium?.copyWith(
                                  color: colors.onSurface.withAlpha(100),
                                ),
                                suffixText: strings.cartridges,
                                helperText: _ammoQuantityError
                                    ? strings.quantityRequiredError
                                    : null,
                                helperStyle: textStyles.bodySmall?.copyWith(
                                  color: colors.error,
                                ),
                                filled: true,
                                fillColor: colors.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                  borderSide: BorderSide(color: colors.outline),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                  borderSide: BorderSide(color: colors.outline),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                  borderSide: BorderSide(color: colors.outline),
                                ),
                              ),
                            ),
                          ),
                          const Gap(AppSpacing.lg),
                          Row(
                            children: [
                              Icon(
                                Icons.euro_rounded,
                                size: 18,
                                color: colors.primary,
                              ),
                              const Gap(8),
                              Text(
                                strings.ammoUnitPriceLabel.toUpperCase(),
                                style: textStyles.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: colors.onSurface,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),
                          const Gap(8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _unitPriceController,
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    hintText: strings.ammoUnitPriceHint,
                                    hintStyle: textStyles.bodyMedium?.copyWith(
                                      color: colors.onSurface.withAlpha(100),
                                    ),
                                    filled: true,
                                    fillColor: colors.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.lg,
                                      ),
                                      borderSide: BorderSide(
                                        color: colors.outline,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.lg,
                                      ),
                                      borderSide: BorderSide(
                                        color: colors.outline,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.lg,
                                      ),
                                      borderSide: BorderSide(
                                        color: colors.primary,
                                        width: 1.6,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Gap(8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                  border: Border.all(color: colors.outline),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedCurrency,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'EUR',
                                        child: Text('€'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'USD',
                                        child: Text('\$'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'CAD',
                                        child: Text('CA\$'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'GBP',
                                        child: Text('£'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'CHF',
                                        child: Text('CHF'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'JPY',
                                        child: Text('¥'),
                                      ),
                                      DropdownMenuItem(
                                        value: 'AUD',
                                        child: Text('A\$'),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          _selectedCurrency = value;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        if (_selectedCategory == 'ACCESSOIRE') ...[
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.sell_rounded,
                                          size: 18,
                                          color: colors.primary,
                                        ),
                                        const Gap(8),
                                        Text(
                                          strings.brandLabel.toUpperCase(),
                                          style: textStyles.labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                color: colors.onSurface,
                                                letterSpacing: 1.1,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const Gap(8),
                                    TextField(
                                      controller: _brandController,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                        hintText:
                                            strings.itemAccessoryBrandHint,
                                        hintStyle: textStyles.bodyMedium
                                            ?.copyWith(
                                              color: colors.onSurface.withAlpha(
                                                100,
                                              ),
                                            ),
                                        filled: true,
                                        fillColor: colors.surface,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          borderSide: BorderSide(
                                            color: colors.outline,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          borderSide: BorderSide(
                                            color: colors.outline,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          borderSide: BorderSide(
                                            color: colors.primary,
                                            width: 1.6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.category_rounded,
                                          size: 18,
                                          color: colors.primary,
                                        ),
                                        const Gap(8),
                                        Text(
                                          strings.typeLabel.toUpperCase(),
                                          style: textStyles.labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                                color: colors.onSurface,
                                                letterSpacing: 1.1,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const Gap(8),
                                    Container(
                                      key: _accessoryTypeFieldKey,
                                      child: DropdownButtonFormField<String>(
                                        isExpanded: true,
                                        value: _isAccessoryTypeCustom
                                            ? '__custom__'
                                            : _selectedAccessoryType,
                                        style: textStyles.bodyMedium?.copyWith(
                                          color: colors.onSurface,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        selectedItemBuilder: (context) {
                                          final labels = [
                                            ..._accessoryTypes.map(
                                              (t) => strings
                                                  .itemAccessoryTypeLabel(t),
                                            ),
                                            strings.customOtherLabel,
                                          ];
                                          return labels
                                              .map(
                                                (label) => Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    label,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: textStyles.bodyMedium
                                                        ?.copyWith(
                                                          color:
                                                              colors.onSurface,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                  ),
                                                ),
                                              )
                                              .toList();
                                        },
                                        decoration: InputDecoration(
                                          helperText: _accessoryTypeError
                                              ? strings.requiredFieldError
                                              : null,
                                          helperStyle: textStyles.bodySmall
                                              ?.copyWith(color: colors.error),
                                          filled: true,
                                          fillColor: colors.surface,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.lg,
                                            ),
                                            borderSide: BorderSide(
                                              color: colors.outline,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.lg,
                                            ),
                                            borderSide: BorderSide(
                                              color: colors.outline,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              AppRadius.lg,
                                            ),
                                            borderSide: BorderSide(
                                              color: colors.outline,
                                            ),
                                          ),
                                        ),
                                        items: [
                                          ..._accessoryTypes.map(
                                            (t) => DropdownMenuItem(
                                              value: t,
                                              child: Text(
                                                strings.itemAccessoryTypeLabel(
                                                  t,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: textStyles.bodyMedium
                                                    ?.copyWith(
                                                      color: colors.onSurface,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          DropdownMenuItem(
                                            value: '__custom__',
                                            child: Text(
                                              strings.customOtherLabel,
                                              style: textStyles.bodyMedium
                                                  ?.copyWith(
                                                    color: colors.onSurface,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                            ),
                                          ),
                                        ],
                                        onChanged: (v) {
                                          if (v == null) return;
                                          setState(() {
                                            _accessoryTypeError = false;
                                            if (v == '__custom__') {
                                              _isAccessoryTypeCustom = true;
                                              _typeController.text =
                                                  _typeController.text.isEmpty
                                                  ? ''
                                                  : _typeController.text;
                                            } else {
                                              _isAccessoryTypeCustom = false;
                                              _selectedAccessoryType = v;
                                              _typeController.text = '';
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (_isAccessoryTypeCustom) ...[
                            const Gap(AppSpacing.lg),
                            Text(
                              strings.customTypeLabel.toUpperCase(),
                              style: textStyles.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: colors.onSurface,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const Gap(8),
                            Container(
                              key: _accessoryTypeFieldKey,
                              child: TextField(
                                controller: _typeController,
                                onChanged: (_) {
                                  if (_accessoryTypeError &&
                                      _typeController.text.trim().isNotEmpty) {
                                    setState(() => _accessoryTypeError = false);
                                  }
                                },
                                decoration: InputDecoration(
                                  hintText: strings.itemAccessoryCustomTypeHint,
                                  hintStyle: textStyles.bodyMedium?.copyWith(
                                    color: colors.onSurface.withAlpha(100),
                                  ),
                                  errorText: _accessoryTypeError
                                      ? strings.requiredFieldError
                                      : null,
                                  filled: true,
                                  fillColor: colors.surface,
                                  border: InputBorder.none,
                                  contentPadding: AppSpacing.paddingMd,
                                ),
                              ),
                            ),
                          ],
                        ],

                        if (_selectedCategory == 'PLATEFORME' ||
                            _selectedCategory == 'ACCESSOIRE') ...[
                          const Gap(AppSpacing.lg),
                          // Header with title and link button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.link_rounded,
                                    size: 18,
                                    color: colors.primary,
                                  ),
                                  const Gap(8),
                                  Text(
                                    strings.liaisonsLabel.toUpperCase(),
                                    style: textStyles.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: colors.onSurface,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                              if (_selectedCategory == 'PLATEFORME')
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _editLinkedAccessories(provider),
                                  icon: const Icon(
                                    Icons.add_link_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    AppStrings.of(context).associateAccessory,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.primary,
                                    foregroundColor: colors.onPrimary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.lg,
                                      ),
                                      side: BorderSide.none,
                                    ),
                                  ),
                                )
                              else if (_selectedCategory == 'ACCESSOIRE')
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _editLinkedPlatforms(provider),
                                  icon: const Icon(
                                    Icons.add_link_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    AppStrings.of(context).associatePlatform,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.primary,
                                    foregroundColor: colors.onPrimary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.lg,
                                      ),
                                      side: BorderSide.none,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const Gap(8),
                          Container(
                            width: double.infinity,
                            padding: AppSpacing.paddingMd,
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(color: colors.outline),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_selectedCategory == 'PLATEFORME') ...[
                                  if (_linkedAccessoryIds.isEmpty)
                                    Text(
                                      strings.noAccessoryLinked,
                                      style: textStyles.bodySmall?.copyWith(
                                        color: colors.secondary,
                                      ),
                                    )
                                  else
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: provider.accessories
                                          .where(
                                            (a) => _linkedAccessoryIds.contains(
                                              a.id,
                                            ),
                                          )
                                          .map(
                                            (a) => InputChip(
                                              avatar: Icon(
                                                Icons.inventory_2_rounded,
                                                size: 16,
                                                color: colors.onPrimary,
                                              ),
                                              label: Text(
                                                a.name,
                                                style: TextStyle(
                                                  color: colors.onPrimary,
                                                ),
                                              ),
                                              backgroundColor: colors.primary,
                                              side: BorderSide.none,
                                              deleteIconColor: colors.onPrimary,
                                              onDeleted: () async {
                                                if (!await _confirmUnlink())
                                                  return;
                                                if (!mounted) return;
                                                setState(
                                                  () => _linkedAccessoryIds
                                                      .remove(a.id),
                                                );
                                              },
                                            ),
                                          )
                                          .toList(),
                                    ),
                                ],
                                if (_selectedCategory == 'ACCESSOIRE') ...[
                                  if (_linkedPlatformIds.isEmpty)
                                    Text(
                                      strings.noPlatformLinked,
                                      style: textStyles.bodySmall?.copyWith(
                                        color: colors.secondary,
                                      ),
                                    )
                                  else
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: provider.platforms
                                          .where(
                                            (w) => _linkedPlatformIds.contains(
                                              w.id,
                                            ),
                                          )
                                          .map(
                                            (w) => InputChip(
                                              avatar: Icon(
                                                Icons.link_rounded,
                                                size: 16,
                                                color: colors.onPrimary,
                                              ),
                                              label: Text(
                                                w.name,
                                                style: TextStyle(
                                                  color: colors.onPrimary,
                                                ),
                                              ),
                                              backgroundColor: colors.primary,
                                              side: BorderSide.none,
                                              deleteIconColor: colors.onPrimary,
                                              onDeleted: () async {
                                                if (!await _confirmUnlink())
                                                  return;
                                                if (!mounted) return;
                                                setState(
                                                  () => _linkedPlatformIds
                                                      .remove(w.id),
                                                );
                                              },
                                            ),
                                          )
                                          .toList(),
                                    ),
                                ],
                              ],
                            ),
                          ),
                        ],
                        const Gap(AppSpacing.lg),

                        // Comment
                        Row(
                          children: [
                            Icon(
                              Icons.edit_rounded,
                              size: 18,
                              color: colors.primary,
                            ),
                            const Gap(8),
                            Text(
                              strings.commentOptionalLabel.toUpperCase(),
                              style: textStyles.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: colors.onSurface,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                        const Gap(8),
                        TextField(
                          controller: _commentController,
                          maxLines: 4,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            hintText: strings.itemCommentHint,
                            hintStyle: textStyles.bodyMedium?.copyWith(
                              color: colors.onSurface.withAlpha(100),
                            ),
                            filled: true,
                            fillColor: colors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              borderSide: BorderSide(color: colors.outline),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              borderSide: BorderSide(color: colors.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              borderSide: BorderSide(
                                color: colors.primary,
                                width: 1.6,
                              ),
                            ),
                          ),
                        ),
                        const Gap(AppSpacing.lg),

                        // Photo
                        Row(
                          children: [
                            Icon(
                              Icons.photo_camera_rounded,
                              size: 18,
                              color: colors.primary,
                            ),
                            const Gap(8),
                            Text(
                              strings.itemPhotoLabel.toUpperCase(),
                              style: textStyles.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: colors.onSurface,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                        const Gap(8),
                        GestureDetector(
                          onTap: _pickPhoto,
                          child: Container(
                            height: 130,
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(color: colors.outline),
                            ),
                            child: _photoPath != null
                                ? Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.lg,
                                        ),
                                        child: CrossPlatformImage(
                                          filePath: _photoPath,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.close_rounded,
                                            size: 20,
                                          ),
                                          onPressed: () =>
                                              setState(() => _photoPath = null),
                                          color: colors.onPrimary,
                                          style: IconButton.styleFrom(
                                            backgroundColor: colors.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate_rounded,
                                          color: colors.secondary,
                                          size: 40,
                                        ),
                                        const Gap(8),
                                        Text(
                                          strings.clickToAddPhoto,
                                          style: textStyles.bodySmall?.copyWith(
                                            color: colors.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                        const Gap(AppSpacing.lg),

                        // Documents

                        // APRÈS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.picture_as_pdf_rounded,
                                  size: 18,
                                  color: colors.primary,
                                ),
                                const Gap(8),
                                Text(
                                  strings.itemDocumentsLabel.toUpperCase(),
                                  style: textStyles.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: colors.onSurface,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ],
                            ),
                            FilledButton.icon(
                              onPressed: _pickPdf,
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: Text(strings.settingsAddDocument),
                              style: FilledButton.styleFrom(
                                backgroundColor: colors.primary,
                                foregroundColor: colors.onPrimary,
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(8),
                        if (_documents.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: AppSpacing.paddingLg,
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(color: colors.outline),
                            ),
                            child: Text(
                              strings.settingsDocumentsEmptyTitle,
                              style: textStyles.bodyMedium?.copyWith(
                                color: colors.secondary,
                              ),
                            ),
                          )
                        else
                          ..._documents.map(
                            (doc) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: GestureDetector(
                                onTap: () =>
                                    _openDocumentPath(doc.file.path ?? ''),
                                child: Container(
                                  padding: AppSpacing.paddingMd,
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.lg,
                                    ),
                                    border: Border.all(
                                      color: colors.outline.withValues(
                                        alpha: 0.25,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        _documentIconForPath(
                                          doc.file.path ?? '',
                                        ),
                                        color: _documentIconColorForPath(
                                          colors,
                                          doc.file.path ?? '',
                                        ),
                                        size: 24,
                                      ),
                                      const Gap(16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              doc.name,
                                              style: textStyles.bodyMedium
                                                  ?.copyWith(
                                                    color: colors.onSurface,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              doc.type,
                                              style: textStyles.labelSmall
                                                  ?.copyWith(
                                                    color: colors.secondary,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: Icon(
                                          Icons.more_vert_rounded,
                                          color: colors.secondary,
                                        ),
                                        onSelected: (v) async {
                                          switch (v) {
                                            case 'share':
                                              await _shareDocument(doc);
                                              break;
                                            case 'edit':
                                              await _editDocument(doc);
                                              break;
                                            case 'delete':
                                              _removeDocument(doc);
                                              break;
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          PopupMenuItem<String>(
                                            value: 'share',
                                            child: Text(
                                              strings.sessionMenuShare,
                                            ),
                                          ),
                                          PopupMenuItem<String>(
                                            value: 'edit',
                                            child: Text(
                                              strings.settingsEditDocument,
                                            ),
                                          ),
                                          PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Text(strings.delete),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                        const Gap(AppSpacing.lg),

                        // Tracking options - only show if at least one option is applicable and enabled
                        if (_shouldShowTrackingOptions()) ...[
                          // Tracking options
                          Row(
                            children: [
                              Icon(
                                Icons.track_changes_rounded,
                                size: 18,
                                color: colors.primary,
                              ),
                              const Gap(8),
                              Text(
                                strings.trackingOptionsTitle.toUpperCase(),
                                style: textStyles.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: colors.onSurface,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          ),

                          const Gap(8),

                          Container(
                            padding: AppSpacing.paddingLg,
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(color: colors.outline),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Platform-specific tracking
                                if (_selectedCategory == 'PLATEFORME') ...[
                                  _TrackingToggle(
                                    label: strings.platformWearTrackingLabel,
                                    subtitle:
                                        strings.platformWearTrackingSubtitle,
                                    value: _trackWear,
                                    onChanged: (val) =>
                                        setState(() => _trackWear = val),
                                  ),
                                  if (_trackWear) ...[
                                    const Gap(8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            strings.wearThresholdLabel,
                                            style: textStyles.bodyMedium
                                                ?.copyWith(
                                                  color: colors.secondary,
                                                ),
                                          ),
                                        ),
                                        const Gap(16),
                                        SizedBox(
                                          width: 108,
                                          child: TextField(
                                            controller:
                                                _wearRoundsThresholdController,
                                            textAlign: TextAlign.end,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10,
                                                  ),
                                              filled: true,
                                              fillColor: colors.surface,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.lg,
                                                    ),
                                                borderSide: BorderSide(
                                                  color: colors.outline,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.lg,
                                                    ),
                                                borderSide: BorderSide(
                                                  color: colors.outline,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.lg,
                                                    ),
                                                borderSide: BorderSide(
                                                  color: colors.outline,
                                                  width: 2,
                                                ),
                                              ),
                                              suffix: Text(
                                                strings.sessionLabelShots,
                                                style: textStyles.bodySmall
                                                    ?.copyWith(
                                                      color: colors.secondary,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const Gap(20),
                                  _TrackingToggle(
                                    label:
                                        strings.platformCleaningTrackingLabel,
                                    subtitle: strings
                                        .platformCleaningTrackingSubtitle,
                                    value: _trackCleanliness,
                                    onChanged: (val) =>
                                        setState(() => _trackCleanliness = val),
                                  ),
                                  if (_trackCleanliness) ...[
                                    const Gap(8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            strings.cleaningThresholdShotsLabel,
                                            style: textStyles.bodyMedium
                                                ?.copyWith(
                                                  color: colors.secondary,
                                                ),
                                          ),
                                        ),
                                        const Gap(16),
                                        SizedBox(
                                          width: 108,
                                          child: TextField(
                                            controller:
                                                _cleaningRoundsThresholdController,
                                            textAlign: TextAlign.end,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10,
                                                  ),
                                              filled: true,
                                              fillColor: colors.surface,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.lg,
                                                    ),
                                                borderSide: BorderSide(
                                                  color: colors.outline,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.lg,
                                                    ),
                                                borderSide: BorderSide(
                                                  color: colors.outline,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.lg,
                                                    ),
                                                borderSide: BorderSide(
                                                  color: colors.outline,
                                                  width: 2,
                                                ),
                                              ),
                                              suffix: Text(
                                                strings.sessionLabelShots,
                                                style: textStyles.bodySmall
                                                    ?.copyWith(
                                                      color: colors.secondary,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const Gap(20),
                                  _TrackingToggle(
                                    label: strings.platformRoundCounterLabel,
                                    subtitle:
                                        strings.platformRoundCounterSubtitle,
                                    value: _trackRounds,
                                    onChanged: (val) =>
                                        setState(() => _trackRounds = val),
                                  ),
                                  if (_trackRounds) ...[
                                    const Gap(8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          strings.initialRoundCounterLabel,
                                          style: textStyles.bodyMedium
                                              ?.copyWith(
                                                color: colors.secondary,
                                              ),
                                        ),
                                        SizedBox(
                                          width: 96,
                                          child: TextField(
                                            controller:
                                                _initialRoundsController,
                                            textAlign: TextAlign.end,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10,
                                                  ),
                                              filled: true,
                                              fillColor: colors.surface,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.lg,
                                                    ),
                                                borderSide: BorderSide(
                                                  color: colors.outline,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.lg,
                                                    ),
                                                borderSide: BorderSide(
                                                  color: colors.outline,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.lg,
                                                    ),
                                                borderSide: BorderSide(
                                                  color: colors.outline,
                                                  width: 2,
                                                ),
                                              ),
                                              suffix: Text(
                                                strings.sessionLabelShots,
                                                style: textStyles.bodySmall
                                                    ?.copyWith(
                                                      color: colors.secondary,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],

                                // Ammo-specific tracking
                                if (_selectedCategory == 'CONSOMMABLE') ...[
                                  _TrackingToggle(
                                    label: strings.stockTrackingLabel,
                                    subtitle: strings.stockTrackingSubtitle,
                                    value: _trackStock,
                                    onChanged: (val) =>
                                        setState(() => _trackStock = val),
                                  ),
                                  if (_trackStock) ...[
                                    const Gap(8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            strings.stockAlertThresholdLabel,
                                            style: textStyles.bodyMedium
                                                ?.copyWith(
                                                  color: colors.secondary,
                                                ),
                                          ),
                                        ),
                                        const Gap(16),
                                        SizedBox(
                                          width: 108,
                                          child: TextField(
                                            controller:
                                                _lowStockThresholdController,
                                            textAlign: TextAlign.end,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: colors.surface,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.lg,
                                                    ),
                                                borderSide: BorderSide(
                                                  color: colors.outline,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.lg,
                                                    ),
                                                borderSide: BorderSide(
                                                  color: colors.outline,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.lg,
                                                    ),
                                                borderSide: BorderSide(
                                                  color: colors.outline,
                                                  width: 2,
                                                ),
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 8,
                                                  ),
                                              suffix: Text(
                                                strings.sessionLabelShots,
                                                style: textStyles.bodySmall
                                                    ?.copyWith(
                                                      color: colors.secondary,
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],

                                // Accessory-specific tracking
                                if (_selectedCategory == 'ACCESSOIRE' &&
                                    _canTrackAccessoryBattery(
                                      _trackingAccessoryType,
                                    )) ...[
                                  _TrackingToggle(
                                    label: strings.batteryChangeDateLabel,
                                    subtitle: strings.batteryChangeDateSubtitle,
                                    value: _trackBattery,
                                    onChanged: (val) => setState(() {
                                      _trackBattery = val;
                                      if (!_trackBattery) {
                                        _batteryChangedAt = null;
                                        _batteryDateError = false;
                                      } else {
                                        // Keep existing value (edit mode) but don't auto-fill on first enable.
                                        // The date becomes required and will be requested on save.
                                        _batteryChangedAt = _batteryChangedAt;
                                      }
                                    }),
                                  ),
                                  if (_trackBattery) ...[
                                    const Gap(8),
                                    InkWell(
                                      onTap: () async {
                                        await _pickBatteryChangedDate();
                                        if (_batteryDateError &&
                                            _batteryChangedAt != null) {
                                          if (mounted) {
                                            setState(
                                              () => _batteryDateError = false,
                                            );
                                          }
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_month_rounded,
                                            size: 18,
                                            color: colors.primary,
                                          ),
                                          const Gap(8),
                                          _batteryChangedAt == null
                                              ? Text(
                                                  strings.selectDateLabel,
                                                  style: textStyles.bodyMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                )
                                              : Row(
                                                  children: [
                                                    Text(
                                                      strings
                                                          .batteryChangedLabel,
                                                      style: textStyles
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                    const Gap(4),
                                                    Text(
                                                      AppDateFormats.formatDateShort(
                                                        context,
                                                        _batteryChangedAt!,
                                                      ),
                                                      style: textStyles
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                        ],
                                      ),
                                    ),
                                    const Gap(16),
                                  ],
                                ],

                                // Accessory maintenance tracking (platform-like)
                                if (_selectedCategory == 'ACCESSOIRE' &&
                                    _canTrackAccessoryWear(
                                      _trackingAccessoryType,
                                    )) ...[
                                  _TrackingToggle(
                                    label: strings.accessoryWearTrackingLabel,
                                    subtitle:
                                        strings.accessoryWearTrackingSubtitle,
                                    value: _trackWear,
                                    onChanged: (val) =>
                                        setState(() => _trackWear = val),
                                  ),
                                  if (_trackWear) ...[
                                    const Gap(8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            strings.revisionThresholdShotsLabel,
                                            style: textStyles.bodyMedium
                                                ?.copyWith(
                                                  color: colors.secondary,
                                                ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 92,
                                          child: TextField(
                                            controller:
                                                _wearRoundsThresholdController,
                                            textAlign: TextAlign.end,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10,
                                                  ),
                                              filled: true,
                                              fillColor: colors.surface,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.lg,
                                                    ),
                                                borderSide: BorderSide(
                                                  color: colors.outline,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.lg,
                                                    ),
                                                borderSide: BorderSide(
                                                  color: colors.outline,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.lg,
                                                    ),
                                                borderSide: BorderSide(
                                                  color: colors.outline,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                                if (_selectedCategory == 'ACCESSOIRE' &&
                                    _canTrackAccessoryWear(
                                      _trackingAccessoryType,
                                    ) &&
                                    _canTrackAccessoryCleanliness(
                                      _trackingAccessoryType,
                                    )) ...[
                                  const Gap(12),
                                ],
                                if (_selectedCategory == 'ACCESSOIRE' &&
                                    _canTrackAccessoryCleanliness(
                                      _trackingAccessoryType,
                                    )) ...[
                                  _TrackingToggle(
                                    label:
                                        strings.accessoryCleaningTrackingLabel,
                                    subtitle: strings
                                        .accessoryCleaningTrackingSubtitle,
                                    value: _trackCleanliness,
                                    onChanged: (val) =>
                                        setState(() => _trackCleanliness = val),
                                  ),
                                  if (_trackCleanliness) ...[
                                    const Gap(16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            strings.cleaningThresholdShotsLabel,
                                            style: textStyles.bodyMedium
                                                ?.copyWith(
                                                  color: colors.secondary,
                                                ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 92,
                                          child: TextField(
                                            controller:
                                                _cleaningRoundsThresholdController,
                                            textAlign: TextAlign.end,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10,
                                                  ),
                                              filled: true,
                                              fillColor: colors.surface,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.lg,
                                                    ),
                                                borderSide: BorderSide(
                                                  color: colors.outline,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.lg,
                                                    ),
                                                borderSide: BorderSide(
                                                  color: colors.outline,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.lg,
                                                    ),
                                                borderSide: BorderSide(
                                                  color: colors.outline,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ],
                            ),
                          ),
                          const Gap(AppSpacing.lg),
                        ],

                        // Actions
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => context.pop(),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.lg,
                                    ),
                                  ),
                                  side: BorderSide(color: colors.outline),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    strings.cancel.toUpperCase(),
                                    style: TextStyle(color: colors.secondary),
                                  ),
                                ),
                              ),
                            ),
                            const Gap(AppSpacing.md),
                            Expanded(
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                  boxShadow: AppShadows.cardPremium,
                                ),
                                child: FilledButton(
                                  onPressed: _saveItem,
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size(
                                      double.infinity,
                                      50,
                                    ),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.lg,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.save, size: 20),
                                      const Gap(6),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            _isEditMode
                                                ? strings.saveChangesButton
                                                : strings.saveItemButton,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(AppSpacing.lg),
                      ], // ← ferme children: [] de Column intérieur (7)
                    ), // ← ferme Column (7)
                  ), // ← ferme SingleChildScrollView (6)
                ), // ← ferme Expanded (5)
              ], // ← ferme children: [] de Column extérieur (4)
            ), // ← ferme Column (4)
          ), // ← ferme SafeArea (3)
        ), // ← ferme GestureDetector (body)
      ), // ← ferme Scaffold (2)
    ); // ← ferme AnnotatedRegion (1)
  }

  Future<void> _pickPhoto() async {
    final picked = await NativePicker.pick(context, mode: PickerMode.photoOnly);
    if (!mounted || picked.isCancelled) return;
    final persistedPath = kIsWeb
        ? picked.path
        : await ImageStorage.persistFromPath(picked.path);
    if (!mounted) return;
    setState(() {
      if (kIsWeb) {
        _photoBytes = picked.bytes;
        if (picked.bytes != null && picked.name != null) {
          final ext = picked.name!.split('.').last;
          final base64 = base64Encode(picked.bytes!);
          _photoPath = 'data:image/$ext;base64,$base64';
        }
      } else {
        _photoPath = persistedPath;
        _photoBytes = null;
      }
    });
  }

  Future<void> _pickPdf() async {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    if (!provider.canAddDocumentToItem(
      currentDocumentsCount: _documents.length,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.of(context).itemFreePdfLimitSingle),
          duration: const Duration(seconds: 3),
        ),
      );
      context.push('/pro');
      return;
    }

    final picked = await NativePicker.pick(
      context,
      mode: PickerMode.photoOrDocument,
    );
    if (!mounted || picked.isCancelled) return;

    // For images picked via camera/gallery, wrap into a PlatformFile-like path
    // For documents picked via file_picker, path is already set
    final String? resolvedPath;
    if (kIsWeb) {
      if (picked.bytes == null) return;
      final ext = (picked.name ?? 'file').split('.').last.toLowerCase();
      final mime = _mimeFromExtension(ext);
      resolvedPath = 'data:$mime;base64,${base64Encode(picked.bytes!)}';
    } else {
      resolvedPath = picked.path;
    }
    if (resolvedPath == null || resolvedPath.isEmpty) return;

    final details = await _askDocumentDetails(
      initialName: _stripPdfExtension(picked.name ?? 'document'),
    );
    if (!mounted || details == null) return;

    setState(() {
      _documents.add(
        _ItemDocumentDraft(
          name: details.name,
          type: details.type,
          expiryDate: details.expiryDate,
          notifyBeforeDays: details.notifyBeforeDays,
          file: PlatformFile(
            name: picked.name ?? 'document',
            size: picked.bytes?.length ?? 0,
            path: resolvedPath,
            bytes: picked.bytes,
          ),
        ),
      );
    });
  }

  String _mimeFromExtension(String ext) {
    final e = ext.toLowerCase();
    if (e == 'pdf') return 'application/pdf';
    if (e == 'png') return 'image/png';
    if (e == 'jpg' || e == 'jpeg') return 'image/jpeg';
    return 'application/octet-stream';
  }

  PlatformFile? _normalizePickedDocument(PlatformFile file) {
    if (kIsWeb) {
      if (file.bytes == null) return null;

      final ext = (file.extension ?? '').toLowerCase();
      final mime = _mimeFromExtension(ext);
      final base64Data = base64Encode(file.bytes!);
      final dataUrl = 'data:$mime;base64,$base64Data';

      return PlatformFile(
        name: file.name,
        size: file.size,
        path: dataUrl,
        bytes: file.bytes,
      );
    }

    if (file.path == null) return null;
    return file;
  }

  void _removeDocument(_ItemDocumentDraft doc) =>
      setState(() => _documents.remove(doc));

  IconData _documentIconForPath(String path) {
    final normalized = path.toLowerCase();
    if (normalized.endsWith('.png') ||
        normalized.endsWith('.jpg') ||
        normalized.endsWith('.jpeg')) {
      return Icons.image_rounded;
    }
    return Icons.picture_as_pdf_rounded;
  }

  Color _documentIconColorForPath(ColorScheme colors, String path) {
    final normalized = path.toLowerCase();
    if (normalized.endsWith('.png') ||
        normalized.endsWith('.jpg') ||
        normalized.endsWith('.jpeg')) {
      return colors.primary;
    }
    return colors.error;
  }

  Future<void> _openDocumentPath(String path) async {
    try {
      if (path.trim().isEmpty) throw Exception('Empty path');

      // Web: base64 data URL
      if (kIsWeb && path.startsWith('data:')) {
        await WebDocumentOpener.openDataUrlInNewTab(path, windowName: '_blank');
        return;
      }

      // HTTP / HTTPS
      if (path.startsWith('http://') || path.startsWith('https://')) {
        final ok = await launchUrl(
          Uri.parse(path),
          mode: LaunchMode.externalApplication,
        );
        if (!ok) throw Exception('launchUrl failed for http(s)');
        return;
      }

      // Android content URI (SAF / picker système)
      if (path.startsWith('content://')) {
        final ok = await launchUrl(
          Uri.parse(path),
          mode: LaunchMode.externalApplication,
        );
        if (!ok) throw Exception('launchUrl failed for content://');
        return;
      }

      // Fichier local classique
      final ok = await launchUrl(
        Uri.file(path),
        mode: LaunchMode.externalApplication,
      );
      if (!ok) throw Exception('launchUrl failed for file');
    } catch (e) {
      if (!mounted) return;
      final strings = AppStrings.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.settingsOpenDocumentFailed),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _shareDocument(_ItemDocumentDraft doc) async {
    try {
      final path = doc.file.path ?? '';
      if (path.trim().isEmpty) throw Exception('Empty path');

      if (kIsWeb) {
        if (path.startsWith('data:')) {
          final objectUrl = await WebDocumentOpener.createObjectUrlFromDataUrl(
            path,
          );
          await SharePlus.instance.share(ShareParams(text: objectUrl));
          return;
        }
        await SharePlus.instance.share(ShareParams(text: path));
        if (path.startsWith('data:')) {
          final objectUrl = await WebDocumentOpener.createObjectUrlFromDataUrl(
            path,
          );
          await SharePlus.instance.share(ShareParams(text: objectUrl));
          return;
        }
        await SharePlus.instance.share(ShareParams(text: path));
        return;
      }

      await SharePlus.instance.share(
        ShareParams(files: [XFile(path)], text: doc.name),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.of(context).settingsPickFileError('share')),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _editDocument(_ItemDocumentDraft doc) async {
    final strings = AppStrings.of(context);
    final details = await _askDocumentDetails(
      initialName: doc.name,
      initialType: doc.type,
    );
    if (!mounted || details == null) return;

    setState(() {
      final idx = _documents.indexOf(doc);
      if (idx < 0) return;
      _documents[idx] = _ItemDocumentDraft(
        file: doc.file,
        name: details.name,
        type: details.type,
        expiryDate: details.expiryDate,
        notifyBeforeDays: details.notifyBeforeDays,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.settingsDocumentUpdatedSuccess),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<_DocumentDetails?> _askDocumentDetails({
    required String initialName,
    String? initialType,
  }) async {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final nameController = TextEditingController(
      text: initialName.isEmpty ? strings.itemDefaultDocumentName : initialName,
    );

    String selectedType = _documentTypes.contains(initialType)
        ? initialType!
        : _documentTypes.first;
    DateTime? expiryDate;
    int selectedNotifyDays = 0;

    return showDialog<_DocumentDetails?>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(strings.settingsDocumentDetailsTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                strings.settingsDocumentNameLabel,
                style: textStyles.labelMedium?.copyWith(
                  color: colors.secondary,
                ),
              ),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () => nameController.clear(),
                  ),
                ),
                textInputAction: TextInputAction.next,
              ),
              const Gap(16),
              Text(
                strings.settingsDocumentTypeLabel,
                style: textStyles.labelMedium?.copyWith(
                  color: colors.secondary,
                ),
              ),
              DropdownButtonFormField<String>(
                value: selectedType,
                style: textStyles.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w400,
                ),
                decoration: const InputDecoration(),
                items: _documentTypes
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(strings.itemDocumentTypeLabelForValue(t)),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => selectedType = v);
                },
              ),
              const Gap(16),
              Text(
                strings.docExpiryDateLabel,
                style: textStyles.labelMedium?.copyWith(
                  color: colors.secondary,
                ),
              ),
              const Gap(8),
              Row(
                children: [
                  Expanded(
                    child: expiryDate == null
                        ? OutlinedButton.icon(
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365 * 20),
                                ),
                              );
                              if (pickedDate != null) {
                                setState(
                                  () => expiryDate = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.calendar_today_rounded,
                              size: 16,
                            ),
                            label: Text(strings.selectDateLabel),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: colors.outline),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 16,
                                  color: colors.primary,
                                ),
                                const Gap(8),
                                Expanded(
                                  child: Text(
                                    AppDateFormats.formatDateShort(
                                      context,
                                      expiryDate!,
                                    ),
                                    style: textStyles.bodyMedium,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() {
                                    expiryDate = null;
                                    selectedNotifyDays = 0;
                                  }),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: colors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
              if (expiryDate != null) ...[
                const Gap(16),
                Text(
                  strings.docExpiryNotifyLabel,
                  style: textStyles.labelMedium?.copyWith(
                    color: colors.secondary,
                  ),
                ),
                const Gap(8),
                DropdownButtonFormField<int>(
                  value: selectedNotifyDays > 0 ? selectedNotifyDays : 0,
                  style: textStyles.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: const InputDecoration(),
                  items: [
                    DropdownMenuItem<int>(
                      value: 0,
                      child: Text(strings.docExpiryNotifyNone),
                    ),
                    DropdownMenuItem<int>(
                      value: 7,
                      child: Text(strings.docExpiryNotifyOneWeek),
                    ),
                    DropdownMenuItem<int>(
                      value: 30,
                      child: Text(strings.docExpiryNotifyOneMonth),
                    ),
                    DropdownMenuItem<int>(
                      value: 90,
                      child: Text(strings.docExpiryNotifyThreeMonths),
                    ),
                  ],
                  onChanged: (v) => setState(() => selectedNotifyDays = v ?? 0),
                ),
                const Gap(8),
                Text(
                  strings.docExpiryNotifyHint,
                  style: textStyles.bodySmall?.copyWith(
                    color: colors.secondary,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () async {
                final remindersReady = await provider
                    .ensureDocumentReminderEnabled(
                      notifyBeforeDays: selectedNotifyDays,
                    );
                if (!remindersReady) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(strings.documentPushPermissionDenied),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                  return;
                }

                final name = nameController.text.trim();
                Navigator.pop(
                  context,
                  _DocumentDetails(
                    name: name.isEmpty ? strings.itemDefaultDocumentName : name,
                    type: selectedType,
                    expiryDate: expiryDate,
                    notifyBeforeDays: selectedNotifyDays,
                  ),
                );
              },
              child: Text(strings.settingsAdd),
            ),
          ],
        ),
      ),
    );
  }

  String _stripPdfExtension(String name) {
    final trimmed = name.trim();
    if (trimmed.toLowerCase().endsWith('.pdf')) {
      return trimmed.substring(0, trimmed.length - 4);
    }
    return trimmed;
  }

  Future<void> _saveItem() async {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final strings = AppStrings.of(context);
    setState(() {
      _caliberError = false;
    });

    final documents = _documents
        .map(
          (d) => ItemDocument(
            path: d.file.path ?? '',
            name: d.name,
            type: d.type,
            expiryDate: d.expiryDate,
            notifyBeforeDays: d.notifyBeforeDays,
          ),
        )
        .where((d) => d.path.isNotEmpty)
        .toList();

    setState(() {
      _primaryNameError = _nameController.text.trim().isEmpty;

      if (_selectedCategory == 'PLATEFORME') {
        _caliberError = _caliberController.text.trim().isEmpty;
        _platformTypeError = _selectedPlatformType.trim().isEmpty;
        _ammoQuantityError = false;
        _accessoryTypeError = false;
        _batteryDateError = false;
      } else if (_selectedCategory == 'CONSOMMABLE') {
        _caliberError = _caliberController.text.trim().isEmpty;
        final qty = int.tryParse(_quantityController.text.trim()) ?? 0;
        _ammoQuantityError = qty <= 0;
        _platformTypeError = false;
        _accessoryTypeError = false;
        _batteryDateError = false;
      } else {
        // ACCESSOIRE
        final typeValue = _isAccessoryTypeCustom
            ? _typeController.text.trim()
            : _selectedAccessoryType.trim();
        final trackingType = _trackingAccessoryType;
        final batteryTrackingEnabled = _canTrackAccessoryBattery(trackingType);
        _accessoryTypeError = typeValue.isEmpty;
        _caliberError = false;
        _platformTypeError = false;
        _ammoQuantityError = false;
        _batteryDateError =
            batteryTrackingEnabled &&
            _trackBattery &&
            _batteryChangedAt == null;
      }
    });

    Future<void> scrollTo(GlobalKey key) async {
      final ctx = key.currentContext;
      if (ctx == null) return;
      await Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
    }

    if (_primaryNameError) {
      scrollTo(_primaryNameFieldKey);
      return;
    }
    if (_caliberError) {
      scrollTo(_caliberFieldKey);
      return;
    }
    if (_platformTypeError) {
      scrollTo(_platformTypeFieldKey);
      return;
    }
    if (_ammoQuantityError) {
      scrollTo(_ammoQuantityFieldKey);
      return;
    }
    if (_accessoryTypeError) {
      scrollTo(_accessoryTypeFieldKey);
      return;
    }
    if (_batteryDateError) {
      scrollTo(_batteryDateFieldKey);
      return;
    }

    if (_selectedCategory == 'PLATEFORME') {
      final existing = _isEditMode && widget.itemId != null
          ? provider.getPlatformById(widget.itemId!)
          : null;
      final initialRounds = int.tryParse(_initialRoundsController.text) ?? 0;
      final platform = Platform(
        id: _isEditMode
            ? widget.itemId!
            : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        model: _brandController.text.isEmpty
            ? _nameController.text
            : _brandController.text,
        comment: _commentController.text.trim(),
        type: _selectedPlatformType,
        caliber: _caliberController.text,
        serialNumber: _serialController.text,
        weight: double.tryParse(_weightController.text) ?? 0.0,
        totalRounds: initialRounds,
        lastCleaned: existing?.lastCleaned ?? DateTime.now(),
        lastRevised:
            existing?.lastRevised ?? (existing?.lastCleaned ?? DateTime.now()),
        lastUsed: existing?.lastUsed,
        trackWear: _trackWear,
        trackCleanliness: _trackCleanliness,
        trackRounds: _trackRounds,
        cleaningRoundsThreshold:
            int.tryParse(_cleaningRoundsThresholdController.text) ?? 500,
        wearRoundsThreshold:
            int.tryParse(_wearRoundsThresholdController.text) ?? 10000,
        roundsAtLastCleaning: existing?.roundsAtLastCleaning ?? initialRounds,
        roundsAtLastRevision: existing?.roundsAtLastRevision ?? initialRounds,
        photoPath: _photoPath,
        documents: documents,
        linkedAccessoryIds: _linkedAccessoryIds.toList(growable: false),
      );

      if (_isEditMode) {
        provider.updatePlatform(platform);
      } else {
        if (!provider.canAddPlatform()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.getLimitMessage('platform')),
              duration: const Duration(seconds: 3),
            ),
          );
          context.push('/pro');
          return;
        }
        provider.addPlatform(platform);
      }

      _syncPlatformAccessoryLinks(
        provider: provider,
        platformId: platform.id,
        desiredAccessoryIds: _linkedAccessoryIds,
      );
    } else if (_selectedCategory == 'CONSOMMABLE') {
      final ammoType = _isAmmoProjectileTypeCustom
          ? _ammoTypeController.text.trim()
          : _selectedAmmoProjectileType;

      // Stock logic:
      // - quantity = current stock
      // - initialQuantity = baseline "stock de départ" (used for progress/criticality)
      // If the user doesn't explicitly provide an initial stock (field left at 0),
      // default baseline to the entered quantity.
      final parsedQuantity =
          int.tryParse(
            _quantityController.text.isEmpty
                ? _initialRoundsController.text
                : _quantityController.text,
          ) ??
          0;
      final parsedInitial = int.tryParse(_initialRoundsController.text);
      final effectiveInitial = (parsedInitial == null || parsedInitial <= 0)
          ? parsedQuantity
          : parsedInitial;
      final ammo = Ammo(
        id: _isEditMode
            ? widget.itemId!
            : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        brand: _brandController.text,
        caliber: _caliberController.text,
        comment: _commentController.text.trim(),
        projectileType: ammoType,
        quantity: parsedQuantity,
        initialQuantity: effectiveInitial,
        lastUsed: null,
        trackStock: _trackStock,
        lowStockThreshold:
            int.tryParse(_lowStockThresholdController.text) ?? 50,
        photoPath: _photoPath,
        documents: documents,
        unitPrice: double.tryParse(_unitPriceController.text.trim()),
        currency: _selectedCurrency,
      );

      if (_isEditMode) {
        final existingAmmo = provider.ammos
            .where((a) => a.id == widget.itemId)
            .firstOrNull;
        provider.updateAmmo(
          ammo.copyWith(history: existingAmmo?.history ?? const []),
        );
      } else {
        if (!provider.canAddAmmo()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.getLimitMessage('ammo')),
              duration: const Duration(seconds: 3),
            ),
          );
          context.push('/pro');
          return;
        }
        provider.addAmmo(ammo);
      }
    } else {
      // ACCESSOIRE
      final existing = _isEditMode
          ? provider.accessories.where((a) => a.id == widget.itemId).firstOrNull
          : null;
      final model = _nameController.text.trim();
      final brand = _brandController.text.trim();
      final type = _isAccessoryTypeCustom
          ? (_typeController.text.trim().isEmpty
                ? strings.settingsDocumentTypeOther
                : _typeController.text.trim())
          : _selectedAccessoryType;

      final trackingType = _isAccessoryTypeCustom ? '__custom__' : type;
      final wearEnabled = _canTrackAccessoryWear(trackingType);
      final cleanlinessEnabled = _canTrackAccessoryCleanliness(trackingType);
      final batteryEnabled = _canTrackAccessoryBattery(trackingType);

      final displayName = [
        brand,
        model,
      ].where((s) => s.isNotEmpty).join(' ').trim();

      final accessory = Accessory(
        id: _isEditMode
            ? widget.itemId!
            : DateTime.now().millisecondsSinceEpoch.toString(),
        name: displayName.isEmpty
            ? strings.quickActionLabelAccessory
            : displayName,
        brand: brand,
        model: model,
        comment: _commentController.text.trim(),
        type: type,
        lastUsed: existing?.lastUsed,
        totalRounds: existing?.totalRounds ?? 0,
        lastCleaned: existing?.lastCleaned ?? DateTime.now(),
        lastRevised:
            existing?.lastRevised ?? (existing?.lastCleaned ?? DateTime.now()),
        trackWear: wearEnabled ? _trackWear : false,
        trackCleanliness: cleanlinessEnabled ? _trackCleanliness : false,
        cleaningRoundsThreshold: cleanlinessEnabled
            ? (int.tryParse(_cleaningRoundsThresholdController.text) ?? 500)
            : 500,
        wearRoundsThreshold: wearEnabled
            ? (int.tryParse(_wearRoundsThresholdController.text) ?? 10000)
            : 10000,
        roundsAtLastCleaning:
            existing?.roundsAtLastCleaning ?? (existing?.totalRounds ?? 0),
        roundsAtLastRevision:
            existing?.roundsAtLastRevision ?? (existing?.totalRounds ?? 0),
        batteryChangedAt: batteryEnabled && _trackBattery
            ? (_batteryChangedAt ??
                  existing?.batteryChangedAt ??
                  DateTime.now())
            : null,
        trackBattery: batteryEnabled ? _trackBattery : false,
        photoPath: _photoPath,
        documents: documents,
        linkedPlatformIds: _linkedPlatformIds.toList(growable: false),
      );

      if (_isEditMode) {
        provider.updateAccessory(accessory);
      } else {
        if (!provider.canAddAccessory()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(provider.getLimitMessage('accessory')),
              duration: const Duration(seconds: 3),
            ),
          );
          context.push('/pro');
          return;
        }
        provider.addAccessory(accessory);
      }

      _syncAccessoryPlatformLinks(
        provider: provider,
        accessoryId: accessory.id,
        desiredPlatformIds: _linkedPlatformIds,
      );
    }

    context.pop();
  }
}

class ItemLinkMultiSelectSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final Set<String> initialSelection;
  final String Function(T item) idOf;
  final String Function(T item) labelOf;
  final String Function(T item) subtitleOf;
  final IconData icon;

  const ItemLinkMultiSelectSheet({
    required this.title,
    required this.items,
    required this.initialSelection,
    required this.idOf,
    required this.labelOf,
    required this.subtitleOf,
    required this.icon,
  });

  @override
  State<ItemLinkMultiSelectSheet<T>> createState() =>
      _ItemLinkMultiSelectSheetState<T>();
}

class _ItemLinkMultiSelectSheetState<T>
    extends State<ItemLinkMultiSelectSheet<T>> {
  late final Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set<String>.from(widget.initialSelection);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    return SafeArea(
      top: false,
      child: FractionallySizedBox(
        heightFactor: 0.82,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: LightColors.iconInactive.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(AppSpacing.md),
              Padding(
                padding: AppSpacing.paddingLg,
                child: Row(
                  children: [
                    Icon(widget.icon, color: colors.primary, size: 20),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Divider(color: colors.outline),
              ),
              Expanded(
                child: widget.items.isEmpty
                    ? Center(
                        child: Padding(
                          padding: AppSpacing.paddingLg,
                          child: Text(
                            strings.settingsDocumentsEmptyTitle,
                            style: textStyles.bodyMedium?.copyWith(
                              color: colors.secondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: AppSpacing.paddingMd,
                        itemBuilder: (context, index) {
                          final item = widget.items[index];
                          final id = widget.idOf(item);
                          final selected = _selectedIds.contains(id);
                          return CheckboxListTile(
                            value: selected,
                            onChanged: (checked) {
                              setState(() {
                                if (checked ?? false) {
                                  _selectedIds.add(id);
                                } else {
                                  _selectedIds.remove(id);
                                }
                              });
                            },
                            title: Text(widget.labelOf(item)),
                            subtitle: Text(widget.subtitleOf(item)),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: AppSpacing.paddingSm,
                          );
                        },
                        separatorBuilder: (_, __) =>
                            Divider(color: colors.outline, height: 1),
                        itemCount: widget.items.length,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Divider(color: colors.outline),
              ),
              Padding(
                padding: AppSpacing.paddingLg,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus(); // Fermer le clavier
                          Navigator.of(context).pop();
                        },
                        child: Text(strings.cancel),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus(); // Fermer le clavier
                          Navigator.of(context).pop(_selectedIds);
                        },
                        child: Text(strings.validate),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackingToggle extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _TrackingToggle({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textStyles.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(4),
              Text(
                subtitle,
                style: textStyles.bodySmall?.copyWith(color: colors.secondary),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: colors.primary,
        ),
      ],
    );
  }
}

class DottedBorderPlaceholder extends StatelessWidget {
  final Widget child;
  const DottedBorderPlaceholder({Key? key, required this.child})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
