import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:thot/data/models.dart';
import 'package:thot/data/thot_provider.dart';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/presentation/shooting_table_qr_scanner_screen.dart';
import 'package:thot/theme.dart';
import 'package:thot/utils/shooting_table_share_codec.dart';

part 'shooting_tables/models.dart';
part 'shooting_tables/shared_widgets.dart';
part 'shooting_tables/target_painter.dart';
part 'shooting_tables/adjustment_entry_form_sheet.dart';
part 'shooting_tables/pocket_card_overlay.dart';
part 'shooting_tables/dialogs_and_sheets.dart';

class ShootingTablesScreen extends StatefulWidget {
  const ShootingTablesScreen({super.key});

  @override
  State<ShootingTablesScreen> createState() => _ShootingTablesScreenState();
}


class _ShootingTablesScreenState extends State<ShootingTablesScreen> {
  static const double _c50OuterRadiusMm = 250.0;
  static const double _c50VisualBlackRadiusMm = 100.0;
  static const double _c50TenRadiusMm = 25.0;
  static const double _targetVisualRadiusFactor = 0.82;
  static const double _fitAllFramePaddingFactor = 1.12;
  static const double _allImpactsMinZoomOutFactor = 1.25;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _tableNameController = TextEditingController();

  int _pageIndex = 0;
  String _searchQuery = '';
  _TableSort _sortBy = _TableSort.updatedAt;
  bool _sortDescending = true;
  bool _showDopeOnly = false;

  String? _editingTableId;
  String? _editorPlatformId;
  String? _editorCustomPlatformName;
  bool _editorPlatformIsOther = false;
  String? _editorAmmoId;
  String? _editorCustomAmmoName;
  bool _editorAmmoIsOther = false;
  Set<String> _editorAccessoryIds = <String>{};
  List<String> _editorCustomAccessoryNames = <String>[];
  bool _editorAccessoriesCustomized = false;
  List<ShootingAdjustmentEntry> _editorEntries = <ShootingAdjustmentEntry>[];
  bool _editorIsDope = false;

  double? _activeDistance;
  String? _selectedEntryId;
  bool _showAllImpacts = false;
  bool _fitAllImpactsInFrame = false;
  double _lastScaleReferenceMm = _c50OuterRadiusMm;

  // Unit system getters
  bool get _useMetric =>
      Provider.of<ThotProvider>(context, listen: false).useMetric;
  AdjustmentDistanceUnit get _defaultDistanceUnit =>
      _useMetric ? AdjustmentDistanceUnit.meter : AdjustmentDistanceUnit.yard;
  AdjustmentOffsetUnit get _defaultOffsetUnit =>
      _useMetric ? AdjustmentOffsetUnit.centimeter : AdjustmentOffsetUnit.inch;

  // Conversion functions
  double _convertDistance(
    double distance,
    AdjustmentDistanceUnit fromUnit,
    AdjustmentDistanceUnit toUnit,
  ) {
    if (fromUnit == toUnit) return distance;

    // Convert to meters first, then to target unit
    double inMeters = distance;
    if (fromUnit == AdjustmentDistanceUnit.yard) {
      inMeters = distance * 0.9144; // 1 yard = 0.9144 meters
    }

    if (toUnit == AdjustmentDistanceUnit.yard) {
      return inMeters / 0.9144; // meters to yards
    }
    return inMeters; // meters
  }

  double _convertOffset(
    double offset,
    AdjustmentOffsetUnit fromUnit,
    AdjustmentOffsetUnit toUnit,
  ) {
    if (fromUnit == toUnit) return offset;

    // Convert to centimeters first, then to target unit
    double inCm = offset;
    if (fromUnit == AdjustmentOffsetUnit.inch) {
      inCm = offset * 2.54; // 1 inch = 2.54 cm
    }

    if (toUnit == AdjustmentOffsetUnit.inch) {
      return inCm / 2.54; // cm to inches
    }
    return inCm; // cm
  }

  double _getDistanceInDefaultUnit(
    double distance,
    AdjustmentDistanceUnit storedUnit,
  ) {
    return _convertDistance(distance, storedUnit, _defaultDistanceUnit);
  }

  double _getOffsetInDefaultUnit(
    double offset,
    AdjustmentOffsetUnit storedUnit,
  ) {
    return _convertOffset(offset, storedUnit, _defaultOffsetUnit);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<ThotProvider>(context, listen: false);
    if (provider.shootingAdjustmentTables.isNotEmpty &&
        _editingTableId == null &&
        _pageIndex == 0) {
      _openEditorForTable(
        provider,
        provider.shootingAdjustmentTables.first,
        openPage: false,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tableNameController.dispose();
    super.dispose();
  }

  void _syncDistanceSelectionFromEntries() {
    final entries = _editorEntries;
    final distances = _extractDistances(entries);
    if (_activeDistance == null ||
        !distances.any((d) => _sameDistance(d, _activeDistance!))) {
      _activeDistance = distances.isEmpty ? null : distances.first;
    }
    if (_selectedEntryId != null &&
        !entries.any((e) => e.id == _selectedEntryId)) {
      _selectedEntryId = null;
    }
  }

  String _tableDisplayName(ShootingAdjustmentTable table) {
    final name = table.name.trim();
    if (name.isNotEmpty) return name;
    return 'Table';
  }

  String _platformName(
    ThotProvider provider,
    String platformId, {
    String? customPlatformName,
  }) {
    if (customPlatformName != null && customPlatformName.isNotEmpty) {
      return customPlatformName;
    }
    final platform = provider.getPlatformById(platformId);
    return platform?.name ?? '-';
  }

  String _ammoName(
    ThotProvider provider,
    String? ammoId,
    AppStrings strings, {
    String? customAmmoName,
  }) {
    if (customAmmoName != null && customAmmoName.isNotEmpty) {
      return customAmmoName;
    }
    if (ammoId == null || ammoId.isEmpty) return strings.shootingTableNoAmmo;
    final ammo = provider.getAmmoById(ammoId);
    return ammo?.name ?? strings.shootingTableNoAmmo;
  }

  ShootingAdjustmentTable _asImportedCustomTable(
    ShootingAdjustmentTable table,
    ThotProvider provider,
    AppStrings strings,
  ) {
    final accessoryNames = <String>{
      ...provider.accessories
          .where((a) => table.accessoryIds.contains(a.id))
          .map((a) => a.name.trim())
          .where((name) => name.isNotEmpty),
      ...table.customAccessoryNames
          .map((name) => name.trim())
          .where((name) => name.isNotEmpty),
    }.toList(growable: false);

    return table.copyWith(
      platformId: '',
      customPlatformName: table.customPlatformName?.trim().isNotEmpty == true
          ? table.customPlatformName!.trim()
          : '-',
      clearAmmoId: true,
      customAmmoName: table.customAmmoName?.trim().isNotEmpty == true
          ? table.customAmmoName!.trim()
          : strings.shootingTableNoAmmo,
      accessoryIds: const [],
      customAccessoryNames: accessoryNames,
      accessoriesCustomized: true,
    );
  }

  Widget _svgFieldIcon(String asset, Color color) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SvgPicture.asset(
        asset,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }

  Widget _tableInfoLine({
    required String asset,
    required String text,
    required Color color,
    required TextStyle? style,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: SvgPicture.asset(
            asset,
            width: 12,
            height: 12,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          ),
        ),
        const Gap(6),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }

  TextStyle? _hintStyle(BuildContext context, {double? fontSize}) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    return textStyles.bodyMedium?.copyWith(
      fontSize: fontSize,
      color: colors.onSurface.withAlpha(100),
    );
  }

  bool _tableMatchesSearch(
    ThotProvider provider,
    AppStrings strings,
    ShootingAdjustmentTable table,
    String query,
  ) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;

    final platform = _platformName(
      provider,
      table.platformId,
      customPlatformName: table.customPlatformName,
    ).toLowerCase();
    final ammo = _ammoName(
      provider,
      table.ammoId,
      strings,
      customAmmoName: table.customAmmoName,
    ).toLowerCase();
    final name = _tableDisplayName(table).toLowerCase();
    final accessoryNames = [
      ...provider.accessories
          .where((a) => table.accessoryIds.contains(a.id))
          .map((a) => a.name.toLowerCase()),
      ...table.customAccessoryNames.map((n) => n.toLowerCase()),
    ].join(' ');
    final distances = table.entries
        .map(
          (e) => _formatNumber(
            _getDistanceInDefaultUnit(e.distance, e.distanceUnit),
          ).toLowerCase(),
        )
        .join(' ');

    return name.contains(normalized) ||
        platform.contains(normalized) ||
        ammo.contains(normalized) ||
        accessoryNames.contains(normalized) ||
        distances.contains(normalized);
  }

