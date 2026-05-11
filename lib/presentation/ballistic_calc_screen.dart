import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import 'package:thot/theme.dart';
import 'package:thot/l10n/app_strings.dart';
import '../data/thot_provider.dart';

class BallisticCalcScreen extends StatefulWidget {
  final bool embedded;

  const BallisticCalcScreen({super.key, this.embedded = false});

  @override
  State<BallisticCalcScreen> createState() => _BallisticCalcScreenState();
}

// Deprecated alias for backward compatibility
@Deprecated('Use BallisticCalcScreen instead')
typedef MilliemeToolScreen = BallisticCalcScreen;

class _BallisticCalcScreenState extends State<BallisticCalcScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<TextSpan> _parseBoldText(String text, TextStyle baseStyle) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, match.start), style: baseStyle));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: baseStyle.copyWith(fontWeight: FontWeight.bold),
      ));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex), style: baseStyle));
    }

    return spans;
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;

    final content = GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Column(
        children: [
          if (!widget.embedded) ...[
            Column(
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
              ],
            ),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          strings.ballisticCalcTitle,
                          style: textStyles.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                      const Gap(4),
                      Tooltip(
                        richMessage: TextSpan(
                          children: _parseBoldText(strings.ballisticCalcTooltip, textStyles.bodySmall?.copyWith(color: colors.surface) ?? const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                        triggerMode: TooltipTriggerMode.tap,
                        showDuration: const Duration(seconds: 6),
                        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: colors.onSurface.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(10),
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
                const Gap(AppSpacing.xs),
                GestureDetector(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Divider(color: colors.outline),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: _SlidingSegmentedSelector(
              selectedIndex: _tabController.index,
              labels: [
                strings.ballisticCalcTabMillieme,
                strings.ballisticCalcTabHitFactor,
                strings.ballisticCalcTabPowerFactor,
              ],
              onSelected: (index) {
                setState(() {
                  _tabController.animateTo(index);
                });
              },
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _MilliemeTab(),
                _HitFactorTab(),
                _PowerFactorTab(),
              ],
            ),
          ),
        ],
      ),
    );

    if (widget.embedded) {
      return Container(
        color: baseBackground,
        child: content,
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: baseBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: content,
    );
  }
}

class _MilliemePreset {
  final String id;
  final String label;
  final double valueMeters;
  final IconData icon;
  final bool isVertical;

  const _MilliemePreset({
    required this.id,
    required this.label,
    required this.valueMeters,
    required this.icon,
    required this.isVertical,
  });
}

class _MilliemeTab extends StatefulWidget {
  const _MilliemeTab();

  @override
  State<_MilliemeTab> createState() => _MilliemeTabState();
}

class _MilliemeTabState extends State<_MilliemeTab> {
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _milliemeController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();

  String? _selectedPresetId;
  bool _presetsExpanded = false;
  OverlayEntry? _hintOverlay;
  Offset? _tapPosition;

