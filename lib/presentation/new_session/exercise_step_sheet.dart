part of '../new_session_screen.dart';

class _AddExerciseStepSheet extends StatefulWidget {
  final ExerciseStep? initialStep;
  final List<Platform> availablePlatforms;
  final List<Ammo> availableAmmos;
  final String? defaultPlatformId;
  final String? defaultAmmoId;

  const _AddExerciseStepSheet({
    // ignore: unused_element_parameter
    this.initialStep,
    this.availablePlatforms = const [],
    this.availableAmmos = const [],
    this.defaultPlatformId,
    this.defaultAmmoId,
  });

  @override
  State<_AddExerciseStepSheet> createState() => _AddExerciseStepSheetState();
}

class _AddExerciseStepSheetState extends State<_AddExerciseStepSheet> {
  static const String _noneValue = '__none__';
  static const String _customValue = '__custom__';
  static const String _customPrefix = 'custom:';

  StepType _type = StepType.tir;
  ShootingPosition? _position;

  final _distanceController = TextEditingController();
  final _shotsController = TextEditingController();
  final _targetController = TextEditingController();
  final _platformFromController = TextEditingController();
  final _platformToController = TextEditingController();
  final _customPlatformController = TextEditingController();
  final _customAmmoController = TextEditingController();
  String? _usedPlatformId;
  String? _usedAmmoId;
  ReloadType? _reloadType;
  final _durationController = TextEditingController();
  final _triggerController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialStep;
    if (initial == null) {
      _usedPlatformId = widget.defaultPlatformId;
      _usedAmmoId = widget.defaultAmmoId;
      return;
    }

    _type = initial.type;
    _position = initial.position;
    _reloadType = initial.reloadType;

    _distanceController.text = initial.distanceM?.toString() ?? '';
    _shotsController.text = initial.shots?.toString() ?? '';
    _targetController.text = initial.target ?? '';
    _platformFromController.text = initial.platformFrom ?? '';
    _platformToController.text = initial.platformTo ?? '';
    final initialPlatform = initial.usedPlatformId;
    if (initialPlatform != null && initialPlatform.startsWith(_customPrefix)) {
      _usedPlatformId = _customValue;
      _customPlatformController.text = initialPlatform
          .substring(_customPrefix.length)
          .trim();
    } else {
      _usedPlatformId = initialPlatform ?? widget.defaultPlatformId;
    }
    final initialAmmo = initial.usedAmmoId;
    if (initialAmmo != null && initialAmmo.startsWith(_customPrefix)) {
      _usedAmmoId = _customValue;
      _customAmmoController.text = initialAmmo
          .substring(_customPrefix.length)
          .trim();
    } else {
      _usedAmmoId = initialAmmo ?? widget.defaultAmmoId;
    }
    _durationController.text = initial.durationSeconds?.toString() ?? '';
    _triggerController.text = initial.trigger ?? '';
    _commentController.text = initial.comment ?? '';
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _shotsController.dispose();
    _targetController.dispose();
    _platformFromController.dispose();
    _platformToController.dispose();
    _customPlatformController.dispose();
    _customAmmoController.dispose();
    _durationController.dispose();
    _triggerController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final distUnit = provider.useMetric ? 'm' : 'yd';
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;
    final availablePlatformIds = widget.availablePlatforms
        .map((w) => w.id)
        .toSet();
    final availableAmmoIds = widget.availableAmmos.map((a) => a.id).toSet();
    final selectedPlatformValue = _usedPlatformId == _customValue
        ? _customValue
        : availablePlatformIds.contains(_usedPlatformId)
        ? _usedPlatformId
        : _noneValue;
    final selectedAmmoValue = _usedAmmoId == _customValue
        ? _customValue
        : availableAmmoIds.contains(_usedAmmoId)
        ? _usedAmmoId
        : _noneValue;

