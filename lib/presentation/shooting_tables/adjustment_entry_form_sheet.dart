part of '../shooting_tables_screen.dart';

class _AdjustmentEntryFormSheet extends StatefulWidget {
  final ShootingAdjustmentEntry? existing;
  final AdjustmentDistanceUnit distanceUnit;
  final AdjustmentOffsetUnit offsetUnit;

  const _AdjustmentEntryFormSheet({
    required this.existing,
    required this.distanceUnit,
    required this.offsetUnit,
  });

  @override
  State<_AdjustmentEntryFormSheet> createState() =>
      _AdjustmentEntryFormSheetState();
}

class _AdjustmentEntryFormSheetState extends State<_AdjustmentEntryFormSheet> {
  late final TextEditingController _distanceController;
  late final TextEditingController _xController;
  late final TextEditingController _yController;
  late final TextEditingController _leftClicksController;
  late final TextEditingController _rightClicksController;
  late final TextEditingController _upClicksController;
  late final TextEditingController _downClicksController;
  late final TextEditingController _noteController;

  late AdjustmentDistanceUnit _distanceUnit;
  late AdjustmentOffsetUnit _offsetUnit;

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

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;

    _distanceController = TextEditingController(
      text: existing == null
          ? ''
          : _convertDistance(
              existing.distance,
              existing.distanceUnit,
              _defaultDistanceUnit,
            ).toString(),
    );
    _xController = TextEditingController(
      text: existing == null
          ? ''
          : _convertOffset(
              existing.horizontalOffset,
              existing.offsetUnit,
              _defaultOffsetUnit,
            ).toString(),
    );
    _yController = TextEditingController(
      text: existing == null
          ? ''
          : _convertOffset(
              existing.verticalOffset,
              existing.offsetUnit,
              _defaultOffsetUnit,
            ).toString(),
    );
    final parsedCorrections = _parseCorrectionInstructions(
      existing?.correction,
    );
    _leftClicksController = TextEditingController(
      text: (parsedCorrections[_CorrectionDirection.left] ?? 0).toString(),
    );
    _rightClicksController = TextEditingController(
      text: (parsedCorrections[_CorrectionDirection.right] ?? 0).toString(),
    );
    _upClicksController = TextEditingController(
      text: (parsedCorrections[_CorrectionDirection.up] ?? 0).toString(),
    );
    _downClicksController = TextEditingController(
      text: (parsedCorrections[_CorrectionDirection.down] ?? 0).toString(),
    );
    _noteController = TextEditingController(text: existing?.note ?? '');

    _distanceUnit = _defaultDistanceUnit;
    _offsetUnit = _defaultOffsetUnit;
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _xController.dispose();
    _yController.dispose();
    _leftClicksController.dispose();
    _rightClicksController.dispose();
    _upClicksController.dispose();
    _downClicksController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Map<_CorrectionDirection, int> _parseCorrectionInstructions(String? raw) {
    final result = <_CorrectionDirection, int>{
      _CorrectionDirection.left: 0,
      _CorrectionDirection.right: 0,
      _CorrectionDirection.up: 0,
      _CorrectionDirection.down: 0,
    };

    if (raw == null || raw.trim().isEmpty) return result;

    final regex = RegExp(r'(\d+)\s*clics?\s*([←→↑↓])', caseSensitive: false);
    for (final match in regex.allMatches(raw)) {
      final clicks = int.tryParse(match.group(1) ?? '') ?? 0;
      final arrow = match.group(2);
      final direction = switch (arrow) {
        '←' => _CorrectionDirection.left,
        '→' => _CorrectionDirection.right,
        '↑' => _CorrectionDirection.up,
        '↓' => _CorrectionDirection.down,
        _ => null,
      };
      if (direction != null && clicks > 0) {
        result[direction] = clicks;
      }
    }

    return result;
  }

  int _safeClicks(TextEditingController controller) {
    final value = int.tryParse(controller.text.trim()) ?? 0;
    return value < 0 ? 0 : value;
  }

  String _correctionLabel(int clicks, String arrow) {
    final strings = AppStrings.of(context);
    final unit = clicks > 1 ? strings.clicks : strings.click;
    return '$clicks $unit $arrow';
  }

  String _buildCorrectionInstructions() {
    final instructions = <String>[];

    final rightClicks = _safeClicks(_rightClicksController);
    if (rightClicks > 0) {
      instructions.add(_correctionLabel(rightClicks, '→'));
    }

    final leftClicks = _safeClicks(_leftClicksController);
    if (leftClicks > 0) {
      instructions.add(_correctionLabel(leftClicks, '←'));
    }

    final upClicks = _safeClicks(_upClicksController);
    if (upClicks > 0) {
      instructions.add(_correctionLabel(upClicks, '↑'));
    }

    final downClicks = _safeClicks(_downClicksController);
    if (downClicks > 0) {
      instructions.add(_correctionLabel(downClicks, '↓'));
    }

    return instructions.join('\n');
  }

