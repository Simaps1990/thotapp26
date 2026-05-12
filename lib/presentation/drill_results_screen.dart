import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:thot/l10n/app_strings.dart';
import 'package:thot/theme.dart';

class DrillResultsScreen extends StatefulWidget {
  const DrillResultsScreen({
    super.key,
    required this.title,
    required this.mode,
    required this.difficulty,
    required this.stats,
  });

  final String title;
  final String mode;
  final String difficulty;
  final Map<String, String> stats;

  @override
  State<DrillResultsScreen> createState() => _DrillResultsScreenState();
}

class _DrillResultsScreenState extends State<DrillResultsScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;

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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade300
                          : LightColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: texts.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                ),
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
              padding: AppSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StatCard(
                    title: widget.mode,
                    rows: [
                      if (widget.difficulty.isNotEmpty)
                        _StatRow(
                          label: strings.reflexesDifficultyLabel,
                          value: widget.difficulty,
                        ),
                      ...widget.stats.entries
                          .where((e) => !e.key.startsWith('_'))
                          .map((e) => _StatRow(label: e.key, value: e.value)),
                    ],
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

class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.rows});

  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;

    return Container(
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
            title,
            style: texts.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.secondary,
            ),
          ),
          const Gap(AppSpacing.md),
          ...rows,
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final texts = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: texts.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            value,
            style: texts.titleMedium?.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