  List<ShootingAdjustmentTable> _filteredTables(
    ThotProvider provider,
    AppStrings strings,
  ) {
    var tables = [...provider.shootingAdjustmentTables]
        .where(
          (t) =>
              t.platformId.trim().isNotEmpty ||
              (t.customPlatformName?.trim().isNotEmpty ?? false),
        )
        .where((t) => _tableMatchesSearch(provider, strings, t, _searchQuery))
        .toList(growable: false);

    if (_showDopeOnly) {
      tables = tables.where((t) => t.isDope).toList(growable: false);
    }

    int byMaxDistance(ShootingAdjustmentTable t) {
      if (t.entries.isEmpty) return 0;
      final maxDistance = t.entries
          .map((e) => _getDistanceInDefaultUnit(e.distance, e.distanceUnit))
          .fold<double>(0, (max, value) => value > max ? value : max);
      return (maxDistance * 100).round();
    }

    tables.sort((a, b) {
      int cmp;
      switch (_sortBy) {
        case _TableSort.name:
          cmp = _tableDisplayName(
            a,
          ).toLowerCase().compareTo(_tableDisplayName(b).toLowerCase());
          break;
        case _TableSort.distance:
          cmp = byMaxDistance(a).compareTo(byMaxDistance(b));
          break;
        case _TableSort.updatedAt:
          cmp = a.updatedAt.compareTo(b.updatedAt);
          break;
      }
      return _sortDescending ? -cmp : cmp;
    });

    return tables;
  }

  void _openEditorForCreate(ThotProvider provider) {
    final defaultPlatform = provider.platforms.isEmpty
        ? ''
        : provider.platforms.first.id;
    final linkedAccessoryIds = provider.platforms.isEmpty
        ? <String>{}
        : provider
              .linkedAccessoriesForPlatform(defaultPlatform)
              .map((a) => a.id)
              .toSet();

    setState(() {
      _editingTableId = null;
      _tableNameController.clear();
      _editorPlatformId = defaultPlatform;
      _editorCustomPlatformName = null;
      _editorPlatformIsOther = false;
      _editorAmmoId = null;
      _editorCustomAmmoName = null;
      _editorAmmoIsOther = false;
      _editorAccessoryIds = linkedAccessoryIds;
      _editorCustomAccessoryNames = <String>[];
      _editorAccessoriesCustomized = false;
      _editorEntries = <ShootingAdjustmentEntry>[];
      _editorIsDope = false;
      _activeDistance = null;
      _selectedEntryId = null;
      _showAllImpacts = false;
      _fitAllImpactsInFrame = false;
      _lastScaleReferenceMm = _c50OuterRadiusMm;
      _pageIndex = 1;
    });
  }

  void _openEditorForTable(
    ThotProvider provider,
    ShootingAdjustmentTable table, {
    bool openPage = true,
  }) {
    setState(() {
      _editingTableId = table.id;
      _tableNameController.text = table.name;
      _editorPlatformId = table.platformId;
      _editorCustomPlatformName = table.customPlatformName;
      _editorPlatformIsOther =
          table.customPlatformName != null &&
          table.customPlatformName!.trim().isNotEmpty;
      _editorAmmoId = table.ammoId;
      _editorCustomAmmoName = table.customAmmoName;
      _editorAmmoIsOther =
          table.customAmmoName != null &&
          table.customAmmoName!.trim().isNotEmpty;
      _editorAccessoryIds = table.accessoryIds.toSet();
      _editorCustomAccessoryNames = table.customAccessoryNames.toList();
      _editorAccessoriesCustomized = table.accessoriesCustomized;
      _editorEntries = [...table.entries]
        ..sort((a, b) => a.distance.compareTo(b.distance));
      _editorIsDope = table.isDope;
      _showAllImpacts = false;
      _fitAllImpactsInFrame = false;
      _selectedEntryId = null;
      _lastScaleReferenceMm = _c50OuterRadiusMm;
      _syncDistanceSelectionFromEntries();
      if (openPage) _pageIndex = 1;
    });
  }

  void _cancelEditor() {
    setState(() {
      _pageIndex = 0;
      _selectedEntryId = null;
      _showAllImpacts = false;
      _fitAllImpactsInFrame = false;
      _lastScaleReferenceMm = _c50OuterRadiusMm;
      _editorIsDope = false;
    });
  }

  Future<void> _saveEditor(ThotProvider provider, AppStrings strings) async {
    final tableName = _tableNameController.text.trim();
    final platformId = _editorPlatformId ?? '';
    if (tableName.isEmpty) return;

    if (platformId.isEmpty &&
        (_editorCustomPlatformName == null ||
            _editorCustomPlatformName!.trim().isEmpty)) {
      return;
    }

    if (_editingTableId == null) {
      provider.createAdjustmentTable(
        name: tableName,
        platformId: platformId,
        customPlatformName: _editorCustomPlatformName,
        ammoId: _editorAmmoId,
        customAmmoName: _editorCustomAmmoName,
        accessoryIds: _editorAccessoryIds.toList(growable: false),
        customAccessoryNames: _editorCustomAccessoryNames,
        accessoriesCustomized: _editorAccessoriesCustomized,
        entries: _editorEntries,
        isDope: _editorIsDope,
      );
    } else {
      provider.updateAdjustmentTableById(
        tableId: _editingTableId!,
        name: tableName,
        platformId: platformId,
        customPlatformName: _editorCustomPlatformName,
        ammoId: _editorAmmoId,
        customAmmoName: _editorCustomAmmoName,
        clearAmmoId: _editorAmmoId == null,
        accessoryIds: _editorAccessoryIds.toList(growable: false),
        customAccessoryNames: _editorCustomAccessoryNames,
        accessoriesCustomized: _editorAccessoriesCustomized,
        entries: _editorEntries,
        isDope: _editorIsDope,
      );
    }

    if (!mounted) return;
    setState(() {
      _pageIndex = 0;
    });
  }


  List<double> _extractDistances(List<ShootingAdjustmentEntry> entries) {
    final seen = <double>[];
    for (final entry in entries) {
      if (!seen.any((d) => _sameDistance(d, entry.distance))) {
        seen.add(entry.distance);
      }
    }
    seen.sort((a, b) => a.compareTo(b));
    return seen;
  }

  bool _sameDistance(double a, double b) => (a - b).abs() < 0.0001;

