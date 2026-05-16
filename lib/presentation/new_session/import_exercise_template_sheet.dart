part of '../new_session_screen.dart';

class _ImportExerciseTemplateSheet extends StatefulWidget {
  final ThotProvider provider;
  final ValueChanged<ExerciseTemplate> onSelected;

  const _ImportExerciseTemplateSheet({
    required this.provider,
    required this.onSelected,
  });

  @override
  State<_ImportExerciseTemplateSheet> createState() =>
      _ImportExerciseTemplateSheetState();
}

class _ImportExerciseTemplateSheetState
    extends State<_ImportExerciseTemplateSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedSourceIndex = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExerciseTemplate> _filteredTemplates(List<ExerciseTemplate> templates) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return templates;
    return templates
        .where(
          (template) =>
              template.name.toLowerCase().contains(query) ||
              template.observations.toLowerCase().contains(query),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;
    final searchFillColor = Color.alphaBlend(
      colors.outline.withValues(alpha: 0.8),
      baseBackground,
    );
    final standardDrills = _filteredTemplates(StandardDrills.all(strings));
    final userTemplates = _filteredTemplates(widget.provider.exerciseTemplates);
    final visibleTemplates = _selectedSourceIndex == 0
        ? standardDrills
        : userTemplates;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: Container(
            color: baseBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Gap(10),
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
                const Gap(12),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                strings.importTemplateTitle.toUpperCase(),
                                style: textStyles.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.onSurface,
                                ),
                              ),
                            ),
                            const Gap(6),
                            Tooltip(
                              message: strings.createTemplateTooltip,
                              triggerMode: TooltipTriggerMode.tap,
                              showDuration: const Duration(seconds: 5),
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
                                color: colors.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                    ],
                  ),
                ),
                const Gap(AppSpacing.xs),
                Divider(
                  color: colors.outline,
                  indent: AppSpacing.lg,
                  endIndent: AppSpacing.lg,
                ),
                const Gap(AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xs,
                    AppSpacing.lg,
                    10,
                  ),
                  child: SizedBox(
                    height: 44,
                    child: _SlidingSegmentedSelector(
                      selectedIndex: _selectedSourceIndex,
                      labels: [
                        strings.exerciseTemplatesStandardSection,
                        strings.exerciseTemplatesMyTemplatesSection,
                      ],
                      onSelected: (index) {
                        setState(() => _selectedSourceIndex = index);
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
                    style: textStyles.bodyMedium?.copyWith(fontSize: 14),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                    decoration: InputDecoration(
                      hintText: strings.searchEllipsis,
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
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
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
                        borderSide: BorderSide(color: colors.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colors.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: colors.outline),
                      ),
                    ),
                  ),
                ),
                const Gap(AppSpacing.md),
                Expanded(
                  child: visibleTemplates.isEmpty
                      ? Center(
                          child: Padding(
                            padding: AppSpacing.paddingLg,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bookmark_border_rounded,
                                  size: 64,
                                  color: colors.secondary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const Gap(AppSpacing.md),
                                Text(
                                  strings.noTemplatesAvailable,
                                  style: textStyles.bodyMedium?.copyWith(
                                    color: colors.secondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: controller,
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: visibleTemplates.length,
                          itemBuilder: (context, index) {
                            final template = visibleTemplates[index];
                            final subtitle = template.detailedMode
                                ? '${strings.stepsCount(template.steps?.length ?? 0)} · ${template.distance} m'
                                : '${template.shotsFired} coups · ${template.distance} m';
                            final isStandard = _selectedSourceIndex == 0;
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                0,
                                AppSpacing.lg,
                                AppSpacing.md,
                              ),
                              child: Material(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => widget.onSelected(template),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: 8,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          template.name,
                                                          style: textStyles
                                                              .titleSmall
                                                              ?.copyWith(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: colors
                                                                    .onSurface,
                                                              ),
                                                        ),
                                                      ),
                                                      if (isStandard) ...[
                                                        const Gap(6),
                                                        Icon(
                                                          Icons
                                                              .verified_rounded,
                                                          size: 16,
                                                          color: colors.primary,
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                  const Gap(2),
                                                  Text(
                                                    subtitle,
                                                    style: textStyles.bodySmall
                                                        ?.copyWith(
                                                          color:
                                                              colors.secondary,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Gap(AppSpacing.sm),
                                            FilledButton.icon(
                                              onPressed: () =>
                                                  widget.onSelected(template),
                                              icon: const Icon(
                                                Icons.add,
                                                size: 16,
                                              ),
                                              label: Text(
                                                strings.templateImportButton,
                                              ),
                                              style: FilledButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8,
                                                    ),
                                                visualDensity:
                                                    VisualDensity.compact,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (template.observations
                                            .trim()
                                            .isNotEmpty) ...[
                                          const Gap(4),
                                          Text(
                                            '${strings.observationsTitle} : ${template.observations.trim()}',
                                            style: textStyles.bodySmall
                                                ?.copyWith(
                                                  color: colors.secondary,
                                                  fontStyle: FontStyle.italic,
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

