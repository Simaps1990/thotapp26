import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import 'package:thot/theme.dart';
import 'package:thot/l10n/app_strings.dart';
import '../data/thot_provider.dart';

class MilliemeToolScreen extends StatefulWidget {
  final bool embedded;

  const MilliemeToolScreen({Key? key, this.embedded = false}) : super(key: key);

  @override
  State<MilliemeToolScreen> createState() => _MilliemeToolScreenState();
}

enum _EditingField { front, millieme, distance }

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

class _MilliemeToolScreenState extends State<MilliemeToolScreen> {
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _milliemeController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();

  _EditingField? _editingField;
  bool _isUpdating = false;
  String? _selectedPresetId;
  bool _presetsExpanded = false;

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

    _isUpdating = true;
    setState(() {
      _frontController.text = newFront == null ? '' : _formatNumber(newFront!);
      _milliemeController.text = newMil == null ? '' : _formatNumber(newMil!);
      _distanceController.text = newDist == null ? '' : _formatNumber(newDist!);
    });
    _isUpdating = false;
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

  void _onFieldChanged(_EditingField field) {
    if (_isUpdating) return;

    // Ne plus recalculer automatiquement : on ne fait que
    // mémoriser le champ en cours d'édition pour l'UI.
    setState(() {
      _editingField = field;
    });
  }

  void _applyPreset(_MilliemePreset preset) {
    setState(() {
      _selectedPresetId = preset.id;
      _frontController.text = _formatNumber(preset.valueMeters);
    });
  }

  void _resetAll() {
    setState(() {
      _frontController.clear();
      _milliemeController.clear();
      _distanceController.clear();
      _selectedPresetId = null;
      _editingField = null;
    });
  }

  void _resetField(_EditingField field) {
    setState(() {
      switch (field) {
        case _EditingField.front:
          _frontController.clear();
          _selectedPresetId = null;
          break;
        case _EditingField.millieme:
          _milliemeController.clear();
          break;
        case _EditingField.distance:
          _distanceController.clear();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final provider = Provider.of<ThotProvider>(context, listen: true);
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;

    final presets = _presets(context);

    final content = Column(
      children: [
        if (!widget.embedded) ...[
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(AppSpacing.md),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  strings.milliemeToolTitle,
                  style: textStyles.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ),
              // Icône en forme de V pour fermer
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
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              strings.milliemeToolSubtitle,
              style: textStyles.bodySmall?.copyWith(
                color: colors.secondary,
              ),
            ),
          ),
        ),
        if (!provider.useMetric)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg).copyWith(top: AppSpacing.xs),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Divider(color: colors.outline),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: AppSpacing.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.milliemeFrontLabel,
                  style: textStyles.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.secondary,
                  ),
                ),
                const Gap(AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _frontController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: false,
                        ),
                        decoration: InputDecoration(
                          hintText: strings.milliemeFrontField,
                          suffixText: 'm',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(AppSpacing.sm),
                // En-tête déployable / repliable pour les presets
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
                          color: colors.secondary,
                        ),
                      ),
                      Icon(
                        _presetsExpanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        color: colors.secondary,
                      ),
                    ],
                  ),
                ),
                const Gap(AppSpacing.xs),
                if (_presetsExpanded)
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final preset in presets)
                        SizedBox(
                          width: (MediaQuery.of(context).size.width -
                                  (AppSpacing.lg * 2) -
                                  18) /
                              4,
                          child: _MilliemePresetButton(
                            preset: preset,
                            selected: preset.id == _selectedPresetId,
                            onTap: () => _applyPreset(preset),
                          ),
                        ),
                    ],
                  ),
                const Gap(AppSpacing.lg),
                Text(
                  strings.milliemeMilliemeLabel,
                  style: textStyles.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.secondary,
                  ),
                ),
                const Gap(AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _milliemeController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: false,
                        ),
                        decoration: InputDecoration(
                          hintText: strings.milliemeMilliemeField,
                          suffixText: 'mil',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(AppSpacing.lg),
                Text(
                  strings.milliemeDistanceLabel,
                  style: textStyles.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.secondary,
                  ),
                ),
                const Gap(AppSpacing.xs),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _distanceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: false,
                        ),
                        decoration: InputDecoration(
                          hintText: strings.milliemeDistanceField,
                          suffixText: 'm',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(AppSpacing.lg),
                Text(
                  strings.milliemeHelpFormula,
                  style: textStyles.bodySmall?.copyWith(
                    color: colors.secondary,
                  ),
                ),
                const Gap(AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: _resetAll,
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              colors.secondary.withValues(alpha: 0.85),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                        ),
                        child: Text(strings.milliemeResetAll),
                      ),
                    ),
                    const Gap(AppSpacing.sm),
                    Expanded(
                      child: FilledButton(
                        onPressed: _calculate,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                        ),
                        child: Text(strings.milliemeCalculate),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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
    final background = selected
        ? colors.primary.withValues(alpha: 0.06)
        : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 64,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(AppRadius.sm),
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