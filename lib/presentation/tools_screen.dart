import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import 'package:thot/data/thot_provider.dart';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/theme.dart';

import 'package:thot/presentation/diagnostic_screen.dart';
import 'package:thot/presentation/ballistic_calc_screen.dart';
import 'package:thot/presentation/reflexes_screen.dart';
import 'package:thot/presentation/shooting_timer_screen.dart';
import 'package:thot/presentation/pro_screen.dart';
import 'package:thot/presentation/shooting_tables_screen.dart';
import 'package:thot/presentation/color_pod_screen.dart';

String _toolsHeroAsset(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? 'assets/images/outilsn.webp' : 'assets/images/outils.webp';
}

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key, this.initialOpenTool, this.initialOpenToken});

  final String? initialOpenTool;
  final String? initialOpenToken;

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  static const double _toolSheetInitialSize = 0.9;
  static const double _toolSheetMinSize = 0.5;
  static const double _toolSheetMaxSize = 0.95;
  bool _hasAutoOpenedTool = false;

  void _handleInitialOpenTool() {
    if (!mounted || _hasAutoOpenedTool) return;
    final provider = Provider.of<ThotProvider>(context, listen: false);
    if (widget.initialOpenTool == 'reflexes') {
      _hasAutoOpenedTool = true;
      _openReflexes(provider);
      return;
    }
    if (provider.consumeOpenReflexesToolRequest()) {
      _hasAutoOpenedTool = true;
      _openReflexes(provider);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInitialOpenTool();
    });
  }

  @override
  void didUpdateWidget(covariant ToolsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialOpenTool != widget.initialOpenTool ||
        oldWidget.initialOpenToken != widget.initialOpenToken) {
      _hasAutoOpenedTool = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleInitialOpenTool();
      });
    }
  }

  void _openToolSheet(Widget child) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: _toolSheetInitialSize,
        minChildSize: _toolSheetMinSize,
        maxChildSize: _toolSheetMaxSize,
        expand: false,
        builder: (_, scrollController) => child,
      ),
    );
  }

  void _showComingSoonSnack() {
    final strings = AppStrings.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.toolComingSoon),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openVisualStimulus(ThotProvider provider) {
    if (!provider.isPremium) {
      showProModal(context);
      return;
    }
    _openToolSheet(const ColorPodScreen());
  }

  void _openAudioStimulus(ThotProvider provider) {
    if (!provider.isPremium) {
      showProModal(context);
      return;
    }
    _showComingSoonSnack();
  }

  void _openReflexes(ThotProvider provider) {
    if (!provider.isPremium) {
      showProModal(context);
      return;
    }
    _openToolSheet(const ReflexesScreen());
  }

  void _openCalculations() {
    _openToolSheet(const BallisticCalcScreen());
  }

  void _openTimer() {
    _openToolSheet(const ShootingTimerScreen());
  }

  void _openShootingTables() {
    _openToolSheet(const ShootingTablesScreen());
  }

  void _openDiagnostic(ThotProvider provider) {
    if (!provider.isPremium) {
      showProModal(context);
      return;
    }
    _openToolSheet(const DiagnosticScreen());
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final provider = Provider.of<ThotProvider>(context);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const heroHeight = 208.0;
    const panelTop = 120.0;

    Widget toolButton({
      required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
      Color? iconColor,
    }) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: AppSpacing.paddingMd,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: isDark
                  ? Border.all(color: colors.outline)
                  : Border.all(
                      color: LightColors.surfaceHighlight,
                      width: 1.35,
                    ),
              boxShadow: AppShadows.cardPremium,
            ),
            child: Row(
              children: [
                Icon(icon, color: iconColor ?? colors.primary, size: 24),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textStyles.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        subtitle,
                        style: textStyles.bodySmall?.copyWith(
                          color: colors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: colors.secondary),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: baseBackground,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              SizedBox(
                height: heroHeight,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      _toolsHeroAsset(context),
                      fit: BoxFit.cover,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.16),
                            Colors.black.withValues(alpha: 0.42),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: AppSpacing.lg,
                top: panelTop - 44,
                child: Text(
                  strings.toolsSubtitle,
                  style: textStyles.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    shadows: const [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(1, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: panelTop),
                decoration: BoxDecoration(
                  color: baseBackground,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      toolButton(
                        icon: Icons.timer_rounded,
                        title: strings.homeTimerTitle,
                        subtitle: strings.homeTimerSubtitle,
                        onTap: _openTimer,
                        iconColor: const Color(0xFF4A90E2),
                      ),
                      const Gap(AppSpacing.md),
                      toolButton(
                        icon: Icons.palette_rounded,
                        title: strings.visualStimulusToolTitle,
                        subtitle: strings.visualStimulusToolSubtitle,
                        onTap: () => _openVisualStimulus(provider),
                        iconColor: const Color(0xFFE91E63),
                      ),
                      // const Gap(AppSpacing.md),
                      // toolButton(
                      //   icon: Icons.graphic_eq_rounded,
                      //   title: strings.audioStimulusToolTitle,
                      //   subtitle: strings.audioStimulusToolSubtitle,
                      //   onTap: () => _openAudioStimulus(provider),
                      // ),
                      const Gap(AppSpacing.md),
                      toolButton(
                        icon: Icons.bolt_rounded,
                        title: strings.reflexesToolTitle,
                        subtitle: strings.reflexesToolSubtitle,
                        onTap: () => _openReflexes(provider),
                        iconColor: const Color(0xFFFF9800),
                      ),
                      const Gap(AppSpacing.md),
                      toolButton(
                        icon: Icons.calculate_rounded,
                        title: strings.calculationsToolTitle,
                        subtitle: strings.calculationsToolSubtitle,
                        onTap: _openCalculations,
                        iconColor: const Color(0xFF9C27B0),
                      ),
                      const Gap(AppSpacing.md),
                      toolButton(
                        icon: Icons.table_chart_outlined,
                        title: strings.shootingTablesToolTitle,
                        subtitle: strings.shootingTablesToolSubtitle,
                        onTap: _openShootingTables,
                        iconColor: const Color(0xFF4CAF50),
                      ),
                      const Gap(AppSpacing.md),
                      toolButton(
                        icon: Icons.medical_services_outlined,
                        title: strings.homeDiagnosticTitle,
                        subtitle: strings.homeDiagnosticSubtitle,
                        onTap: () => _openDiagnostic(provider),
                        iconColor: const Color(0xFFF44336),
                      ),
                      const Gap(40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}