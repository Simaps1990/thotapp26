import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:thot/l10n/app_strings.dart';
import '../theme.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final strings = AppStrings.of(context);
    final currentIndex = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 74,
          labelPadding: const EdgeInsets.only(top: 1),
          iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
            (states) {
              final selected = states.contains(WidgetState.selected);
              final Color color;
              if (isDark) {
                color = selected ? colors.onSurface : colors.secondary;
              } else {
                color = selected
                    ? LightColors.iconActive
                    : LightColors.iconInactive;
              }
              return IconThemeData(color: color, size: 24);
            },
          ),
          labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
            (states) {
              final selected = states.contains(WidgetState.selected);
              final base = theme.textTheme.labelSmall ?? const TextStyle();
              final Color color;
              if (isDark) {
                color = selected ? colors.onSurface : colors.secondary;
              } else {
                color = selected
                    ? LightColors.iconActive
                    : LightColors.iconInactive;
              }
              return base.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
                height: 1.0,
              );
            },
          ),
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) {
              if (states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.focused) ||
                  states.contains(WidgetState.pressed)) {
                return Colors.transparent;
              }
              return null;
            },
          ),
        ),
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.07),
                blurRadius: 14,
                spreadRadius: 0,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? colors.surface : LightColors.surface,
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? colors.outline.withValues(alpha: 0.72)
                          : LightColors.surfaceHighlight.withValues(alpha: 1),
                      width: 1.1,
                    ),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      6,
                    ),
                    child: NavigationBar(
                      key: ValueKey('bottom_nav_$currentIndex'),
                      backgroundColor: Colors.transparent,
                      surfaceTintColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      selectedIndex: currentIndex,
                      onDestinationSelected: _goBranch,
                      height: 68,
                      destinations: [
                        NavigationDestination(
                          icon: const Icon(Icons.home_outlined),
                          selectedIcon: const Icon(Icons.home_rounded),
                          label: strings.navHomeLabel,
                        ),
                        NavigationDestination(
                          icon: const _NavSvgIcon('assets/images/seance.svg'),
                          selectedIcon: const _NavSvgIcon('assets/images/seance.svg'),
                          label: strings.navSessionsLabel,
                        ),
                        NavigationDestination(
                          icon: const _NavSvgIcon('assets/images/material.svg'),
                          selectedIcon: const _NavSvgIcon('assets/images/material.svg'),
                          label: strings.navInventoryLabel,
                        ),
                        NavigationDestination(
                          icon: const Icon(Icons.handyman_outlined),
                          selectedIcon: const Icon(Icons.handyman_rounded),
                          label: strings.navToolsLabel,
                        ),
                        NavigationDestination(
                          icon: const Icon(Icons.settings_outlined),
                          selectedIcon: const Icon(Icons.settings_rounded),
                          label: strings.navSettingsLabel,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavSvgIcon extends StatelessWidget {
  const _NavSvgIcon(this.assetPath);

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final color = IconTheme.of(context).color;
    return SvgPicture.asset(
      assetPath,
      width: 24,
      height: 24,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}