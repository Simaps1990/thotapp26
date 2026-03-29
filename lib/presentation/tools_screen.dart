import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import 'package:thot/data/thot_provider.dart';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/theme.dart';

import 'package:thot/presentation/diagnostic_screen.dart';
import 'package:thot/presentation/millieme_tool_screen.dart';
import 'package:thot/presentation/shooting_timer_screen.dart';
import 'package:thot/presentation/pro_screen.dart';
import 'package:thot/presentation/color_pod_screen.dart';

const _toolsHeroAsset = 'assets/images/carnet.webp';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  void _openMillieme(ThotProvider provider) {
    if (!provider.isPremium) {
      showProModal(context);
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const MilliemeToolScreen(),
    );
  }

  void _openTimer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ShootingTimerScreen(),
    );
  }

  void _openColorPod() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ColorPodScreen(),
    );
  }

  void _openDiagnostic(ThotProvider provider) {
    if (!provider.isPremium) {
      showProModal(context);
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DiagnosticScreen(),
    );
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
    const panelHeight = 140.0;

    Widget toolButton({
      required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap,
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
                Icon(icon, color: colors.primary, size: 24),
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
        child: Column(
          children: [
            SizedBox(
              height: panelTop + panelHeight,
              child: Stack(
                children: [
                  SizedBox(
                    height: heroHeight,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          _toolsHeroAsset,
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
                    left: 0,
                    right: 0,
                    top: panelTop,
                    child: Container(
                      decoration: BoxDecoration(
                        color: baseBackground,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          18,
                          AppSpacing.lg,
                          14,
                        ),
                        child: Text(
                          strings.homeToolsSectionTitle,
                          style: textStyles.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: baseBackground,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      toolButton(
                        icon: Icons.straighten_rounded,
                        title: strings.milliemeToolTitle,
                        subtitle: strings.milliemeToolSubtitle,
                        onTap: () => _openMillieme(provider),
                      ),
                      const Gap(AppSpacing.md),
                      toolButton(
                        icon: Icons.timer_rounded,
                        title: strings.homeTimerTitle,
                        subtitle: strings.homeTimerSubtitle,
                        onTap: _openTimer,
                      ),
                      const Gap(AppSpacing.md),
                      toolButton(
                        icon: Icons.medical_services_outlined,
                        title: strings.homeDiagnosticTitle,
                        subtitle: strings.homeDiagnosticSubtitle,
                        onTap: () => _openDiagnostic(provider),
                      ),
                      const Gap(AppSpacing.md),
                      toolButton(
                        icon: Icons.color_lens_rounded,
                        title: strings.colorPodToolTitle,
                        subtitle: strings.colorPodToolSubtitle,
                        onTap: _openColorPod,
                      ),
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
}