    InputDecoration decoration(String label) => InputDecoration(
      labelText: label,
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
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: MediaQuery.of(context).size.height * 0.86,
      decoration: BoxDecoration(
        color: baseBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const Gap(10),
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: colors.outline.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const Gap(12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.initialStep == null
                        ? strings.exerciseNewStepTitle
                        : strings.exerciseEditStepTitle,
                    style: textStyles.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  tooltip: strings.close,
                ),
              ],
            ),
          ),
          const Gap(8),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    strings.exerciseStepTypeTitle,
                    style: textStyles.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: StepType.values.map((t) {
                      final selected = _type == t;
                      return ChoiceChip(
                        label: Text(strings.exerciseStepTypeLabel(t)),
                        selected: selected,
                        onSelected: (_) => setState(() => _type = t),
                        selectedColor: colors.primary.withValues(alpha: 0.2),
                        backgroundColor: colors.surface,
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: selected ? colors.primary : colors.outline,
                          ),
                        ),
                        labelStyle: textStyles.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }).toList(),
                  ),
                  const Gap(AppSpacing.md),
                  Text(
                    strings.exerciseStepPositionTitle,
                    style: textStyles.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('·'),
                        selected: _position == null,
                        onSelected: (_) => setState(() => _position = null),
                        selectedColor: colors.primary.withValues(alpha: 0.2),
                        backgroundColor: colors.surface,
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: _position == null
                                ? colors.primary
                                : colors.outline,
                          ),
                        ),
                      ),
                      ...ShootingPosition.values.map((p) {
                        final selected = _position == p;
                        return ChoiceChip(
                          label: Text(strings.exercisePositionLabel(p)),
                          selected: selected,
                          onSelected: (_) => setState(() => _position = p),
                          selectedColor: colors.primary.withValues(alpha: 0.2),
                          backgroundColor: colors.surface,
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: selected ? colors.primary : colors.outline,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const Gap(AppSpacing.md),

                  if (_type == StepType.tir) ...[
                    DropdownButtonFormField<String>(
                      initialValue: selectedPlatformValue,
                      decoration: decoration(strings.stepUsedPlatformLabel),
                      items: [
                        DropdownMenuItem<String>(
                          value: _noneValue,
                          child: Text(
                            '${strings.stepUsedPlatformLabel}${strings.exerciseOptionalHint}',
                          ),
                        ),
                        ...widget.availablePlatforms.map(
                          (w) => DropdownMenuItem<String>(
                            value: w.id,
                            child: Text(w.name),
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: _customValue,
                          child: Text(
                            strings.exercisePositionLabel(
                              ShootingPosition.autre,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() {
                        _usedPlatformId = v == _noneValue ? null : v;
                      }),
                    ),
                    if (_usedPlatformId == _customValue) ...[
                      const Gap(10),
                      TextField(
                        controller: _customPlatformController,
                        decoration: decoration(
                          '${strings.stepUsedPlatformLabel}${strings.exerciseOptionalHint}',
                        ),
                      ),
                    ],
                    const Gap(10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedAmmoValue,
                      decoration: decoration(strings.stepUsedAmmoLabel),
                      items: [
                        DropdownMenuItem<String>(
                          value: _noneValue,
                          child: Text(
                            '${strings.stepUsedAmmoLabel}${strings.exerciseOptionalHint}',
                          ),
                        ),
                        ...widget.availableAmmos.map(
                          (a) => DropdownMenuItem<String>(
                            value: a.id,
                            child: Text(a.name),
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: _customValue,
                          child: Text(
                            strings.exercisePositionLabel(
                              ShootingPosition.autre,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() {
                        _usedAmmoId = v == _noneValue ? null : v;
                      }),
                    ),
                    if (_usedAmmoId == _customValue) ...[
                      const Gap(10),
                      TextField(
                        controller: _customAmmoController,
                        decoration: decoration(
                          '${strings.stepUsedAmmoLabel}${strings.exerciseOptionalHint}',
                        ),
                      ),
                    ],
                    const Gap(10),
                    TextField(
                      controller: _shotsController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                        '${strings.exerciseFieldShots}${strings.exerciseOptionalHint}',
                      ),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                        '${strings.exerciseFieldDistance} ($distUnit)${strings.exerciseOptionalHint}',
                      ),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _targetController,
                      decoration: decoration(
                        '${strings.exerciseFieldTarget}${strings.exerciseOptionalHint}',
                      ),
                    ),
                  ] else if (_type == StepType.deplacement) ...[
                    TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                        '${strings.exerciseFieldDistance} ($distUnit)${strings.exerciseOptionalHint}',
                      ),
                    ),
                  ] else if (_type == StepType.rechargement) ...[
                    Text(
                      strings.exerciseFieldReloadType,
                      style: textStyles.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Gap(8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ReloadType.values.map((t) {
                        final selected = _reloadType == t;
                        return ChoiceChip(
                          label: Text(strings.exerciseReloadTypeLabel(t)),
                          selected: selected,
                          onSelected: (_) => setState(() => _reloadType = t),
                          selectedColor: colors.primary.withValues(alpha: 0.2),
                          backgroundColor: colors.surface,
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: selected ? colors.primary : colors.outline,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ] else if (_type == StepType.transition) ...[
                    TextField(
                      controller: _platformFromController,
                      decoration: decoration(
                        '${strings.exerciseFieldPlatformFrom}${strings.exerciseOptionalHint}',
                      ),
                    ),
                    if (_platformFromController.text.isNotEmpty &&
                        widget.defaultPlatformId == null) ...[
                      const SizedBox(height: 4),
                      Text(
                        strings.exercisePlatformSelectionHint,
                        style: textStyles.bodySmall?.copyWith(
                          color: colors.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const Gap(10),
                    TextField(
                      controller: _platformToController,
                      decoration: decoration(
                        '${strings.exerciseFieldPlatformTo}${strings.exerciseOptionalHint}',
                      ),
                    ),
                    if (_platformToController.text.isNotEmpty &&
                        widget.defaultPlatformId == null) ...[
                      const SizedBox(height: 4),
                      Text(
                        strings.exercisePlatformSelectionHint,
                        style: textStyles.bodySmall?.copyWith(
                          color: colors.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ] else if (_type == StepType.miseEnJoue) ...[
                    TextField(
                      controller: _targetController,
                      decoration: decoration(
                        '${strings.exerciseFieldTarget}${strings.exerciseOptionalHint}',
                      ),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                        '${strings.exerciseFieldDistance} ($distUnit)${strings.exerciseOptionalHint}',
                      ),
                    ),
                  ] else if (_type == StepType.attente) ...[
                    TextField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                        '${strings.exerciseFieldDuration} (s)${strings.exerciseOptionalHint}',
                      ),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                        '${strings.exerciseFieldDistance} ($distUnit)${strings.exerciseOptionalHint}',
                      ),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _triggerController,
                      decoration: decoration(
                        '${strings.exerciseFieldTrigger}${strings.exerciseOptionalHint}',
                      ),
                    ),
                  ],

                  const Gap(AppSpacing.md),
                  TextField(
                    controller: _commentController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: decoration(strings.exerciseStepCommentLabel),
                  ),

                  const Gap(AppSpacing.lg),
                  SizedBox(
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: AppShadows.cardPremium,
                      ),
                      child: FilledButton(
                        onPressed: () {
                          final distanceM = int.tryParse(
                            _distanceController.text.trim(),
                          );
                          final shots = int.tryParse(
                            _shotsController.text.trim(),
                          );
                          final durationSeconds = int.tryParse(
                            _durationController.text.trim(),
                          );

                          final customPlatformName = _customPlatformController
                              .text
                              .trim();
                          final customAmmoName = _customAmmoController.text
                              .trim();
                          final effectivePlatformId =
                              _usedPlatformId == _customValue
                              ? (customPlatformName.isEmpty
                                    ? null
                                    : '$_customPrefix$customPlatformName')
                              : (_usedPlatformId ?? '').trim().isEmpty
                              ? null
                              : _usedPlatformId!.trim();
                          final effectiveAmmoId = _usedAmmoId == _customValue
                              ? (customAmmoName.isEmpty
                                    ? null
                                    : '$_customPrefix$customAmmoName')
                              : (_usedAmmoId ?? '').trim().isEmpty
                              ? null
                              : _usedAmmoId!.trim();
                          final step = ExerciseStep(
                            id:
                                widget.initialStep?.id ??
                                DateTime.now().microsecondsSinceEpoch
                                    .toString(),
                            type: _type,
                            position: _position,
                            distanceM: distanceM,
                            shots: shots,
                            target: _targetController.text.trim().isEmpty
                                ? null
                                : _targetController.text.trim(),
                            platformFrom:
                                _platformFromController.text.trim().isEmpty
                                ? null
                                : _platformFromController.text.trim(),
                            platformTo:
                                _platformToController.text.trim().isEmpty
                                ? null
                                : _platformToController.text.trim(),
                            usedPlatformId: effectivePlatformId,
                            usedAmmoId: effectiveAmmoId,
                            reloadType: _reloadType,
                            durationSeconds: durationSeconds,
                            trigger: _triggerController.text.trim().isEmpty
                                ? null
                                : _triggerController.text.trim(),
                            comment: _commentController.text.trim().isEmpty
                                ? null
                                : _commentController.text.trim(),
                          );

                          Navigator.of(context).pop(step);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                        ),
                        child: Text(
                          widget.initialStep == null
                              ? strings.exerciseActionAdd
                              : strings.exerciseActionSave,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

