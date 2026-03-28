import 'package:flutter/material.dart';

import 'package:thot/data/exercise_step.dart';
import 'package:thot/theme.dart';
import 'package:gap/gap.dart';
import 'package:thot/l10n/app_strings.dart';

class ExerciseStepsCarousel extends StatefulWidget {
final List<ExerciseStep> steps;
  final bool useMetric;

  const ExerciseStepsCarousel({super.key, required this.steps, required this.useMetric});

  @override
  State<ExerciseStepsCarousel> createState() => _ExerciseStepsCarouselState();
}

class _ExerciseStepsCarouselState extends State<ExerciseStepsCarousel> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    if (widget.steps.isEmpty) return const SizedBox.shrink();

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 220),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: colors.outline),
            ),
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: widget.steps.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) {
                      final step = widget.steps[i];
final config = _StepUiConfig.fromStep(context, step, strings, widget.useMetric);
                      return Padding(
                        padding: AppSpacing.paddingMd,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    config.icon,
                                    style: textStyles.displaySmall?.copyWith(
                                      fontSize: 72,
                                      height: 1,
                                    ),
                                  ),
                                  const Gap(8),
                                  Text(
                                    config.title,
                                    style: textStyles.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: config.color,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (config.subtitle != null) ...[
                                    const Gap(4),
                                    Text(
                                      config.subtitle!,
                                      style: textStyles.bodySmall?.copyWith(
                                        color: colors.secondary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Container(
                              height: 1,
                              color: colors.outline,
                            ),
                            const Gap(10),
                            Builder(
                              builder: (context) {
                                final cells = <Widget>[];

                                if (config.info1Value.trim().isNotEmpty) {
                                  cells.add(_InfoCell(
                                    label: config.info1Label,
                                    value: config.info1Value,
                                  ));
                                }
                                if (config.info2Value.trim().isNotEmpty) {
                                  cells.add(_InfoCell(
                                    label: config.info2Label,
                                    value: config.info2Value,
                                  ));
                                }
                                if (config.info3Value.trim().isNotEmpty) {
                                  cells.add(_InfoCell(
                                    label: config.info3Label,
                                    value: config.info3Value,
                                  ));
                                }

                                if (cells.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: cells,
                                );
                              },
                            ),
                            if ((step.comment ?? '').trim().isNotEmpty) ...[
                              const Gap(10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: LightColors.surfaceHighlight,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                  border: Border.all(
                                    color: colors.outline.withValues(alpha: 0.7),
                                  ),
                                ),
                                child: Text(
                                  '💬 ${step.comment!.trim()}',
                                  style: textStyles.bodySmall?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const Gap(8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.steps.length, (i) {
                    final active = i == _index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 12 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active ? colors.primary : colors.outline,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  }),
                ),
                const Gap(10),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: _ArrowButton(
                enabled: _index > 0,
                icon: Icons.chevron_left_rounded,
                onPressed: () => _controller.previousPage(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _ArrowButton(
                enabled: _index < widget.steps.length - 1,
                icon: Icons.chevron_right_rounded,
                onPressed: () => _controller.nextPage(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final bool enabled;
  final IconData icon;
  final VoidCallback onPressed;

  const _ArrowButton({
    required this.enabled,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return IgnorePointer(
      ignoring: !enabled,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1 : 0,
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          color: colors.onSurface,
          style: IconButton.styleFrom(
            backgroundColor: colors.surface.withValues(alpha: 0.9),
          ),
        ),
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    if (label.trim().isEmpty && value.trim().isEmpty) {
      return const SizedBox(width: 1);
    }

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: textStyles.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: colors.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Gap(2),
          Text(
            label,
            style: textStyles.labelSmall?.copyWith(
              color: colors.secondary,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StepUiConfig {
  final String icon;
  final String title;
  final String? subtitle;
  final Color color;

  final String info1Label;
  final String info1Value;
  final String info2Label;
  final String info2Value;
  final String info3Label;
  final String info3Value;

  const _StepUiConfig({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.info1Label,
    required this.info1Value,
    required this.info2Label,
    required this.info2Value,
    required this.info3Label,
    required this.info3Value,
  });

static _StepUiConfig fromStep(BuildContext context, ExerciseStep step, AppStrings strings, bool useMetric) {    final colors = Theme.of(context).colorScheme;

    final positionText = step.position == null
        ? null
        : strings.exercisePositionLabel(step.position!);

    // Normalize optional text fields once to avoid null-check errors.
    final targetText = (step.target ?? '').trim();
    final weaponFromText = (step.weaponFrom ?? '').trim();
    final weaponToText = (step.weaponTo ?? '').trim();
    final triggerText = (step.trigger ?? '').trim();

    switch (step.type) {
      case StepType.tir:
        return _StepUiConfig(
          icon: '💥',
          title: strings.exerciseStepTypeLabel(StepType.tir),
          subtitle: positionText,
          color: colors.error,
          info1Label: strings.exerciseFieldShots,
          info1Value: step.shots?.toString() ?? '',
          info2Label: strings.exerciseFieldDistance,
          info2Value: step.distanceM == null ? '' : useMetric ? '${step.distanceM} m' : '${(step.distanceM! * 1.09361).round()} yd',
          info3Label: strings.exerciseFieldTarget,
          info3Value: targetText,
        );
case StepType.deplacement:
        return _StepUiConfig(
          icon: '🏃🏻‍♂️‍➡️',
          title: strings.exerciseStepTypeLabel(StepType.deplacement),
          subtitle: step.movementType == null ? null : strings.exerciseMovementTypeLabel(step.movementType!),
          color: colors.primary,
          info1Label: strings.exerciseFieldMovementType,
          info1Value: step.movementType == null ? '' : strings.exerciseMovementTypeLabel(step.movementType!),
          info2Label: strings.exerciseFieldDistance,
          info2Value: step.distanceM == null ? '' : useMetric ? '${step.distanceM} m' : '${(step.distanceM! * 1.09361).round()} yd',
          info3Label: '',
          info3Value: '',
        );
      case StepType.rechargement:
        return _StepUiConfig(
          icon: '🔄',
          title: strings.exerciseStepTypeLabel(StepType.rechargement),
          subtitle: positionText,
          color: LightColors.warning,
          info1Label: strings.exerciseFieldReloadType,
          info1Value: step.reloadType == null
              ? ''
              : strings.exerciseReloadTypeLabel(step.reloadType!),
          info2Label: '',
          info2Value: '',
          info3Label: '',
          info3Value: '',
        );
      case StepType.transition:
        return _StepUiConfig(
          icon: '🔀',
          title: strings.exerciseStepTypeLabel(StepType.transition),
          subtitle: positionText,
          color: LightColors.transitionViolet,
          info1Label: strings.exerciseFieldWeaponFrom,
          info1Value: weaponFromText,
          info2Label: strings.exerciseFieldWeaponTo,
          info2Value: weaponToText,
          info3Label: '',
          info3Value: '',
        );
      case StepType.miseEnJoue:
        return _StepUiConfig(
          icon: '🎯',
          title: strings.exerciseStepTypeLabel(StepType.miseEnJoue),
          subtitle: positionText,
          color: colors.primary,
          info1Label: strings.exerciseFieldTarget,
          info1Value: targetText,
          info2Label: strings.exerciseFieldDistance,
          info2Value: step.distanceM == null ? '' : useMetric ? '${step.distanceM} m' : '${(step.distanceM! * 1.09361).round()} yd',
          info3Label: '',
          info3Value: '',
        );
      case StepType.attente:
        return _StepUiConfig(
          icon: '⏱',
          title: strings.exerciseStepTypeLabel(StepType.attente),
          subtitle: positionText,
          color: LightColors.waitTeal,
          info1Label: strings.exerciseFieldDuration,
          info1Value:
              step.durationSeconds == null ? '' : '${step.durationSeconds} s',
          info2Label: strings.exerciseFieldDistance,
          info2Value: step.distanceM == null ? '' : useMetric ? '${step.distanceM} m' : '${(step.distanceM! * 1.09361).round()} yd',
          info3Label: strings.exerciseFieldTrigger,
          info3Value: triggerText,
        );
      case StepType.securite:
        return _StepUiConfig(
          icon: '🔒',
          title: strings.exerciseStepTypeLabel(StepType.securite),
          subtitle: positionText,
          color: LightColors.securityGold,
          info1Label: '',
          info1Value: '',
          info2Label: '',
          info2Value: '',
          info3Label: '',
          info3Value: '',
        );
      case StepType.autre:
        return _StepUiConfig(
          icon: '⚙️',
          title: strings.exerciseStepTypeLabel(StepType.autre),
          subtitle: positionText,
          color: colors.secondary,
          info1Label: '',
          info1Value: '',
          info2Label: '',
          info2Value: '',
          info3Label: '',
          info3Value: '',
        );
    }
  }
}