  int _sortIndex() {
    switch (_sortBy) {
      case _TableSort.updatedAt:
        return 0;
      case _TableSort.name:
        return 1;
      case _TableSort.distance:
        return 2;
    }
  }

  String _formatNumber(double value) {
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }

  String _distanceUnitLabel(AppStrings strings, AdjustmentDistanceUnit unit) {
    return unit == AdjustmentDistanceUnit.meter
        ? strings.shootingTableDistanceUnitMeter
        : strings.shootingTableDistanceUnitYard;
  }

  String _offsetUnitLabel(AppStrings strings, AdjustmentOffsetUnit unit) {
    return unit == AdjustmentOffsetUnit.centimeter
        ? strings.shootingTableOffsetUnitCm
        : strings.shootingTableOffsetUnitInch;
  }

  double _offsetToMillimeters(double value, AdjustmentOffsetUnit unit) {
    return unit == AdjustmentOffsetUnit.centimeter
        ? value * 10.0
        : value * 25.4;
  }

  double _entryRadiusMillimeters(ShootingAdjustmentEntry entry) {
    final xMm = _offsetToMillimeters(entry.horizontalOffset, entry.offsetUnit);
    final yMm = _offsetToMillimeters(entry.verticalOffset, entry.offsetUnit);
    return math.sqrt((xMm * xMm) + (yMm * yMm));
  }

  Offset _entryOffsetMillimeters(ShootingAdjustmentEntry entry) {
    return Offset(
      _offsetToMillimeters(entry.horizontalOffset, entry.offsetUnit),
      _offsetToMillimeters(entry.verticalOffset, entry.offsetUnit),
    );
  }


