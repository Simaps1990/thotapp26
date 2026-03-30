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
import 'package:thot/data/exercise_step.dart';
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

  void _showTemplateModal(BuildContext context) {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, __) => ChangeNotifierProvider<ThotProvider>.value(
          value: provider,
          child: const TemplateManagerScreen(),
        ),
      ),
    );
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
                    left: AppSpacing.lg,
                    top: panelTop - 44,
                    child: Text(
                      strings.sessionsSubtitle,
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
                  // --- BOUTON MODÈLES EN HAUT À DROITE ---
                  Positioned(
                    right: AppSpacing.lg,
                    top: MediaQuery.of(context).padding.top + 12, 
                    child: TextButton.icon(
                      onPressed: () => _showTemplateModal(context),
                      icon: const Icon(Icons.bookmark_rounded, color: Colors.white, size: 18),
                      label: Text(
                        "Modèles",
                        style: textStyles.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.35),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                  ),
                  // ----------------------------------------
                  Positioned(
                    left: 0,
                    right: 0,
                    top: panelTop,
                    child: Container(
                      decoration: BoxDecoration(
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
                            child: SizedBox(
                              height: 44,
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

class TemplateManagerScreen extends StatefulWidget {
  const TemplateManagerScreen({super.key});

  @override
  State<TemplateManagerScreen> createState() => TemplateManagerScreenState();
}

class TemplateManagerScreenState extends State<TemplateManagerScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _pageIndex = 0;

  String _searchQuery = '';
  bool _sortByDate = true;
  bool _dateDescending = true;
  bool _sortByName = false;
  int _modeFilterIndex = 0; // 0 = tous, 1 = simples, 2 = détaillés

  ExerciseTemplate? _editingTemplate;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _shotsController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _detailedMode = false;
  final List<ExerciseStep> _steps = [];

@override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _shotsController.dispose();
    _distanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    setState(() {
      _pageIndex = index;
    });
  }

  void _openEditor({ExerciseTemplate? template}) {
    setState(() {
      _editingTemplate = template;
      if (template == null) {
        _nameController.text = '';
        _shotsController.text = '';
        _distanceController.text = '';
        _notesController.text = '';
        _detailedMode = false;
        _steps
          ..clear();
      } else {
        _nameController.text = template.name;
        _shotsController.text = template.shotsFired.toString();
        _distanceController.text = template.distance.toString();
        _notesController.text = template.observations;
        _detailedMode = template.detailedMode;
        _steps
          ..clear()
          ..addAll(template.steps ?? const []);
      }
    });
    _goToPage(1);
  }

  int _computedTotalShots() {
    return _steps
        .where((s) => s.type == StepType.tir && s.shots != null)
        .fold<int>(0, (sum, s) => sum + (s.shots ?? 0));
  }

  int _computedMaxDistance() {
    final distances = _steps.map((s) => s.distanceM).whereType<int>();
    if (distances.isEmpty) return 0;
    return distances.reduce((a, b) => a > b ? a : b);
  }

  Future<void> _addOrEditStep({ExerciseStep? initial}) async {
    final step = await showModalBottomSheet<ExerciseStep>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TemplateStepSheet(initialStep: initial),
    );
    if (!mounted || step == null) return;
    setState(() {
      final idx = _steps.indexWhere((s) => s.id == step.id);
      if (idx >= 0) {
        _steps[idx] = step;
      } else {
        _steps.add(step);
      }
    });
  }

  void _deleteStep(String id) {
    setState(() {
      _steps.removeWhere((s) => s.id == id);
    });
  }

  void _moveStepUp(int index) {
    if (index <= 0) return;
    setState(() {
      final step = _steps.removeAt(index);
      _steps.insert(index - 1, step);
    });
  }

  void _moveStepDown(int index) {
    if (index >= _steps.length - 1) return;
    setState(() {
      final step = _steps.removeAt(index);
      _steps.insert(index + 1, step);
    });
  }

  void _toggleDateSort() {
    setState(() {
      _sortByDate = true;
      _sortByName = false;
      _dateDescending = !_dateDescending;
    });
  }

  void _activateNameSort() {
    setState(() {
      _sortByDate = false;
      _sortByName = true;
    });
  }

  void _cycleModeFilter() {
    setState(() {
      _modeFilterIndex = (_modeFilterIndex + 1) % 3;
    });
  }

  String _modeFilterLabel() {
    switch (_modeFilterIndex) {
      case 1:
        return 'Simples';
      case 2:
        return 'Détaillés';
      default:
        return 'Tous les modes';
    }
  }

  List<ExerciseTemplate> _filteredTemplates(ThotProvider provider) {
    var list = provider.exerciseTemplates.toList();

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list
          .where((t) =>
              t.name.toLowerCase().contains(q) ||
              t.observations.toLowerCase().contains(q))
          .toList();
    }

    if (_modeFilterIndex == 1) {
      list = list.where((t) => !t.detailedMode).toList();
    } else if (_modeFilterIndex == 2) {
      list = list.where((t) => t.detailedMode).toList();
    }

    list.sort((a, b) {
      if (_sortByName) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      final cmp = a.createdAt.compareTo(b.createdAt);
      return _dateDescending ? -cmp : cmp;
    });

    return list;
  }

  Future<void> _saveTemplate(ThotProvider provider) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final typedShots = int.tryParse(_shotsController.text.trim());
    final typedDistance = int.tryParse(_distanceController.text.trim());
    final shots = _detailedMode
        ? (typedShots ?? _computedTotalShots())
        : (typedShots ?? 0);
    final distance = _detailedMode
        ? (typedDistance ?? _computedMaxDistance())
        : (typedDistance ?? 0);
    final notes = _notesController.text.trim();

    final now = DateTime.now();
    final existing = _editingTemplate;
    final template = ExerciseTemplate(
      id: existing?.id ?? now.microsecondsSinceEpoch.toString(),
      name: name,
      createdAt: existing?.createdAt ?? now,
      shotsFired: shots,
      distance: distance,
      detailedMode: _detailedMode,
      steps: _detailedMode ? List<ExerciseStep>.from(_steps) : null,
      observations: notes,
    );

    provider.saveExerciseTemplate(template);
    _goToPage(0);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final provider = Provider.of<ThotProvider>(context);
    final templates = _filteredTemplates(provider);
    
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;
    final subtleBorderColor = colors.outline.withValues(alpha: 0.45);
    final searchFillColor = Color.alphaBlend(
      colors.outline.withValues(alpha: 0.8),
      baseBackground,
    );

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        color: baseBackground,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: _pageIndex == 0
              ? FloatingActionButton.extended(
                  onPressed: () => _openEditor(template: null),
                  icon: const Icon(Icons.add),
                  label: Text(strings.createTemplateButton),
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                )
              : null,
          body: IndexedStack(
            index: _pageIndex,
            children: [
          // --- PAGE 1: LISTE DES MODÈLES ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 10),
                child: Text(
                  strings.homeTemplateTitle,
                  style: textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(_sortByDate
                          ? (_dateDescending ? 'Date (récentes)' : 'Date (anciennes)')
                          : 'Date'),
                      selected: _sortByDate,
                      onSelected: (_) => _toggleDateSort(),
                    ),
                    ChoiceChip(
                      label: const Text('Nom'),
                      selected: _sortByName,
                      onSelected: (_) => _activateNameSort(),
                    ),
                    ChoiceChip(
                      label: Text(_modeFilterLabel()),
                      selected: _modeFilterIndex != 0,
                      onSelected: (_) => _cycleModeFilter(),
                    ),
                  ],
                ),
              ),
              const Gap(AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: TextField(
                  controller: _searchController,
                  style: textStyles.bodyMedium?.copyWith(
                    fontSize: 14,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
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
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
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
              const Gap(AppSpacing.md),
              Expanded(
                child: templates.isEmpty
                    ? Center(
                        child: Text(
                          strings.noTemplatesAvailable,
                          style: textStyles.bodyMedium?.copyWith(color: colors.secondary),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 80),
                        itemCount: templates.length,
                        separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final t = templates[index];
                          final subtitle = t.detailedMode
                              ? '${t.steps?.length ?? 0} étapes · ${AppDateFormats.formatDateShort(context, t.createdAt)}'
                              : '${t.shotsFired} coups · ${t.distance} m · ${AppDateFormats.formatDateShort(context, t.createdAt)}';

                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            tileColor: colors.surface,
                            title: Text(
                              t.name,
                              style: textStyles.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              subtitle,
                              style: textStyles.bodySmall?.copyWith(color: colors.secondary),
                            ),
                            onTap: () => _openEditor(template: t),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_rounded, color: colors.error),
                              onPressed: () {
                                showDialog<void>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(strings.confirmDeleteTitle),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(),
                                        child: Text(strings.actionCancel),
                                      ),
                                      FilledButton(
                                        onPressed: () {
                                          provider.deleteExerciseTemplate(t.id);
                                          Navigator.of(ctx).pop();
                                        },
                                        child: Text(strings.actionDelete),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          
          // --- PAGE 2: ÉDITEUR DE MODÈLE ---
          Padding(
            padding: AppSpacing.paddingLg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      onPressed: () => _goToPage(0),
                      color: colors.onSurface,
                    ),
                    const Gap(AppSpacing.sm),
                    Expanded(
                      child: Text(
                        _editingTemplate != null 
                          ? strings.templateNameDialogTitle 
                          : strings.createExerciseTemplateTitle,
                        style: textStyles.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(AppSpacing.md),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: strings.templateNameDialogTitle,
                    hintText: strings.templateNameHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
                const Gap(AppSpacing.md),
                Row(
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: colors.primary,
                    ),
                    const Gap(8),
                    Text(
                      strings.exerciseModeLabel,
                      style: textStyles.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
                const Gap(10),
                SizedBox(
                  height: 44,
                  child: _SlidingSegmentedSelector(
                    selectedIndex: _detailedMode ? 1 : 0,
                    labels: [
                      strings.exerciseModeSimple,
                      strings.exerciseModeDetailed,
                    ],
                    onSelected: (index) {
                      setState(() {
                        _detailedMode = index == 1;
                      });
                    },
                  ),
                ),
                const Gap(AppSpacing.md),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (!_detailedMode) ...[
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          'assets/images/hit.svg',
                                          width: 18,
                                          height: 18,
                                          colorFilter: ColorFilter.mode(
                                            colors.primary,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                        const Gap(8),
                                        Text(
                                          strings.shotsCountLabel,
                                          style: textStyles.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Gap(AppSpacing.sm),
                                    TextField(
                                      controller: _shotsController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: '0',
                                        filled: true,
                                        fillColor: colors.surface,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(AppRadius.lg),
                                          borderSide: BorderSide(color: colors.outline),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(AppRadius.lg),
                                          borderSide: BorderSide(color: colors.outline),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(AppRadius.lg),
                                          borderSide: BorderSide(
                                            color: colors.primary,
                                            width: 1.6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.straighten_rounded,
                                          size: 18,
                                          color: colors.primary,
                                        ),
                                        const Gap(8),
                                        Text(
                                          strings.distanceLabel,
                                          style: textStyles.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Gap(AppSpacing.sm),
                                    TextField(
                                      controller: _distanceController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: '0',
                                        filled: true,
                                        fillColor: colors.surface,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(AppRadius.lg),
                                          borderSide: BorderSide(color: colors.outline),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(AppRadius.lg),
                                          borderSide: BorderSide(color: colors.outline),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(AppRadius.lg),
                                          borderSide: BorderSide(
                                            color: colors.primary,
                                            width: 1.6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Gap(AppSpacing.md),
                        ],
                        if (_detailedMode) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Étapes',
                                style: textStyles.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: colors.onSurface,
                                ),
                              ),
                              FilledButton.icon(
                                onPressed: () => _addOrEditStep(),
                                icon: const Icon(Icons.add, size: 18),
                                label: Text(strings.exerciseActionAdd),
                              ),
                            ],
                          ),
                          const Gap(AppSpacing.sm),
                          if (_steps.isEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.surface,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(color: colors.outline),
                              ),
                              child: Text(
                                'Aucune étape',
                                style: textStyles.bodyMedium?.copyWith(color: colors.secondary),
                                textAlign: TextAlign.center,
                              ),
                            )
                          else
                            ...List.generate(_steps.length, (index) {
                              final s = _steps[index];
                              final title = strings.exerciseStepTypeLabel(s.type);
                              final parts = <String>[];
                              if (s.type == StepType.tir && s.shots != null) {
                                parts.add('${s.shots} ${strings.exerciseNarrativeShotsWord}');
                              }
                              if (s.distanceM != null) parts.add('${s.distanceM} ${provider.useMetric ? 'm' : 'yd'}');
                              if ((s.target ?? '').trim().isNotEmpty) parts.add(s.target!.trim());
                              final subtitle = parts.isEmpty ? '—' : parts.join(' · ');
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  border: Border.all(color: colors.outline),
                                ),
                                child: ListTile(
                                  leading: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          iconSize: 18,
                                          onPressed: index > 0 ? () => _moveStepUp(index) : null,
                                          icon: Icon(
                                            Icons.arrow_upward_rounded,
                                            color: index > 0 ? colors.primary : colors.outline,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          iconSize: 18,
                                          onPressed: index < _steps.length - 1 ? () => _moveStepDown(index) : null,
                                          icon: Icon(
                                            Icons.arrow_downward_rounded,
                                            color: index < _steps.length - 1 ? colors.primary : colors.outline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  title: Text(
                                    title,
                                    style: textStyles.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  subtitle: Text(
                                    subtitle,
                                    style: textStyles.bodySmall?.copyWith(color: colors.secondary),
                                  ),
                                  onTap: () => _addOrEditStep(initial: s),
                                  trailing: IconButton(
                                    onPressed: () => _deleteStep(s.id),
                                    icon: Icon(Icons.delete_rounded, color: colors.error),
                                  ),
                                ),
                              );
                            }),
                          const Gap(AppSpacing.md),
                        ],
                        TextField(
                          controller: _notesController,
                          minLines: 4,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: strings.observationsTitle,
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(AppSpacing.md),
                SizedBox(
                  height: 52,
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: () => _goToPage(0),
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.primary.withValues(alpha: 0.72),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            strings.actionCancel.toUpperCase(),
                            style: textStyles.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                      const Gap(AppSpacing.md),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => _saveTemplate(provider),
                          style: FilledButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            'ENREGISTRER',
                            style: textStyles.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      ),
      ),
    );
  }
}

class _TemplateStepSheet extends StatefulWidget {
  final ExerciseStep? initialStep;

  const _TemplateStepSheet({this.initialStep});

  @override
  State<_TemplateStepSheet> createState() => _TemplateStepSheetState();
}

class _TemplateStepSheetState extends State<_TemplateStepSheet> {
  StepType _type = StepType.tir;
  ShootingPosition? _position;

  final _distanceController = TextEditingController();
  final _shotsController = TextEditingController();
  final _targetController = TextEditingController();
  final _weaponFromController = TextEditingController();
  final _weaponToController = TextEditingController();
  ReloadType? _reloadType;
  MovementType? _movementType;
  final _durationController = TextEditingController();
  final _triggerController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initial = widget.initialStep;
    if (initial == null) return;

    _type = initial.type;
    _position = initial.position;
    _reloadType = initial.reloadType;
    _movementType = initial.movementType;

    _distanceController.text = initial.distanceM?.toString() ?? '';
    _shotsController.text = initial.shots?.toString() ?? '';
    _targetController.text = initial.target ?? '';
    _weaponFromController.text = initial.weaponFrom ?? '';
    _weaponToController.text = initial.weaponTo ?? '';
    _durationController.text = initial.durationSeconds?.toString() ?? '';
    _triggerController.text = initial.trigger ?? '';
    _commentController.text = initial.comment ?? '';
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _shotsController.dispose();
    _targetController.dispose();
    _weaponFromController.dispose();
    _weaponToController.dispose();
    _durationController.dispose();
    _triggerController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);
    final provider = Provider.of<ThotProvider>(context, listen: false);
    final distUnit = provider.useMetric ? 'm' : 'yd';
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;

    InputDecoration decoration(String label) => InputDecoration(
          labelText: label,
          filled: true,
          fillColor: colors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide(color: colors.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide(color: colors.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            borderSide: BorderSide(color: colors.primary, width: 1.6),
          ),
        );

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
          const Gap(12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.initialStep == null
                        ? strings.exerciseNewStepTitle
                        : strings.exerciseEditStepTitle,
                    style: textStyles.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Gap(8),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    strings.exerciseStepTypeTitle,
                    style: textStyles.labelLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: StepType.values.map((t) {
                      final selected = _type == t;
                      return ChoiceChip(
                        label: Text(strings.exerciseStepTypeLabel(t)),
                        selected: selected,
                        onSelected: (_) => setState(() => _type = t),
                        selectedColor: colors.primary.withValues(alpha: 0.2),
                        backgroundColor: colors.surface,
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: selected ? colors.primary : colors.outline,
                          ),
                        ),
                        labelStyle: textStyles.labelLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      );
                    }).toList(),
                  ),
                  const Gap(AppSpacing.md),
                  Text(
                    strings.exerciseStepPositionTitle,
                    style: textStyles.labelLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('·'),
                        selected: _position == null,
                        onSelected: (_) => setState(() => _position = null),
                        selectedColor: colors.primary.withValues(alpha: 0.2),
                        backgroundColor: colors.surface,
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: _position == null
                                ? colors.primary
                                : colors.outline,
                          ),
                        ),
                      ),
                      ...ShootingPosition.values.map((p) {
                        final selected = _position == p;
                        return ChoiceChip(
                          label: Text(strings.exercisePositionLabel(p)),
                          selected: selected,
                          onSelected: (_) => setState(() => _position = p),
                          selectedColor: colors.primary.withValues(alpha: 0.2),
                          backgroundColor: colors.surface,
                          shape: StadiumBorder(
                            side: BorderSide(
                              color:
                                  selected ? colors.primary : colors.outline,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const Gap(AppSpacing.md),
                  if (_type == StepType.tir) ...[
                    TextField(
                      controller: _shotsController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                          '${strings.exerciseFieldShots}${strings.exerciseOptionalHint}'),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                          '${strings.exerciseFieldDistance} ($distUnit)${strings.exerciseOptionalHint}'),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _targetController,
                      decoration: decoration(
                          '${strings.exerciseFieldTarget}${strings.exerciseOptionalHint}'),
                    ),
                  ] else if (_type == StepType.deplacement) ...[
                    Text(
                      strings.exerciseFieldMovementType,
                      style: textStyles.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const Gap(8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('·'),
                          selected: _movementType == null,
                          onSelected: (_) => setState(() => _movementType = null),
                          selectedColor: colors.primary.withValues(alpha: 0.2),
                          backgroundColor: colors.surface,
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: _movementType == null
                                  ? colors.primary
                                  : colors.outline,
                            ),
                          ),
                        ),
                        ...MovementType.values.map((t) {
                          final selected = _movementType == t;
                          return ChoiceChip(
                            label: Text(strings.exerciseMovementTypeLabel(t)),
                            selected: selected,
                            onSelected: (_) => setState(() => _movementType = t),
                            selectedColor: colors.primary.withValues(alpha: 0.2),
                            backgroundColor: colors.surface,
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: selected ? colors.primary : colors.outline,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const Gap(10),
                    TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                          '${strings.exerciseFieldDistance} ($distUnit)${strings.exerciseOptionalHint}'),
                    ),
                  ] else if (_type == StepType.rechargement) ...[
                    Text(
                      strings.exerciseFieldReloadType,
                      style: textStyles.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const Gap(8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ReloadType.values.map((t) {
                        final selected = _reloadType == t;
                        return ChoiceChip(
                          label: Text(strings.exerciseReloadTypeLabel(t)),
                          selected: selected,
                          onSelected: (_) => setState(() => _reloadType = t),
                          selectedColor: colors.primary.withValues(alpha: 0.2),
                          backgroundColor: colors.surface,
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: selected ? colors.primary : colors.outline,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ] else if (_type == StepType.transition) ...[
                    TextField(
                      controller: _weaponFromController,
                      decoration: decoration(
                          '${strings.exerciseFieldWeaponFrom}${strings.exerciseOptionalHint}'),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _weaponToController,
                      decoration: decoration(
                          '${strings.exerciseFieldWeaponTo}${strings.exerciseOptionalHint}'),
                    ),
                  ] else if (_type == StepType.miseEnJoue) ...[
                    TextField(
                      controller: _targetController,
                      decoration: decoration(
                          '${strings.exerciseFieldTarget}${strings.exerciseOptionalHint}'),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                          '${strings.exerciseFieldDistance} ($distUnit)${strings.exerciseOptionalHint}'),
                    ),
                  ] else if (_type == StepType.attente) ...[
                    TextField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                          '${strings.exerciseFieldDuration} (s)${strings.exerciseOptionalHint}'),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                          '${strings.exerciseFieldDistance} ($distUnit)${strings.exerciseOptionalHint}'),
                    ),
                    const Gap(10),
                    TextField(
                      controller: _triggerController,
                      decoration: decoration(
                          '${strings.exerciseFieldTrigger}${strings.exerciseOptionalHint}'),
                    ),
                  ] else ...[
                    TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: decoration(
                          '${strings.exerciseFieldDistance} ($distUnit)${strings.exerciseOptionalHint}'),
                    ),
                  ],
                  const Gap(AppSpacing.md),
                  TextField(
                    controller: _commentController,
                    minLines: 2,
                    maxLines: 4,
                    decoration: decoration(strings.exerciseStepCommentLabel),
                  ),
                  const Gap(AppSpacing.lg),
                  SizedBox(
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: AppShadows.cardPremium,
                      ),
                      child: FilledButton(
                        onPressed: () {
                          final distanceM =
                              int.tryParse(_distanceController.text.trim());
                          final shots =
                              int.tryParse(_shotsController.text.trim());
                          final durationSeconds =
                              int.tryParse(_durationController.text.trim());

                          final step = ExerciseStep(
                            id: widget.initialStep?.id ??
                                DateTime.now()
                                    .microsecondsSinceEpoch
                                    .toString(),
                            type: _type,
                            position: _position,
                            distanceM: distanceM,
                            shots: shots,
                            target: _targetController.text.trim().isEmpty
                                ? null
                                : _targetController.text.trim(),
                            weaponFrom:
                                _weaponFromController.text.trim().isEmpty
                                    ? null
                                    : _weaponFromController.text.trim(),
                            weaponTo: _weaponToController.text.trim().isEmpty
                                ? null
                                : _weaponToController.text.trim(),
                            reloadType: _reloadType,
                            movementType: _movementType,
                            durationSeconds: durationSeconds,
                            trigger: _triggerController.text.trim().isEmpty
                                ? null
                                : _triggerController.text.trim(),
                            comment: _commentController.text.trim().isEmpty
                                ? null
                                : _commentController.text.trim(),
                          );

                          Navigator.of(context).pop(step);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                        ),
                        child: Text(
                          widget.initialStep == null
                              ? strings.exerciseActionAdd
                              : strings.exerciseActionSave,
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
    );
  }
}