  Widget _buildCorrectionRow({
    required String arrow,
    required TextEditingController controller,
  }) {
    final textStyles = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Opacity(
            opacity: 0.4,
            child: Text(
              arrow,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const Gap(6),
        SizedBox(
          width: 64,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(signed: true),
              textAlign: TextAlign.center,
              style: textStyles.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                hintText: 'ex: 0',
                isDense: true,
                filled: true,
                fillColor: colors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
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
              ),
            ),
          ),
        ),
        const Gap(6),
        Text(
          AppStrings.of(context).clicks,
          style: textStyles.bodySmall?.copyWith(color: colors.secondary),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    return SafeArea(
      top: false,
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: FractionallySizedBox(
          heightFactor: 0.88,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: LightColors.iconInactive.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Gap(AppSpacing.md),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade300
                                : LightColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.black
                                : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const Gap(AppSpacing.sm),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                (widget.existing == null
                                        ? strings.shootingTableAddEntryTitle
                                        : strings.shootingTableEditEntryTitle)
                                    .toUpperCase(),
                                textAlign: TextAlign.center,
                                style: textStyles.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(color: colors.outline),
                  const Gap(AppSpacing.xs),

                  // ── Distance ──────────────────────────────────────────────
                  _SectionHeader(
                    leading: Icon(
                      Icons.place_outlined,
                      color: colors.secondary,
                    ),
                    title: strings.distanceLabel,
                  ),
                  const Gap(AppSpacing.xs),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: TextField(
                      controller: _distanceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        hintText: strings.shootingTableDistanceHint,
                        hintStyle: textStyles.bodyMedium?.copyWith(
                          color: colors.onSurface.withAlpha(100),
                        ),
                        suffixText:
                            _defaultDistanceUnit == AdjustmentDistanceUnit.meter
                            ? strings.shootingTableDistanceUnitMeter
                            : strings.shootingTableDistanceUnitYard,
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
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(AppSpacing.md),

                  // ── Écart ─────────────────────────────────────────────────
                  _SectionHeader(
                    leading: Icon(
                      Icons.gps_fixed_rounded,
                      color: colors.secondary,
                    ),
                    title: strings.shootingTableCorrectionLabel,
                  ),
                  const Gap(AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: TextField(
                            controller: _xController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9,+.\-]'),
                              ),
                            ],
                            decoration: InputDecoration(
                              hintText: strings.shootingTableHorizontalHint,
                              hintStyle: textStyles.bodyMedium?.copyWith(
                                color: colors.onSurface.withAlpha(100),
                              ),
                              suffixText:
                                  _defaultOffsetUnit ==
                                      AdjustmentOffsetUnit.centimeter
                                  ? strings.shootingTableOffsetUnitCm
                                  : strings.shootingTableOffsetUnitInch,
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
                      ),
                      const Gap(AppSpacing.sm),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: TextField(
                            controller: _yController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9,+.\-]'),
                              ),
                            ],
                            decoration: InputDecoration(
                              hintText: strings.shootingTableVerticalHint,
                              hintStyle: textStyles.bodyMedium?.copyWith(
                                color: colors.onSurface.withAlpha(100),
                              ),
                              suffixText:
                                  _defaultOffsetUnit ==
                                      AdjustmentOffsetUnit.centimeter
                                  ? strings.shootingTableOffsetUnitCm
                                  : strings.shootingTableOffsetUnitInch,
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
                      ),
                    ],
                  ),
                  const Gap(AppSpacing.xs),
                  Text(
                    strings.shootingTableAxisHint,
                    style: textStyles.bodySmall?.copyWith(
                      color: colors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(AppSpacing.md),

                  // ── Clics de réglage ──────────────────────────────────────
                  _SectionHeader(
                    leading: Icon(Icons.tune_rounded, color: colors.secondary),
                    title: strings.shootingTableCorrectionLabel,
                  ),
                  const Gap(AppSpacing.xs),
                  Row(
                    children: [
                      _buildCorrectionRow(
                        arrow: '←',
                        controller: _leftClicksController,
                      ),
                      const Gap(AppSpacing.xl),
                      _buildCorrectionRow(
                        arrow: '→',
                        controller: _rightClicksController,
                      ),
                    ],
                  ),
                  const Gap(AppSpacing.xs),
                  Row(
                    children: [
                      _buildCorrectionRow(
                        arrow: '↑',
                        controller: _upClicksController,
                      ),
                      const Gap(AppSpacing.xl),
                      _buildCorrectionRow(
                        arrow: '↓',
                        controller: _downClicksController,
                      ),
                    ],
                  ),
                  const Gap(AppSpacing.md),

                  // ── Notes ─────────────────────────────────────────────────
                  _SectionHeader(
                    leading: Icon(Icons.notes_rounded, color: colors.secondary),
                    title: strings.notes,
                  ),
                  const Gap(AppSpacing.xs),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: TextField(
                      controller: _noteController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: strings.noteOptional,
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
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(AppSpacing.lg),

                  // ── Boutons ───────────────────────────────────────────────
                  SizedBox(
                    height: 52,
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: () => Navigator.of(context).pop(),
                            style: FilledButton.styleFrom(
                              backgroundColor: colors.primary.withValues(
                                alpha: 0.72,
                              ),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              strings.cancel.toUpperCase(),
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
                            onPressed: () {
                              final distance = double.tryParse(
                                _distanceController.text.trim(),
                              );
                              final x = double.tryParse(
                                _xController.text.trim(),
                              );
                              final y = double.tryParse(
                                _yController.text.trim(),
                              );
                              if (distance == null || x == null || y == null)
                                return;
                              final now = DateTime.now();
                              final existing = widget.existing;
                              final entry = ShootingAdjustmentEntry(
                                id:
                                    existing?.id ??
                                    'adj-entry-${now.microsecondsSinceEpoch}',
                                distance: distance,
                                distanceUnit: _distanceUnit,
                                horizontalOffset: x,
                                verticalOffset: y,
                                offsetUnit: _offsetUnit,
                                correction: _buildCorrectionInstructions(),
                                note: _noteController.text.trim(),
                                createdAt: existing?.createdAt ?? now,
                                updatedAt: now,
                              );
                              Navigator.of(context).pop(entry);
                            },
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(strings.confirm.toUpperCase()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

