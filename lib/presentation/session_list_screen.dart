import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:thot/data/models.dart';
import 'package:thot/data/thot_provider.dart';
import 'package:thot/theme.dart';
import 'package:thot/presentation/pro_screen.dart';
import 'package:thot/utils/exercise_display.dart';
import 'package:thot/utils/session_text_exporter.dart';
import 'package:thot/utils/unit_converter.dart';
import 'package:thot/utils/web_text_exporter.dart';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/utils/app_date_formats.dart';

const _sessionsHeroAsset = 'assets/images/carnet.webp';

class SessionListScreen extends StatefulWidget {
  const SessionListScreen({Key? key}) : super(key: key);

  @override
  State<SessionListScreen> createState() => _SessionListScreenState();
}

class _SessionListScreenState extends State<SessionListScreen> {
  String _selectedFilter = 'all'; // 'all', '7days', 'month'
  final _searchController = TextEditingController();
  String _searchQuery = '';

  int get _selectedIndex {
    switch (_selectedFilter) {
      case 'month':
        return 1;
      case '7days':
        return 2;
      case 'all':
      default:
        return 0;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fonction pour retirer les accents et passer en minuscules
  String _normalize(String str) {
    const withDia = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    const withoutDia = 'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

    String normalized = str.toLowerCase();
    for (int i = 0; i < withDia.length; i++) {
      normalized = normalized.replaceAll(
          withDia[i].toLowerCase(), withoutDia[i].toLowerCase());
    }
    return normalized;
  }

  List<Session> _filterSessions(List<Session> sessions, ThotProvider provider) {
    List<Session> filtered = List.from(sessions);
    final now = DateTime.now();

    // Apply time filter
    if (_selectedFilter == '7days') {
      filtered = filtered.where((session) {
        final diff = now.difference(session.date).inDays;
        return diff >= 0 && diff < 7;
      }).toList();
    } else if (_selectedFilter == 'month') {
      filtered = filtered.where((session) {
        return session.date.year == now.year && session.date.month == now.month;
      }).toList();
    }

    // Apply search filter with normalization
    if (_searchQuery.isNotEmpty) {
      final query = _normalize(_searchQuery);
      
      filtered = filtered.where((session) {
        // Search in session name
        if (_normalize(session.name).contains(query)) return true;

        // Search in location
        if (_normalize(session.location).contains(query)) return true;

        // Search in session type
        if (_normalize(session.sessionType).contains(query)) return true;

        // Search in date
        final dateStr =
            _normalize(AppDateFormats.formatDateShort(context, session.date));
        if (dateStr.contains(query)) return true;

        // Search in weapons, ammo, accessories used in exercises
        for (var exercise in session.exercises) {
          final weapon = provider.getWeaponById(exercise.weaponId);
          if (weapon != null && _normalize(weapon.name).contains(query)) {
            return true;
          }

          final ammo = provider.getAmmoById(exercise.ammoId);
          if (ammo != null && _normalize(ammo.name).contains(query)) {
            return true;
          }

          for (final equipmentId in exercise.equipmentIds) {
            final accessory = provider.accessories
                .where((a) => a.id == equipmentId)
                .firstOrNull;
            if (accessory != null &&
                _normalize(accessory.name).contains(query)) return true;
          }
        }

        return false;
      }).toList();
    }

    // Sort by date descending (most recent first)
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ThotProvider>(context);
    final converter = UnitConverter(provider.useMetric);
    final allSessions = provider.sessions;
    final filteredSessions = _filterSessions(allSessions, provider);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    const heroHeight = 208.0;
    const panelTop = 120.0;
    const panelHeight = 140.0;
    final subtleBorderColor = colors.outline.withValues(alpha: 0.45);
    // Fond global (même que la home) pour la page et le bandeau.
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;
    final canAddSession = provider.canAddSession();
    final searchFillColor = Color.alphaBlend(
      colors.outline.withValues(alpha: 0.8),
      baseBackground,
    );

    return Scaffold(
      backgroundColor: baseBackground,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (!provider.canAddSession()) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(provider.getLimitMessage('session'))),
            );
            showProModal(context);
            return;
          }
          context.push('/sessions/new');
        },
        icon: const Icon(Icons.add),
        label: canAddSession
            ? Text(
                strings.newSessionCta,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : Stack(
                clipBehavior: Clip.none,
                children: [
                  const SizedBox(width: 0),
                  Padding(
                    padding: const EdgeInsets.only(right: 34),
                    child: Text(
                      strings.newSessionCta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Positioned(
                    top: -10,
                    right: -12,
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
                        strings.proBadge,
                        style: textStyles.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        backgroundColor: canAddSession ? colors.primary : colors.surface,
        foregroundColor: canAddSession ? colors.onPrimary : colors.secondary,
      ),
      body: SafeArea(
        top: false, // laisse l'image de héros monter sous la status bar
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
                          _sessionsHeroAsset,
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
                        // Même couleur que le fond global pour le bandeau haut.
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.lg,
                              20,
                              AppSpacing.lg,
                              10,
                            ),
                            child: _SlidingSegmentedSelector(
                              selectedIndex: _selectedIndex,
                              labels: [
                                strings.sessionsFilterAll,
                                strings.sessionsFilterMonth,
                                strings.sessionsFilter7Days,
                              ],
                              onSelected: (index) {
                                setState(() {
                                  _selectedFilter = switch (index) {
                                    1 => 'month',
                                    2 => '7days',
                                    _ => 'all',
                                  };
                                });
                              },
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
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 14,
                                  ),
                              onChanged: (value) {
                                setState(() => _searchQuery = value);
                              },
                              decoration: InputDecoration(
                                hintText: strings.sessionsSearchHint,
                                hintStyle: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
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
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: filteredSessions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 64,
                            color: colors.secondary.withValues(alpha: 0.5),
                          ),
                          const Gap(AppSpacing.md),
                          Text(
                            _searchQuery.isNotEmpty
                                ? strings.sessionsEmptySearchTitle
                                : strings.sessionsEmptyPeriodTitle,
                            style: textStyles.titleMedium?.copyWith(
                              color: colors.secondary,
                            ),
                          ),
                          const Gap(AppSpacing.sm),
                          Text(
                            _searchQuery.isNotEmpty
                                ? strings.sessionsEmptySearchSubtitle
                                : strings.sessionsEmptyPeriodSubtitle,
                            style: textStyles.bodyMedium?.copyWith(
                              color: colors.secondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      itemCount: filteredSessions.length,
                      separatorBuilder: (_, __) => const Gap(AppSpacing.md),
                      itemBuilder: (context, index) {
                        final session = filteredSessions[index];
                        final isLocked = provider.isSessionLockedForFree(session, index);
                        // Get the first weapon and ammo from exercises (supports none/borrowed)
                        String weaponName = "—";
                        String ammoName = "—";
                        if (session.exercises.isNotEmpty) {
                          final firstEx = session.exercises.first;
                          weaponName = weaponDisplayName(provider, firstEx);
                          ammoName = ammoDisplayName(provider, firstEx);
                        }

                        return _SessionCard(
                          session: session,
                          weaponName: weaponName,
                          ammoName: ammoName,
                          provider: provider,
                          converter: converter,
                          isLocked: isLocked,
                        );
                      },
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionStat extends StatelessWidget {
  final Widget icon;
  final String label;
  final String value;
  final ColorScheme colors;
  final TextTheme textStyles;

  const _SessionStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
    required this.textStyles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icon,
        const Gap(4),
        Text(
          label,
          style: (textStyles.labelSmall ?? const TextStyle())
              .copyWith(color: colors.secondary),
          textAlign: TextAlign.center,
        ),
        Text(
          value,
          style: (textStyles.bodySmall ?? const TextStyle()).copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textStyles = Theme.of(context).textTheme;
    final subtleBorderColor = colors.outline.withValues(alpha: 0.45);
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth / labels.length;
        // Fond des onglets : légèrement plus foncé que le fond global.
        final chipGray = Color.alphaBlend(
          colors.outline.withValues(alpha: 0.8),
          baseBackground,
        );

        return Container(
          height: 44,
          decoration: BoxDecoration(
            color: chipGray,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: subtleBorderColor,
            ),
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
                              padding: const EdgeInsets.symmetric(horizontal: 8),
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

class _SessionCard extends StatelessWidget {
  final Session session;
  final String weaponName;
  final String ammoName;
  final ThotProvider provider;
  final UnitConverter converter;
  final bool isLocked;

  const _SessionCard({
    required this.session,
    required this.weaponName,
    required this.ammoName,
    required this.provider,
    required this.converter,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final accuracy = session.averagePrecision.toStringAsFixed(0);
    final hasPrecision = session.hasCountedPrecision;

    Widget buildMenu() {
      return PopupMenuButton<String>(
        icon: Icon(
          Icons.more_vert_rounded,
          color: colors.onSurface,
        ),
        onSelected: (value) {
          if (value == 'delete') {
            _showDeleteConfirmation(context);
            return;
          }

          if (isLocked) {
            context.push('/pro');
            return;
          }

          if (value == 'edit') {
            context.push(
              '/sessions/new?sessionId=${Uri.encodeComponent(session.id)}',
            );
          } else if (value == 'duplicate') {
            final duplicated = provider.duplicateSession(session);
            if (!duplicated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(provider.getLimitMessage('session')),
                ),
              );
              context.push('/pro');
              return;
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(strings.sessionDuplicatedSnack),
              ),
            );
          } else if (value == 'share') {
            _shareSession(context);
          }
        },
        itemBuilder: (context) {
          if (isLocked) {
            return [
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline_rounded, size: 20),
                    const Gap(12),
                    Text(strings.sessionMenuDelete),
                  ],
                ),
              ),
            ];
          }

          return [
            PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit_rounded, size: 20),
                  const Gap(12),
                  Text(strings.sessionMenuEdit),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'duplicate',
              child: Row(
                children: [
                  const Icon(Icons.content_copy_rounded, size: 20),
                  const Gap(12),
                  Text(strings.sessionMenuDuplicate),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'share',
              child: Row(
                children: [
                  const Icon(Icons.share_rounded, size: 20),
                  const Gap(12),
                  Text(strings.sessionMenuShare),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete_outline_rounded, size: 20),
                  const Gap(12),
                  Text(strings.sessionMenuDelete),
                ],
              ),
            ),
          ];
        },
      );
    }

    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLocked
            ? () => context.push('/pro')
            : () {
                context.push(
                  '/sessions/exercises?sessionId=${Uri.encodeComponent(session.id)}',
                );
              },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: isDark
                ? null
                : Border.all(
                    color: LightColors.surfaceHighlight,
                    width: 1.35,
                  ),
            boxShadow: AppShadows.cardPremium,
          ),
          child: Opacity(
            opacity: isLocked ? 0.45 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            session.name,
                            style: textStyles.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Gap(AppSpacing.xs),
                          Row(
                            children: [
                              Icon(
                                Icons.event_rounded,
                                size: 14,
                                color: colors.secondary,
                              ),
                              const Gap(4),
                              Text(
                                AppDateFormats.formatDateTimeShort(
                                  context,
                                  session.date,
                                ),
                                style: textStyles.labelSmall?.copyWith(
                                  color: colors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasPrecision)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: LightColors.surfaceHighlight,
                                width: 1.35,
                              ),
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/images/target.svg',
                                  width: 16,
                                  height: 16,
                                  colorFilter: ColorFilter.mode(
                                    colors.onPrimary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  '$accuracy%',
                                  style: textStyles.labelLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Transform.translate(
                            offset: const Offset(8, 0),
                            child: buildMenu(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Gap(AppSpacing.sm),
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colors.outline,
                      width: 1.2,
                    ),
                  ),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(color: colors.onSurface),
                    child: IconTheme.merge(
                      data: IconThemeData(color: colors.primary),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/images/gun.svg',
                                          width: 16,
                                          height: 16,
                                          colorFilter: ColorFilter.mode(
                                            colors.primary,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                        const Gap(8),
                                        Text(
                                          strings.quickActionLabelWeapon,
                                          style: (textStyles.labelSmall ??
                                                  const TextStyle())
                                              .copyWith(
                                            color: colors.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Gap(4),
                                    Text(
                                      weaponName,
                                      style: (textStyles.bodySmall ??
                                              const TextStyle())
                                          .copyWith(
                                        color: colors.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(AppSpacing.xs),
                              Container(
                                width: 1,
                                height: 32,
                                color: colors.outline,
                              ),
                              const Gap(AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/images/bullet.svg',
                                          width: 16,
                                          height: 16,
                                          colorFilter: ColorFilter.mode(
                                            colors.primary,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                        const Gap(8),
                                        Text(
                                          strings.quickActionLabelAmmo,
                                          style: (textStyles.labelSmall ??
                                                  const TextStyle())
                                              .copyWith(
                                            color: colors.secondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Gap(4),
                                    Text(
                                      ammoName,
                                      style: (textStyles.bodySmall ??
                                              const TextStyle())
                                          .copyWith(
                                        color: colors.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Gap(AppSpacing.sm),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _SessionStat(
                                icon: SvgPicture.asset(
                                  'assets/images/train.svg',
                                  width: 18,
                                  height: 18,
                                  colorFilter: ColorFilter.mode(
                                    colors.primary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                label: strings.exercisesLabel,
                                value: "${session.exercises.length}",
                                colors: colors,
                                textStyles: textStyles,
                              ),
                              Container(
                                width: 1,
                                height: 32,
                                color: colors.outline,
                              ),
                              _SessionStat(
                                icon: SvgPicture.asset(
                                  'assets/images/hit.svg',
                                  width: 18,
                                  height: 18,
                                  colorFilter: ColorFilter.mode(
                                    colors.primary,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                label: strings.shotsFiredLabel,
                                value: "${session.totalRounds}",
                                colors: colors,
                                textStyles: textStyles,
                              ),
                              Container(
                                width: 1,
                                height: 32,
                                color: colors.outline,
                              ),
                              _SessionStat(
                                icon: Icon(
                                  Icons.place_rounded,
                                  size: 18,
                                  color: colors.primary,
                                ),
                                label: strings.locationLabel,
                                value: session.location.split(' ').take(2).join(' '),
                                colors: colors,
                                textStyles: textStyles,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        card,
        if (isLocked)
          Positioned(
            top: 10,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: LightColors.surfaceHighlight,
                  width: 1.35,
                ),
              ),
              child: Text(
                strings.proBadge,
                style: textStyles.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _shareSession(BuildContext context) async {
    final strings = AppStrings.of(context);
    final summary = SessionTextExporter.buildSummary(
        session: session, provider: provider, converter: converter);

    // On web, the native share sheet is often unavailable (depends on HTTPS +
    // browser support). So we show a dedicated export sheet (copy + download).
    if (kIsWeb) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => SessionShareSheet(session: session, summary: summary),
      );
      return;
    }

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: summary,
          subject: '${strings.sessionShareSubjectPrefix}${session.name}',
        ),
      );
    } catch (e) {
      debugPrint('Failed to share session: $e');
      if (!context.mounted) return;
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => SessionShareSheet(session: session, summary: summary),
      );
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    final strings = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.confirmDeleteTitle),
        content: Text(
            strings.confirmDeleteSessionMessage(session.name)),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(strings.actionCancel),
          ),
          FilledButton(
            onPressed: () {
              provider.deleteSession(session.id);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(strings.sessionDeletedSnack(session.name))),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(strings.actionDelete),
          ),
        ],
      ),
    );
  }
}

class SessionShareSheet extends StatelessWidget {
  final Session session;
  final String summary;

  const SessionShareSheet(
      {super.key, required this.session, required this.summary});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.sm,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(strings.exportSessionTitle,
                style: textStyles.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const Gap(AppSpacing.xs),
            Text(
              strings.exportSessionSubtitle,
              style: textStyles.bodyMedium?.copyWith(color: colors.secondary),
            ),
            const Gap(AppSpacing.md),
            Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: colors.outline),
              ),
              child: SingleChildScrollView(
                child: SelectableText(summary,
                    style: textStyles.bodySmall?.copyWith(height: 1.45)),
              ),
            ),
            const Gap(AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: summary));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(strings.copiedSnack)));
                    },
                    icon: Icon(Icons.copy_rounded, color: colors.onPrimary),
                    label: Text(strings.actionCopy,
                        style: textStyles.labelLarge
                            ?.copyWith(color: colors.onPrimary)),
                  ),
                ),
                const Gap(AppSpacing.sm),
                Expanded(
                  child: kIsWeb
                      ? OutlinedButton.icon(
                          onPressed: () async {
                            final safeName = session.name.trim().isEmpty
                                ? 'seance'
                                : session.name.trim();
                            final filename = 'THOT_$safeName.txt'
                                .replaceAll(RegExp(r'[^a-zA-Z0-9_\-\.]+'), '_');
                            try {
                              await WebTextExporter.downloadTextFile(
                                  filename: filename, content: summary);
                            } catch (e) {
                              debugPrint('Failed to export text file: $e');
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(strings.downloadFailedSnack)),
                              );
                            }
                          },
                          icon: Icon(Icons.download_rounded,
                              color: colors.primary),
                          label: Text(strings.actionDownloadTxt,
                              style: textStyles.labelLarge
                                  ?.copyWith(color: colors.primary)),
                        )
                      : OutlinedButton.icon(
                          onPressed: () async {
                            try {
                              await SharePlus.instance.share(
                                ShareParams(
                                  text: summary,
                                  subject: '${strings.sessionShareSubjectPrefix}${session.name}',
                                ),
                              );
                            } catch (e) {
                              debugPrint('Failed to share session (sheet): $e');
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(strings.shareUnavailableSnack)),
                              );
                            }
                          },
                          icon:
                              Icon(Icons.share_rounded, color: colors.primary),
                          label: Text(strings.sessionMenuShare,
                              style: textStyles.labelLarge
                                  ?.copyWith(color: colors.primary)),
                        ),
                ),
              ],
            ),
            const Gap(AppSpacing.sm),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(strings.actionClose,
                  style:
                      textStyles.labelLarge?.copyWith(color: colors.secondary)),
            ),
          ],
        ),
      ),
    );
  }
}