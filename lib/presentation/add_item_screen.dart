import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, Uint8List;
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
import 'package:crypto/crypto.dart';
import '../data/thot_provider.dart';
import '../data/models.dart';
import '../theme.dart';
import '../widgets/cross_platform_image.dart';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/data/material_types.dart';
import 'package:thot/utils/app_date_formats.dart';
import 'package:thot/utils/image_storage.dart';
import 'package:thot/utils/validators.dart';

part 'add_item/models.dart';
part 'add_item/localized_options.dart';
part 'add_item/linking_sheets.dart';
part 'add_item/documents_and_save.dart';
part 'add_item/shared_widgets.dart';

class AddItemScreen extends StatefulWidget {
  final String? itemId;
  final String? itemType;

  const AddItemScreen({Key? key, this.itemId, this.itemType}) : super(key: key);

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}


class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCategory =
      'PLATEFORME'; // PLATEFORME, CONSOMMABLE, ACCESSOIRE
  bool _isEditMode = false;
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _caliberController = TextEditingController();
  final _serialController = TextEditingController();
  final _weightController = TextEditingController();
  final _initialRoundsController = TextEditingController(text: '0');
  final _typeController = TextEditingController();
  final _ammoTypeController = TextEditingController();
  final _quantityController = TextEditingController(text: '0');
  final _unitPriceController = TextEditingController();
  String _selectedCurrency = 'EUR';
  final _commentController = TextEditingController();
  final _lowStockThresholdController = TextEditingController(text: '50');
  final _cleaningRoundsThresholdController = TextEditingController(text: '500');
  final _wearRoundsThresholdController = TextEditingController(text: '10000');

  String? _photoPath;
  Uint8List? _photoBytes; // For web platform
  List<_ItemDocumentDraft> _documents = [];

  // Hash of initial form state for detecting unsaved changes
  String _initialFormHash = '';





  String _selectedAccessoryType = AccessoryTypeKey.all.first;
  bool _isAccessoryTypeCustom = false;

  String _selectedPlatformType = PlatformTypeKey.all.first;

  String _selectedAmmoProjectileType = AmmoTypeKey.all.first;
  bool _isAmmoProjectileTypeCustom = false;

  // Tracking toggles
  bool _trackWear = true;
  bool _trackCleanliness = true;
  bool _trackRounds = true;
  bool _trackStock = true;
  bool _trackBattery = false;
  DateTime? _batteryChangedAt;

  static const Set<String> _accessoryWearEnabledTypes =
      AccessoryTypeKey.wearEnabled;

  static const Set<String> _accessoryCleanlinessEnabledTypes =
      AccessoryTypeKey.cleanlinessEnabled;

  static const Set<String> _accessoryBatteryEnabledTypes =
      AccessoryTypeKey.batteryEnabled;


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
        _selectedPlatformType = PlatformTypeKey.all.contains(platform.type)
            ? platform.type
            : PlatformTypeKey.all.first;
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
        final known = AmmoTypeKey.all.contains(ammo.projectileType)
            ? ammo.projectileType
            : AmmoTypeKey.all.first;
        _isAmmoProjectileTypeCustom =
            ammo.projectileType.isNotEmpty &&
            !AmmoTypeKey.all.contains(ammo.projectileType);
        _selectedAmmoProjectileType = _isAmmoProjectileTypeCustom
            ? AmmoTypeKey.all.first
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
        final known = AccessoryTypeKey.all.contains(accessory.type)
            ? accessory.type
            : AccessoryTypeKey.other;
        _selectedAccessoryType = known;
        _isAccessoryTypeCustom = !AccessoryTypeKey.all.contains(accessory.type);
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
    // Store hash of initial state for change detection
    _initialFormHash = _computeFormHash();
  }

  /// Computes a hash of all form fields to detect unsaved changes
  String _computeFormHash() {
    final data = {
      'category': _selectedCategory,
      'name': _nameController.text,
      'brand': _brandController.text,
      'caliber': _caliberController.text,
      'serial': _serialController.text,
      'weight': _weightController.text,
      'initialRounds': _initialRoundsController.text,
      'type': _typeController.text,
      'ammoType': _ammoTypeController.text,
      'quantity': _quantityController.text,
      'unitPrice': _unitPriceController.text,
      'currency': _selectedCurrency,
      'comment': _commentController.text,
      'lowStock': _lowStockThresholdController.text,
      'cleaning': _cleaningRoundsThresholdController.text,
      'wear': _wearRoundsThresholdController.text,
      'photo': _photoPath,
    };
    return base64Encode(
      sha256.convert(utf8.encode(jsonEncode(data))).bytes,
    );
  }

  bool get _hasUnsavedChanges => _computeFormHash() != _initialFormHash;

  Future<bool> _showUnsavedChangesDialog() async {
    final strings = AppStrings.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.unsavedChangesTitle),
        content: Text(strings.unsavedChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.unsavedChangesDiscard),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.unsavedChangesKeep),
          ),
        ],
      ),
    );
    return result ?? false;
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!_hasUnsavedChanges) {
          if (mounted) Navigator.of(context).pop();
          return;
        }
        final shouldLeave = await _showUnsavedChangesDialog();
        if (shouldLeave && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: colors.surface,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
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
                        tooltip: strings.close,
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                        // Form
                        Row(
                          children: [
                            const Icon(Icons.edit_note_rounded, size: 18),
                            const Gap(8),
                            Text(
                              '${_primaryNameLabel().toUpperCase()} *',
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
                            maxLength: 100,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(100),
                            ],
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
                              counterText: '', // Hide character counter
                              errorText: _primaryNameError
                                  ? strings.requiredFieldError
                                  : null,
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
                                      maxLength: 100,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(100),
                                      ],
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                        hintText: strings.itemPlatformBrandHint,
                                        counterText: '',
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
                                          '${strings.caliberLabel.toUpperCase()} *',
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
                                      key: _caliberFieldKey,
                                      child: TextField(
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
                                          errorText: _caliberError
                                              ? strings.requiredFieldError
                                              : null,
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
                                '${strings.typeLabel.toUpperCase()} *',
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
                              initialValue: _selectedPlatformType,
                              decoration: InputDecoration(
                                errorText: _platformTypeError
                                    ? strings.requiredFieldError
                                    : null,
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
                              items: PlatformTypeKey.all
                                  .map(
                                    (t) => DropdownMenuItem(
                                      value: t,
                                      child: Text(
                                        strings.platformTypeLabel(t),
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
                                      maxLength: 50,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(50),
                                      ],
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                        hintText: strings.itemSerialNumberHint,
                                        counterText: '',
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
                                    TextFormField(
                                      controller: _weightController,
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [ThotInputFormatters.decimal],
                                      validator: (v) => ThotValidators.positiveDouble(v, strings),
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
                                      maxLength: 50,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(50),
                                      ],
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                        hintText: strings.itemAmmoBrandHint,
                                        counterText: '',
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
                                          '${strings.caliberLabel.toUpperCase()} *',
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
                                      key: _caliberFieldKey,
                                      child: TextField(
                                        controller: _caliberController,
                                        maxLength: 50,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(50),
                                        ],
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
                                          counterText: '',
                                          hintStyle: textStyles.bodyMedium
                                              ?.copyWith(
                                                color: colors.onSurface.withAlpha(
                                                  100,
                                                ),
                                              ),
                                          errorText: _caliberError
                                              ? strings.requiredFieldError
                                              : null,
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
                                '${strings.typeLabel.toUpperCase()} *',
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
                              initialValue: _isAmmoProjectileTypeCustom
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
                                ...AmmoTypeKey.all
                                    .where((t) => t != AmmoTypeKey.other)
                                    .map(
                                      (t) => DropdownMenuItem(
                                        value: t,
                                        child: Text(
                                          strings.ammoTypeLabel(t),
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
                                        AmmoTypeKey.all.first;
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
                                maxLength: 50,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(50),
                                ],
                                decoration: InputDecoration(
                                  hintText: strings.itemProjectileCustomHint,
                                  counterText: '',
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
                            child: TextFormField(
                              controller: _quantityController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [ThotInputFormatters.integer],
                              validator: (v) => ThotValidators.positiveInt(v, strings),
                              onTap: () {
                                // Effacer le zéro si c'est la seule valeur
                                if (_quantityController.text == '0') {
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
                                child: TextFormField(
                                  controller: _unitPriceController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  inputFormatters: [ThotInputFormatters.decimal],
                                  validator: (v) => ThotValidators.positiveDouble(v, strings),
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
                                      maxLength: 50,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(50),
                                      ],
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),
                                        hintText:
                                            strings.itemAccessoryBrandHint,
                                        counterText: '',
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
                                          '${strings.typeLabel.toUpperCase()} *',
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
                                        initialValue: _isAccessoryTypeCustom
                                            ? '__custom__'
                                            : _selectedAccessoryType,
                                        style: textStyles.bodyMedium?.copyWith(
                                          color: colors.onSurface,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        selectedItemBuilder: (context) {
                                          final labels = [
                                            ...AccessoryTypeKey.all.map(
                                              (t) => strings
                                                  .accessoryTypeLabel(t),
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
                                          errorText: _accessoryTypeError
                                              ? strings.requiredFieldError
                                              : null,
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
                                          ...AccessoryTypeKey.all.map(
                                            (t) => DropdownMenuItem(
                                              value: t,
                                              child: Text(
                                                strings.accessoryTypeLabel(
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
                          maxLength: 500,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(500),
                          ],
                          maxLines: 4,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            hintText: strings.itemCommentHint,
                            counterText: '',
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
                                          tooltip: strings.removePhoto,
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
                                          child: TextFormField(
                                            controller:
                                                _wearRoundsThresholdController,
                                            textAlign: TextAlign.end,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [ThotInputFormatters.integer],
                                            validator: (v) => ThotValidators.positiveInt(v, strings),
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
                                          child: TextFormField(
                                            controller:
                                                _cleaningRoundsThresholdController,
                                            textAlign: TextAlign.end,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [ThotInputFormatters.integer],
                                            validator: (v) => ThotValidators.positiveInt(v, strings),
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
                                          child: TextFormField(
                                            controller:
                                                _initialRoundsController,
                                            textAlign: TextAlign.end,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [ThotInputFormatters.integer],
                                            validator: (v) => ThotValidators.positiveInt(v, strings),
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
                                          child: TextFormField(
                                            controller:
                                                _lowStockThresholdController,
                                            textAlign: TextAlign.end,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [ThotInputFormatters.integer],
                                            validator: (v) => ThotValidators.positiveInt(v, strings),
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
                                          child: TextFormField(
                                            controller:
                                                _cleaningRoundsThresholdController,
                                            textAlign: TextAlign.end,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [ThotInputFormatters.integer],
                                            validator: (v) => ThotValidators.positiveInt(v, strings),
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
                                      const Icon(Icons.save, size: 20),
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
                    ), // ← ferme Form
                  ), // ← ferme SingleChildScrollView (6)
                ), // ← ferme Expanded (5)
              ], // ← ferme children: [] de Column extérieur (4)
            ), // ← ferme Column (4)
          ), // ← ferme SafeArea (3)
        ), // ← ferme GestureDetector (body)
      ), // ← ferme Scaffold (2)
      ),
    );
  }

}

