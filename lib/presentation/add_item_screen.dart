import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import '../data/thot_provider.dart';
import '../data/models.dart';
import '../theme.dart';
import '../widgets/cross_platform_image.dart';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/utils/app_date_formats.dart';
import 'package:thot/utils/web_document_opener.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

class _AddItemScreenState extends State<AddItemScreen> {
  String _selectedCategory = 'ARME'; // ARME, MUNITION, ACCESSOIRE
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
    'Entretien',
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
    'Modérateurs',
    'Réducteur de son',
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

  static const List<String> _weaponTypes = [
    'Pistolet semi-auto',
    'Révolver',
    'Pistolet mitrailleur',
    "Fusil d'assaut",
    'Fusil mitrailleur',
    'Carabine',
    'Fusil à pompe',
    'Fusil de chasse',
    'Fusil de précision',
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

  String _selectedAccessoryType = _accessoryTypes.first;
  bool _isAccessoryTypeCustom = false;

  String _selectedWeaponType = _weaponTypes.first;

  String _selectedAmmoProjectileType = _ammoProjectileTypes.first;
  bool _isAmmoProjectileTypeCustom = false;
  
  // Tracking toggles
  bool _trackWear = true;
  bool _trackCleanliness = true;
  bool _trackRounds = true;
  bool _trackStock = true;
  bool _trackBattery = false;
  DateTime? _batteryChangedAt;

  final _primaryNameFieldKey = GlobalKey();
  final _caliberFieldKey = GlobalKey();
  final _weaponTypeFieldKey = GlobalKey();
  final _ammoQuantityFieldKey = GlobalKey();
  final _accessoryTypeFieldKey = GlobalKey();
  final _batteryDateFieldKey = GlobalKey();

  bool _primaryNameError = false;
  bool _caliberError = false;
  bool _weaponTypeError = false;
  bool _ammoQuantityError = false;
  bool _accessoryTypeError = false;
  bool _batteryDateError = false;
  final Set<String> _linkedAccessoryIds = {};
  final Set<String> _linkedWeaponIds = {};
  
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
    _commentController.dispose();
    _lowStockThresholdController.dispose();
    _cleaningRoundsThresholdController.dispose();
    _wearRoundsThresholdController.dispose();
    super.dispose();
  }
  
