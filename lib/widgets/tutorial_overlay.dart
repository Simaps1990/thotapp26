import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:gap/gap.dart';
import '../theme.dart';
import '../l10n/app_strings.dart';

class TutorialStep {
  final GlobalKey targetKey;
  final String title;
  final String description;
  final Alignment? tooltipAlignment;

  const TutorialStep({
    required this.targetKey,
    required this.title,
    required this.description,
    this.tooltipAlignment,
  });
}

class TutorialOverlay extends StatefulWidget {
  final List<TutorialStep> steps;
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;
  final VoidCallback? onNeverShowAgain;
  final ValueChanged<int>? onStepChanged;

  const TutorialOverlay({
    super.key,
    required this.steps,
    this.onComplete,
    this.onSkip,
    this.onNeverShowAgain,
    this.onStepChanged,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late final Ticker _targetFollowTicker;
  Rect? _trackedTargetRect;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _targetFollowTicker = createTicker((_) {
      _syncTrackedTargetRect();
    })..start();
    _controller.forward();
  }

  @override
  void dispose() {
    _targetFollowTicker.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      _controller.reset();
      setState(() {
        _currentStep++;
        _trackedTargetRect = null;
      });
      widget.onStepChanged?.call(_currentStep);
      _scrollToTarget(widget.steps[_currentStep].targetKey, _currentStep);
      _controller.forward();
    } else {
      widget.onComplete?.call();
    }
  }

  void _scrollToTarget(GlobalKey key, int stepIndex) {
    final context = key.currentContext;
    if (context == null) return;

    double alignment = 0.5;
    if (stepIndex == 1) {
      alignment = 0.3;
    }

    Scrollable.ensureVisible(
      context,
      alignment: alignment,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _skip() {
    widget.onSkip?.call();
  }

  void _neverShowAgain() {
    widget.onNeverShowAgain?.call();
  }

  Rect? _resolveTargetRect(GlobalKey key) {
    final renderObject = key.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return null;
    }
    final position = renderObject.localToGlobal(Offset.zero);
    return position & renderObject.size;
  }

  void _syncTrackedTargetRect() {
    if (!mounted || widget.steps.isEmpty) return;
    final nextRect = _resolveTargetRect(widget.steps[_currentStep].targetKey);
    if (nextRect == _trackedTargetRect) return;
    setState(() {
      _trackedTargetRect = nextRect;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = widget.steps[_currentStep];
    final targetRect = _trackedTargetRect ??
        _resolveTargetRect(currentStep.targetKey);
    final progress = (_currentStep + 1) / widget.steps.length;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: _TutorialScrim(
              targetRect: targetRect,
              onTap: _nextStep,
            ),
          ),
          if (targetRect != null)
            _FocusPulse(
              rect: targetRect,
              animation: _controller,
            ),
          Positioned.fill(
            child: _TutorialCard(
              title: currentStep.title,
              description: currentStep.description,
              currentStep: _currentStep + 1,
              totalSteps: widget.steps.length,
              progress: progress,
              onNext: _nextStep,
              onSkip: _skip,
              onNeverShowAgain: _neverShowAgain,
              fadeAnimation: _fadeAnimation,
              scaleAnimation: _scaleAnimation,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onStepChanged?.call(_currentStep);
      _scrollToTarget(widget.steps[_currentStep].targetKey, _currentStep);
    });
  }
}

class _TutorialScrim extends StatelessWidget {
  final Rect? targetRect;
  final VoidCallback onTap;

  const _TutorialScrim({
    required this.targetRect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: CustomPaint(
        painter: _SpotlightPainter(targetRect: targetRect),
        size: Size.infinite,
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect? targetRect;

  _SpotlightPainter({required this.targetRect});

  @override
  void paint(Canvas canvas, Size size) {
    final scrimPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.72)
      ..style = PaintingStyle.fill;

    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()..addRect(fullRect);

    if (targetRect != null) {
      final inflated = targetRect!.inflate(10);
      path
        ..addRRect(
          RRect.fromRectAndRadius(inflated, const Radius.circular(16)),
        )
        ..fillType = PathFillType.evenOdd;
    }

    canvas.drawPath(path, scrimPaint);

    if (targetRect != null) {
      final ringRect = targetRect!.inflate(10);
      final glowPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
      canvas.drawRRect(
        RRect.fromRectAndRadius(ringRect, const Radius.circular(16)),
        glowPaint,
      );

      final borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;
      canvas.drawRRect(
        RRect.fromRectAndRadius(ringRect, const Radius.circular(16)),
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect;
  }
}

class _FocusPulse extends StatelessWidget {
  final Rect rect;
  final Animation<double> animation;

  const _FocusPulse({
    required this.rect,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = Curves.easeOut.transform(animation.value);
        final scale = 1.0 + ((1 - t) * 0.04);
        return Positioned(
          left: rect.left - 10,
          top: rect.top - 10,
          width: rect.width + 20,
          height: rect.height + 20,
          child: IgnorePointer(
            child: Transform.scale(
              scale: scale,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.12),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TutorialCard extends StatelessWidget {
  final String title;
  final String description;
  final int currentStep;
  final int totalSteps;
  final double progress;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final VoidCallback onNeverShowAgain;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;

  const _TutorialCard({
    required this.title,
    required this.description,
    required this.currentStep,
    required this.totalSteps,
    required this.progress,
    required this.onNext,
    required this.onSkip,
    required this.onNeverShowAgain,
    required this.fadeAnimation,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          22,
        ),
        child: FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? colors.surface.withValues(alpha: 0.96)
                    : colors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark
                      ? colors.outline.withValues(alpha: 0.30)
                      : LightColors.surfaceHighlight,
                  width: 1.35,
                ),
                boxShadow: AppShadows.cardPremium,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lightbulb_outline_rounded,
                              size: 14,
                              color: colors.primary,
                            ),
                            const Gap(AppSpacing.xs),
                            Text(
                              '$currentStep/$totalSteps',
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: onSkip,
                        icon: Icon(Icons.close_rounded, size: 20, color: colors.onSurface.withValues(alpha: 0.65)),
                      ),
                    ],
                  ),
                  const Gap(AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: colors.outline.withValues(alpha: 0.22),
                      valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                    ),
                  ),
                  const Gap(AppSpacing.sm),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colors.onSurface,
                        ),
                  ),
                  const Gap(AppSpacing.xs),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.82),
                          height: 1.45,
                        ),
                  ),
                  const Gap(AppSpacing.md),
                  Row(
                    children: [
                      TextButton(
                        onPressed: onNeverShowAgain,
                        style: TextButton.styleFrom(
                          foregroundColor:
                              colors.onSurface.withValues(alpha: 0.65),
                        ),
                        child: Text(
                          strings.tutorialNeverShowAgain,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const Spacer(),
                      FilledButton(
                        onPressed: onNext,
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                        ),
                        child: Text(
                          currentStep == totalSteps
                              ? strings.tutorialFinish
                              : strings.tutorialNext,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
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
