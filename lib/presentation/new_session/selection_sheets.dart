part of '../new_session_screen.dart';

class _SourceToggleRow extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final String value;
  final ValueChanged<String> onChanged;

  const _SourceToggleRow({
    required this.leftLabel,
    required this.rightLabel,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: _SlidingSegmentedSelector(
        selectedIndex: value == 'borrowed' ? 1 : 0,
        labels: [leftLabel, rightLabel],
        onSelected: (index) {
          onChanged(index == 1 ? 'borrowed' : 'inventory');
        },
      ),
    );
  }
}

class _SelectedSingleItemField extends StatelessWidget {
  final IconData? icon;
  final Widget? leading;
  final String titleWhenEmpty;
  final String titleWhenSet;
  final String? subtitle;
  final VoidCallback onTap;

  const _SelectedSingleItemField({
    this.icon,
    this.leading,
    required this.titleWhenEmpty,
    required this.titleWhenSet,
    required this.onTap,
    this.subtitle,
  }) : assert(
         icon != null || leading != null,
         'Provide either icon or leading',
       );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final isEmpty = titleWhenSet == titleWhenEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.outline),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: Center(
                        child:
                            leading ??
                            Icon(icon!, size: 18, color: colors.primary),
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        isEmpty ? titleWhenEmpty : titleWhenSet,
                        style: textStyles.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Gap(8),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colors.outline,
                    ),
                  ],
                ),
                if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                  const Gap(6),
                  Text(
                    subtitle!,
                    style: textStyles.bodySmall?.copyWith(
                      color: colors.secondary,
                    ),
                  ),
                ],
                if (subtitle == null || subtitle!.trim().isEmpty) ...[
                  const Gap(6),
                  Text(
                    strings.tapToChooseFromInventory,
                    style: textStyles.bodySmall?.copyWith(
                      color: colors.outline,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SingleSelectSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String? initialId;
  final IconData? icon;
  final Widget Function(bool selected, ColorScheme colors)? iconBuilder;
  final String Function(T item) primaryText;
  final String Function(T item) secondaryText;
  final bool Function(T item, String query) matchesQuery;
  final String Function(T item) getId;
  final bool Function(T item)? isLockedItem;

  const _SingleSelectSheet({
    required this.title,
    required this.items,
    required this.initialId,
    this.icon,
    this.iconBuilder,
    required this.primaryText,
    required this.secondaryText,
    required this.matchesQuery,
    required this.getId,
    this.isLockedItem,
  }) : assert(
         icon != null || iconBuilder != null,
         'Provide either icon or iconBuilder',
       );

  @override
  State<_SingleSelectSheet<T>> createState() => _SingleSelectSheetState<T>();
}

class _SingleSelectSheetState<T> extends State<_SingleSelectSheet<T>> {
  String _query = '';
  String? _selection;

  @override
  void initState() {
    super.initState();
    _selection = widget.initialId;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;
    final subtleBorderColor = colors.outline.withValues(alpha: 0.45);
    final searchFillColor = Color.alphaBlend(
      colors.outline.withValues(alpha: 0.8),
      baseBackground,
    );

    final filtered = widget.items.where((it) {
      if (_query.trim().isEmpty) return true;
      return widget.matchesQuery(it, _query.trim());
    }).toList();

    final canValidate = _selection != null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: textStyles.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: strings.actionClose,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                style: textStyles.bodyMedium?.copyWith(fontSize: 14),
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: strings.searchSessionsHint,
                  hintStyle: textStyles.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: colors.secondary,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  suffixIcon: _query.trim().isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          tooltip: strings.clear,
                          splashRadius: 18,
                          onPressed: () {
                            setState(() => _query = '');
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
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: subtleBorderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: subtleBorderColor),
                  ),
                ),
              ),
            ),
            Flexible(
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        strings.noResults,
                        style: textStyles.bodyMedium?.copyWith(
                          color: colors.secondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Gap(6),
                      itemBuilder: (context, index) {
                        final it = filtered[index];
                        final id = widget.getId(it);
                        final isLocked = widget.isLockedItem?.call(it) ?? false;

                        final tile = Container(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: colors.outline),
                          ),
                          child: Stack(
                            children: [
                              Opacity(
                                opacity: isLocked ? 0.45 : 1,
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    splashFactory: NoSplash.splashFactory,
                                  ),
                                  child: RadioListTile<String>(
                                    value: id,
                                    groupValue: _selection,
                                    onChanged: isLocked
                                        ? null
                                        : (v) => setState(() => _selection = v),
                                    fillColor: WidgetStateProperty.resolveWith((
                                      states,
                                    ) {
                                      if (states.contains(
                                        WidgetState.selected,
                                      )) {
                                        return colors.primary;
                                      }
                                      return Colors.transparent;
                                    }),
                                    title: Text(
                                      widget.primaryText(it),
                                      style: textStyles.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    subtitle: Text(
                                      widget.secondaryText(it),
                                      style: textStyles.bodySmall?.copyWith(
                                        color: colors.secondary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                  ),
                                ),
                              ),
                              if (isLocked)
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.primary,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: LightColors.surfaceHighlight,
                                        width: 1.35,
                                      ),
                                    ),
                                    child: Text(
                                      AppStrings.of(context).proBadge,
                                      style: textStyles.labelSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: colors.onPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );

                        if (!isLocked) return tile;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => context.push('/pro'),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            child: tile,
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: Transform.translate(
                  offset: const Offset(0, -4),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: canValidate ? AppShadows.cardPremium : null,
                    ),
                    child: FilledButton(
                      onPressed: canValidate
                          ? () => context.pop(_selection)
                          : null,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        disabledBackgroundColor: colors.outline.withValues(
                          alpha: 0.18,
                        ),
                        disabledForegroundColor: colors.outline.withValues(
                          alpha: 0.85,
                        ),
                        overlayColor: Colors.transparent,
                      ),
                      child: Text(strings.validate),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedEquipmentField extends StatelessWidget {
  final List<Accessory> accessories;
  final Set<String> selectedIds;
  final Set<String> linkedIds;
  final VoidCallback onTap;
  final ValueChanged<String> onRemove;
  final ValueChanged<String>? onUnlinkForSession;

  const _SelectedEquipmentField({
    required this.accessories,
    required this.selectedIds,
    this.linkedIds = const {},
    required this.onTap,
    required this.onRemove,
    this.onUnlinkForSession,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    final selected = selectedIds
        .map((id) => accessories.where((a) => a.id == id).firstOrNull)
        .whereType<Accessory>()
        .toList();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.outline),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(splashFactory: NoSplash.splashFactory),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.build_rounded, size: 18, color: colors.primary),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        selected.isEmpty
                            ? strings.noEquipmentSelected
                            : strings.selectedEquipmentCount(selected.length),
                        style: textStyles.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Gap(8),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colors.outline,
                    ),
                  ],
                ),
                if (selected.isNotEmpty) ...[
                  const Gap(10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selected.map((a) {
                      final isLinked = linkedIds.contains(a.id);
                      return InputChip(
                        avatar: isLinked
                            ? Icon(
                                Icons.link_rounded,
                                size: 16,
                                color: colors.primary,
                              )
                            : null,
                        label: Text(a.name, overflow: TextOverflow.ellipsis),
                        onDeleted: () {
                          if (isLinked && onUnlinkForSession != null) {
                            onUnlinkForSession!(a.id);
                          } else {
                            onRemove(a.id);
                          }
                        },
                        deleteIcon: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: colors.onSurface,
                        ),
                        backgroundColor: isLinked
                            ? colors.primary.withValues(alpha: 0.1)
                            : colors.surface,
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: isLinked
                                ? colors.primary.withValues(alpha: 0.4)
                                : colors.outline,
                          ),
                        ),
                        labelStyle: textStyles.labelLarge?.copyWith(
                          color: colors.onSurface,
                        ),
                      );
                    }).toList(),
                  ),
                ] else ...[
                  const Gap(6),
                  Row(
                    children: [
                      if (accessories.isEmpty)
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: colors.secondary,
                        ),
                      if (accessories.isEmpty) const Gap(8),
                      Expanded(
                        child: Text(
                          accessories.isEmpty
                              ? strings.noAccessoryInStock
                              : strings.tapToChooseFromInventory,
                          style: textStyles.bodySmall?.copyWith(
                            color: colors.outline,
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
      ),
    );
  }
}

class _EquipmentMultiSelectSheet extends StatefulWidget {
  final List<Accessory> accessories;
  final Set<String> initialSelection;

  const _EquipmentMultiSelectSheet({
    required this.accessories,
    required this.initialSelection,
  });

  @override
  State<_EquipmentMultiSelectSheet> createState() =>
      _EquipmentMultiSelectSheetState();
}

class _EquipmentMultiSelectSheetState
    extends State<_EquipmentMultiSelectSheet> {
  late Set<String> _selection;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selection = {...widget.initialSelection};
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    final baseBackground = Theme.of(context).scaffoldBackgroundColor;
    final subtleBorderColor = colors.outline.withValues(alpha: 0.45);
    final searchFillColor = Color.alphaBlend(
      colors.outline.withValues(alpha: 0.8),
      baseBackground,
    );

    final filtered = widget.accessories.where((a) {
      if (_query.trim().isEmpty) return true;
      final q = _query.toLowerCase();
      return a.name.toLowerCase().contains(q) ||
          a.type.toLowerCase().contains(q) ||
          a.brand.toLowerCase().contains(q) ||
          a.model.toLowerCase().contains(q);
    }).toList();

    final canValidate = _selection.isNotEmpty;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      strings.equipmentsTitle,
                      style: textStyles.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: strings.actionClose,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                style: textStyles.bodyMedium?.copyWith(fontSize: 14),
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: strings.searchEquipmentHint,
                  hintStyle: textStyles.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: colors.secondary,
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  suffixIcon: _query.trim().isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          tooltip: strings.clear,
                          splashRadius: 18,
                          onPressed: () {
                            setState(() => _query = '');
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
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: subtleBorderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: subtleBorderColor),
                  ),
                ),
              ),
            ),
            Flexible(
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        strings.noEquipmentFound,
                        style: textStyles.bodyMedium?.copyWith(
                          color: colors.secondary,
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Gap(6),
                      itemBuilder: (context, index) {
                        final a = filtered[index];
                        final selected = _selection.contains(a.id);
                        final originalIndex = widget.accessories.indexOf(a);
                        final isLocked = provider.isAccessoryLockedForFree(
                          a,
                          originalIndex,
                        );

                        final tile = Container(
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: colors.outline),
                          ),
                          child: Stack(
                            children: [
                              Opacity(
                                opacity: isLocked ? 0.45 : 1,
                                child: Theme(
                                  data: Theme.of(context).copyWith(
                                    splashFactory: NoSplash.splashFactory,
                                  ),
                                  child: ListTile(
                                    enabled: !isLocked,
                                    leading: Icon(
                                      selected
                                          ? Icons.radio_button_checked_rounded
                                          : Icons
                                                .radio_button_unchecked_rounded,
                                      size: 20,
                                      color: selected
                                          ? colors.primary
                                          : colors.outline,
                                    ),
                                    title: Text(
                                      a.name,
                                      style: textStyles.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    subtitle: Text(
                                      [
                                        strings.itemAccessoryTypeLabel(a.type),
                                        if (a.brand.trim().isNotEmpty) a.brand,
                                        if (a.model.trim().isNotEmpty) a.model,
                                      ].join(' • '),
                                      style: textStyles.bodySmall?.copyWith(
                                        color: colors.secondary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    onTap: isLocked
                                        ? null
                                        : () {
                                            setState(() {
                                              if (selected) {
                                                _selection.remove(a.id);
                                              } else {
                                                _selection.add(a.id);
                                              }
                                            });
                                          },
                                  ),
                                ),
                              ),
                              if (isLocked)
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.primary,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: LightColors.surfaceHighlight,
                                        width: 1.35,
                                      ),
                                    ),
                                    child: Text(
                                      AppStrings.of(context).proBadge,
                                      style: textStyles.labelSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: colors.onPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );

                        if (!isLocked) return tile;

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => context.push('/pro'),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            child: tile,
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: Transform.translate(
                  offset: const Offset(0, -4),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      boxShadow: canValidate ? AppShadows.cardPremium : null,
                    ),
                    child: FilledButton(
                      onPressed: canValidate
                          ? () => context.pop(_selection)
                          : null,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        disabledBackgroundColor: colors.outline.withValues(
                          alpha: 0.18,
                        ),
                        disabledForegroundColor: colors.outline.withValues(
                          alpha: 0.85,
                        ),
                        overlayColor: Colors.transparent,
                      ),
                      child: Text(strings.validate),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNullExt<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

