import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/theme.dart';
import 'package:thot/utils/achievement_definitions.dart';
import 'package:thot/data/thot_provider.dart';
import 'package:gap/gap.dart';

class AchievementToastLayer extends StatefulWidget {
  final Widget child;

  const AchievementToastLayer({Key? key, required this.child}) : super(key: key);

  @override
  State<AchievementToastLayer> createState() => _AchievementToastLayerState();
}

class _AchievementToastLayerState extends State<AchievementToastLayer> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _offsetAnim;
  
  AchievementDefinition? _currentlyShowing;
  bool _isAnimatingOut = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _offsetAnim = Tween<Offset>(begin: const Offset(0, -1.5), end: Offset.zero).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    ));
    _animController.addStatusListener(_onAnimStatus);
  }

  void _onAnimStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && _isAnimatingOut) {
      _isAnimatingOut = false;
      setState(() {
        _currentlyShowing = null;
      });
      // Notifier le provider que l'alerte a été montrée, on passe au suivant
      if (mounted) {
         Provider.of<ThotProvider>(context, listen: false).popAchievement();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // On écoute le provider pour savoir si un trophée est arrivé
    final provider = Provider.of<ThotProvider>(context, listen: true);
    if (_currentlyShowing == null && provider.achievementQueue.isNotEmpty) {
      // Pour éviter de setState en plein build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _currentlyShowing == null && provider.achievementQueue.isNotEmpty) {
          _showToast(provider.achievementQueue.first);
        }
      });
    }
  }

  void _showToast(AchievementDefinition achievement) {
    setState(() {
      _currentlyShowing = achievement;
      _isAnimatingOut = false;
    });
    _animController.forward();
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        _isAnimatingOut = true;
        _animController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Color _tierColor(String tier) {
    switch (tier) {
      case 'gold': return const Color(0xFFC2A14A);
      case 'silver': return const Color(0xFF8C97A8);
      default: return const Color(0xFF8A5A3C);
    }
  }

  Widget _gradientTrophyIcon({required double size, required Color baseColor}) {
    final light = Color.lerp(baseColor, Colors.white, 0.35) ?? baseColor;
    final dark = Color.lerp(baseColor, Colors.black, 0.15) ?? baseColor;

    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            light,
            baseColor,
            dark,
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Icon(Icons.emoji_events_rounded, size: size, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          widget.child,
          if (_currentlyShowing != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: SlideTransition(
                  position: _offsetAnim,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: _tierColor(_currentlyShowing!.tier).withValues(alpha: 0.5), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _tierColor(_currentlyShowing!.tier).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: _gradientTrophyIcon(
                            size: 32,
                            baseColor: _tierColor(_currentlyShowing!.tier),
                          ),
                        ),
                        const Gap(AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                strings.achievementUnlockedToastTitle,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: _tierColor(_currentlyShowing!.tier),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                strings.achievementTitle(_currentlyShowing!.id),
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.onSurface,
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
        ],
      ),
    );
  }
}