  void _showFieldDisabledHint(BuildContext context, Offset? tapPosition) {
    final strings = AppStrings.of(context);
    final overlay = Overlay.of(context);
    
    _hintOverlay?.remove();
    
    _hintOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: (tapPosition?.dy ?? MediaQuery.of(context).size.height * 0.3) - 60,
        left: (tapPosition?.dx ?? 16) - 100,
        child: Material(
          color: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              strings.milliemeFieldDisabledHint,
              style: TextStyle(
                color: Theme.of(context).colorScheme.surface,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
    
    overlay.insert(_hintOverlay!);
    
    Future.delayed(const Duration(seconds: 2), () {
      _hintOverlay?.remove();
      _hintOverlay = null;
    });
  }

  bool _isFieldDisabled(String fieldName) {
    final frontText = _frontController.text.trim();
    final milText = _milliemeController.text.trim();
    final distText = _distanceController.text.trim();

    final values = [frontText, milText, distText];
    final filledCount = values.where((v) => v.isNotEmpty).length;

    if (filledCount < 2) return false;

    // If 2 fields are filled, disable the third
    if (fieldName == 'front' && milText.isNotEmpty && distText.isNotEmpty) return true;
    if (fieldName == 'millieme' && frontText.isNotEmpty && distText.isNotEmpty) return true;
    if (fieldName == 'distance' && frontText.isNotEmpty && milText.isNotEmpty) return true;

    return false;
  }

  List<_MilliemePreset> _presets(BuildContext context) {
    final strings = AppStrings.of(context);

    return [
      _MilliemePreset(
        id: 'pylon_h',
        label: strings.milliemePresetPylonHeight,
        valueMeters: 10.0,
        icon: Icons.cell_tower,
        isVertical: true,
      ),
      _MilliemePreset(
        id: 'pylon_w',
        label: strings.milliemePresetPylonWidth,
        valueMeters: 1.0,
        icon: Icons.cell_tower,
        isVertical: false,
      ),
      _MilliemePreset(
        id: 'truck_h',
        label: strings.milliemePresetTruckHeight,
        valueMeters: 3.5,
        icon: Icons.local_shipping_rounded,
        isVertical: true,
      ),
      _MilliemePreset(
        id: 'truck_w',
        label: strings.milliemePresetTruckWidth,
        valueMeters: 12.0,
        icon: Icons.local_shipping_rounded,
        isVertical: false,
      ),
      _MilliemePreset(
        id: 'car_h',
        label: strings.milliemePresetCarHeight,
        valueMeters: 1.5,
        icon: Icons.directions_car_rounded,
        isVertical: true,
      ),
      _MilliemePreset(
        id: 'car_w',
        label: strings.milliemePresetCarWidth,
        valueMeters: 4.3,
        icon: Icons.directions_car_rounded,
        isVertical: false,
      ),
      _MilliemePreset(
        id: 'human_h',
        label: strings.milliemePresetHumanHeight,
        valueMeters: 1.8,
        icon: Icons.person_rounded,
        isVertical: true,
      ),
      _MilliemePreset(
        id: 'head_h',
        label: strings.milliemePresetHeadHeight,
        valueMeters: 0.25,
        icon: Icons.person_outline_rounded,
        isVertical: true,
      ),
      _MilliemePreset(
        id: 'head_w',
        label: strings.milliemePresetHeadWidth,
        valueMeters: 0.18,
        icon: Icons.person_outline_rounded,
        isVertical: false,
      ),
      _MilliemePreset(
        id: 'door_h',
        label: strings.milliemePresetDoorHeight,
        valueMeters: 2.0,
        icon: Icons.door_front_door_rounded,
        isVertical: true,
      ),
      _MilliemePreset(
        id: 'door_w',
        label: strings.milliemePresetDoorWidth,
        valueMeters: 0.9,
        icon: Icons.door_front_door_rounded,
        isVertical: false,
      ),
      _MilliemePreset(
        id: 'window_h',
        label: strings.milliemePresetWindowHeight,
        valueMeters: 1.2,
        icon: Icons.window_rounded,
        isVertical: true,
      ),
      _MilliemePreset(
        id: 'window_w',
        label: strings.milliemePresetWindowWidth,
        valueMeters: 1.2,
        icon: Icons.window_rounded,
        isVertical: false,
      ),
      _MilliemePreset(
        id: 'tree_h',
        label: strings.milliemePresetTreeHeight,
        valueMeters: 6.0,
        icon: Icons.forest_rounded,
        isVertical: true,
      ),
      _MilliemePreset(
        id: 'tree_w',
        label: strings.milliemePresetTreeWidth,
        valueMeters: 3.0,
        icon: Icons.forest_rounded,
        isVertical: false,
      ),
      _MilliemePreset(
        id: 'house_h',
        label: strings.milliemePresetHouseHeight,
        valueMeters: 6.0,
        icon: Icons.home_rounded,
        isVertical: true,
      ),
      _MilliemePreset(
        id: 'house_w',
        label: strings.milliemePresetHouseWidth,
        valueMeters: 10.0,
        icon: Icons.home_rounded,
        isVertical: false,
      ),
    ];
  }

  @override
  void dispose() {
    _frontController.dispose();
    _milliemeController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  void _calculate() {
    final front = _parseNumber(_frontController.text);
    final mil = _parseNumber(_milliemeController.text);
    final dist = _parseNumber(_distanceController.text);

    final values = [front, mil, dist];
    final filledCount = values.where((v) => v != null).length;
    if (filledCount < 2) return;

    double? newFront = front;
    double? newMil = mil;
    double? newDist = dist;

    if (newFront == null && newMil != null && newDist != null && newMil != 0) {
      newFront = _computeFront(
        millieme: newMil,
        distanceMeters: newDist,
      );
    } else if (newMil == null &&
        newFront != null &&
        newDist != null &&
        newDist != 0) {
      newMil = _computeMillieme(
        frontMeters: newFront,
        distanceMeters: newDist,
      );
    } else if (newDist == null &&
        newFront != null &&
        newMil != null &&
        newMil != 0) {
      newDist = _computeDistanceMeters(
        frontMeters: newFront,
        millieme: newMil,
      );
    } else if (filledCount == 3) {
      if (newFront != null && newMil != null && newMil != 0) {
        newDist = _computeDistanceMeters(
          frontMeters: newFront,
          millieme: newMil,
        );
      }
    }

    setState(() {
      _frontController.text = newFront == null ? '' : _formatNumber(newFront);
      _milliemeController.text = newMil == null ? '' : _formatNumber(newMil);
      _distanceController.text = newDist == null ? '' : _formatNumber(newDist);
    });
  }

  double? _parseNumber(String text) {
    final normalized = text.replaceAll(',', '.').trim();
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  String _formatNumber(double value) {
    final rounded = value.roundToDouble();
    if ((value - rounded).abs() < 1e-6) {
      return rounded.toStringAsFixed(0);
    }
    final absVal = value.abs();
    final decimals = absVal >= 10 ? 1 : 2;
    return value.toStringAsFixed(decimals);
  }

  double _computeDistanceMeters({
    required double frontMeters,
    required double millieme,
  }) {
    return 1000.0 * frontMeters / millieme;
  }

  double _computeMillieme({
    required double frontMeters,
    required double distanceMeters,
  }) {
    return 1000.0 * frontMeters / distanceMeters;
  }

  double _computeFront({
    required double millieme,
    required double distanceMeters,
  }) {
    return millieme * (distanceMeters / 1000.0);
  }

  void _applyPreset(_MilliemePreset preset) {
    setState(() {
      _selectedPresetId = preset.id;
      _frontController.text = _formatNumber(preset.valueMeters);
      _presetsExpanded = false;
    });
  }

  void _resetAll() {
    setState(() {
      _frontController.clear();
      _milliemeController.clear();
      _distanceController.clear();
      _selectedPresetId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final provider = Provider.of<ThotProvider>(context, listen: true);

    final presets = _presets(context);

    final fieldDecoration = InputDecoration(
      filled: true,
      fillColor: colors.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
    );

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!provider.useMetric)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  strings.milliemeImperialWarning,
                  style: textStyles.bodySmall?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          const Gap(4),
          Text(
            strings.milliemeIntro,
            style: textStyles.bodySmall?.copyWith(color: colors.secondary),
          ),
          const Gap(AppSpacing.lg),
          Text(
            strings.milliemeFrontLabel,
            style: textStyles.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: colors.secondary),
          ),
          const Gap(AppSpacing.xs),
          Stack(
            children: [
              TextField(
                controller: _frontController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                onChanged: (_) => setState(() {}),
                decoration: fieldDecoration.copyWith(hintText: strings.milliemeFrontField, suffixText: 'm'),
              ),
              if (_isFieldDisabled('front'))
                Positioned.fill(
                  child: Container(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTapDown: (details) {
                        _tapPosition = details.globalPosition;
                        _showFieldDisabledHint(context, _tapPosition);
                      },
                      behavior: HitTestBehavior.opaque,
                    ),
                  ),
                ),
            ],
          ),
          const Gap(AppSpacing.sm),
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  onTap: () => setState(() {
                    _presetsExpanded = !_presetsExpanded;
                  }),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        strings.milliemePresetsTitle,
                        style: textStyles.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                      Icon(_presetsExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, color: Colors.white),
                    ],
                  ),
                ),
                if (_presetsExpanded) ...[
                  const Gap(AppSpacing.xs),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const columns = 4;
                      const spacing = 8.0;
                      final tileWidth = (constraints.maxWidth - (spacing * (columns - 1))) / columns;
                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          for (final preset in presets)
                            SizedBox(
                              width: tileWidth,
                              child: _MilliemePresetButton(
                                preset: preset,
                                selected: preset.id == _selectedPresetId,
                                onTap: () => _applyPreset(preset),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          const Gap(AppSpacing.lg),
          Text(
            strings.milliemeMilliemeLabel,
            style: textStyles.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: colors.secondary),
          ),
          const Gap(AppSpacing.xs),
          Stack(
            children: [
              TextField(
                controller: _milliemeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                onChanged: (_) => setState(() {}),
                decoration: fieldDecoration.copyWith(hintText: strings.milliemeMilliemeField, suffixText: 'mil'),
              ),
              if (_isFieldDisabled('millieme'))
                Positioned.fill(
                  child: Container(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTapDown: (details) {
                        _tapPosition = details.globalPosition;
                        _showFieldDisabledHint(context, _tapPosition);
                      },
                      behavior: HitTestBehavior.opaque,
                    ),
                  ),
                ),
            ],
          ),
          const Gap(AppSpacing.lg),
          Text(
            strings.milliemeDistanceLabel,
            style: textStyles.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: colors.secondary),
          ),
          const Gap(AppSpacing.xs),
          Stack(
            children: [
              TextField(
                controller: _distanceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                onChanged: (_) => setState(() {}),
                decoration: fieldDecoration.copyWith(hintText: strings.milliemeDistanceField, suffixText: 'm'),
              ),
              if (_isFieldDisabled('distance'))
                Positioned.fill(
                  child: Container(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTapDown: (details) {
                        _tapPosition = details.globalPosition;
                        _showFieldDisabledHint(context, _tapPosition);
                      },
                      behavior: HitTestBehavior.opaque,
                    ),
                  ),
                ),
            ],
          ),
          const Gap(AppSpacing.lg),
          Text(
            strings.milliemeHelpFormula,
            style: textStyles.bodySmall?.copyWith(color: colors.secondary),
          ),
          const Gap(AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: FilledButton.tonal(
                  onPressed: _resetAll,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.secondary.withValues(alpha: 0.85),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(strings.milliemeResetAll),
                ),
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: _calculate,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(strings.milliemeCalculate),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MilliemePresetButton extends StatelessWidget {
  final _MilliemePreset preset;
  final bool selected;
  final VoidCallback onTap;

  const _MilliemePresetButton({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    final borderColor = selected ? colors.primary : colors.outline;
    final background = colors.surface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 64,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: borderColor,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.rotate(
                      angle: preset.isVertical ? 0 : math.pi / 2,
                      child: Icon(
                        Icons.height_rounded, // flèche double, une pointe à chaque extrémité
                        color: colors.secondary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(preset.icon, color: colors.primary, size: 22),
                  ],
                ),
                const Gap(2),
                Text(
                  preset.label,
                  style: textStyles.labelSmall?.copyWith(
                    color: colors.onSurface,
                    fontSize: 9,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SlidingSegmentedSelector extends StatelessWidget {
  final int selectedIndex;
  final List<String> labels;
  final ValueChanged<int> onSelected;

  const _SlidingSegmentedSelector({
    required this.selectedIndex,
    required this.labels,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final subtleBorderColor = colors.outline.withValues(alpha: 0.45);
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth / labels.length;

        final chipGray = Color.alphaBlend(
          colors.outline.withValues(alpha: 0.8),
          baseBackground,
        );

        return Container(
          height: 44,
          decoration: BoxDecoration(
            color: chipGray,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: subtleBorderColor,
            ),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: selectedIndex * itemWidth,
                top: 0,
                bottom: 0,
                width: itemWidth,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: List.generate(labels.length, (index) {
                  final isSelected = index == selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onSelected(index),
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: Text(
                          labels[index],
                          style: textStyles.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected && Theme.of(context).brightness == Brightness.dark
                                ? Colors.black
                                : isSelected
                                    ? Colors.white
                                    : colors.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- Hit Factor Tab ---

class _HitFactorTab extends StatefulWidget {
  const _HitFactorTab();

  @override
  State<_HitFactorTab> createState() => _HitFactorTabState();
}

class _HitFactorTabState extends State<_HitFactorTab> {
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _zoneAController = TextEditingController(text: '0');
  final TextEditingController _zoneCController = TextEditingController(text: '0');
  final TextEditingController _zoneDController = TextEditingController(text: '0');
  final TextEditingController _missController = TextEditingController(text: '0');
  final TextEditingController _noShootController = TextEditingController(text: '0');

  bool _isMajor = false;

  double get _time => double.tryParse(_timeController.text) ?? 0;
  int get _zoneA => int.tryParse(_zoneAController.text) ?? 0;
  int get _zoneC => int.tryParse(_zoneCController.text) ?? 0;
  int get _zoneD => int.tryParse(_zoneDController.text) ?? 0;
  int get _miss => int.tryParse(_missController.text) ?? 0;
  int get _noShoot => int.tryParse(_noShootController.text) ?? 0;

  double get _score {
    final coefA = 5;
    final coefC = _isMajor ? 4 : 3;
    final coefD = _isMajor ? 2 : 1;
    return (_zoneA * coefA) + (_zoneC * coefC) + (_zoneD * coefD) + (_miss * -10) + (_noShoot * -10);
  }

  double get _hitFactor {
    if (_time <= 0) return 0;
    return math.max(0, _score) / _time;
  }

  @override
  void dispose() {
    _timeController.dispose();
    _zoneAController.dispose();
    _zoneCController.dispose();
    _zoneDController.dispose();
    _missController.dispose();
    _noShootController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _timeController.clear();
      _zoneAController.text = '0';
      _zoneCController.text = '0';
      _zoneDController.text = '0';
      _missController.text = '0';
      _noShootController.text = '0';
      _isMajor = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    final fieldDecoration = InputDecoration(
      filled: true,
      fillColor: colors.surfaceContainerHighest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
    );

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Gap(4),
          Text(
            strings.hitFactorIntro,
            style: textStyles.bodySmall?.copyWith(color: colors.secondary),
          ),
          const Gap(AppSpacing.lg),
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.hitFactorTimeLabel,
                  style: textStyles.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: colors.secondary),
                ),
                const Gap(AppSpacing.xs),
                TextField(
                  controller: _timeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: fieldDecoration.copyWith(
                    suffixText: 's',
                    suffixStyle: textStyles.bodyMedium?.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : colors.onSurface,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const Gap(AppSpacing.md),
                Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SwitchListTile.adaptive(
                    contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    title: Text('Major / Minor'),
                    subtitle: Text(_isMajor ? 'Major' : 'Minor'),
                    value: _isMajor,
                    onChanged: (value) => setState(() => _isMajor = value),
                  ),
                ),
              ],
            ),
          ),
          const Gap(AppSpacing.md),
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Zone A', style: textStyles.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: colors.secondary)),
                          const Gap(AppSpacing.xs),
                          TextField(
                            controller: _zoneAController,
                            keyboardType: TextInputType.number,
                            decoration: fieldDecoration,
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                    const Gap(AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Zone C', style: textStyles.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: colors.secondary)),
                          const Gap(AppSpacing.xs),
                          TextField(
                            controller: _zoneCController,
                            keyboardType: TextInputType.number,
                            decoration: fieldDecoration,
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Zone D', style: textStyles.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: colors.secondary)),
                          const Gap(AppSpacing.xs),
                          TextField(
                            controller: _zoneDController,
                            keyboardType: TextInputType.number,
                            decoration: fieldDecoration,
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                    const Gap(AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(strings.hitFactorMike, style: textStyles.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: colors.secondary)),
                          const Gap(AppSpacing.xs),
                          TextField(
                            controller: _missController,
                            keyboardType: TextInputType.number,
                            decoration: fieldDecoration,
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Gap(AppSpacing.md),
                Text('No-shoot (NS)', style: textStyles.labelMedium?.copyWith(fontWeight: FontWeight.w700, color: colors.secondary)),
                const Gap(AppSpacing.xs),
                TextField(
                  controller: _noShootController,
                  keyboardType: TextInputType.number,
                  decoration: fieldDecoration,
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          ),
          const Gap(AppSpacing.md),
          Container(
            padding: AppSpacing.paddingLg,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Score : ${_score.toStringAsFixed(0)} points',
                  style: textStyles.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: colors.onSurface),
                ),
                const Gap(AppSpacing.sm),
                Text(
                  'Hit Factor : ${_hitFactor.toStringAsFixed(4)}',
                  style: textStyles.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: colors.primary),
                ),
              ],
            ),
          ),
          const Gap(AppSpacing.md),
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.hitFactorCoefficientsLegend,
                  style: textStyles.bodySmall?.copyWith(color: colors.secondary),
                ),
                const Gap(AppSpacing.xs),
                Text(
                  _isMajor ? 'Major : A=5, C=4, D=2, M=-10, NS=-10' : 'Minor : A=5, C=3, D=1, M=-10, NS=-10',
                  style: textStyles.bodySmall?.copyWith(color: colors.secondary),
                ),
              ],
            ),
          ),
          const Gap(AppSpacing.lg),
          FilledButton.tonal(
            onPressed: _reset,
            style: FilledButton.styleFrom(
              backgroundColor: colors.secondary.withValues(alpha: 0.85),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(strings.hitFactorReset.toUpperCase()),
          ),
          const Gap(AppSpacing.xl),
        ],
      ),
    );
  }
}

// --- Power Factor Tab ---

class _PowerFactorTab extends StatefulWidget {
  const _PowerFactorTab();

  @override
  State<_PowerFactorTab> createState() => _PowerFactorTabState();
}

class _PowerFactorTabState extends State<_PowerFactorTab> {
  final TextEditingController _velocityController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  double get _velocity => double.tryParse(_velocityController.text) ?? 0;
  double get _weight => double.tryParse(_weightController.text) ?? 0;

  double _velocityFps(VelocityUnit unit) {
    if (unit == VelocityUnit.feetPerSecond) return _velocity;
    return mpsToFps(_velocity);
  }

  double _weightGrain(WeightUnit unit) {
    if (unit == WeightUnit.grain) return _weight;
    if (unit == WeightUnit.ounce) return gramsToGrains(ouncesToGrams(_weight));
    return gramsToGrains(_weight);
  }

  double _powerFactor(ThotProvider provider) =>
      (_velocityFps(provider.velocityUnit) * _weightGrain(provider.weightUnit)) / 1000;

  String _classification(AppStrings strings) {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final powerFactor = _powerFactor(provider);
    if (powerFactor >= 165) return strings.powerFactorClassificationMajor;
    if (powerFactor >= 125) return strings.powerFactorClassificationMinor;
    return strings.powerFactorClassificationSubMinor;
  }

  Color _classificationColor(ColorScheme colors) {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final powerFactor = _powerFactor(provider);
    if (powerFactor >= 165) return colors.primary;
    if (powerFactor >= 125) return const Color(0xFFFFA726).withValues(alpha: 0.9);
    return const Color(0xFFE53935).withValues(alpha: 0.9);
  }

  @override
  void dispose() {
    _velocityController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final provider = Provider.of<ThotProvider>(context);
    final velocitySuffix =
        provider.velocityUnit == VelocityUnit.metersPerSecond ? 'm/s' : 'fps';
    final weightSuffix = provider.weightUnit == WeightUnit.grain
        ? 'gr'
        : provider.weightUnit == WeightUnit.ounce
            ? 'oz'
            : 'g';
    final powerFactor = _powerFactor(provider);

    final fieldDecoration = InputDecoration(
      filled: true,
      fillColor: colors.surfaceContainerHighest,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
    );

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Gap(4),
          Text(
            strings.powerFactorIntro,
            style: textStyles.bodySmall?.copyWith(color: colors.secondary),
          ),
          const Gap(AppSpacing.lg),
          Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.powerFactorVelocityLabel,
                  style: textStyles.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: colors.secondary),
                ),
                const Gap(AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _velocityController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: fieldDecoration.copyWith(
                            hintText: strings.powerFactorVelocityHint,
                            suffixText: velocitySuffix,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(AppSpacing.md),
                Text(
                  strings.powerFactorWeightLabel,
                  style: textStyles.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: colors.secondary),
                ),
                const Gap(AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _weightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: fieldDecoration.copyWith(
                            hintText: strings.powerFactorWeightHint,
                            suffixText: weightSuffix,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(AppSpacing.md),
          Container(
            padding: AppSpacing.paddingLg,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.powerFactorResultLabel,
                  style: textStyles.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: colors.secondary),
                ),
                const Gap(AppSpacing.sm),
                Text(
                  powerFactor.toStringAsFixed(1),
                  style: textStyles.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: colors.primary),
                ),
                const Gap(AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: (powerFactor / 170).clamp(0.0, 1.0).toDouble(),
                    backgroundColor: colors.primary.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                  ),
                ),
                const Gap(AppSpacing.sm),
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: _classificationColor(colors),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _classification(strings),
                    style: textStyles.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const Gap(AppSpacing.md),
          Text(
            strings.powerFactorFormulaNote,
            style: textStyles.bodySmall?.copyWith(color: colors.secondary),
          ),
          const Gap(AppSpacing.xs),
          Text(
            strings.powerFactorThresholdsNote,
            style: textStyles.bodySmall?.copyWith(color: colors.secondary),
          ),
        ],
      ),
    );
  }
}