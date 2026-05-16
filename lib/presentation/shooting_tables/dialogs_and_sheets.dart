part of '../shooting_tables_screen.dart';

extension _ShootingTablesDialogsAndSheets on _ShootingTablesScreenState {
  Future<void> _confirmDeleteTable(
    ThotProvider provider,
    AppStrings strings,
    ShootingAdjustmentTable table,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.confirmDeleteTitle),
        content: Text(
          strings.shootingTableDeleteTableConfirm(_tableDisplayName(table)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(strings.noUpper),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(strings.yesUpper),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      provider.deleteAdjustmentTableById(table.id);
      if (_editingTableId == table.id) {
        _cancelEditor();
      }
    }
  }

  Future<void> _showShareTableDialog(ShootingAdjustmentTable table) async {
    final strings = AppStrings.of(context);
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final exportAccessoryNames = <String>{
      ...provider.accessories
          .where((a) => table.accessoryIds.contains(a.id))
          .map((a) => a.name.trim())
          .where((name) => name.isNotEmpty),
      ...table.customAccessoryNames
          .map((name) => name.trim())
          .where((name) => name.isNotEmpty),
    }.toList(growable: false);
    final exportTable = table.copyWith(
      customPlatformName: table.customPlatformName?.trim().isNotEmpty == true
          ? table.customPlatformName
          : _platformName(provider, table.platformId),
      clearAmmoId: true,
      customAmmoName: table.customAmmoName?.trim().isNotEmpty == true
          ? table.customAmmoName
          : _ammoName(provider, table.ammoId, strings),
      accessoryIds: const [],
      customAccessoryNames: exportAccessoryNames,
      accessoriesCustomized: true,
    );
    final code = ShootingTableShareCodec.encode(exportTable);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;
        final textStyles = Theme.of(dialogContext).textTheme;
        Future<void> copyCode() async {
          try {
            await Clipboard.setData(ClipboardData(text: code));
          } catch (e) {
            debugPrint('Failed to copy to clipboard: $e');
          }
          if (!dialogContext.mounted) return;
          unawaited(
            showDialog<void>(
              context: dialogContext,
              barrierColor: Colors.transparent,
              builder: (toastContext) {
                Future.delayed(const Duration(milliseconds: 850), () {
                  if (toastContext.mounted) {
                    Navigator.of(toastContext).pop();
                  }
                });
                return Center(
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colors.inverseSurface,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        strings.shootingTableShareCopied,
                        style: textStyles.labelMedium?.copyWith(
                          color: colors.onInverseSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        return AlertDialog(
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          actionsPadding: EdgeInsets.zero,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        strings.shootingTableShareTitle.toUpperCase(),
                        style: textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                      tooltip: strings.close,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Divider(
                  height: 1,
                  color: colors.outline.withValues(alpha: 0.55),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 360,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    strings.shootingTableShareSubtitle,
                    style: textStyles.bodyMedium?.copyWith(
                      color: colors.secondary,
                      height: 1.35,
                    ),
                  ),
                  const Gap(AppSpacing.md),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: QrImageView(data: code, size: 220),
                    ),
                  ),
                  const Gap(AppSpacing.lg),
                  Row(
                    children: [
                      Icon(
                        Icons.copy_rounded,
                        size: 16,
                        color: colors.onSurface,
                      ),
                      const Gap(6),
                      Text(
                        strings.shootingTableEncryptedCodeTitle,
                        style: textStyles.labelLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ],
                  ),
                  const Gap(AppSpacing.xs),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: copyCode,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 120),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(
                            alpha: 0.45,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: colors.outline.withValues(alpha: 0.25),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            code,
                            style: textStyles.bodySmall,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Gap(2),
                  Align(
                    child: TextButton.icon(
                      onPressed: copyCode,
                      icon: const Icon(Icons.copy_rounded),
                      label: Text(strings.shootingTableShareCopyCode),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showImportTableCodeDialog(ThotProvider provider) async {
    final strings = AppStrings.of(context);
    final controller = TextEditingController();
    ShootingAdjustmentTable? imported;
    try {
      imported = await showDialog<ShootingAdjustmentTable>(
        context: context,
        builder: (dialogContext) {
          final colors = Theme.of(dialogContext).colorScheme;
          final textStyles = Theme.of(dialogContext).textTheme;
          String? errorText;

          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xl,
                ),
                title: Text(
                  strings.shootingTableImportTitle.toUpperCase(),
                  style: textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                content: SizedBox(
                  width: 520,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              strings.shootingTableImportDescription,
                              style: textStyles.bodyMedium?.copyWith(
                                color: colors.secondary,
                                height: 1.35,
                              ),
                            ),
                          ),
                          const Gap(AppSpacing.md),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  colors.primary.withValues(alpha: 0.1),
                              foregroundColor: colors.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            icon: const Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 20,
                            ),
                            label: Text(strings.shootingTableImportScanQr),
                            onPressed: () async {
                              final code = await Navigator.of(
                                context,
                              ).push<String>(
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          const ShootingTableQrScannerScreen(),
                                ),
                              );
                              if (code != null && code.trim().isNotEmpty) {
                                controller.text = code.trim();
                              }
                            },
                          ),
                        ],
                      ),
                      const Gap(AppSpacing.md),
                      SizedBox(
                        height: 150,
                        child: TextField(
                          controller: controller,
                          expands: true,
                          maxLines: null,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            hintText: strings.shootingTableImportCodeHint,
                            hintStyle: _hintStyle(dialogContext),
                            errorText: errorText,
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
                                width: 1.4,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              borderSide: BorderSide(color: colors.error),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              borderSide: BorderSide(color: colors.error),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Navigator.of(dialogContext).pop();
                    },
                    child: Text(strings.cancel),
                  ),
                  FilledButton(
                    onPressed: () {
                      final code = controller.text.trim();
                      if (code.isEmpty) {
                        setDialogState(() {
                          errorText = strings.shootingTableImportEmptyCode;
                        });
                        return;
                      }

                      try {
                        final decoded = ShootingTableShareCodec.decode(
                          code,
                          importedSuffix: strings.tableImportedSuffix,
                        );
                        FocusManager.instance.primaryFocus?.unfocus();
                        Navigator.of(dialogContext).pop(decoded);
                      } catch (_) {
                        setDialogState(() {
                          errorText = strings.shootingTableImportInvalidCode;
                        });
                      }
                    },
                    child: Text(strings.shootingTableImportAction),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      unawaited(
        Future<void>.delayed(
          const Duration(milliseconds: 350),
          controller.dispose,
        ),
      );
    }
    if (!mounted || imported == null) return;
    provider.importShootingAdjustmentTable(
      _asImportedCustomTable(imported, provider, strings),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(strings.shootingTableImportSuccess)));
  }

  Future<void> _showScanTableQrDialog(ThotProvider provider) async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const ShootingTableQrScannerScreen()),
    );
    if (!mounted || code == null || code.trim().isEmpty) return;
    _importTableCode(provider, code);
  }

  void _importTableCode(ThotProvider provider, String code) {
    final strings = AppStrings.of(context);
    try {
      final imported = _asImportedCustomTable(
        ShootingTableShareCodec.decode(
          code,
          importedSuffix: strings.tableImportedSuffix,
        ),
        provider,
        strings,
      );
      provider.importShootingAdjustmentTable(imported);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.shootingTableImportSuccess)),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.shootingTableImportInvalidCode)),
      );
    }
  }

  Future<void> _pickAccessories(
    ThotProvider provider,
    AppStrings strings,
  ) async {
    if (_editorPlatformId == null) return;
    final selected = Set<String>.from(_editorAccessoryIds);
    final customNames = List<String>.from(_editorCustomAccessoryNames);

    final result = await showModalBottomSheet<_AccessoryPickerResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final colors = Theme.of(sheetContext).colorScheme;
        final textStyles = Theme.of(sheetContext).textTheme;
        final localSelected = Set<String>.from(selected);
        final localCustomNames = List<String>.from(customNames);
        final customController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              top: false,
              child: FractionallySizedBox(
                heightFactor: 0.78,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: LightColors.iconInactive.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const Gap(AppSpacing.md),
                      Padding(
                        padding: AppSpacing.paddingLg,
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/images/tube.svg',
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                colors.primary,
                                BlendMode.srcIn,
                              ),
                            ),
                            const Gap(8),
                            Expanded(
                              child: Text(
                                strings.shootingTableAccessoryPickerTitle
                                    .toUpperCase(),
                                style: textStyles.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.1,
                                  color: colors.onSurface.withValues(
                                    alpha: 0.82,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                              ),
                              tooltip: strings.close,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          children: [
                            if (provider.accessories.isEmpty)
                              Padding(
                                padding: AppSpacing.paddingMd,
                                child: Text(
                                  strings.shootingTableNoAccessory,
                                  style: textStyles.bodyMedium?.copyWith(
                                    color: colors.secondary,
                                  ),
                                ),
                              )
                            else
                              ...provider.accessories.map((accessory) {
                                final isChecked = localSelected.contains(
                                  accessory.id,
                                );
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Material(
                                    color: isChecked
                                        ? colors.primary.withValues(alpha: 0.1)
                                        : colors.surface,
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.md,
                                    ),
                                    child: CheckboxListTile(
                                      value: isChecked,
                                      title: Text(accessory.name),
                                      subtitle: accessory.type.trim().isEmpty
                                          ? null
                                          : Text(accessory.type),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppRadius.md,
                                        ),
                                      ),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      onChanged: (value) {
                                        setModalState(() {
                                          if (value == true) {
                                            localSelected.add(accessory.id);
                                          } else {
                                            localSelected.remove(accessory.id);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                );
                              }),
                            const Gap(AppSpacing.md),
                            TextField(
                              controller: customController,
                              decoration: InputDecoration(
                                labelText:
                                    strings.shootingTableCustomAccessoryHint,
                                hintText: strings.shootingTableAddAccessory,
                                hintStyle: _hintStyle(context),
                                prefixIcon: const Icon(Icons.add_rounded),
                              ),
                              onSubmitted: (value) {
                                final trimmed = value.trim();
                                if (trimmed.isEmpty) return;
                                setModalState(() {
                                  localCustomNames.add(trimmed);
                                  customController.clear();
                                });
                              },
                            ),
                            const Gap(AppSpacing.xs),
                            Text(
                              strings.shootingTableCustomAccessoryHelper,
                              style: textStyles.bodySmall?.copyWith(
                                color: colors.secondary,
                              ),
                            ),
                            if (localCustomNames.isNotEmpty) ...[
                              const Gap(AppSpacing.sm),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: localCustomNames
                                    .map(
                                      (name) => Chip(
                                        side: BorderSide.none,
                                        backgroundColor: colors.primary
                                            .withValues(alpha: 0.12),
                                        label: Text(name),
                                        deleteIcon: const Icon(
                                          Icons.close,
                                          size: 16,
                                        ),
                                        onDeleted: () {
                                          setModalState(() {
                                            localCustomNames.remove(name);
                                          });
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
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
                            const Gap(AppSpacing.sm),
                            Expanded(
                              child: FilledButton(
                                onPressed: () => Navigator.of(context).pop(
                                  _AccessoryPickerResult(
                                    accessoryIds: localSelected,
                                    customAccessoryNames: localCustomNames,
                                  ),
                                ),
                                child: Text(strings.confirm),
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
          },
        );
      },
    );

    if (!mounted || result == null) return;
    setState(() {
      _editorAccessoryIds = result.accessoryIds;
      _editorCustomAccessoryNames = result.customAccessoryNames;
      _editorAccessoriesCustomized = true;
    });
  }

  Future<void> _addOrEditEntry({ShootingAdjustmentEntry? existing}) async {
    if (_editorPlatformId == null) return;
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final defaultDistanceUnit = provider.useMetric
        ? AdjustmentDistanceUnit.meter
        : AdjustmentDistanceUnit.yard;
    final defaultOffsetUnit = provider.useMetric
        ? AdjustmentOffsetUnit.centimeter
        : AdjustmentOffsetUnit.inch;

    final saved = await showModalBottomSheet<ShootingAdjustmentEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AdjustmentEntryFormSheet(
        existing: existing,
        distanceUnit: defaultDistanceUnit,
        offsetUnit: defaultOffsetUnit,
      ),
    );

    if (!mounted || saved == null) return;
    setState(() {
      if (existing == null) {
        _editorEntries = [..._editorEntries, saved]
          ..sort((a, b) => a.distance.compareTo(b.distance));
      } else {
        final index = _editorEntries.indexWhere((e) => e.id == existing.id);
        if (index != -1) {
          final updated = [..._editorEntries];
          updated[index] = saved;
          updated.sort((a, b) => a.distance.compareTo(b.distance));
          _editorEntries = updated;
        }
      }
      _activeDistance = saved.distance;
      _selectedEntryId = saved.id;
      _showAllImpacts = false;
    });
  }

  Future<void> _deleteEntry({
    required AppStrings strings,
    required ShootingAdjustmentEntry entry,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(strings.shootingTableDeleteEntryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _editorEntries = _editorEntries
          .where((e) => e.id != entry.id)
          .toList(growable: false);
      if (_selectedEntryId == entry.id) {
        _selectedEntryId = null;
      }
      _syncDistanceSelectionFromEntries();
    });
  }
}
