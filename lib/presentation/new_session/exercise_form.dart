part of '../new_session_screen.dart';

class _ExerciseForm extends StatefulWidget {
  final Exercise? exercise;
  final Function(Exercise) onSave;
  final ScrollController? scrollController;

  const _ExerciseForm({
    this.exercise,
    required this.onSave,
    this.scrollController,
  });

  @override
  State<_ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends State<_ExerciseForm> {
  final _formKey = GlobalKey<FormState>();
  final _exerciseNameController = TextEditingController();
  final _exerciseScrollController = ScrollController();
  final _nameFieldKey = GlobalKey();
  final _platformFieldKey = GlobalKey();
  final _ammoFieldKey = GlobalKey();
  final _shotsFieldKey = GlobalKey();
  final _distanceFieldKey = GlobalKey();

  bool _detailedMode = false;
  final List<ExerciseStep> _steps = [];

  bool _nameError = false;
  bool _platformError = false;
  bool _ammoError = false;
  bool _shotsError = false;
  bool _distanceError = false;

  String _platformSource = 'inventory'; // inventory | borrowed
  String _ammoSource = 'inventory'; // inventory | borrowed
  String? _selectedPlatformId;
  String? _selectedAmmoId;
  final _borrowedPlatformController = TextEditingController();
  final _borrowedAmmoController = TextEditingController();
  final Set<String> _selectedEquipmentIds = {};
  final Set<String> _removedLinkedAccessoryIds = {};
  final _targetNameController = TextEditingController();
  final List<ExercisePhoto> _targetPhotos = [];
  final _shotsFiredController = TextEditingController();
  final _distanceController = TextEditingController();
  final _observationsController = TextEditingController();
  bool _measurePrecision = false;
  double _precision = 0;
  bool _precisionEnabled = true;
  bool _defaultsInitialized = false;
  final Map<String, TextEditingController> _photoControllers = {};

  @override
  void initState() {
    super.initState();
    if (widget.exercise != null) {
      _exerciseNameController.text = widget.exercise!.name;

      final platformId = widget.exercise!.platformId;
      if (platformId == 'borrowed' || platformId == 'none') {
        _platformSource = 'borrowed';
        _selectedPlatformId = null;
        _borrowedPlatformController.text = widget.exercise!.platformLabel ?? '';
      } else {
        _platformSource = 'inventory';
        _selectedPlatformId = platformId;
      }

      final ammoId = widget.exercise!.ammoId;
      if (ammoId == 'borrowed' || ammoId == 'none') {
        _ammoSource = 'borrowed';
        _selectedAmmoId = null;
        _borrowedAmmoController.text = widget.exercise!.ammoLabel ?? '';
      } else {
        _ammoSource = 'inventory';
        _selectedAmmoId = ammoId;
      }

      _selectedEquipmentIds
        ..clear()
        ..addAll(widget.exercise!.equipmentIds);

      // Si on est en mode édition avec une plateforme sélectionnée et aucun équipement personnalisé,
      // ajouter automatiquement les accessoires liés
      if (_platformSource == 'inventory' &&
          _selectedPlatformId != null &&
          widget.exercise!.equipmentIds.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final provider = Provider.of<ThotProvider>(context, listen: false);
            _updateEquipmentForPlatform(provider);
          }
        });
      }
      _targetNameController.text = widget.exercise!.targetName ?? '';
      _targetPhotos
        ..clear()
        ..addAll(widget.exercise!.targetPhotos);
      for (var photo in _targetPhotos) {
        _photoControllers[photo.id] = TextEditingController(text: photo.name);
      }
      _shotsFiredController.text = widget.exercise!.shotsFired.toString();
      _distanceController.text = widget.exercise!.distance.toString();
      _observationsController.text = widget.exercise!.observations;
      _measurePrecision = widget.exercise!.precision != null;
      _precision = widget.exercise!.precision ?? 0;
      _precisionEnabled = widget.exercise!.precisionEnabled;