  void _loadItem() {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    
    if (_selectedCategory == 'ARME') {
      final weapon = provider.weapons.where((w) => w.id == widget.itemId).firstOrNull;
      if (weapon == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.of(context).itemNotFound)),
        );
        context.pop();
        return;
      }
      setState(() {
        _nameController.text = weapon.name;
        _brandController.text = weapon.model;
        _caliberController.text = weapon.caliber;
        _serialController.text = weapon.serialNumber;
        _weightController.text = weapon.weight == 0 ? '' : weapon.weight.toString();
        _initialRoundsController.text = weapon.totalRounds.toString();
        _commentController.text = weapon.comment;
        _selectedWeaponType = _weaponTypes.contains(weapon.type) ? weapon.type : _weaponTypes.first;
        _photoPath = weapon.photoPath;
        _documents = weapon.documents
            .map((d) => _ItemDocumentDraft(
                  name: d.name,
                  type: d.type,
                  file: PlatformFile(name: d.name, path: d.path, size: 0),
                ))
            .toList();
        _trackWear = weapon.trackWear;
        _trackCleanliness = weapon.trackCleanliness;
        _trackRounds = weapon.trackRounds;
        _cleaningRoundsThresholdController.text = weapon.cleaningRoundsThreshold.toString();
        _wearRoundsThresholdController.text = weapon.wearRoundsThreshold.toString();
        _linkedAccessoryIds
          ..clear()
          ..addAll(weapon.linkedAccessoryIds);
      });
    } else if (_selectedCategory == 'MUNITION') {
      final ammo = provider.ammos.where((a) => a.id == widget.itemId).firstOrNull;
      if (ammo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.of(context).itemNotFound)),
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
        _commentController.text = ammo.comment;
        _lowStockThresholdController.text = ammo.lowStockThreshold.toString();
        _photoPath = ammo.photoPath;
        _documents = ammo.documents
            .map((d) => _ItemDocumentDraft(
                  name: d.name,
                  type: d.type,
                  file: PlatformFile(name: d.name, path: d.path, size: 0),
                ))
            .toList();
        _trackStock = ammo.trackStock;
        final known = _ammoProjectileTypes.contains(ammo.projectileType) ? ammo.projectileType : _ammoProjectileTypes.first;
        _isAmmoProjectileTypeCustom = ammo.projectileType.isNotEmpty && !_ammoProjectileTypes.contains(ammo.projectileType);
        _selectedAmmoProjectileType = _isAmmoProjectileTypeCustom ? _ammoProjectileTypes.first : known;
        _ammoTypeController.text = _isAmmoProjectileTypeCustom ? ammo.projectileType : '';
      });
    } else {
      final accessory = provider.accessories.where((a) => a.id == widget.itemId).firstOrNull;
      if (accessory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.of(context).itemNotFound)),
        );
        context.pop();
        return;
      }
      setState(() {
        _nameController.text = accessory.model.isNotEmpty ? accessory.model : accessory.name;
        _brandController.text = accessory.brand;
        _commentController.text = accessory.comment;

        // Prefer a known dropdown option when possible, otherwise fall back to custom.
        final known = _accessoryTypes.contains(accessory.type) ? accessory.type : 'Divers';
        _selectedAccessoryType = known;
        _isAccessoryTypeCustom = !_accessoryTypes.contains(accessory.type);
        _typeController.text = _isAccessoryTypeCustom ? accessory.type : '';

        _photoPath = accessory.photoPath;
        _documents = accessory.documents
            .map((d) => _ItemDocumentDraft(
                  name: d.name,
                  type: d.type,
                  file: PlatformFile(name: d.name, path: d.path, size: 0),
                ))
            .toList();
        _trackBattery = accessory.trackBattery;
        _batteryChangedAt = accessory.batteryChangedAt;

        _trackWear = accessory.trackWear;
        _trackCleanliness = accessory.trackCleanliness;
        _cleaningRoundsThresholdController.text =
            accessory.cleaningRoundsThreshold.toString();
        _wearRoundsThresholdController.text =
            accessory.wearRoundsThreshold.toString();
        _linkedWeaponIds
          ..clear()
          ..addAll(accessory.linkedWeaponIds);
      });
    }
  }

  void _syncWeaponAccessoryLinks({
    required ThotProvider provider,
    required String weaponId,
    required Set<String> desiredAccessoryIds,
  }) {
    final currentAccessoryIds =
        provider.linkedAccessoriesForWeapon(weaponId).map((a) => a.id).toSet();

    for (final accessoryId in desiredAccessoryIds.difference(currentAccessoryIds)) {
      provider.linkWeaponToAccessory(
        weaponId: weaponId,
        accessoryId: accessoryId,
      );
    }

    for (final accessoryId in currentAccessoryIds.difference(desiredAccessoryIds)) {
      provider.unlinkWeaponFromAccessory(
        weaponId: weaponId,
        accessoryId: accessoryId,
      );
    }
  }

  void _syncAccessoryWeaponLinks({
    required ThotProvider provider,
    required String accessoryId,
    required Set<String> desiredWeaponIds,
  }) {
    final currentWeaponIds =
        provider.linkedWeaponsForAccessory(accessoryId).map((w) => w.id).toSet();

    for (final weaponId in desiredWeaponIds.difference(currentWeaponIds)) {
      provider.linkWeaponToAccessory(
        weaponId: weaponId,
        accessoryId: accessoryId,
      );
    }

    for (final weaponId in currentWeaponIds.difference(desiredWeaponIds)) {
      provider.unlinkWeaponFromAccessory(
        weaponId: weaponId,
        accessoryId: accessoryId,
      );
    }
  }

  Future<bool> _confirmUnlink() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text('Êtes-vous sûr de vouloir délier cet élément ?'),
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
      builder: (context) => _ItemLinkMultiSelectSheet(
        title: 'Lier des accessoires',
        items: provider.accessories,
        initialSelection: _linkedAccessoryIds,
        labelOf: (a) => a.name,
        subtitleOf: (a) => [if (a.type.trim().isNotEmpty) a.type, if (a.brand.trim().isNotEmpty) a.brand].join(' • '),
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
  }

  Future<void> _editLinkedWeapons(ThotProvider provider) async {
    final updated = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ItemLinkMultiSelectSheet(
        title: 'Lier des armes',
        items: provider.weapons,
        initialSelection: _linkedWeaponIds,
        labelOf: (w) => w.name,
        subtitleOf: (w) => [if (w.type.trim().isNotEmpty) w.type, if (w.caliber.trim().isNotEmpty) w.caliber].join(' • '),
        idOf: (w) => w.id,
        icon: Icons.sports_martial_arts_rounded,
      ),
    );
    if (!mounted || updated == null) return;
    setState(() {
      _linkedWeaponIds
        ..clear()
        ..addAll(updated);
    });
  }

  Future<void> _pickBatteryChangedDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _batteryChangedAt ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    setState(() => _batteryChangedAt = DateTime(picked.year, picked.month, picked.day));
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
    if (_isEditMode) return _sentenceCase(_pageTitle());
    return _pageTitle();
  }

  Widget _headerIcon(ColorScheme colors) {
    switch (_selectedCategory) {
      case 'ARME':
        return SvgPicture.asset(
          'assets/images/gun.svg',
          width: 18,
          height: 18,
          colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
        );
      case 'MUNITION':
        return SvgPicture.asset(
          'assets/images/bullet.svg',
          width: 18,
          height: 18,
          colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
        );
      default:
        return Icon(Icons.inventory_2_rounded,
            size: 18, color: colors.primary);
    }
  }

  String _primaryNameLabel() => AppStrings.of(context).itemPrimaryNameLabel(_selectedCategory);

  String _primaryNameHint() => AppStrings.of(context).itemPrimaryNameHint(_selectedCategory);

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
        backgroundColor: baseBackground,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 12,
                  20,
                  12,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border(bottom: BorderSide(color: colors.outline)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      color: colors.onSurface,
                      onPressed: () => context.pop(),
                    ),
                    Text(
                      _headerTitle(strings),
                      style: textStyles.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    // Form
                    Row(
                      children: [
                  Icon(Icons.edit_note_rounded, size: 18, color: colors.primary),
                  const Gap(8),
                  Text(
                    _sentenceCase(_primaryNameLabel()),
                    style: textStyles.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
              const Gap(8),
              Container(
                key: _primaryNameFieldKey,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: _primaryNameError ? colors.error : colors.outline,
                    width: 1.4,
                  ),
                ),
                child: TextField(
                  controller: _nameController,
                  onChanged: (_) {
                    if (_primaryNameError && _nameController.text.trim().isNotEmpty) {
                      setState(() => _primaryNameError = false);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: _primaryNameHint(),
                    helperText:
                        _primaryNameError ? strings.requiredFieldError : null,
                    helperStyle:
                        textStyles.bodySmall?.copyWith(color: colors.error),
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
                      borderSide:
                          BorderSide(color: colors.primary, width: 2),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: BorderSide(color: colors.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      borderSide: BorderSide(color: colors.error, width: 2),
                    ),
                  ),
                ),
              ),
              const Gap(AppSpacing.lg),

              // Category-specific fields
              if (_selectedCategory == 'ARME') ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.sell_rounded,
                                  size: 18, color: colors.primary),
                              const Gap(8),
                              Text(_sentenceCase(strings.brandModelLabel),
                              style: textStyles.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colors.onSurface)),
                            ],
                          ),
                          const Gap(8),
                          TextField(
                            controller: _brandController,
                            decoration: InputDecoration(
                              hintText: strings.itemWeaponBrandHint,
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
                                borderSide:
                                    BorderSide(color: colors.primary, width: 1.6),
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
                              Icon(Icons.straighten_rounded,
                                  size: 18, color: colors.primary),
                              const Gap(8),
                              Text(_sentenceCase(strings.caliberLabel),
                              style: textStyles.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colors.onSurface)),
                            ],
                          ),
                          const Gap(8),
                          TextField(
                            controller: _caliberController,
                            onChanged: (_) {
                              if (_caliberError &&
                                  _caliberController.text.trim().isNotEmpty) {
                                setState(() => _caliberError = false);
                              }
                            },
                            decoration: InputDecoration(
                              hintText: strings.itemCaliberHint,
                              helperText:
                                  _caliberError
                                      ? strings.requiredFieldError
                                      : null,
                              helperStyle: textStyles.bodySmall
                                  ?.copyWith(color: colors.error),
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
                                borderSide:
                                    BorderSide(color: colors.primary, width: 1.6),
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
                    Icon(Icons.category_rounded,
                        size: 18, color: colors.primary),
                    const Gap(8),
                    Text(_sentenceCase(strings.typeLabel),
                    style: textStyles.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: colors.onSurface)),
                  ],
                ),
                const Gap(8),
                Container(
                  key: _weaponTypeFieldKey,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: _weaponTypeError ? colors.error : colors.outline,
                      width: 1.4,
                    ),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedWeaponType,
                    decoration: InputDecoration(
                      helperText:
                          _weaponTypeError ? strings.requiredFieldError : null,
                      helperStyle:
                          textStyles.bodySmall?.copyWith(color: colors.error),
                      filled: true,
                      fillColor: colors.surface,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide:
                              BorderSide(color: colors.primary, width: 1.6)),
                    ),
                    items: _weaponTypes
                        .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(strings.itemWeaponTypeLabel(t)),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _selectedWeaponType = v;
                        _weaponTypeError = false;
                      });
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
                              Icon(Icons.confirmation_number_rounded,
                                  size: 18, color: colors.primary),
                              const Gap(8),
                              Text(_sentenceCase(strings.serialNumberLabel),
                              style: textStyles.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colors.onSurface)),
                            ],
                          ),
                          const Gap(8),
                          TextField(
                            controller: _serialController,
                            decoration: InputDecoration(
                              hintText: strings.itemSerialNumberHint,
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
                                borderSide:
                                    BorderSide(color: colors.primary, width: 1.6),
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
                              Icon(Icons.scale_rounded,
                                  size: 18, color: colors.primary),
                              const Gap(8),
                              Text(_sentenceCase(strings.weightGramsLabel),
                              style: textStyles.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colors.onSurface)),
                            ],
                          ),
                          const Gap(8),
                          TextField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: strings.itemWeightHint,
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
                                borderSide:
                                    BorderSide(color: colors.primary, width: 1.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              
              if (_selectedCategory == 'MUNITION') ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.sell_rounded,
                                  size: 18, color: colors.primary),
                              const Gap(8),
                              Text(_sentenceCase(strings.brandLabel),
                              style: textStyles.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colors.onSurface)),
                            ],
                          ),
                          const Gap(8),
                          TextField(
                            controller: _brandController,
                            decoration: InputDecoration(
                              hintText: strings.itemAmmoBrandHint,
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
                                borderSide:
                                    BorderSide(color: colors.primary, width: 1.6),
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
                          Text(strings.caliberLabel,
                              style: textStyles.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colors.onSurface)),
                          const Gap(8),
                          TextField(
                            controller: _caliberController,
                            onChanged: (_) {
                              if (_caliberError &&
                                  _caliberController.text.trim().isNotEmpty) {
                                setState(() => _caliberError = false);
                              }
                            },
                            decoration: InputDecoration(
                              hintText: strings.itemCaliberHint,
                              helperText:
                                  _caliberError
                                      ? strings.requiredFieldError
                                      : null,
                              helperStyle: textStyles.bodySmall
                                  ?.copyWith(color: colors.error),
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
                                borderSide:
                                    BorderSide(color: colors.primary, width: 1.6),
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
                    Icon(Icons.category_rounded,
                        size: 18, color: colors.primary),
                    const Gap(8),
                    Text(_sentenceCase(strings.typeLabel),
                    style: textStyles.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: colors.onSurface)),
                  ],
                ),
                const Gap(8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: colors.outline, width: 1.4),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _isAmmoProjectileTypeCustom ? null : _selectedAmmoProjectileType,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colors.surface,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide:
                              BorderSide(color: colors.primary, width: 1.6)),
                    ),
                    items: [
                      ..._ammoProjectileTypes
                          .where((t) => t != 'Autre')
                          .map((t) => DropdownMenuItem(
                                value: t,
                                child: Text(strings.itemProjectileTypeLabel(t)),
                              )),
                      DropdownMenuItem(value: '__custom__', child: Text(strings.customOtherLabel)),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        if (v == '__custom__') {
                          _isAmmoProjectileTypeCustom = true;
                          _selectedAmmoProjectileType = _ammoProjectileTypes.first;
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
                  TextField(
                    controller: _ammoTypeController,
                    decoration: InputDecoration(
                      hintText: strings.itemProjectileCustomHint,
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
                        borderSide: BorderSide(color: colors.primary, width: 1.6),
                      ),
                    ),
                  ),
                ],
                const Gap(AppSpacing.lg),
                Row(
                  children: [
                    Icon(Icons.inventory_2_rounded,
                        size: 18, color: colors.primary),
                    const Gap(8),
                    Text(_sentenceCase(strings.initialQuantityLabel),
                    style: textStyles.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600, color: colors.onSurface)),
                  ],
                ),
                const Gap(8),
                Container(
                  key: _ammoQuantityFieldKey,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: _ammoQuantityError
                          ? colors.error
                          : colors.outline,
                      width: 1.4,
                    ),
                  ),
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) {
                      final qty = int.tryParse(_quantityController.text.trim());
                      if (_ammoQuantityError && (qty ?? 0) > 0) {
                        setState(() => _ammoQuantityError = false);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: strings.itemQuantityHint,
                      suffixText: strings.cartridges,
                      helperText:
                          _ammoQuantityError ? strings.quantityRequiredError : null,
                      helperStyle: textStyles.bodySmall
                          ?.copyWith(color: colors.error),
                      filled: true,
                      fillColor: colors.surface,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: BorderSide.none),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          borderSide:
                              BorderSide(color: colors.primary, width: 1.6)),
                    ),
                  ),
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
                              Icon(Icons.sell_rounded,
                                  size: 18, color: colors.primary),
                              const Gap(8),
                              Text(_sentenceCase(strings.brandLabel),
                              style: textStyles.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: colors.onSurface)),
                            ],
                          ),
                          const Gap(8),
                          TextField(
                            controller: _brandController,
                            decoration: InputDecoration(
                              hintText: strings.itemAccessoryBrandHint,
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
                                borderSide:
                                    BorderSide(color: colors.primary, width: 1.6),
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
                              Icon(Icons.category_rounded,
                                  size: 18, color: colors.primary),
                              const Gap(8),
                              Text(_sentenceCase(strings.typeLabel),
                              style: textStyles.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: colors.onSurface)),
                            ],
                          ),
                          const Gap(8),
                          Container(
                            key: _accessoryTypeFieldKey,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              border: Border.all(
                                color: _accessoryTypeError
                                    ? colors.error
                                    : colors.outline,
                                width: 1.4,
                              ),
                            ),
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              value: _isAccessoryTypeCustom
                                  ? null
                                  : _selectedAccessoryType,
                              decoration: InputDecoration(
                                errorText: _accessoryTypeError
                                    ? strings.requiredFieldError
                                    : null,
                                filled: true,
                                fillColor: colors.surface,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.lg),
                                    borderSide: BorderSide.none),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.lg),
                                    borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.lg),
                                    borderSide: BorderSide(
                                        color: colors.primary, width: 1.6)),
                              ),
                              items: [
                                ..._accessoryTypes.map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(
                                      strings.itemAccessoryTypeLabel(t),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                DropdownMenuItem(
                                    value: '__custom__',
                                    child: Text(strings.customOtherLabel)),
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
                  Text(strings.customTypeLabel,
                      style: textStyles.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: colors.onSurface)),
                  const Gap(8),
                  TextField(
                    controller: _typeController,
                    onChanged: (_) {
                      if (_accessoryTypeError &&
                          _typeController.text.trim().isNotEmpty) {
                        setState(() => _accessoryTypeError = false);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: strings.itemAccessoryCustomTypeHint,
                      errorText:
                          _accessoryTypeError ? strings.requiredFieldError : null,
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
                        borderSide: BorderSide(color: colors.primary, width: 1.6),
                      ),
                    ),
                  ),
                ],
              ],

              if (_selectedCategory == 'ARME' ||
                  _selectedCategory == 'ACCESSOIRE') ...[
                const Gap(AppSpacing.lg),
                // Header with title and link button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.link_rounded, size: 18, color: colors.primary),
                        const Gap(8),
                        Text(
                          'Liaisons',
                          style: textStyles.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                    if (_selectedCategory == 'ARME')
                      ElevatedButton.icon(
                        onPressed: () => _editLinkedAccessories(provider),
                        icon: const Icon(Icons.add_link_rounded, size: 18),
                        label: const Text('Associer des accessoires'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      )
                    else if (_selectedCategory == 'ACCESSOIRE')
                      ElevatedButton.icon(
                        onPressed: () => _editLinkedWeapons(provider),
                        icon: const Icon(Icons.add_link_rounded, size: 18),
                        label: const Text('Associer des armes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
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
                    border: Border.all(color: colors.outline.withValues(alpha: 0.35)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedCategory == 'ARME') ...[
                        if (_linkedAccessoryIds.isEmpty)
                          Text(
                            'Aucun accessoire lié.',
                            style: textStyles.bodySmall
                                ?.copyWith(color: colors.secondary),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: provider.accessories
                                .where((a) => _linkedAccessoryIds.contains(a.id))
                                .map(
                                  (a) => InputChip(
                                    avatar: const Icon(Icons.inventory_2_rounded,
                                        size: 16),
                                    label: Text(a.name),
                                    onDeleted: () async {
                                      if (!await _confirmUnlink()) return;
                                      if (!mounted) return;
                                      setState(
                                        () => _linkedAccessoryIds.remove(a.id),
                                      );
                                    },
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                      if (_selectedCategory == 'ACCESSOIRE') ...[
                        if (_linkedWeaponIds.isEmpty)
                          Text(
                            'Aucune arme liée.',
                            style: textStyles.bodySmall
                                ?.copyWith(color: colors.secondary),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: provider.weapons
                                .where((w) => _linkedWeaponIds.contains(w.id))
                                .map(
                                  (w) => InputChip(
                                    avatar: const Icon(
                                      Icons.sports_martial_arts_rounded,
                                      size: 16,
                                    ),
                                    label: Text(w.name),
                                    onDeleted: () async {
                                      if (!await _confirmUnlink()) return;
                                      if (!mounted) return;
                                      setState(
                                        () => _linkedWeaponIds.remove(w.id),
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
                  Icon(Icons.edit_rounded, size: 18, color: colors.primary),
                  const Gap(8),
                  Text(
                    _sentenceCase(strings.commentOptionalLabel),
                    style: textStyles.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600, color: colors.onSurface),
                  ),
                ],
              ),
              const Gap(8),
              TextField(
                controller: _commentController,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: strings.itemCommentHint,
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
                    borderSide: BorderSide(color: colors.primary, width: 1.6),
                  ),
                ),
              ),
              const Gap(AppSpacing.lg),

              // Photo
              Row(
                children: [
                  Icon(Icons.photo_camera_rounded,
                      size: 18, color: colors.primary),
                  const Gap(8),
                  Text(strings.itemPhotoLabel,
                      style: textStyles.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface)),
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
                              borderRadius: BorderRadius.circular(AppRadius.lg),
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
                                icon: const Icon(Icons.close_rounded, size: 20),
                                onPressed: () => setState(() => _photoPath = null),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_rounded,
                                  color: colors.secondary, size: 40),
                              const Gap(8),
                              Text(strings.clickToAddPhoto,
                                  style: textStyles.bodySmall
                                      ?.copyWith(color: colors.secondary)),
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
        Icon(Icons.picture_as_pdf_rounded, size: 18, color: colors.primary),
        const Gap(8),
        Text(strings.itemDocumentsLabel,
            style: textStyles.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
      ],
    ),
    FilledButton.icon(
      onPressed: _pickPdf,
      icon: const Icon(Icons.add_rounded, size: 18),
      label: Text(strings.settingsAddDocument),
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    ),
  ],
),
const Gap(AppSpacing.md),
if (_documents.isEmpty)
  Container(
    width: double.infinity,
    padding: AppSpacing.paddingLg,
    decoration: BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      border: Border.all(color: colors.outline.withValues(alpha: 0.25)),
      boxShadow: AppShadows.cardPremium,
    ),
    child: Text(
      strings.settingsDocumentsEmptyTitle,
      style: textStyles.bodyMedium?.copyWith(color: colors.secondary),
    ),
  )
else
  ..._documents.map(
    (doc) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => _openDocumentPath(doc.file.path ?? ''),
        child: Container(
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.outline.withValues(alpha: 0.25)),
            boxShadow: AppShadows.cardPremium,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _documentIconForPath(doc.file.path ?? ''),
                color: _documentIconColorForPath(colors, doc.file.path ?? ''),
                size: 24,
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.name,
                      style: textStyles.bodyMedium?.copyWith(
                          color: colors.onSurface, fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      doc.type,
                      style: textStyles.labelSmall?.copyWith(color: colors.secondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert_rounded, color: colors.secondary),
                onSelected: (v) async {
                  switch (v) {
                    case 'share': await _shareDocument(doc); break;
                    case 'edit': await _editDocument(doc); break;
                    case 'delete': _removeDocument(doc); break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(value: 'share', child: Text(strings.sessionMenuShare)),
                  PopupMenuItem<String>(value: 'edit', child: Text(strings.settingsEditDocument)),
                  PopupMenuItem<String>(value: 'delete', child: Text(strings.delete)),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  ),

              const Gap(AppSpacing.lg),

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
                    _sentenceCase(strings.trackingOptionsTitle),
                    style: textStyles.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
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
                  border: Border.all(
                    color: colors.outline,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weapon-specific tracking
                    if (_selectedCategory == 'ARME') ...[
                      _TrackingToggle(
                        label: strings.weaponWearTrackingLabel,
                        subtitle: strings.weaponWearTrackingSubtitle,
                        value: _trackWear,
                        onChanged: (val) => setState(() => _trackWear = val),
                      ),
                      if (_trackWear) ...[
                        const Gap(8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(strings.wearThresholdLabel,
                                  style: textStyles.bodyMedium
                                      ?.copyWith(color: colors.secondary)),
                            ),
                            const Gap(16),
                            SizedBox(
                              width: 132,
                              child: TextField(
                                controller: _wearRoundsThresholdController,
                                textAlign: TextAlign.end,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: colors.surface,
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    borderSide:
                                        BorderSide(color: colors.outline),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    borderSide:
                                        BorderSide(color: colors.outline),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    borderSide: BorderSide(
                                      color: colors.outline,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  suffix: Text(strings.sessionLabelShots,
                                      style: textStyles.bodySmall
                                          ?.copyWith(color: colors.secondary)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Gap(20),
                      _TrackingToggle(
                        label: strings.weaponCleaningTrackingLabel,
                        subtitle: strings.weaponCleaningTrackingSubtitle,
                        value: _trackCleanliness,
                        onChanged: (val) => setState(() => _trackCleanliness = val),
                      ),
                      if (_trackCleanliness) ...[
                        const Gap(8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(strings.cleaningThresholdShotsLabel,
                                  style: textStyles.bodyMedium
                                      ?.copyWith(color: colors.secondary)),
                            ),
                            const Gap(16),
                            SizedBox(
                              width: 132,
                              child: TextField(
                                controller: _cleaningRoundsThresholdController,
                                textAlign: TextAlign.end,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: colors.surface,
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    borderSide:
                                        BorderSide(color: colors.outline),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    borderSide:
                                        BorderSide(color: colors.outline),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    borderSide: BorderSide(
                                      color: colors.outline,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  suffix: Text(strings.sessionLabelShots,
                                      style: textStyles.bodySmall
                                          ?.copyWith(color: colors.secondary)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Gap(20),
                      _TrackingToggle(
                        label: strings.weaponRoundCounterLabel,
                        subtitle: strings.weaponRoundCounterSubtitle,
                        value: _trackRounds,
                        onChanged: (val) => setState(() => _trackRounds = val),
                      ),
                      if (_trackRounds) ...[
                        const Gap(8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(strings.initialRoundCounterLabel,
                                style: textStyles.bodyMedium
                                    ?.copyWith(color: colors.secondary)),
                            SizedBox(
                              width: 132,
                              child: TextField(
                                controller: _initialRoundsController,
                                textAlign: TextAlign.end,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: colors.surface,
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    borderSide:
                                        BorderSide(color: colors.outline),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    borderSide:
                                        BorderSide(color: colors.outline),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    borderSide: BorderSide(
                                      color: colors.outline,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  suffix: Text(
                                    strings.sessionLabelShots,
                                    style: textStyles.bodySmall
                                        ?.copyWith(color: colors.secondary),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                    
                    // Ammo-specific tracking
                    if (_selectedCategory == 'MUNITION') ...[
                      _TrackingToggle(
                        label: strings.stockTrackingLabel,
                        subtitle: strings.stockTrackingSubtitle,
                        value: _trackStock,
                        onChanged: (val) => setState(() => _trackStock = val),
                      ),
                      if (_trackStock) ...[
                        const Gap(8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(strings.stockAlertThresholdLabel,
                                  style: textStyles.bodyMedium
                                      ?.copyWith(color: colors.secondary)),
                            ),
                            const Gap(16),
                            SizedBox(
                              width: 132,
                              child: TextField(
                                controller: _lowStockThresholdController,
                                textAlign: TextAlign.end,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: colors.surface,
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    borderSide:
                                        BorderSide(color: colors.outline),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    borderSide:
                                        BorderSide(color: colors.outline),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.lg),
                                    borderSide: BorderSide(
                                      color: colors.outline,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  suffix: Text(
                                    strings.sessionLabelShots,
                                    style: textStyles.bodySmall
                                        ?.copyWith(color: colors.secondary),
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
                        {
                          'Optiques',
                          'Lampes',
                          'Lasers',
                          'Chronographes',
                          'Timers',
                        }.contains(_isAccessoryTypeCustom ? _typeController.text.trim() : _selectedAccessoryType)) ...[
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
                        const Gap(12),
                        Container(
                          key: _batteryDateFieldKey,
                          padding: AppSpacing.paddingMd,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: _batteryDateError
                                  ? colors.error
                                  : colors.outline,
                              width: _batteryDateError ? 1.4 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      strings.lastChangeLabel,
                                      style: textStyles.bodySmall
                                          ?.copyWith(color: colors.secondary),
                                    ),
                                    const Gap(4),
                                    Text(
                                      _batteryChangedAt == null
                                          ? strings.selectDateLabel
                                          : AppDateFormats.formatDateShort(
                                              context, _batteryChangedAt!),
                                      style: textStyles.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(12),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  await _pickBatteryChangedDate();
                                  if (_batteryDateError && _batteryChangedAt != null) {
                                    if (mounted) {
                                      setState(() => _batteryDateError = false);
                                    }
                                  }
                                },
                                icon: const Icon(Icons.calendar_month_rounded, size: 18),
                                label: Text(strings.calendarLabel),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],

                    // Accessory maintenance tracking (weapon-like)
                    if (_selectedCategory == 'ACCESSOIRE' &&
                        {
                          'Modérateurs',
                          'Réducteur de son',
                          'Compensateurs',
                          'Détentes',
                          'Pièces internes',
                        }.contains(_isAccessoryTypeCustom ? _typeController.text.trim() : _selectedAccessoryType)) ...[
                      _TrackingToggle(
                        label: strings.accessoryWearTrackingLabel,
                        subtitle: strings.accessoryWearTrackingSubtitle,
                        value: _trackWear,
                        onChanged: (val) => setState(() => _trackWear = val),
                      ),
                      if (_trackWear) ...[
                        const Gap(16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                strings.revisionThresholdShotsLabel,
                                style: textStyles.bodyMedium
                                    ?.copyWith(color: colors.secondary),
                              ),
                            ),
                            SizedBox(
                              width: 132,
                              child: TextField(
                                controller: _wearRoundsThresholdController,
                                textAlign: TextAlign.end,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: colors.surface,
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.sm),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const Gap(12),
                      _TrackingToggle(
                        label: strings.accessoryCleaningTrackingLabel,
                        subtitle: strings.accessoryCleaningTrackingSubtitle,
                        value: _trackCleanliness,
                        onChanged: (val) =>
                            setState(() => _trackCleanliness = val),
                      ),
                      if (_trackCleanliness) ...[
                        const Gap(16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                strings.cleaningThresholdShotsLabel,
                                style: textStyles.bodyMedium
                                    ?.copyWith(color: colors.secondary),
                              ),
                            ),
                            SizedBox(
                              width: 132,
                              child: TextField(
                                controller: _cleaningRoundsThresholdController,
                                textAlign: TextAlign.end,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: colors.surface,
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.sm),
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

              // Actions
              SizedBox(
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: AppShadows.cardPremium,
                  ),
                  child: FilledButton.icon(
                    onPressed: _saveItem,
                    icon: Icon(
                        _isEditMode ? Icons.check_rounded : Icons.save_rounded),
                    label: Text(_isEditMode
                        ? strings.saveChangesButton
                        : strings.saveItemButton),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(8),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(strings.cancel.toUpperCase(), style: TextStyle(color: colors.secondary)),
                style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
const Gap(AppSpacing.xl),
            ],           // ← ferme children: [] de Column intérieur (7)
          ),             // ← ferme Column (7)
        ),               // ← ferme SingleChildScrollView (6)
      ),                 // ← ferme Expanded (5)
      ],                 // ← ferme children: [] de Column extérieur (4)
      ),                 // ← ferme Column (4)
      ),                 // ← ferme SafeArea (3)
      ),                 // ← ferme Scaffold (2)
    );                   // ← ferme AnnotatedRegion (1)
  }

  Future<void> _pickPhoto() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        if (kIsWeb) {
          // On web, store the bytes and create a data URL
          _photoBytes = file.bytes;
          if (_photoBytes != null) {
            // Create a data URL for web
            final base64 = base64Encode(_photoBytes!);
            _photoPath = 'data:image/${file.extension ?? "png"};base64,$base64';
          }
        } else {
          // On mobile, use the file path
          _photoPath = file.path;
          _photoBytes = null;
        }
      });
    }
  }
  
  Future<void> _pickPdf() async {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    if (!provider.canAddDocumentToItem(currentDocumentsCount: _documents.length)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.of(context).itemFreePdfLimitSingle)),
      );
      context.push('/pro');
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      allowMultiple: true,
      withData: kIsWeb,
    );
    
    if (result == null || result.files.isEmpty) return;

    for (final picked in result.files) {
      if (!provider.canAddDocumentToItem(currentDocumentsCount: _documents.length)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.of(context).itemFreePdfLimitReached)),
        );
        context.push('/pro');
        return;
      }

      final platformFile = _normalizePickedDocument(picked);
      if (platformFile == null) continue;

      final details = await _askDocumentDetails(initialName: _stripPdfExtension(picked.name));
      if (!mounted) return;
      if (details == null) continue;

      setState(() {
        _documents.add(_ItemDocumentDraft(
          name: details.name,
          type: details.type,
          expiryDate: details.expiryDate,
          notifyBeforeDays: details.notifyBeforeDays,
          file: platformFile,
        ));
      });
    }
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

  void _removeDocument(_ItemDocumentDraft doc) => setState(() => _documents.remove(doc));

  IconData _documentIconForPath(String path) {
    final normalized = path.toLowerCase();
    if (normalized.endsWith('.png') || normalized.endsWith('.jpg') || normalized.endsWith('.jpeg')) {
      return Icons.image_rounded;
    }
    return Icons.picture_as_pdf_rounded;
  }

  Color _documentIconColorForPath(ColorScheme colors, String path) {
    final normalized = path.toLowerCase();
    if (normalized.endsWith('.png') || normalized.endsWith('.jpg') || normalized.endsWith('.jpeg')) {
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
        SnackBar(content: Text(strings.settingsOpenDocumentFailed)),
      );
    }
  }

  Future<void> _shareDocument(_ItemDocumentDraft doc) async {
    try {
      final path = doc.file.path ?? '';
      if (path.trim().isEmpty) throw Exception('Empty path');

      if (kIsWeb) {
        if (path.startsWith('data:')) {
          final objectUrl = await WebDocumentOpener.createObjectUrlFromDataUrl(path);
          await SharePlus.instance.share(ShareParams(text: objectUrl));
          return;
        }
        await SharePlus.instance.share(ShareParams(text: path));
      if (path.startsWith('data:')) {
        final objectUrl = await WebDocumentOpener.createObjectUrlFromDataUrl(path);
        await SharePlus.instance.share(ShareParams(text: objectUrl));
        return;
      }
      await SharePlus.instance.share(ShareParams(text: path));
      return;
    }

    await SharePlus.instance.share(ShareParams(
      files: [XFile(path)],
      text: doc.name,
    ));
  } catch (_) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppStrings.of(context).settingsPickFileError('share'))),
    );
  }
}
  Future<void> _editDocument(_ItemDocumentDraft doc) async {
    final strings = AppStrings.of(context);
final details = await _askDocumentDetails(initialName: doc.name, initialType: doc.type);
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
      SnackBar(content: Text(strings.settingsDocumentUpdatedSuccess)),
    );
  }
Future<_DocumentDetails?> _askDocumentDetails({required String initialName, String? initialType}) async {
  final colors = Theme.of(context).colorScheme;
  final textStyles = Theme.of(context).textTheme;
  final strings = AppStrings.of(context);
  final nameController = TextEditingController(
    text: initialName.isEmpty ? strings.itemDefaultDocumentName : initialName,
  );

  String selectedType = _documentTypes.contains(initialType) ? initialType! : _documentTypes.first;
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
              style: textStyles.labelMedium?.copyWith(color: colors.secondary),
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
              style: textStyles.labelMedium?.copyWith(color: colors.secondary),
            ),
            DropdownButtonFormField<String>(
              value: selectedType,
              style: textStyles.bodyMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w400,
              ),
              decoration: const InputDecoration(),
              items: _documentTypes
                  .map((t) => DropdownMenuItem(
                        value: t,
                        child: Text(strings.itemDocumentTypeLabelForValue(t)),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => selectedType = v);
              },
            ),
            const Gap(16),
Text(
              strings.docExpiryDateLabel,
              style: textStyles.labelMedium?.copyWith(color: colors.secondary),
            ),
            const Gap(8),
            Row(children: [
              Expanded(
                child: expiryDate == null
                    ? OutlinedButton.icon(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 365)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
                          );
                          if (pickedDate != null) {
                            setState(() => expiryDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day));
                          }
                        },
                        icon: const Icon(Icons.calendar_today_rounded, size: 16),
                        label: Text(strings.selectDateLabel),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: colors.outline),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(children: [
                          Icon(Icons.calendar_today_rounded, size: 16, color: colors.primary),
                          const Gap(8),
                          Expanded(
                            child: Text(
                              AppDateFormats.formatDateShort(context, expiryDate!),
                              style: textStyles.bodyMedium,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() {
                              expiryDate = null;
                              selectedNotifyDays = 0;
                            }),
                            child: Icon(Icons.close_rounded, size: 16, color: colors.secondary),
                          ),
                        ]),
                      ),
              ),
            ]),
            if (expiryDate != null) ...[
              const Gap(16),
              Text(
                strings.docExpiryNotifyLabel,
                style: textStyles.labelMedium?.copyWith(color: colors.secondary),
              ),
              DropdownButtonFormField<int>(
                value: selectedNotifyDays > 0 ? selectedNotifyDays : 0,
                style: textStyles.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w400,
                ),
                decoration: const InputDecoration(),
                items: const [
                  DropdownMenuItem<int>(value: 0, child: Text('Aucune notification')),
                  DropdownMenuItem<int>(value: 7, child: Text('1 semaine avant')),
                  DropdownMenuItem<int>(value: 30, child: Text('1 mois avant')),
                  DropdownMenuItem<int>(value: 90, child: Text('3 mois avant')),
                ],
                onChanged: (v) => setState(() => selectedNotifyDays = v ?? 0),
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
            onPressed: () {
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
        .map((d) => ItemDocument(
              path: d.file.path ?? '',
              name: d.name,
              type: d.type,
              expiryDate: d.expiryDate,
              notifyBeforeDays: d.notifyBeforeDays,
            ))
        .where((d) => d.path.isNotEmpty)
        .toList();

    setState(() {
      _primaryNameError = _nameController.text.trim().isEmpty;

      if (_selectedCategory == 'ARME') {
        _caliberError = _caliberController.text.trim().isEmpty;
        _weaponTypeError = _selectedWeaponType.trim().isEmpty;
        _ammoQuantityError = false;
        _accessoryTypeError = false;
        _batteryDateError = false;
      } else if (_selectedCategory == 'MUNITION') {
        _caliberError = _caliberController.text.trim().isEmpty;
        final qty = int.tryParse(_quantityController.text.trim()) ?? 0;
        _ammoQuantityError = qty <= 0;
        _weaponTypeError = false;
        _accessoryTypeError = false;
        _batteryDateError = false;
      } else {
        // ACCESSOIRE
        final typeValue = _isAccessoryTypeCustom
            ? _typeController.text.trim()
            : _selectedAccessoryType.trim();
        _accessoryTypeError = typeValue.isEmpty;
        _caliberError = false;
        _weaponTypeError = false;
        _ammoQuantityError = false;
        _batteryDateError = _trackBattery && _batteryChangedAt == null;
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
    if (_weaponTypeError) {
      scrollTo(_weaponTypeFieldKey);
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
    
    if (_selectedCategory == 'ARME') {
      final existing = _isEditMode && widget.itemId != null ? provider.getWeaponById(widget.itemId!) : null;
      final initialRounds = int.tryParse(_initialRoundsController.text) ?? 0;
      final weapon = Weapon(
        id: _isEditMode ? widget.itemId! : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        model: _brandController.text.isEmpty ? _nameController.text : _brandController.text,
        comment: _commentController.text.trim(),
        type: _selectedWeaponType,
        caliber: _caliberController.text,
        serialNumber: _serialController.text,
        weight: double.tryParse(_weightController.text) ?? 0.0,
        totalRounds: initialRounds,
        lastCleaned: existing?.lastCleaned ?? DateTime.now(),
        lastRevised: existing?.lastRevised ?? (existing?.lastCleaned ?? DateTime.now()),
        lastUsed: existing?.lastUsed ?? DateTime.now(),
        trackWear: _trackWear,
        trackCleanliness: _trackCleanliness,
        trackRounds: _trackRounds,
        cleaningRoundsThreshold: int.tryParse(_cleaningRoundsThresholdController.text) ?? 500,
        wearRoundsThreshold: int.tryParse(_wearRoundsThresholdController.text) ?? 10000,
        roundsAtLastCleaning: existing?.roundsAtLastCleaning ?? initialRounds,
        roundsAtLastRevision: existing?.roundsAtLastRevision ?? initialRounds,
        photoPath: _photoPath,
        documents: documents,
        linkedAccessoryIds: _linkedAccessoryIds.toList(growable: false),
      );
      
      if (_isEditMode) {
        provider.updateWeapon(weapon);
      } else {
        if (!provider.canAddWeapon()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.getLimitMessage('weapon'))),
          );
          context.push('/pro');
          return;
        }
        provider.addWeapon(weapon);
      }

      _syncWeaponAccessoryLinks(
        provider: provider,
        weaponId: weapon.id,
        desiredAccessoryIds: _linkedAccessoryIds,
      );
    } else if (_selectedCategory == 'MUNITION') {
      final ammoType = _isAmmoProjectileTypeCustom
          ? _ammoTypeController.text.trim()
          : _selectedAmmoProjectileType;

      // Stock logic:
      // - quantity = current stock
      // - initialQuantity = baseline "stock de départ" (used for progress/criticality)
      // If the user doesn't explicitly provide an initial stock (field left at 0),
      // default baseline to the entered quantity.
      final parsedQuantity = int.tryParse(
            _quantityController.text.isEmpty ? _initialRoundsController.text : _quantityController.text,
          ) ??
          0;
      final parsedInitial = int.tryParse(_initialRoundsController.text);
      final effectiveInitial = (parsedInitial == null || parsedInitial <= 0) ? parsedQuantity : parsedInitial;
      final ammo = Ammo(
        id: _isEditMode ? widget.itemId! : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        brand: _brandController.text,
        caliber: _caliberController.text,
        comment: _commentController.text.trim(),
        projectileType: ammoType,
        quantity: parsedQuantity,
        initialQuantity: effectiveInitial,
        lastUsed: DateTime.now(),
        trackStock: _trackStock,
        lowStockThreshold: int.tryParse(_lowStockThresholdController.text) ?? 50,
        photoPath: _photoPath,
        documents: documents,
      );
      
      if (_isEditMode) {
        provider.updateAmmo(ammo);
      } else {
        if (!provider.canAddAmmo()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.getLimitMessage('ammo'))),
          );
          context.push('/pro');
          return;
        }
        provider.addAmmo(ammo);
      }
    } else {
      final existing = _isEditMode
          ? provider.accessories.where((a) => a.id == widget.itemId).firstOrNull
          : null;
      final model = _nameController.text.trim();
      final brand = _brandController.text.trim();
      final type = _isAccessoryTypeCustom
          ? (_typeController.text.trim().isEmpty ? strings.settingsDocumentTypeOther : _typeController.text.trim())
          : _selectedAccessoryType;

      final maintenanceEnabledTypes = {
        'Modérateurs',
        'Réducteur de son',
        'Compensateurs',
        'Détentes',
        'Pièces internes',
      };
      final maintenanceEnabled = maintenanceEnabledTypes.contains(type);

      final displayName = [brand, model].where((s) => s.isNotEmpty).join(' ').trim();

      final accessory = Accessory(
        id: _isEditMode ? widget.itemId! : DateTime.now().millisecondsSinceEpoch.toString(),
        name: displayName.isEmpty ? strings.quickActionLabelAccessory : displayName,
        brand: brand,
        model: model,
        comment: _commentController.text.trim(),
        type: type,
        lastUsed: DateTime.now(),
        totalRounds: existing?.totalRounds ?? 0,
        lastCleaned: existing?.lastCleaned ?? DateTime.now(),
        lastRevised:
            existing?.lastRevised ?? (existing?.lastCleaned ?? DateTime.now()),
        trackWear: maintenanceEnabled ? _trackWear : false,
        trackCleanliness: maintenanceEnabled ? _trackCleanliness : false,
        cleaningRoundsThreshold: maintenanceEnabled
            ? (int.tryParse(_cleaningRoundsThresholdController.text) ?? 500)
            : 500,
        wearRoundsThreshold: maintenanceEnabled
            ? (int.tryParse(_wearRoundsThresholdController.text) ?? 10000)
            : 10000,
        roundsAtLastCleaning:
            existing?.roundsAtLastCleaning ?? (existing?.totalRounds ?? 0),
        roundsAtLastRevision:
            existing?.roundsAtLastRevision ?? (existing?.totalRounds ?? 0),
        batteryChangedAt: _trackBattery
            ? (_batteryChangedAt ?? existing?.batteryChangedAt ?? DateTime.now())
            : null,
        trackBattery: _trackBattery,
        photoPath: _photoPath,
        documents: documents,
        linkedWeaponIds: _linkedWeaponIds.toList(growable: false),
      );
      
      if (_isEditMode) {
        provider.updateAccessory(accessory);
      } else {
        if (!provider.canAddAccessory()) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(provider.getLimitMessage('accessory'))),
          );
          context.push('/pro');
          return;
        }
        provider.addAccessory(accessory);
      }

      _syncAccessoryWeaponLinks(
        provider: provider,
        accessoryId: accessory.id,
        desiredWeaponIds: _linkedWeaponIds,
      );
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEditMode ? strings.itemSavedSuccess : strings.itemAddedSuccess)),
    );
    context.pop();
  }
}

class _ItemLinkMultiSelectSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final Set<String> initialSelection;
  final String Function(T item) idOf;
  final String Function(T item) labelOf;
  final String Function(T item) subtitleOf;
  final IconData icon;

  const _ItemLinkMultiSelectSheet({
    required this.title,
    required this.items,
    required this.initialSelection,
    required this.idOf,
    required this.labelOf,
    required this.subtitleOf,
    required this.icon,
  });

  @override
  State<_ItemLinkMultiSelectSheet<T>> createState() =>
      _ItemLinkMultiSelectSheetState<T>();
}

class _ItemLinkMultiSelectSheetState<T>
    extends State<_ItemLinkMultiSelectSheet<T>> {
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
              const Gap(12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outline,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
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
              const Divider(height: 1),
              Expanded(
                child: widget.items.isEmpty
                    ? Center(
                        child: Padding(
                          padding: AppSpacing.paddingLg,
                          child: Text(
                            strings.settingsDocumentsEmptyTitle,
                            style: textStyles.bodyMedium
                                ?.copyWith(color: colors.secondary),
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
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemCount: widget.items.length,
                      ),
              ),
              const Divider(height: 1),
              Padding(
                padding: AppSpacing.paddingLg,
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(strings.cancel),
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(_selectedIds),
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
              Text(label,
                  style: textStyles.bodyMedium
                      ?.copyWith(color: colors.onSurface, fontWeight: FontWeight.w600)),
              const Gap(4),
              Text(subtitle,
                  style: textStyles.bodySmall?.copyWith(color: colors.secondary)),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: colors.primary,
        ),
      ],
    );
  }
}

class DottedBorderPlaceholder extends StatelessWidget {
  final Widget child;
  const DottedBorderPlaceholder({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