  ShootingAdjustmentEntry? _selectedEntry(
    List<ShootingAdjustmentEntry> entries,
  ) {
    if (_selectedEntryId == null) return null;
    for (final entry in entries) {
      if (entry.id == _selectedEntryId) return entry;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThotProvider>(context);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtleBorderColor = colors.outline.withValues(alpha: 0.45);
    final searchFillColor = Color.alphaBlend(
      colors.outline.withValues(alpha: 0.8),
      baseBackground,
    );

    final tables = _filteredTables(provider, strings);
    final selectedAccessoryIds = _editorAccessoryIds.toList(growable: false);
    final selectedAmmoId = _editorAmmoId;
    final entries = _editorEntries;
    final platformItems = <Platform>[];
    final seenPlatformIds = <String>{};
    for (final platform in provider.platforms) {
      if (seenPlatformIds.add(platform.id)) {
        platformItems.add(platform);
      }
    }
    final ammoItems = <Ammo>[];
    final seenAmmoIds = <String>{};
    for (final ammo in provider.ammos) {
      if (seenAmmoIds.add(ammo.id)) {
        ammoItems.add(ammo);
      }
    }
    final safePlatformId =
        (_editorPlatformId != null &&
            platformItems.any((p) => p.id == _editorPlatformId))
        ? _editorPlatformId
        : null;
    final safeAmmoId =
        (selectedAmmoId != null && ammoItems.any((a) => a.id == selectedAmmoId))
        ? selectedAmmoId
        : null;
    final selectedAccessoryNames = [
      ...provider.accessories
          .where((a) => selectedAccessoryIds.contains(a.id))
          .map((a) => a.name),
      ..._editorCustomAccessoryNames,
    ];

    final distances = _extractDistances(entries);
    final activeEntries = _showAllImpacts
        ? entries
        : (_activeDistance == null
              ? const <ShootingAdjustmentEntry>[]
              : entries
                    .where((e) => _sameDistance(e.distance, _activeDistance!))
                    .toList(growable: false));
    final entriesForTarget = _fitAllImpactsInFrame
        ? activeEntries
        : activeEntries
              .where((e) => _entryRadiusMillimeters(e) <= _c50OuterRadiusMm)
              .toList(growable: false);
    final selectedEntry = _selectedEntry(entriesForTarget);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Listener(
        onPointerDown: (_) => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(color: baseBackground),
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
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: SizedBox(
                  height: 44,
                  child: Row(
                    children: [
                      if (_pageIndex == 1)
                        GestureDetector(
                          onTap: _cancelEditor,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade300
                                  : LightColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.black
                                  : Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      if (_pageIndex == 1) const Gap(AppSpacing.sm),
                      if (_pageIndex == 1 && _editingTableId != null)
                        const Gap(AppSpacing.sm),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: _pageIndex == 1
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                _pageIndex == 1
                                    ? strings.newTableLabel
                                    : strings.shootingTablesToolTitle,
                                style: textStyles.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.onSurface,
                                ),
                              ),
                            ),
                            const Gap(6),
                            Tooltip(
                              message: _pageIndex == 0
                                  ? strings.shootingTablesListSubtitle
                                  : strings.shootingTablesToolSubtitle,
                              triggerMode: TooltipTriggerMode.tap,
                              showDuration: const Duration(seconds: 4),
                              margin: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: colors.onSurface.withValues(alpha: 0.88),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: textStyles.bodySmall?.copyWith(
                                color: colors.surface,
                              ),
                              child: Icon(
                                Icons.info_outline_rounded,
                                size: 18,
                                color: colors.onSurface.withValues(alpha: 0.45),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_pageIndex == 0) const Gap(AppSpacing.xs),
                      if (_pageIndex == 0) const Gap(AppSpacing.xs),
                      if (_pageIndex == 0)
                        GestureDetector(
                          onTap: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 28,
                              color: colors.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      if (_pageIndex == 1) const Gap(AppSpacing.xs),
                      if (_pageIndex == 1) const Gap(AppSpacing.xs),
                      if (_pageIndex == 1)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _pageIndex = 0;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 28,
                              color: colors.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Divider(color: colors.outline),
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: Stack(
                  children: [
                    IndexedStack(
                      index: _pageIndex,
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                0,
                                AppSpacing.lg,
                                10,
                              ),
                              child: SizedBox(
                                height: 44,
                                child: _SlidingSegmentedSelector(
                                  selectedIndex: _sortIndex(),
                                  labels: [
                                    strings.shootingTableSortDate,
                                    strings.shootingTableSortName,
                                    strings.shootingTableSortDistance,
                                  ],
                                  onSelected: (index) {
                                    setState(() {
                                      if (index == 0) {
                                        if (_sortBy == _TableSort.updatedAt) {
                                          _sortDescending = !_sortDescending;
                                        } else {
                                          _sortBy = _TableSort.updatedAt;
                                          _sortDescending = true;
                                        }
                                      } else if (index == 1) {
                                        if (_sortBy == _TableSort.name) {
                                          _sortDescending = !_sortDescending;
                                        } else {
                                          _sortBy = _TableSort.name;
                                          _sortDescending = false;
                                        }
                                      } else {
                                        if (_sortBy == _TableSort.distance) {
                                          _sortDescending = !_sortDescending;
                                        } else {
                                          _sortBy = _TableSort.distance;
                                          _sortDescending = true;
                                        }
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                0,
                                AppSpacing.lg,
                                8,
                              ),
                              child: SizedBox(
                                height: 44,
                                child: _SlidingSegmentedSelector(
                                  selectedIndex: _showDopeOnly ? 1 : 0,
                                  labels: [
                                    strings.dopeFilterAll,
                                    strings.dopeFilterDopeOnly,
                                  ],
                                  onSelected: (index) {
                                    setState(() {
                                      _showDopeOnly = index == 1;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                0,
                                AppSpacing.lg,
                                8,
                              ),
                              child: TextField(
                                controller: _searchController,
                                style: textStyles.bodyMedium?.copyWith(
                                  fontSize: 14,
                                ),
                                onChanged: (value) =>
                                    setState(() => _searchQuery = value),
                                decoration: InputDecoration(
                                  hintText: strings.shootingTablesSearchHint,
                                  hintStyle: _hintStyle(context, fontSize: 14),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    size: 20,
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 40,
                                    minHeight: 40,
                                  ),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(
                                            Icons.clear,
                                            size: 18,
                                          ),
                                          tooltip: strings.clear,
                                          splashRadius: 18,
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() => _searchQuery = '');
                                          },
                                        )
                                      : null,
                                  suffixIconConstraints: const BoxConstraints(
                                    minWidth: 40,
                                    minHeight: 40,
                                  ),
                                  filled: true,
                                  fillColor: searchFillColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: subtleBorderColor,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: subtleBorderColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: colors.primary,
                                      width: 1.6,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Gap(AppSpacing.sm),
                            tables.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 180),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.table_chart_rounded,
                                            size: 64,
                                            color: colors.secondary.withValues(
                                              alpha: 0.5,
                                            ),
                                          ),
                                          const Gap(AppSpacing.md),
                                          Text(
                                            strings.shootingTableNoTable,
                                            style: textStyles.bodyMedium
                                                ?.copyWith(
                                                  color: colors.secondary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Expanded(
                                    child: ListView(
                                      padding: const EdgeInsets.fromLTRB(
                                        AppSpacing.lg,
                                        0,
                                        AppSpacing.lg,
                                        84,
                                      ),
                                      children: [
                                        for (
                                          var index = 0;
                                          index < tables.length;
                                          index++
                                        ) ...[
                                          Builder(
                                            builder: (context) {
                                              final tableItem = tables[index];
                                              final accessoryNames = [
                                                ...provider.accessories
                                                    .where(
                                                      (a) => tableItem
                                                          .accessoryIds
                                                          .contains(a.id),
                                                    )
                                                    .map((a) => a.name.trim())
                                                    .where(
                                                      (name) => name.isNotEmpty,
                                                    ),
                                                ...tableItem
                                                    .customAccessoryNames
                                                    .map((name) => name.trim())
                                                    .where(
                                                      (name) => name.isNotEmpty,
                                                    ),
                                              ];

                                              return InkWell(
                                                onTap: () =>
                                                    _openEditorForTable(
                                                      provider,
                                                      tableItem,
                                                    ),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                        AppSpacing.md,
                                                        AppSpacing.sm,
                                                        AppSpacing.sm,
                                                        AppSpacing.md,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: colors.surface,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    border: isDark
                                                        ? null
                                                        : Border.all(
                                                            color: LightColors
                                                                .surfaceHighlight,
                                                            width: 1.35,
                                                          ),
                                                    boxShadow:
                                                        AppShadows.cardPremium,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  _tableDisplayName(
                                                                    tableItem,
                                                                  ),
                                                                  style: textStyles
                                                                      .titleMedium
                                                                      ?.copyWith(
                                                                        fontWeight:
                                                                            FontWeight.w800,
                                                                      ),
                                                                ),
                                                                if (tableItem
                                                                    .isDope) ...[
                                                                  const Gap(8),
                                                                  Container(
                                                                    padding: const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          8,
                                                                      vertical:
                                                                          2,
                                                                    ),
                                                                    decoration: BoxDecoration(
                                                                      color: colors
                                                                          .primary,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                            4,
                                                                          ),
                                                                    ),
                                                                    child: Text(
                                                                      strings
                                                                          .dopeBadge,
                                                                      style: textStyles.labelSmall?.copyWith(
                                                                        color: colors
                                                                            .onPrimary,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ],
                                                            ),
                                                          ),
                                                          Transform.translate(
                                                            offset:
                                                                const Offset(
                                                                  8,
                                                                  0,
                                                                ),
                                                            child: PopupMenuButton<String>(
                                                              icon: Icon(
                                                                Icons
                                                                    .more_vert_rounded,
                                                                color: colors
                                                                    .onSurface,
                                                              ),
                                                              onSelected: (value) {
                                                                if (value ==
                                                                    'export') {
                                                                  WidgetsBinding
                                                                      .instance
                                                                      .addPostFrameCallback((
                                                                        _,
                                                                      ) {
                                                                        if (!mounted)
                                                                          return;
                                                                        _showShareTableDialog(
                                                                          tableItem,
                                                                        );
                                                                      });
                                                                } else if (value ==
                                                                    'edit') {
                                                                  _openEditorForTable(
                                                                    provider,
                                                                    tableItem,
                                                                  );
                                                                } else if (value ==
                                                                    'delete') {
                                                                  _confirmDeleteTable(
                                                                    provider,
                                                                    strings,
                                                                    tableItem,
                                                                  );
                                                                }
                                                              },
                                                              itemBuilder: (context) => [
                                                                PopupMenuItem<
                                                                  String
                                                                >(
                                                                  value:
                                                                      'export',
                                                                  child: Row(
                                                                    children: [
                                                                      const Icon(
                                                                        Icons
                                                                            .ios_share_rounded,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                      const Gap(
                                                                        12,
                                                                      ),
                                                                      Text(
                                                                        strings
                                                                            .shootingTableExportAction,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                PopupMenuItem<
                                                                  String
                                                                >(
                                                                  value: 'edit',
                                                                  child: Row(
                                                                    children: [
                                                                      const Icon(
                                                                        Icons
                                                                            .edit_rounded,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                      const Gap(
                                                                        12,
                                                                      ),
                                                                      Text(
                                                                        strings
                                                                            .edit,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                PopupMenuItem<
                                                                  String
                                                                >(
                                                                  value:
                                                                      'delete',
                                                                  child: Row(
                                                                    children: [
                                                                      const Icon(
                                                                        Icons
                                                                            .delete_rounded,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                      const Gap(
                                                                        12,
                                                                      ),
                                                                      Text(
                                                                        strings
                                                                            .delete,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const Gap(1),
                                                      _tableInfoLine(
                                                        asset:
                                                            'assets/images/tube.svg',
                                                        text:
                                                            '${strings.shootingTablePlatformLabel}: ${_platformName(provider, tableItem.platformId, customPlatformName: tableItem.customPlatformName)}',
                                                        color: colors.secondary,
                                                        style: textStyles
                                                            .bodySmall
                                                            ?.copyWith(
                                                              color: colors
                                                                  .secondary,
                                                            ),
                                                      ),
                                                      const Gap(2),
                                                      _tableInfoLine(
                                                        asset:
                                                            'assets/images/pointe.svg',
                                                        text:
                                                            '${strings.shootingTableAmmoLabel}: ${_ammoName(provider, tableItem.ammoId, strings)}',
                                                        color: colors.secondary,
                                                        style: textStyles
                                                            .bodySmall
                                                            ?.copyWith(
                                                              color: colors
                                                                  .secondary,
                                                            ),
                                                      ),
                                                      const Gap(3),
                                                      _tableInfoLine(
                                                        asset:
                                                            'assets/images/material.svg',
                                                        text:
                                                            '${strings.shootingTableAccessoriesLabel}: ${accessoryNames.isEmpty ? strings.shootingTableNoAccessory : accessoryNames.join(', ')}',
                                                        color: colors.secondary,
                                                        style: textStyles
                                                            .bodySmall
                                                            ?.copyWith(
                                                              color: colors
                                                                  .secondary,
                                                            ),
                                                      ),
                                                      const Gap(4),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          const Gap(AppSpacing.md),
                                        ],
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                        ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          children: [
                            _SectionHeader(
                              leading: const Icon(Icons.edit_note_rounded),
                              title: strings.shootingTableNameLabel,
                            ),
                            const Gap(AppSpacing.xs),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                              ),
                              child: TextField(
                                controller: _tableNameController,
                                decoration: InputDecoration(
                                  hintText: strings.shootingTableNameHint,
                                  hintStyle: _hintStyle(context),
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
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Gap(AppSpacing.md),
                            Container(
                              padding: AppSpacing.paddingMd,
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: isDark
                                    ? null
                                    : Border.all(
                                        color: LightColors.surfaceHighlight,
                                        width: 1.2,
                                      ),
                                boxShadow: AppShadows.cardPremium,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_rounded,
                                    color: colors.primary,
                                  ),
                                  const Gap(AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          strings.dopeMarkAsDope,
                                          style: textStyles.titleMedium,
                                        ),
                                        Text(
                                          strings.dopeExplanation,
                                          style: textStyles.bodySmall?.copyWith(
                                            color: colors.onSurface.withValues(
                                              alpha: 0.7,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: _editorIsDope,
                                    onChanged: (value) {
                                      setState(() {
                                        _editorIsDope = value;
                                      });
                                    },
                                    activeThumbColor: colors.primary,
                                  ),
                                ],
                              ),
                            ),
                            const Gap(AppSpacing.lg),
                            _SectionHeader(
                              leading: const Icon(Icons.tune_rounded),
                              title: strings.shootingTableContextTitle,
                            ),
                            const Gap(AppSpacing.sm),
                            Container(
                              padding: AppSpacing.paddingMd,
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: isDark
                                    ? null
                                    : Border.all(
                                        color: LightColors.surfaceHighlight,
                                        width: 1.2,
                                      ),
                                boxShadow: AppShadows.cardPremium,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // --- PLATEFORME ---
                                  DropdownButtonFormField<String>(
                                    initialValue: _editorPlatformIsOther
                                        ? 'other'
                                        : safePlatformId,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      labelText:
                                          strings.shootingTablePlatformLabel,
                                      prefixIcon: _svgFieldIcon(
                                        'assets/images/tube.svg',
                                        colors.secondary,
                                      ),
                                    ),
                                    items: [
                                      ...platformItems.map(
                                        (p) => DropdownMenuItem<String>(
                                          value: p.id,
                                          child: Text(
                                            p.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: textStyles.bodyLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem<String>(
                                        value: 'other',
                                        child: Text(
                                          strings.shootingTableOtherOption,
                                          style: textStyles.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value == null) return;
                                      if (value == 'other') {
                                        setState(() {
                                          _editorPlatformIsOther = true;
                                          _editorPlatformId = '';
                                          _editorCustomPlatformName = null;
                                        });
                                      } else {
                                        final linked = provider
                                            .linkedAccessoriesForPlatform(value)
                                            .map((a) => a.id)
                                            .toSet();
                                        setState(() {
                                          _editorPlatformId = value;
                                          _editorCustomPlatformName = null;
                                          _editorPlatformIsOther = false;
                                          if (!_editorAccessoriesCustomized) {
                                            _editorAccessoryIds = linked;
                                          }
                                          _activeDistance = null;
                                          _selectedEntryId = null;
                                          _showAllImpacts = false;
                                        });
                                      }
                                    },
                                  ),
                                  if (_editorPlatformIsOther) ...[
                                    const Gap(AppSpacing.sm),
                                    TextFormField(
                                      initialValue: _editorCustomPlatformName,
                                      decoration: InputDecoration(
                                        hintText: strings
                                            .shootingTableCustomPlatformHint,
                                        prefixIcon: const Icon(
                                          Icons.edit_outlined,
                                          size: 18,
                                        ),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _editorCustomPlatformName =
                                              value.trim().isEmpty
                                              ? null
                                              : value.trim();
                                          _editorPlatformId = '';
                                        });
                                      },
                                    ),
                                  ],
                                  const Gap(AppSpacing.md),
                                  // --- CONSOMMABLE ---
                                  DropdownButtonFormField<String?>(
                                    initialValue: _editorAmmoIsOther
                                        ? 'other'
                                        : safeAmmoId,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      labelText: strings.shootingTableAmmoLabel,
                                      prefixIcon: _svgFieldIcon(
                                        'assets/images/pointe.svg',
                                        colors.secondary,
                                      ),
                                    ),
                                    items: [
                                      DropdownMenuItem<String?>(
                                        child: Text(
                                          strings.shootingTableNoAmmo,
                                        ),
                                      ),
                                      ...ammoItems.map(
                                        (a) => DropdownMenuItem<String?>(
                                          value: a.id,
                                          child: Text(
                                            a.name,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      DropdownMenuItem<String?>(
                                        value: 'other',
                                        child: Text(
                                          strings.shootingTableOtherOption,
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      if (value == 'other') {
                                        setState(() {
                                          _editorAmmoIsOther = true;
                                          _editorAmmoId = null;
                                          _editorCustomAmmoName = null;
                                        });
                                      } else {
                                        setState(() {
                                          _editorAmmoId = value;
                                          _editorCustomAmmoName = null;
                                          _editorAmmoIsOther = false;
                                        });
                                      }
                                    },
                                  ),
                                  if (_editorAmmoIsOther) ...[
                                    const Gap(AppSpacing.sm),
                                    TextFormField(
                                      initialValue: _editorCustomAmmoName,
                                      decoration: InputDecoration(
                                        hintText:
                                            strings.shootingTableCustomAmmoHint,
                                        prefixIcon: const Icon(
                                          Icons.edit_outlined,
                                          size: 18,
                                        ),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _editorCustomAmmoName =
                                              value.trim().isEmpty
                                              ? null
                                              : value.trim();
                                          _editorAmmoId = null;
                                        });
                                      },
                                    ),
                                  ],
                                  const Gap(AppSpacing.md),
                                  // --- ACCESSOIRES ---
                                  InkWell(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.lg,
                                    ),
                                    onTap: () =>
                                        _pickAccessories(provider, strings),
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        labelText: strings
                                            .shootingTableAccessoriesLabel,
                                        prefixIcon: _svgFieldIcon(
                                          'assets/images/material.svg',
                                          colors.secondary,
                                        ),
                                        suffixIcon: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                        ),
                                      ),
                                      child: Text(
                                        selectedAccessoryNames.isEmpty
                                            ? strings.shootingTableNoAccessory
                                            : selectedAccessoryNames.join(', '),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: textStyles.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Gap(AppSpacing.sm),
                                ],
                              ),
                            ),
                            const Gap(AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: _SectionHeader(
                                    leading: const Icon(
                                      Icons.straighten_rounded,
                                    ),
                                    title: strings.shootingTableDistancesTitle,
                                  ),
                                ),
                                ChoiceChip(
                                  selected: true,
                                  showCheckmark: false,
                                  backgroundColor: colors.surface,
                                  selectedColor: colors.primary,
                                  side: BorderSide(color: colors.primary),
                                  checkmarkColor: colors.onPrimary,
                                  onSelected: (_) {
                                    setState(() {
                                      _showAllImpacts = !_showAllImpacts;
                                      if (_showAllImpacts) {
                                        _fitAllImpactsInFrame = true;
                                      }
                                      _selectedEntryId = null;
                                    });
                                  },
                                  avatar: Icon(
                                    Icons.swap_horiz_rounded,
                                    size: 16,
                                    color: colors.onPrimary,
                                  ),
                                  labelPadding: const EdgeInsets.only(right: 4),
                                  label: Text(
                                    _showAllImpacts
                                        ? strings.shootingTableModeAll
                                        : strings.shootingTableModeActive,
                                    style: TextStyle(color: colors.onPrimary),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(AppSpacing.sm),
                            Container(
                              padding: AppSpacing.paddingMd,
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: isDark
                                    ? null
                                    : Border.all(
                                        color: LightColors.surfaceHighlight,
                                        width: 1.2,
                                      ),
                                boxShadow: AppShadows.cardPremium,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (distances.isEmpty)
                                    Text(
                                      strings.shootingTableNoDistance,
                                      style: textStyles.bodyMedium?.copyWith(
                                        color: colors.secondary,
                                      ),
                                    )
                                  else
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: distances.map((distance) {
                                        final representative = entries
                                            .firstWhere(
                                              (e) => _sameDistance(
                                                e.distance,
                                                distance,
                                              ),
                                            );
                                        final isSelected =
                                            (_activeDistance != null &&
                                                _sameDistance(
                                                  _activeDistance!,
                                                  distance,
                                                ) &&
                                                !_showAllImpacts) ||
                                            _showAllImpacts;

                                        return ChoiceChip(
                                          selected: isSelected,
                                          showCheckmark: false,
                                          backgroundColor: colors.surface,
                                          selectedColor: colors.primary,
                                          side: BorderSide(
                                            color: isSelected
                                                ? colors.primary
                                                : colors.outline.withValues(
                                                    alpha: 0.35,
                                                  ),
                                          ),
                                          onSelected: (_) {
                                            setState(() {
                                              _showAllImpacts = false;
                                              _activeDistance = distance;
                                              _selectedEntryId = null;
                                            });
                                          },
                                          label: Text(
                                            '${_formatNumber(_getDistanceInDefaultUnit(distance, representative.distanceUnit))} ${_distanceUnitLabel(strings, _defaultDistanceUnit)}',
                                            style: TextStyle(
                                              color: isSelected
                                                  ? colors.onPrimary
                                                  : colors.onSurface,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                ],
                              ),
                            ),
                            const Gap(AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: _SectionHeader(
                                    leading: const Icon(
                                      Icons.gps_fixed_rounded,
                                    ),
                                    title: strings.shootingTableTargetTitle,
                                  ),
                                ),
                                ChoiceChip(
                                  selected: true,
                                  showCheckmark: false,
                                  backgroundColor: colors.surface,
                                  selectedColor: colors.primary,
                                  side: BorderSide(color: colors.primary),
                                  checkmarkColor: colors.onPrimary,
                                  onSelected: (_) {
                                    setState(() {
                                      _fitAllImpactsInFrame =
                                          !_fitAllImpactsInFrame;
                                      _selectedEntryId = null;
                                    });
                                  },
                                  avatar: Icon(
                                    Icons.swap_horiz_rounded,
                                    size: 16,
                                    color: colors.onPrimary,
                                  ),
                                  labelPadding: const EdgeInsets.only(right: 4),
                                  label: Text(
                                    _fitAllImpactsInFrame
                                        ? strings.shootingTableZoomTarget
                                        : strings.shootingTableZoomFitAll,
                                    style: TextStyle(color: colors.onPrimary),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(AppSpacing.sm),
                            Container(
                              padding: AppSpacing.paddingMd,
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: isDark
                                    ? null
                                    : Border.all(
                                        color: LightColors.surfaceHighlight,
                                        width: 1.2,
                                      ),
                                boxShadow: AppShadows.cardPremium,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 1,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: colors.surface,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: colors.outline.withValues(
                                            alpha: 0.25,
                                          ),
                                        ),
                                      ),
                                      child: TapRegion(
                                        onTapOutside: (_) {
                                          if (_selectedEntryId == null) return;
                                          setState(() {
                                            _selectedEntryId = null;
                                          });
                                        },
                                        child: LayoutBuilder(
                                          builder: (context, constraints) {
                                            final width = constraints.maxWidth;
                                            final height =
                                                constraints.maxHeight;
                                            final centerX = width / 2;
                                            final centerY = height / 2;
                                            final targetRadiusPx =
                                                (width < height
                                                    ? width
                                                    : height) /
                                                2 *
                                                _targetVisualRadiusFactor;
                                            var targetScaleReferenceMm =
                                                _c50OuterRadiusMm;
                                            if (_fitAllImpactsInFrame &&
                                                entriesForTarget.isNotEmpty) {
                                              var maxRadiusMm = 0.0;
                                              for (final e
                                                  in entriesForTarget) {
                                                final local =
                                                    _entryRadiusMillimeters(e);
                                                if (local > maxRadiusMm) {
                                                  maxRadiusMm = local;
                                                }
                                              }
                                              targetScaleReferenceMm = math.max(
                                                _c50OuterRadiusMm,
                                                maxRadiusMm *
                                                    _fitAllFramePaddingFactor,
                                              );
                                              if (_showAllImpacts) {
                                                targetScaleReferenceMm = math.max(
                                                  targetScaleReferenceMm,
                                                  _c50OuterRadiusMm *
                                                      _allImpactsMinZoomOutFactor,
                                                );
                                              }
                                            }

                                            return TweenAnimationBuilder<
                                              double
                                            >(
                                              duration: const Duration(
                                                milliseconds: 280,
                                              ),
                                              curve: Curves.easeOutCubic,
                                              tween: Tween<double>(
                                                begin: _lastScaleReferenceMm,
                                                end: targetScaleReferenceMm,
                                              ),
                                              onEnd: () {
                                                _lastScaleReferenceMm =
                                                    targetScaleReferenceMm;
                                              },
                                              builder:
                                                  (
                                                    context,
                                                    animatedScaleReferenceMm,
                                                    _,
                                                  ) {
                                                    Offset pointForEntry(
                                                      ShootingAdjustmentEntry
                                                      entry,
                                                    ) {
                                                      final scaleReferenceMm =
                                                          math.max(
                                                            _c50OuterRadiusMm,
                                                            animatedScaleReferenceMm,
                                                          );
                                                      final sceneZoomFactor =
                                                          _c50OuterRadiusMm /
                                                          scaleReferenceMm;
                                                      final offsetMm =
                                                          _entryOffsetMillimeters(
                                                            entry,
                                                          );
                                                      final normalizedX =
                                                          offsetMm.dx /
                                                          _c50OuterRadiusMm;
                                                      final normalizedY =
                                                          offsetMm.dy /
                                                          _c50OuterRadiusMm;

                                                      return Offset(
                                                        centerX +
                                                            (normalizedX *
                                                                targetRadiusPx *
                                                                sceneZoomFactor),
                                                        centerY -
                                                            (normalizedY *
                                                                targetRadiusPx *
                                                                sceneZoomFactor),
                                                      );
                                                    }

                                                    final sceneZoomFactor =
                                                        _c50OuterRadiusMm /
                                                        math.max(
                                                          _c50OuterRadiusMm,
                                                          animatedScaleReferenceMm,
                                                        );

                                                    return Stack(
                                                      children: [
                                                        Positioned.fill(
                                                          child: Transform.scale(
                                                            scale:
                                                                sceneZoomFactor,
                                                            child: const CustomPaint(
                                                              painter:
                                                                  _TargetPainter(),
                                                            ),
                                                          ),
                                                        ),
                                                        if (activeEntries
                                                                .isNotEmpty &&
                                                            entriesForTarget
                                                                .isEmpty)
                                                          Positioned.fill(
                                                            child: IgnorePointer(
                                                              child: Center(
                                                                child: Container(
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            12,
                                                                        vertical:
                                                                            8,
                                                                      ),
                                                                  decoration: BoxDecoration(
                                                                    color: colors
                                                                        .primary,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          AppRadius
                                                                              .md,
                                                                        ),
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .black
                                                                            .withValues(
                                                                              alpha: 0.22,
                                                                            ),
                                                                        blurRadius:
                                                                            8,
                                                                        offset:
                                                                            const Offset(
                                                                              0,
                                                                              2,
                                                                            ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  child: Text(
                                                                    strings
                                                                        .shootingTableNoImpactInTarget,
                                                                    style: textStyles.bodySmall?.copyWith(
                                                                      color: colors
                                                                          .onPrimary,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        if (selectedEntry !=
                                                            null)
                                                          Positioned.fill(
                                                            child: GestureDetector(
                                                              behavior:
                                                                  HitTestBehavior
                                                                      .opaque,
                                                              onTap: () {
                                                                setState(() {
                                                                  _selectedEntryId =
                                                                      null;
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ...entriesForTarget.map((
                                                          entry,
                                                        ) {
                                                          final point =
                                                              pointForEntry(
                                                                entry,
                                                              );

                                                          return Positioned(
                                                            left: point.dx - 9,
                                                            top: point.dy - 9,
                                                            child: GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  _selectedEntryId =
                                                                      entry.id;
                                                                });
                                                              },
                                                              child:
                                                                  const _ImpactCross(),
                                                            ),
                                                          );
                                                        }),
                                                        if (selectedEntry !=
                                                            null)
                                                          Builder(
                                                            builder: (context) {
                                                              final point =
                                                                  pointForEntry(
                                                                    selectedEntry,
                                                                  );
                                                              final bubbleMaxWidth =
                                                                  190.0;
                                                              final bubbleMinWidth =
                                                                  88.0;
                                                              final preferredTop =
                                                                  point.dy - 74;
                                                              final bubbleLeft =
                                                                  (point.dx -
                                                                          (bubbleMaxWidth /
                                                                              2))
                                                                      .clamp(
                                                                        8.0,
                                                                        width -
                                                                            bubbleMaxWidth -
                                                                            8,
                                                                      )
                                                                      .toDouble();
                                                              final bubbleTop =
                                                                  preferredTop <
                                                                      8
                                                                  ? point.dy +
                                                                        14
                                                                  : preferredTop;

                                                              return Positioned(
                                                                left:
                                                                    bubbleLeft,
                                                                top: bubbleTop,
                                                                child: ConstrainedBox(
                                                                  constraints: BoxConstraints(
                                                                    minWidth:
                                                                        bubbleMinWidth,
                                                                    maxWidth:
                                                                        bubbleMaxWidth,
                                                                  ),
                                                                  child: IntrinsicWidth(
                                                                    child: Container(
                                                                      padding: const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            10,
                                                                        vertical:
                                                                            8,
                                                                      ),
                                                                      decoration: BoxDecoration(
                                                                        color: colors
                                                                            .primary,
                                                                        borderRadius: BorderRadius.circular(
                                                                          AppRadius
                                                                              .md,
                                                                        ),
                                                                        boxShadow: [
                                                                          BoxShadow(
                                                                            color: Colors.black.withValues(
                                                                              alpha: 0.2,
                                                                            ),
                                                                            blurRadius:
                                                                                8,
                                                                            offset: const Offset(
                                                                              0,
                                                                              3,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      child: Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            '${_formatNumber(_getDistanceInDefaultUnit(selectedEntry.distance, selectedEntry.distanceUnit))} ${_distanceUnitLabel(strings, _defaultDistanceUnit)}',
                                                                            style: textStyles.bodySmall?.copyWith(
                                                                              color: colors.onPrimary,
                                                                            ),
                                                                          ),
                                                                          if (selectedEntry
                                                                              .correction
                                                                              .trim()
                                                                              .isNotEmpty) ...[
                                                                            const Gap(
                                                                              2,
                                                                            ),
                                                                            Text(
                                                                              selectedEntry.correction,
                                                                              maxLines: 3,
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: textStyles.bodySmall?.copyWith(
                                                                                color: colors.onPrimary,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                      ],
                                                    );
                                                  },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Gap(AppSpacing.sm),
                                  Text(
                                    strings.shootingTableAxisHint,
                                    style: textStyles.bodySmall?.copyWith(
                                      color: colors.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Gap(4),
                                  Text(
                                    strings.shootingTableScaleFixedHint,
                                    style: textStyles.bodySmall?.copyWith(
                                      color: colors.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Gap(AppSpacing.sm),
                                  if (activeEntries.isEmpty)
                                    Text(
                                      strings.shootingTableNoImpact,
                                      style: textStyles.bodySmall?.copyWith(
                                        color: colors.secondary,
                                      ),
                                    )
                                  else if (selectedEntry != null)
                                    Container(
                                      width: double.infinity,
                                      padding: AppSpacing.paddingMd,
                                      decoration: BoxDecoration(
                                        color: colors.primary.withValues(
                                          alpha: 0.08,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.md,
                                        ),
                                        border: Border.all(
                                          color: colors.primary.withValues(
                                            alpha: 0.25,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            strings
                                                .shootingTableImpactDetailsTitle,
                                            style: textStyles.labelLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          const Gap(6),
                                          Text(
                                            '${strings.distanceLabel}: ${_formatNumber(_getDistanceInDefaultUnit(selectedEntry.distance, selectedEntry.distanceUnit))} ${_distanceUnitLabel(strings, _defaultDistanceUnit)}',
                                          ),
                                          Text(
                                            'X: ${_formatNumber(_getOffsetInDefaultUnit(selectedEntry.horizontalOffset, selectedEntry.offsetUnit))} ${_offsetUnitLabel(strings, _defaultOffsetUnit)}',
                                          ),
                                          Text(
                                            'Y: ${_formatNumber(_getOffsetInDefaultUnit(selectedEntry.verticalOffset, selectedEntry.offsetUnit))} ${_offsetUnitLabel(strings, _defaultOffsetUnit)}',
                                          ),
                                          if (selectedEntry.correction
                                              .trim()
                                              .isNotEmpty)
                                            Text(
                                              '${strings.shootingTableCorrectionLabel}: ${selectedEntry.correction}',
                                            ),
                                          if (selectedEntry.note
                                              .trim()
                                              .isNotEmpty)
                                            Text(
                                              '${strings.notes}: ${selectedEntry.note}',
                                            ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Gap(AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: _SectionHeader(
                                    leading: const Icon(Icons.list_alt_rounded),
                                    title: strings.shootingTableEntriesTitle,
                                  ),
                                ),
                                FilledButton.icon(
                                  onPressed: _editorPlatformId == null
                                      ? null
                                      : () => _addOrEditEntry(),
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                  label: Text(strings.add),
                                  style: FilledButton.styleFrom(
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(AppSpacing.sm),
                            Builder(
                              builder: (context) {
                                return Container(
                                  padding: AppSpacing.paddingMd,
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: isDark
                                        ? null
                                        : Border.all(
                                            color: LightColors.surfaceHighlight,
                                            width: 1.2,
                                          ),
                                    boxShadow: AppShadows.cardPremium,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (entries.isEmpty)
                                        Text(
                                          strings.shootingTableNoEntry,
                                          style: textStyles.bodyMedium
                                              ?.copyWith(
                                                color: colors.secondary,
                                              ),
                                        )
                                      else
                                        ListView.separated(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: entries.length,
                                          separatorBuilder: (_, _) =>
                                              const Divider(height: 16),
                                          itemBuilder: (context, index) {
                                            final entry = entries[index];
                                            final isSelected =
                                                _selectedEntryId == entry.id;
                                            return Material(
                                              color: isSelected
                                                  ? colors.primary.withValues(
                                                      alpha: 0.07,
                                                    )
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppRadius.md,
                                                  ),
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppRadius.md,
                                                    ),
                                                onTap: () {
                                                  setState(() {
                                                    _selectedEntryId = entry.id;
                                                    _activeDistance =
                                                        entry.distance;
                                                    _showAllImpacts = false;
                                                  });
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                        AppSpacing.md,
                                                        AppSpacing.sm,
                                                        AppSpacing.md,
                                                        AppSpacing.sm,
                                                      ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .place_outlined,
                                                            size: 18,
                                                            color: isSelected
                                                                ? colors.primary
                                                                : colors
                                                                      .secondary,
                                                          ),
                                                          const Gap(
                                                            AppSpacing.xs,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              '${_formatNumber(_getDistanceInDefaultUnit(entry.distance, entry.distanceUnit))} ${_distanceUnitLabel(strings, _defaultDistanceUnit)}',
                                                              style: textStyles
                                                                  .titleMedium
                                                                  ?.copyWith(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w800,
                                                                    color:
                                                                        isSelected
                                                                        ? colors
                                                                              .primary
                                                                        : colors
                                                                              .onSurface,
                                                                  ),
                                                            ),
                                                          ),
                                                          IconButton(
                                                            onPressed: () =>
                                                                _addOrEditEntry(
                                                                  existing:
                                                                      entry,
                                                                ),
                                                            visualDensity:
                                                                VisualDensity
                                                                    .compact,
                                                            icon: const Icon(
                                                              Icons
                                                                  .edit_rounded,
                                                            ),
                                                            tooltip:
                                                                strings.edit,
                                                            padding:
                                                                EdgeInsets.zero,
                                                            constraints:
                                                                const BoxConstraints.tightFor(
                                                                  width: 32,
                                                                  height: 32,
                                                                ),
                                                          ),
                                                          const Gap(2),
                                                          IconButton(
                                                            onPressed: () =>
                                                                _deleteEntry(
                                                                  strings:
                                                                      strings,
                                                                  entry: entry,
                                                                ),
                                                            visualDensity:
                                                                VisualDensity
                                                                    .compact,
                                                            icon: const Icon(
                                                              Icons
                                                                  .delete_rounded,
                                                            ),
                                                            tooltip:
                                                                strings.delete,
                                                            padding:
                                                                EdgeInsets.zero,
                                                            constraints:
                                                                const BoxConstraints.tightFor(
                                                                  width: 32,
                                                                  height: 32,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      const Gap(AppSpacing.sm),
                                                      Container(
                                                        width: double.infinity,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal:
                                                                  AppSpacing.sm,
                                                              vertical: 7,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: colors
                                                              .onSurface
                                                              .withValues(
                                                                alpha: 0.05,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                AppRadius.sm,
                                                              ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .gps_fixed_rounded,
                                                              size: 14,
                                                              color: colors
                                                                  .secondary,
                                                            ),
                                                            const Gap(
                                                              AppSpacing.xs,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                '${strings.shootingTableEntryImpactsLabel}  X: ${_formatNumber(_getOffsetInDefaultUnit(entry.horizontalOffset, entry.offsetUnit))} ${_offsetUnitLabel(strings, _defaultOffsetUnit)}   Y: ${_formatNumber(_getOffsetInDefaultUnit(entry.verticalOffset, entry.offsetUnit))} ${_offsetUnitLabel(strings, _defaultOffsetUnit)}',
                                                                maxLines: 1,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: textStyles
                                                                    .bodySmall
                                                                    ?.copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color: colors
                                                                          .onSurface,
                                                                    ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const Gap(AppSpacing.sm),
                                                      Container(
                                                        width: double.infinity,
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal:
                                                                  AppSpacing.sm,
                                                              vertical: 7,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: colors.primary
                                                              .withValues(
                                                                alpha: 0.09,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                AppRadius.sm,
                                                              ),
                                                          border: Border.all(
                                                            color: colors
                                                                .primary
                                                                .withValues(
                                                                  alpha: 0.18,
                                                                ),
                                                          ),
                                                        ),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    top: 2,
                                                                  ),
                                                              child: Icon(
                                                                Icons
                                                                    .tune_rounded,
                                                                size: 14,
                                                                color: colors
                                                                    .primary,
                                                              ),
                                                            ),
                                                            const Gap(
                                                              AppSpacing.xs,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                entry.correction
                                                                        .trim()
                                                                        .isEmpty
                                                                    ? '${strings.shootingTableCorrectionLabel} : —'
                                                                    : '${strings.shootingTableCorrectionLabel} : ${entry.correction.replaceAll('\n', '   ')}',
                                                                style: textStyles
                                                                    .bodySmall
                                                                    ?.copyWith(
                                                                      color: colors
                                                                          .primary,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                    ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      if (entry.note
                                                          .trim()
                                                          .isNotEmpty) ...[
                                                        const Gap(
                                                          AppSpacing.sm,
                                                        ),
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets.only(
                                                                    top: 2,
                                                                  ),
                                                              child: Icon(
                                                                Icons
                                                                    .notes_rounded,
                                                                size: 14,
                                                                color: colors
                                                                    .secondary,
                                                              ),
                                                            ),
                                                            const Gap(
                                                              AppSpacing.xs,
                                                            ),
                                                            Expanded(
                                                              child: Text(
                                                                entry.note,
                                                                style: textStyles
                                                                    .bodySmall
                                                                    ?.copyWith(
                                                                      color: colors
                                                                          .secondary,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .italic,
                                                                    ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const Gap(AppSpacing.lg),
                            SizedBox(
                              height: 52,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: FilledButton.tonal(
                                      onPressed: _cancelEditor,
                                      style: FilledButton.styleFrom(
                                        backgroundColor: colors.primary
                                            .withValues(alpha: 0.72),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        strings.actionCancel.toUpperCase(),
                                        style: textStyles.labelLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Gap(AppSpacing.md),
                                  Expanded(
                                    child: FilledButton(
                                      onPressed:
                                          ((_editorPlatformId == null ||
                                                      _editorPlatformId!
                                                          .isEmpty) &&
                                                  (_editorCustomPlatformName ==
                                                          null ||
                                                      _editorCustomPlatformName!
                                                          .trim()
                                                          .isEmpty)) ||
                                              _tableNameController.text
                                                  .trim()
                                                  .isEmpty
                                          ? null
                                          : () =>
                                                _saveEditor(provider, strings),
                                      style: FilledButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        strings.shootingTableSaveButton,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Gap(AppSpacing.lg),
                          ],
                        ),
                      ],
                    ),
                    if (_pageIndex == 0)
                      Positioned(
                        right: AppSpacing.lg,
                        bottom: 50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FloatingActionButton.extended(
                              onPressed: () => _openEditorForCreate(provider),
                              icon: const Icon(Icons.add),
                              label: Text(strings.shootingTableCreateButton),
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                            ),
                            const Gap(AppSpacing.md),
                            FloatingActionButton.extended(
                              onPressed: () =>
                                  _showImportTableCodeDialog(provider),
                              icon: const Icon(Icons.file_upload_outlined),
                              label: Text(strings.shootingTableImportTitle),
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                            ),
                          ],
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