      _detailedMode = widget.exercise!.steps != null;
      _steps
        ..clear()
        ..addAll(widget.exercise!.steps ?? const []);
    } else {
      // Les deux champs démarrent vides
    }
  }

  int _computedTotalShots() {
    return _steps
        .where((s) => s.type == StepType.tir && s.shots != null)
        .fold<int>(0, (sum, s) => sum + (s.shots ?? 0));
  }

  int _computedMaxDistance() {
    final distances = _steps.map((s) => s.distanceM).whereType<int>();
    if (distances.isEmpty) return 0;
    return distances.reduce((a, b) => a > b ? a : b);
  }

  Set<String> _getLinkedAccessoryIds(ThotProvider provider) {
    if (_platformSource != 'inventory' || _selectedPlatformId == null) {
      return const {};
    }
    final platform = provider.getPlatformById(_selectedPlatformId!);
    if (platform == null) return const {};
    return provider
        .linkedAccessoriesForPlatform(platform.id)
        .map((a) => a.id)
        .toSet();
  }

  void _updateEquipmentForPlatform(ThotProvider provider) {
    if (_platformSource != 'inventory' || _selectedPlatformId == null) {
      return;
    }

    final platform = provider.getPlatformById(_selectedPlatformId!);
    if (platform == null) return;

    // Récupérer les accessoires liés à cette plateforme
    final linkedAccessories = provider.linkedAccessoriesForPlatform(
      platform.id,
    );

    // Réinitialiser les suppressions de liaison quand on change de plateforme
    _removedLinkedAccessoryIds.clear();

    // Ajouter les accessoires liés à la sélection existante
    setState(() {
      _selectedEquipmentIds.clear();
      _selectedEquipmentIds.addAll(linkedAccessories.map((a) => a.id));
    });
  }

  List<Platform> _availablePlatformsForStep(ThotProvider provider) {
    if (_platformSource != 'inventory' || _selectedPlatformId == null) {
      return const [];
    }
    final selected = provider.getPlatformById(_selectedPlatformId!);
    if (selected == null) return const [];
    return [selected];
  }

  List<Ammo> _availableAmmosForStep(ThotProvider provider) {
    if (_ammoSource != 'inventory' || _selectedAmmoId == null) {
      return const [];
    }
    final selected = provider.getAmmoById(_selectedAmmoId!);
    if (selected == null) return const [];
    return [selected];
  }

  String _stepTitle(StepType type) {
    return AppStrings.of(context).exerciseStepTypeLabel(type);
  }

  String _positionShort(ShootingPosition? pos) {
    if (pos == null) return '';
    final strings = AppStrings.of(context);
    return strings.exercisePositionLabel(pos);
  }

  String _stepSummary(ExerciseStep s, AppStrings strings, bool useMetric) {
    final parts = <String>[];
    final provider = Provider.of<ThotProvider>(context, listen: false);
    if (s.type == StepType.tir && s.shots != null) {
      parts.add('${s.shots} ${strings.exerciseNarrativeShotsWord}');
      final usedPlatformId = (s.usedPlatformId ?? '').trim();
      if (usedPlatformId.isNotEmpty) {
        final platformName = usedPlatformId.startsWith('custom:')
            ? usedPlatformId.substring('custom:'.length).trim()
            : provider.getPlatformById(usedPlatformId)?.name;
        if (platformName != null && platformName.trim().isNotEmpty) {
          parts.add(platformName);
        }
      }
      final usedAmmoId = (s.usedAmmoId ?? '').trim();
      if (usedAmmoId.isNotEmpty) {
        final ammoName = usedAmmoId.startsWith('custom:')
            ? usedAmmoId.substring('custom:'.length).trim()
            : provider.getAmmoById(usedAmmoId)?.name;
        if (ammoName != null && ammoName.trim().isNotEmpty) {
          parts.add(ammoName);
        }
      }
    }
    if (s.distanceM != null) {
      final dist = useMetric
          ? '${s.distanceM} m'
          : '${(s.distanceM! * 1.09361).round()} yd';
      parts.add(dist);
    }
    if ((s.target ?? '').trim().isNotEmpty) parts.add(s.target!.trim());
    if (s.type == StepType.transition) {
      if ((s.platformFrom ?? '').trim().isNotEmpty) {
        parts.add(
          '${strings.exerciseNarrativeFrom.trim()} ${s.platformFrom!.trim()}',
        );
      }
      if ((s.platformTo ?? '').trim().isNotEmpty) {
        parts.add(
          '${strings.exerciseNarrativeTo.trim()} ${s.platformTo!.trim()}',
        );
      }
    }
    if (s.type == StepType.rechargement && s.reloadType != null) {
      parts.add(strings.exerciseReloadTypeNarrative(s.reloadType!));
    }
    if (s.type == StepType.attente && s.durationSeconds != null) {
      parts.add('${s.durationSeconds}s');
    }
    return parts.isEmpty ? '—' : parts.join(' · ');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_defaultsInitialized) return;
    _defaultsInitialized = true;

    // Ensure we always land in a valid state (no more "none").
    final provider = Provider.of<ThotProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        if (_platformSource == 'inventory') {
          final exists =
              _selectedPlatformId != null &&
              provider.platforms.any((w) => w.id == _selectedPlatformId);
          final allowed = _selectedPlatformId != null
              ? provider.canUsePlatformId(_selectedPlatformId!)
              : true;
          if (!exists || !allowed) {
            _selectedPlatformId = provider.platforms.isNotEmpty
                ? provider.platforms.first.id
                : null;
            if (provider.platforms.isEmpty) _platformSource = 'borrowed';
          }
        }

        if (_ammoSource == 'inventory') {
          final exists =
              _selectedAmmoId != null &&
              provider.ammos.any((a) => a.id == _selectedAmmoId);
          final allowed = _selectedAmmoId != null
              ? provider.canUseAmmoId(_selectedAmmoId!)
              : true;
          if (!exists || !allowed) {
            _selectedAmmoId = provider.ammos.isNotEmpty
                ? provider.ammos.first.id
                : null;
            if (provider.ammos.isEmpty) _ammoSource = 'borrowed';
          }
        }
      });

      // Auto-ajouter les accessoires liés quand la plateforme est pré-sélectionnée
      if (_platformSource == 'inventory' &&
          _selectedPlatformId != null &&
          _selectedEquipmentIds.isEmpty) {
        _updateEquipmentForPlatform(provider);
      }
    });
  }

  Future<void> _editEquipments(ThotProvider provider) async {
    final updated = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EquipmentMultiSelectSheet(
        accessories: provider.accessories,
        initialSelection: _selectedEquipmentIds,
      ),
    );

    if (!mounted || updated == null) return;
    setState(() {
      _selectedEquipmentIds
        ..clear()
        ..addAll(updated);
    });
  }

  @override
  void dispose() {
    _exerciseNameController.dispose();
    _borrowedPlatformController.dispose();
    _borrowedAmmoController.dispose();
    _targetNameController.dispose();
    _shotsFiredController.dispose();
    _distanceController.dispose();
    _observationsController.dispose();
    for (var c in _photoControllers.values) {
      c.dispose();
    }
    _exerciseScrollController.dispose();
    super.dispose();
  }

  Future<void> _pickTargetPhoto() async {
    final picked = await NativePicker.pick(context, mode: PickerMode.photoOnly);
    if (!mounted || picked.isCancelled) return;

    final path = picked.path;
    if (path == null || path.isEmpty) return;

    final id =
        DateTime.now().microsecondsSinceEpoch.toString() +
        (picked.name ?? 'img');
    final photo = ExercisePhoto(
      id: id,
      name: picked.name ?? 'photo',
      path: path,
    );

    _photoControllers[photo.id] = TextEditingController(text: photo.name);

    setState(() {
      _targetPhotos.add(photo);
    });
  }

  void _renameTargetPhoto(String id, String newName) {
    final index = _targetPhotos.indexWhere((p) => p.id == id);
    if (index == -1) return;
    _targetPhotos[index] = _targetPhotos[index].copyWith(name: newName);
  }

  void _removeTargetPhoto(String id) {
    setState(() {
      _targetPhotos.removeWhere((p) => p.id == id);
      _photoControllers[id]?.dispose();
      _photoControllers.remove(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThotProvider>(context);
    final converter = UnitConverter(provider.useMetric);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;

    final needsGlobalPlatform = !_detailedMode ||
        _steps.any(
          (s) =>
              s.type == StepType.tir &&
              (s.shots ?? 0) > 0 &&
              (s.usedPlatformId ?? '').trim().isEmpty,
        );
    final needsGlobalAmmo = !_detailedMode ||
        _steps.any(
          (s) =>
              s.type == StepType.tir &&
              (s.shots ?? 0) > 0 &&
              (s.usedAmmoId ?? '').trim().isEmpty,
        );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        decoration: BoxDecoration(
          color: baseBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      strings.addExerciseTitle.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textStyles.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  // Icône en forme de V pour fermer
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
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

            Expanded(
              child: SingleChildScrollView(
                controller:
                    widget.scrollController ?? _exerciseScrollController,
                padding: EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    const Gap(AppSpacing.lg),

                    Row(
                      children: [
                        Icon(
                          Icons.edit_note_rounded,
                          size: 18,
                          color: colors.primary,
                        ),
                        const Gap(8),
                        Text(
                          '${strings.exerciseNameLabel.toUpperCase()} *',
                          style: textStyles.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.sm),

                    Container(
                      key: _nameFieldKey,
                      child: TextField(
                        controller: _exerciseNameController,
                        textInputAction: TextInputAction.next,
                        onTap: () =>
                            _exerciseNameController.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: _exerciseNameController.text.length,
                            ),
                        onChanged: (_) {
                          if (_nameError && _exerciseNameController.text.trim().isNotEmpty) {
                            setState(() => _nameError = false);
                          }
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'.*')),
                        ],
                        decoration: InputDecoration(
                          hintText: strings.exerciseNameHint,
                          errorText: _nameError ? strings.requiredFieldError : null,
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
                    ),
                    const Gap(AppSpacing.lg),

                    // Platform Section
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/images/tube.svg',
                          width: 18,
                          height: 18,
                          colorFilter: ColorFilter.mode(
                            colors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          '${strings.platformTitle.toUpperCase()}${needsGlobalPlatform ? " *" : ""}',
                          style: textStyles.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.sm),
                    Container(
                      padding: AppSpacing.paddingMd,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: _platformError ? colors.error : colors.outline,
                          width: _platformError ? 1.6 : 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SourceToggleRow(
                            leftLabel: strings.myInventory,
                            rightLabel: strings.borrowed,
                            value: _platformSource,
                            onChanged: (v) => setState(() {
                              _platformSource = v;
                              if (_platformSource == 'borrowed') {
                                _selectedPlatformId = null;
                                // Vider les équipements quand on passe en mode emprunté
                                _selectedEquipmentIds.clear();
                              }
                              if (_platformSource != 'borrowed') {
                                _borrowedPlatformController.text = '';
                              }
                            }),
                          ),
                          const Gap(10),
                          Container(
                            key: _platformFieldKey,
                            child: _platformSource == 'inventory'
                                ? (provider.platforms.isEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.warning_amber_rounded,
                                                size: 18,
                                                color: colors.secondary,
                                              ),
                                              const Gap(8),
                                              Expanded(
                                                child: Text(
                                                  strings.noPlatformInStock,
                                                  style: textStyles.bodySmall
                                                      ?.copyWith(
                                                        color: colors.secondary,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : _SelectedSingleItemField(
                                          leading: _selectedPlatformId == null
                                              ? SvgPicture.asset(
                                                  'assets/images/tube.svg',
                                                  width: 18,
                                                  height: 18,
                                                  colorFilter: ColorFilter.mode(
                                                    colors.primary,
                                                    BlendMode.srcIn,
                                                  ),
                                                )
                                              : Icon(
                                                  Icons
                                                      .radio_button_checked_rounded,
                                                  size: 18,
                                                  color: colors.primary,
                                                ),
                                          titleWhenEmpty: strings
                                              .choosePlatformFromInventory,
                                          titleWhenSet:
                                              (_selectedPlatformId == null
                                                      ? null
                                                      : provider.getPlatformById(
                                                          _selectedPlatformId!,
                                                        ))
                                                  ?.name ??
                                              strings
                                                  .choosePlatformFromInventory,
                                          subtitle:
                                              (_selectedPlatformId == null
                                                      ? null
                                                      : provider.getPlatformById(
                                                          _selectedPlatformId!,
                                                        )) ==
                                                  null
                                              ? null
                                              : strings.tapToChange,
                                          onTap: () async {
                                            if (provider.platforms.isEmpty) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    strings
                                                        .noPlatformInStockSwitchBorrowed,
                                                  ),
                                                ),
                                              );
                                              return;
                                            }
                                            final selected = await showModalBottomSheet<String>(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              builder: (context) =>
                                                  _SingleSelectSheet<Platform>(
                                                    title: strings.platformsTab,
                                                    items: provider.platforms,
                                                    initialId:
                                                        _selectedPlatformId,
                                                    isLockedItem: (w) {
                                                      final idx = provider
                                                          .platforms
                                                          .indexOf(w);
                                                      return idx >= 0
                                                          ? provider
                                                                .isPlatformLockedForFree(
                                                                  w,
                                                                  idx,
                                                                )
                                                          : false;
                                                    },
                                                    iconBuilder:
                                                        (
                                                          selected,
                                                          colors,
                                                        ) => SvgPicture.asset(
                                                          'assets/images/tube.svg',
                                                          width: 20,
                                                          height: 20,
                                                          colorFilter:
                                                              ColorFilter.mode(
                                                                selected
                                                                    ? colors
                                                                          .primary
                                                                    : colors
                                                                          .outline,
                                                                BlendMode.srcIn,
                                                              ),
                                                        ),
                                                    primaryText: (w) => w.name,
                                                    secondaryText: (w) => [
                                                      strings
                                                          .itemPlatformTypeLabel(
                                                            w.type,
                                                          ),
                                                      if (w.model
                                                          .trim()
                                                          .isNotEmpty)
                                                        w.model,
                                                      if (w.caliber
                                                          .trim()
                                                          .isNotEmpty)
                                                        w.caliber,
                                                    ].join(' • '),
                                                    matchesQuery: (w, q) {
                                                      final qq = q
                                                          .toLowerCase();
                                                      return w.name
                                                              .toLowerCase()
                                                              .contains(qq) ||
                                                          w.type
                                                              .toLowerCase()
                                                              .contains(qq) ||
                                                          w.model
                                                              .toLowerCase()
                                                              .contains(qq) ||
                                                          w.caliber
                                                              .toLowerCase()
                                                              .contains(qq) ||
                                                          w.serialNumber
                                                              .toLowerCase()
                                                              .contains(qq);
                                                    },
                                                    getId: (w) => w.id,
                                                  ),
                                            );
                                            if (!mounted || selected == null)
                                              return;
                                            setState(() {
                                              _selectedPlatformId = selected;
                                              _platformError = false;
                                            });
                                            // Auto-ajouter les accessoires liés à la plateforme
                                            _updateEquipmentForPlatform(
                                              provider,
                                            );
                                          },
                                        ))
                                : TextField(
                                    controller: _borrowedPlatformController,
                                    textInputAction: TextInputAction.next,
                                    onTap: () =>
                                        _borrowedPlatformController.selection =
                                            TextSelection(
                                              baseOffset: 0,
                                              extentOffset:
                                                  _borrowedPlatformController
                                                      .text
                                                      .length,
                                            ),
                                    decoration: InputDecoration(
                                      labelText:
                                          strings.borrowedPlatformOptional,
                                      hintText: strings.borrowedPlatformHint,
                                      hintStyle: textStyles.bodyMedium
                                          ?.copyWith(
                                            color: colors.onSurface.withAlpha(
                                              100,
                                            ),
                                          ),
                                      prefixIcon: const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Icon(
                                          Icons.radio_button_checked_rounded,
                                          size: 18,
                                        ),
                                      ),
                                      prefixIconConstraints:
                                          const BoxConstraints(
                                            minWidth: 44,
                                            minHeight: 44,
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
                        ],
                      ),
                    ),
                    const Gap(AppSpacing.lg),

                    // Équipement utilisé
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_rounded,
                          size: 18,
                          color: colors.primary,
                        ),
                        const Gap(8),
                        Text(
                          strings.usedEquipmentLabel.toUpperCase(),
                          style: textStyles.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.sm),
                    Container(
                      padding: AppSpacing.paddingMd,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SelectedEquipmentField(
                            accessories: provider.accessories,
                            selectedIds: _selectedEquipmentIds,
                            linkedIds: _getLinkedAccessoryIds(
                              provider,
                            ).difference(_removedLinkedAccessoryIds),
                            onTap: () => _editEquipments(provider),
                            onRemove: (id) => setState(
                              () => _selectedEquipmentIds.remove(id),
                            ),
                            onUnlinkForSession: (id) async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(strings.confirmDeleteTitle),
                                  content: Text(
                                    strings.unlinkAccessoryForSessionMessage,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(false),
                                      child: Text(strings.actionCancel),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.of(ctx).pop(true),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: colors.error,
                                      ),
                                      child: Text(strings.actionDelete),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed != true || !mounted) return;
                              setState(() {
                                _removedLinkedAccessoryIds.add(id);
                                _selectedEquipmentIds.remove(id);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    if (_platformError) ...[
                      const Gap(6),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          strings.requiredFieldError,
                          style: textStyles.bodySmall?.copyWith(
                            color: colors.error,
                          ),
                        ),
                      ),
                    ],
                    const Gap(AppSpacing.lg),

                    // Consommable Section
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
                          '${strings.ammoTitle.toUpperCase()}${needsGlobalAmmo ? " *" : ""}',
                          style: textStyles.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.sm),
                    Container(
                      padding: AppSpacing.paddingMd,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: _ammoError ? colors.error : colors.outline,
                          width: _ammoError ? 1.6 : 1.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SourceToggleRow(
                            leftLabel: strings.myInventory,
                            rightLabel: strings.borrowed,
                            value: _ammoSource,
                            onChanged: (v) => setState(() {
                              _ammoSource = v;
                              if (_ammoSource == 'borrowed')
                                _selectedAmmoId = null;
                              if (_ammoSource != 'borrowed')
                                _borrowedAmmoController.text = '';
                            }),
                          ),
                          const Gap(10),
                          Container(
                            key: _ammoFieldKey,
                            child: _ammoSource == 'inventory'
                                ? (provider.ammos.isEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.all(12),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.warning_amber_rounded,
                                                size: 18,
                                                color: colors.secondary,
                                              ),
                                              const Gap(8),
                                              Expanded(
                                                child: Text(
                                                  strings.noAmmoInStock,
                                                  style: textStyles.bodySmall
                                                      ?.copyWith(
                                                        color: colors.secondary,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : _SelectedSingleItemField(
                                          leading: Icon(
                                            Icons.radio_button_checked_rounded,
                                            size: 18,
                                            color: colors.primary,
                                          ),
                                          titleWhenEmpty:
                                              strings.chooseAmmoFromInventory,
                                          titleWhenSet:
                                              (_selectedAmmoId == null
                                                      ? null
                                                      : provider.getAmmoById(
                                                          _selectedAmmoId!,
                                                        ))
                                                  ?.name ??
                                              strings.chooseAmmoFromInventory,
                                          subtitle:
                                              (_selectedAmmoId == null
                                                      ? null
                                                      : provider.getAmmoById(
                                                          _selectedAmmoId!,
                                                        )) ==
                                                  null
                                              ? null
                                              : strings.tapToChange,
                                          onTap: () async {
                                            if (provider.ammos.isEmpty) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    strings
                                                        .noAmmoInStockSwitchBorrowed,
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            final selected =
                                                await showModalBottomSheet<
                                                  String
                                                >(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  builder: (context) =>
                                                      _SingleSelectSheet<Ammo>(
                                                        title: strings.ammosTab,
                                                        items: provider.ammos,
                                                        initialId:
                                                            _selectedAmmoId,
                                                        isLockedItem: (a) {
                                                          final idx = provider
                                                              .ammos
                                                              .indexOf(a);
                                                          return idx >= 0
                                                              ? provider
                                                                    .isAmmoLockedForFree(
                                                                      a,
                                                                      idx,
                                                                    )
                                                              : false;
                                                        },
                                                        icon: Icons
                                                            .trip_origin_rounded,
                                                        primaryText: (a) =>
                                                            a.name,
                                                        secondaryText: (a) => [
                                                          a.caliber,
                                                          if (a.brand
                                                              .trim()
                                                              .isNotEmpty)
                                                            a.brand,
                                                          if (a.projectileType
                                                              .trim()
                                                              .isNotEmpty)
                                                            strings.itemProjectileTypeLabel(
                                                              a.projectileType,
                                                            ),
                                                        ].join(' • '),
                                                        matchesQuery: (a, q) {
                                                          final qq = q
                                                              .toLowerCase();
                                                          return a.name
                                                                  .toLowerCase()
                                                                  .contains(
                                                                    qq,
                                                                  ) ||
                                                              a.caliber
                                                                  .toLowerCase()
                                                                  .contains(
                                                                    qq,
                                                                  ) ||
                                                              a.brand
                                                                  .toLowerCase()
                                                                  .contains(
                                                                    qq,
                                                                  ) ||
                                                              a.projectileType
                                                                  .toLowerCase()
                                                                  .contains(qq);
                                                        },
                                                        getId: (a) => a.id,
                                                      ),
                                                );

                                            if (!mounted || selected == null)
                                              return;
                                            setState(() {
                                              _selectedAmmoId = selected;
                                              _ammoError = false;
                                            });
                                          },
                                        ))
                                : TextField(
                                    controller: _borrowedAmmoController,
                                    textInputAction: TextInputAction.next,
                                    onTap: () =>
                                        _borrowedAmmoController
                                            .selection = TextSelection(
                                          baseOffset: 0,
                                          extentOffset: _borrowedAmmoController
                                              .text
                                              .length,
                                        ),
                                    decoration: InputDecoration(
                                      labelText: strings.borrowedAmmoOptional,
                                      hintText: strings.borrowedAmmoHint,
                                      hintStyle: textStyles.bodyMedium
                                          ?.copyWith(
                                            color: colors.onSurface.withAlpha(
                                              100,
                                            ),
                                          ),
                                      prefixIcon: const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: Icon(
                                          Icons.radio_button_checked_rounded,
                                          size: 18,
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
                          ),
                        ],
                      ),
                    ),
                    if (_ammoError) ...[
                      const Gap(6),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          strings.requiredFieldError,
                          style: textStyles.bodySmall?.copyWith(
                            color: colors.error,
                          ),
                        ),
                      ),
                    ],
                    const Gap(AppSpacing.lg),

                    // DÉROULÉ Section
                    Row(
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 18,
                          color: colors.primary,
                        ),
                        const Gap(8),
                        Text(
                          strings.exerciseModeLabel.toUpperCase(),
                          style: textStyles.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.sm),
                    Container(
                      padding: AppSpacing.paddingMd,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Column(
                        children: [
                          _SlidingSegmentedSelector(
                            selectedIndex: _detailedMode ? 1 : 0,
                            labels: [
                              strings.exerciseModeSimple,
                              strings.exerciseModeDetailed,
                            ],
                            onSelected: (index) {
                              setState(() {
                                _detailedMode = index == 1;
                              });
                            },
                          ),
                          if (!_detailedMode) ...[
                            const Gap(AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/hit.svg',
                                            width: 14,
                                            height: 14,
                                            colorFilter: ColorFilter.mode(
                                              colors.primary,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          const Gap(6),
                                          Text(
                                            '${strings.shotsCountLabel.toUpperCase()} *',
                                            style: textStyles.labelLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w900,
                                                  color: colors.onSurface,
                                                  letterSpacing: 1.1,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const Gap(6),
                                      Container(
                                        key: _shotsFieldKey,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          border: Border.all(
                                            color: _shotsError
                                                ? colors.error
                                                : Colors.transparent,
                                            width: 1.4,
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller: _shotsFiredController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [ThotInputFormatters.integer],
                                          validator: (v) => ThotValidators.positiveInt(v, strings),
                                          style: textStyles.titleMedium,
                                          onTap: () =>
                                              _shotsFiredController.selection =
                                                  TextSelection(
                                                    baseOffset: 0,
                                                    extentOffset:
                                                        _shotsFiredController
                                                            .text
                                                            .length,
                                                  ),
                                          onChanged: (_) {
                                            final shots = int.tryParse(
                                              _shotsFiredController.text.trim(),
                                            );
                                            if (_shotsError &&
                                                shots != null &&
                                                shots > 0) {
                                              setState(
                                                () => _shotsError = false,
                                              );
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText: '0',
                                            hintStyle: textStyles.bodyMedium
                                                ?.copyWith(
                                                  color: colors.onSurface
                                                      .withAlpha(100),
                                                ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 10,
                                                ),
                                            filled: true,
                                            fillColor: Color.alphaBlend(
                                              colors.onSurface.withValues(
                                                alpha: 0.03,
                                              ),
                                              colors.surface,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppRadius.lg,
                                                  ),
                                              borderSide: BorderSide(
                                                color: colors.outline
                                                    .withValues(alpha: 0.3),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppRadius.lg,
                                                  ),
                                              borderSide: BorderSide(
                                                color: colors.outline
                                                    .withValues(alpha: 0.3),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
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
                                const Gap(AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.straighten_rounded,
                                            size: 14,
                                            color: colors.primary,
                                          ),
                                          const Gap(6),
                                          Text(
                                            '${strings.distanceLabel.toUpperCase()} *',
                                            style: textStyles.labelLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w900,
                                                  color: colors.onSurface,
                                                  letterSpacing: 1.1,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const Gap(6),
                                      Container(
                                        key: _distanceFieldKey,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.lg,
                                          ),
                                          border: Border.all(
                                            color: _distanceError
                                                ? colors.error
                                                : Colors.transparent,
                                            width: 1.4,
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller: _distanceController,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [ThotInputFormatters.integer],
                                          validator: (v) => ThotValidators.positiveInt(v, strings),
                                          style: textStyles.titleMedium,
                                          onTap: () =>
                                              _distanceController.selection =
                                                  TextSelection(
                                                    baseOffset: 0,
                                                    extentOffset:
                                                        _distanceController
                                                            .text
                                                            .length,
                                                  ),
                                          onChanged: (_) {
                                            final distance = int.tryParse(
                                              _distanceController.text.trim(),
                                            );
                                            if (_distanceError &&
                                                distance != null &&
                                                distance > 0) {
                                              setState(
                                                () => _distanceError = false,
                                              );
                                            }
                                          },
                                          decoration: InputDecoration(
                                            hintText: '0',
                                            hintStyle: textStyles.bodyMedium
                                                ?.copyWith(
                                                  color: colors.onSurface
                                                      .withAlpha(100),
                                                ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 10,
                                                ),
                                            suffixText: converter.useMetric
                                                ? 'm'
                                                : 'yd',
                                            filled: true,
                                            fillColor: Color.alphaBlend(
                                              colors.onSurface.withValues(
                                                alpha: 0.03,
                                              ),
                                              colors.surface,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppRadius.lg,
                                                  ),
                                              borderSide: BorderSide(
                                                color: colors.outline
                                                    .withValues(alpha: 0.3),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppRadius.lg,
                                                  ),
                                              borderSide: BorderSide(
                                                color: colors.outline
                                                    .withValues(alpha: 0.3),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
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
                            if (_shotsError || _distanceError)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _shotsError
                                      ? strings.shotsFiredError
                                      : strings.distanceError,
                                  style: textStyles.bodySmall?.copyWith(
                                    color: colors.error,
                                  ),
                                ),
                              ),
                          ] else ...[
                            const Gap(AppSpacing.md),
                            // Badge Total
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: Color.alphaBlend(
                                  colors.primary.withValues(alpha: 0.1),
                                  colors.surface,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                                border: Border.all(
                                  color: colors.primary.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.primary,
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: Text(
                                      strings.exerciseAutoBadge,
                                      style: textStyles.labelSmall?.copyWith(
                                        color: colors.onPrimary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const Gap(10),
                                  Expanded(
                                    child: Text(
                                      strings.exerciseAutoTotals(
                                        _computedTotalShots(),
                                        _steps.length,
                                        _computedMaxDistance(),
                                        converter.useMetric ? 'm' : 'yd',
                                      ),
                                      style: textStyles.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Gap(AppSpacing.md),
                            // Header Steps
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  strings.exerciseStepsTitle.toUpperCase(),
                                  style: textStyles.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: colors.onSurface,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final availablePlatforms =
                                        _availablePlatformsForStep(provider);
                                    final availableAmmos =
                                        _availableAmmosForStep(provider);
                                    final step =
                                        await showModalBottomSheet<
                                          ExerciseStep
                                        >(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (_) => _AddExerciseStepSheet(
                                            availablePlatforms:
                                                availablePlatforms,
                                            availableAmmos: availableAmmos,
                                            defaultPlatformId:
                                                _platformSource == 'inventory'
                                                ? _selectedPlatformId
                                                : null,
                                            defaultAmmoId:
                                                _ammoSource == 'inventory'
                                                ? _selectedAmmoId
                                                : null,
                                          ),
                                        );
                                    if (!mounted || step == null) return;
                                    setState(() => _steps.add(step));
                                  },
                                  icon: const Icon(Icons.add_rounded, size: 14),
                                  label: Text(
                                    strings.exerciseAddStep,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.primary,
                                    foregroundColor: colors.onPrimary,
                                    visualDensity: VisualDensity.compact,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.lg,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(AppSpacing.sm),
                            if (_steps.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Color.alphaBlend(
                                    colors.onSurface.withValues(alpha: 0.03),
                                    colors.surface,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.lg,
                                  ),
                                  border: Border.all(color: colors.outline),
                                ),
                                child: Text(
                                  strings.exerciseNoSteps,
                                  style: textStyles.bodyMedium?.copyWith(
                                    color: colors.secondary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            else
                              ReorderableListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                buildDefaultDragHandles: false,
                                itemCount: _steps.length,
                                onReorder: (oldIndex, newIndex) {
                                  setState(() {
                                    if (newIndex > oldIndex) newIndex -= 1;
                                    final item = _steps.removeAt(oldIndex);
                                    _steps.insert(newIndex, item);
                                  });
                                },
                                itemBuilder: (context, i) {
                                  final s = _steps[i];
                                  return Container(
                                    key: ValueKey(s.id),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.fromLTRB(
                                      12,
                                      8,
                                      2,
                                      8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color.alphaBlend(
                                        colors.onSurface.withValues(
                                          alpha: 0.03,
                                        ),
                                        colors.surface,
                                      ),
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
                                      children: [
                                        Text(
                                          (i + 1).toString().padLeft(2, '0'),
                                          style: textStyles.labelLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w900,
                                              ),
                                        ),
                                        const Gap(10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _stepTitle(s.type),
                                                style: textStyles.labelLarge
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 13,
                                                    ),
                                              ),
                                              Text(
                                                '${_positionShort(s.position)}${_positionShort(s.position).isEmpty ? '' : ' · '}${_stepSummary(s, strings, provider.useMetric)}',
                                                style: textStyles.bodySmall
                                                    ?.copyWith(
                                                      color: colors.secondary,
                                                      fontSize: 11,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Gap(2),
                                        ReorderableDragStartListener(
                                          index: i,
                                          child: Icon(
                                            Icons.drag_indicator_rounded,
                                            size: 20,
                                            color: colors.onSurface,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete_rounded,
                                            size: 18,
                                          ),
                                          tooltip: strings.deleteButton,
                                          onPressed: () => setState(
                                            () => _steps.removeAt(i),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          splashRadius: 20,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ],
                      ),
                    ),

                    const Gap(AppSpacing.lg),

                    // Cible utilisée
                    Row(
                      children: [
                        Icon(
                          Icons.adjust_rounded,
                          size: 18,
                          color: colors.primary,
                        ),
                        const Gap(8),
                        Text(
                          strings.usedTargetLabel.toUpperCase(),
                          style: textStyles.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.sm),
                    TextField(
                      controller: _targetNameController,
                      onTap: () =>
                          _targetNameController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _targetNameController.text.length,
                          ),
                      decoration: InputDecoration(
                        hintText: strings.targetNameHint,
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

                    // Photo de la cible
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.photo_camera_rounded,
                              size: 18,
                              color: colors.primary,
                            ),
                            const Gap(8),
                            Text(
                              strings.targetPhotosTitle.toUpperCase(),
                              style: textStyles.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: colors.onSurface,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                        FilledButton.icon(
                          onPressed: _pickTargetPhoto,
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(strings.addButton),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.sm),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: colors.outline),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_targetPhotos.isEmpty) ...[
                              InkWell(
                                onTap: _pickTargetPhoto,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.sm,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_rounded,
                                        color: colors.outline,
                                        size: 40,
                                      ),
                                      const Gap(8),
                                      Text(
                                        strings.targetPhotosHint,
                                        style: textStyles.bodySmall?.copyWith(
                                          color: colors.outline,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else ...[
                              const Gap(8),

                              ..._targetPhotos.map(
                                (photo) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: colors.surface,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.sm,
                                      ),
                                      border: Border.all(color: colors.outline),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller:
                                                    _photoControllers[photo.id],
                                                onChanged: (value) =>
                                                    setState(() {
                                                      _renameTargetPhoto(
                                                        photo.id,
                                                        value,
                                                      );
                                                    }),
                                                decoration: InputDecoration(
                                                  labelText: strings
                                                      .targetPhotoNameLabel,
                                                  isDense: true,
                                                  filled: true,
                                                  fillColor: colors.surface,
                                                  suffixIcon:
                                                      (_photoControllers[photo
                                                                  .id]
                                                              ?.text
                                                              .trim()
                                                              .isNotEmpty ??
                                                          false)
                                                      ? IconButton(
                                                          icon: const Icon(
                                                            Icons.clear_rounded,
                                                            size: 18,
                                                          ),
                                                          splashRadius: 18,
                                                          tooltip:
                                                              strings.clear,
                                                          onPressed: () {
                                                            final c =
                                                                _photoControllers[photo
                                                                    .id];
                                                            if (c == null)
                                                              return;
                                                            c.clear();
                                                            _renameTargetPhoto(
                                                              photo.id,
                                                              '',
                                                            );
                                                            setState(() {});
                                                          },
                                                        )
                                                      : null,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          AppRadius.sm,
                                                        ),
                                                    borderSide: BorderSide(
                                                      color: colors.outline,
                                                    ),
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              AppRadius.sm,
                                                            ),
                                                        borderSide: BorderSide(
                                                          color: colors.outline,
                                                        ),
                                                      ),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              AppRadius.sm,
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
                                            IconButton(
                                              onPressed: () =>
                                                  _removeTargetPhoto(photo.id),
                                              icon: const Icon(
                                                Icons.delete_rounded,
                                              ),
                                              tooltip: strings.removePhoto,
                                              splashColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                            ),
                                          ],
                                        ),
                                        const Gap(8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.sm,
                                          ),
                                          child: AspectRatio(
                                            aspectRatio: 16 / 10,
                                            child: CrossPlatformImage(
                                              filePath: photo.path,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    const Gap(AppSpacing.lg),

                    // Mesurer la précision
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.insights_rounded,
                              size: 18,
                              color: colors.primary,
                            ),
                            const Gap(8),
                            Text(
                              strings.measurePrecisionTitle.toUpperCase(),
                              style: textStyles.labelLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: colors.onSurface,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _measurePrecision,
                          onChanged: (val) =>
                              setState(() => _measurePrecision = val),
                        ),
                      ],
                    ),
                    if (_measurePrecision) ...[
                      const Gap(AppSpacing.sm),
                      Slider(
                        value: _precision,
                        max: 100,
                        divisions: 20,
                        label: '${_precision.toStringAsFixed(0)}%',
                        onChanged: (val) => setState(() => _precision = val),
                      ),
                      Text(
                        strings.precisionValueLabel(
                          '${_precision.toStringAsFixed(0)}%',
                        ),
                        textAlign: TextAlign.center,
                        style: textStyles.titleMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const Gap(AppSpacing.lg),

                    // Observations
                    Row(
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: colors.primary,
                        ),
                        const Gap(8),
                        Text(
                          strings.observationsTitle.toUpperCase(),
                          style: textStyles.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.sm),
                    TextField(
                      controller: _observationsController,
                      maxLines: 3,
                      textAlignVertical: TextAlignVertical.top,
                      onTap: () =>
                          _observationsController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _observationsController.text.length,
                          ),
                      decoration: InputDecoration(
                        hintText: strings.observationsExample,
                        hintStyle: textStyles.bodyMedium?.copyWith(
                          color: colors.onSurface.withAlpha(100),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
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

                    // Save buttons row
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 50,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                                boxShadow: AppShadows.cardPremium,
                              ),
                              child: FilledButton(
                                onPressed: _save,
                                style: FilledButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.lg,
                                    ),
                                  ),
                                ),
                                child: Text(strings.saveExerciseButton),
                              ),
                            ),
                          ),
                        ),
                        const Gap(10),
                        SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: _saveAsTemplate,
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  AppRadius.lg,
                                ),
                              ),
                              side: BorderSide(
                                color: colors.primary,
                                width: 1.6,
                              ),
                            ),
                            child: Icon(
                              Icons.bookmark_add_outlined,
                              size: 22,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(AppSpacing.lg),
                    const Gap(AppSpacing.sm),
                  ],
                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveAsTemplate() {
    final strings = AppStrings.of(context);
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.templateNameDialogTitle),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: strings.templateNameHint,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final shots = _detailedMode
                  ? _computedTotalShots()
                  : (int.tryParse(_shotsFiredController.text.trim()) ?? 0);
              final distance = _detailedMode
                  ? _computedMaxDistance()
                  : (int.tryParse(_distanceController.text.trim()) ?? 0);
              final template = ExerciseTemplate(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                name: name,
                createdAt: DateTime.now(),
                shotsFired: shots,
                distance: distance,
                detailedMode: _detailedMode,
                steps: _detailedMode ? List<ExerciseStep>.from(_steps) : null,
                observations: _observationsController.text.trim(),
              );
              Provider.of<ThotProvider>(
                context,
                listen: false,
              ).saveExerciseTemplate(template);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(strings.templateSavedSnack),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            child: Text(strings.validate),
          ),
        ],
      ),
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final shots = int.tryParse(_shotsFiredController.text.trim());
    final distance = int.tryParse(_distanceController.text.trim());

    final computedShots = _detailedMode ? _computedTotalShots() : (shots ?? 0);
    final computedDistance = _detailedMode
        ? _computedMaxDistance()
        : (distance ?? 0);
    final hasTirStep =
        _detailedMode &&
        _steps.any((s) => s.type == StepType.tir && (s.shots ?? 0) > 0);
    final needsGlobalPlatform =
        !_detailedMode ||
        _steps.any(
          (s) =>
              s.type == StepType.tir &&
              (s.shots ?? 0) > 0 &&
              (s.usedPlatformId ?? '').trim().isEmpty,
        );
    final needsGlobalAmmo =
        !_detailedMode ||
        _steps.any(
          (s) =>
              s.type == StepType.tir &&
              (s.shots ?? 0) > 0 &&
              (s.usedAmmoId ?? '').trim().isEmpty,
        );
    final hasUnattributedTirStep =
        _detailedMode &&
        _steps.any(
          (s) =>
              s.type == StepType.tir &&
              (s.shots ?? 0) > 0 &&
              ((s.usedPlatformId ?? '').trim().isEmpty &&
                      _platformSource == 'inventory' &&
                      _selectedPlatformId == null ||
                  (s.usedAmmoId ?? '').trim().isEmpty &&
                      _ammoSource == 'inventory' &&
                      _selectedAmmoId == null),
        );

    setState(() {
      _nameError = _exerciseNameController.text.trim().isEmpty;
      _platformError =
          needsGlobalPlatform &&
          _platformSource == 'inventory' &&
          _selectedPlatformId == null;
      _ammoError =
          needsGlobalAmmo &&
          _ammoSource == 'inventory' &&
          _selectedAmmoId == null;
      _shotsError = _detailedMode
          ? (hasTirStep && computedShots <= 0)
          : (shots == null || shots <= 0);
      _distanceError = _detailedMode
          ? (_steps.isEmpty || (hasTirStep && computedDistance <= 0))
          : (distance == null || distance <= 0);
    });

    if (_nameError) {
      await Scrollable.ensureVisible(
        _nameFieldKey.currentContext!,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
      return;
    }

    if (_platformError) {
      await Scrollable.ensureVisible(
        _platformFieldKey.currentContext!,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
      return;
    }

    if (_ammoError) {
      await Scrollable.ensureVisible(
        _ammoFieldKey.currentContext!,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
      return;
    }

    if (_shotsError) {
      await Scrollable.ensureVisible(
        _shotsFieldKey.currentContext!,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
      return;
    }

    if (_distanceError) {
      await Scrollable.ensureVisible(
        _distanceFieldKey.currentContext!,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        alignment: 0.15,
      );
      return;
    }

    if (hasUnattributedTirStep) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.of(context).stepPlatformAmmoRequired),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final effectivePlatformId = _platformSource == 'borrowed'
        ? 'borrowed'
        : (_selectedPlatformId ?? 'none');

    final effectiveAmmoId = _ammoSource == 'borrowed'
        ? 'borrowed'
        : (_selectedAmmoId ?? 'none');

    final effectiveSteps = _detailedMode
        ? List<ExerciseStep>.from(_steps)
        : null;
    final provider = Provider.of<ThotProvider>(context, listen: false);

    final effectivePlatformAssignments = <ExercisePlatformAssignment>[];
    final effectiveShotAllocations = <ExerciseShotAllocation>[];

    if (effectivePlatformId != 'borrowed' &&
        effectivePlatformId != 'none' &&
        effectivePlatformId.trim().isNotEmpty) {
      final linkedAccessoryIds = provider
          .linkedAccessoriesForPlatform(effectivePlatformId)
          .map((a) => a.id)
          .toSet();
      final effectiveAccessoryIds = {
        ...linkedAccessoryIds,
        ..._selectedEquipmentIds,
      };
      effectiveAccessoryIds.removeAll(_removedLinkedAccessoryIds);

      effectivePlatformAssignments.add(
        ExercisePlatformAssignment(
          platformId: effectivePlatformId,
          platformLabel: _platformSource == 'borrowed'
              ? _borrowedPlatformController.text.trim()
              : null,
          ammoIds: [
            if (effectiveAmmoId.trim().isNotEmpty &&
                effectiveAmmoId != 'none' &&
                effectiveAmmoId != 'borrowed')
              effectiveAmmoId,
          ],
          accessoryIds: effectiveAccessoryIds.toList(growable: false),
        ),
      );
    }

    if (effectiveSteps != null) {
      for (final step in effectiveSteps) {
        if (step.type != StepType.tir) continue;
        final stepShots = step.shots ?? 0;
        if (stepShots <= 0) continue;
        final usedPlatformId = (step.usedPlatformId ?? effectivePlatformId)
            .trim();
        final usedAmmoId = (step.usedAmmoId ?? effectiveAmmoId).trim();
        if (usedPlatformId.isEmpty ||
            usedPlatformId == 'none' ||
            usedPlatformId == 'borrowed') {
          continue;
        }
        if (usedAmmoId.isEmpty ||
            usedAmmoId == 'none' ||
            usedAmmoId == 'borrowed') {
          continue;
        }
        effectiveShotAllocations.add(
          ExerciseShotAllocation(
            platformId: usedPlatformId,
            ammoId: usedAmmoId,
            shots: stepShots,
          ),
        );
      }
    } else if (computedShots > 0 &&
        effectivePlatformId != 'borrowed' &&
        effectivePlatformId != 'none' &&
        effectiveAmmoId != 'borrowed' &&
        effectiveAmmoId != 'none') {
      effectiveShotAllocations.add(
        ExerciseShotAllocation(
          platformId: effectivePlatformId,
          ammoId: effectiveAmmoId,
          shots: computedShots,
        ),
      );
    }

    final exercise = Exercise(
      id:
          widget.exercise?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: _exerciseNameController.text.trim(),
      platformId: effectivePlatformId,
      platformLabel: effectivePlatformId == 'borrowed'
          ? _borrowedPlatformController.text.trim()
          : null,
      ammoId: effectiveAmmoId,
      ammoLabel: effectiveAmmoId == 'borrowed'
          ? _borrowedAmmoController.text.trim()
          : null,
      equipmentIds: _selectedEquipmentIds
          .where((id) => !_removedLinkedAccessoryIds.contains(id))
          .toList(),
      targetName: _targetNameController.text.isEmpty
          ? null
          : _targetNameController.text,
      targetPhotos: List<ExercisePhoto>.from(_targetPhotos),
      shotsFired: computedShots,
      distance: computedDistance,
      precision: _measurePrecision ? _precision : null,
      precisionEnabled: _measurePrecision ? _precisionEnabled : true,
      observations: _observationsController.text,
      steps: effectiveSteps,
      platformAssignments: effectivePlatformAssignments,
      shotAllocations: effectiveShotAllocations,
    );

    widget.onSave(exercise);
  }
}

