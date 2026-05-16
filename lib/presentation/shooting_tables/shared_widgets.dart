part of '../shooting_tables_screen.dart';

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
            border: Border.all(color: subtleBorderColor),
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
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (int i = 0; i < labels.length; i++)
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => onSelected(i),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                labels[i],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: textStyles.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: i == selectedIndex
                                      ? colors.onPrimary
                                      : colors.secondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final Widget leading;
  final String title;

  const _SectionHeader({required this.leading, required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    return Row(
      children: [
        IconTheme(
          data: IconThemeData(color: colors.primary, size: 18),
          child: leading,
        ),
        const Gap(AppSpacing.sm),
        Text(
          title.toUpperCase(),
          style: textStyles.titleSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
            color: colors.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _ImpactCross extends StatelessWidget {
  const _ImpactCross();

  @override
  Widget build(BuildContext context) {
    const size = 18.0;
    return const SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ImpactCrossPainter(strokeWidth: 2.4)),
    );
  }
}

class _ImpactCrossPainter extends CustomPainter {
  const _ImpactCrossPainter({required this.strokeWidth});

  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Offset(size.width * 0.22, size.height * 0.22);
    final p2 = Offset(size.width * 0.78, size.height * 0.78);
    final p3 = Offset(size.width * 0.78, size.height * 0.22);
    final p4 = Offset(size.width * 0.22, size.height * 0.78);

    final shadowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 0.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.7)
      ..color = Colors.black.withValues(alpha: 0.24);

    final crossPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFD62828);

    const shadowOffset = Offset(0.6, 0.8);
    canvas.drawLine(p1 + shadowOffset, p2 + shadowOffset, shadowPaint);
    canvas.drawLine(p3 + shadowOffset, p4 + shadowOffset, shadowPaint);

    canvas.drawLine(p1, p2, crossPaint);
    canvas.drawLine(p3, p4, crossPaint);
  }

  @override
  bool shouldRepaint(covariant _ImpactCrossPainter oldDelegate) {
    return oldDelegate.strokeWidth != strokeWidth;
  }
}

