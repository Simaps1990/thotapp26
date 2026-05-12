import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thot/data/thot_provider.dart';
import 'package:thot/data/models.dart';
import 'package:thot/theme.dart';
import 'package:thot/widgets/cross_platform_image.dart';
import 'package:thot/l10n/app_strings.dart';
import 'package:thot/widgets/tutorial_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _inventoryHeroAsset(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? 'assets/images/paneln.webp' : 'assets/images/panel.webp';
}

class InventoryScreen extends StatefulWidget {
  final int initialIndex;

  const InventoryScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _compactInventoryView = false;
  final GlobalKey _menuSearchKey = GlobalKey();
  OverlayEntry? _tutorialOverlayEntry;
  static const _tutorialNeverShowAgainKey =
      'inventory_tutorial_never_show_again_v1';
  bool _tutorialDismissedThisSession = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      initialIndex: widget.initialIndex,
      vsync: this,
    );
    _tabController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowTutorial();
    });
  }

  Future<void> _checkAndShowTutorial() async {
    if (_tutorialDismissedThisSession) return;
    final prefs = await SharedPreferences.getInstance();
    final neverShowAgain = prefs.getBool(_tutorialNeverShowAgainKey) ?? false;
    if (!neverShowAgain && mounted && _tutorialOverlayEntry == null) {
      _showTutorial();
    }
  }

  void _showTutorial() {
    final strings = AppStrings.of(context);
    final steps = [
      TutorialStep(
        targetKey: _menuSearchKey,
        title: strings.tutorialInventoryMenuSearchTitle,
        description: strings.tutorialInventoryMenuSearchDescription,
      ),
    ];

    _tutorialOverlayEntry = OverlayEntry(
      builder: (_) => TutorialOverlay(
        steps: steps,
        onComplete: () {
          _hideTutorial();
        },
        onSkip: () {
          _hideTutorial();
        },
        onNeverShowAgain: () async {
          _hideTutorial();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_tutorialNeverShowAgainKey, true);
        },
      ),
    );

    final rootOverlay = Overlay.of(context, rootOverlay: true);
    if (rootOverlay == null) return;
    rootOverlay.insert(_tutorialOverlayEntry!);
  }

  void _hideTutorial() {
    _tutorialOverlayEntry?.remove();
    _tutorialOverlayEntry = null;
    _tutorialDismissedThisSession = true;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _tutorialOverlayEntry?.remove();
    super.dispose();
  }

  String get _currentTabLabel {
    final strings = AppStrings.of(context);
    switch (_tabController.index) {
      case 0:
        return strings.addPlatform;
      case 1:
        return strings.addAmmo;
      case 2:
        return strings.addAccessory;
      default:
        return strings.addEquipment;
    }
  }

  String get _currentTabType {
    switch (_tabController.index) {
      case 0:
        return "PLATEFORME";
      case 1:
        return "CONSOMMABLE";
      case 2:
        return "ACCESSOIRE";
      default:
        return "PLATEFORME";
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    final provider = Provider.of<ThotProvider>(context);
    const heroHeight = 208.0;
    const panelTop = 120.0;
    const panelHeight = 140.0;
    // Fond global (même que la home) pour la page et le bandeau.
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;
    // Légère variation plus foncée que le fond global pour les champs de recherche.
    final searchFillColor = Color.alphaBlend(
      colors.outline.withValues(alpha: 0.8),
      baseBackground,
    );

    final canAddCurrent = switch (_currentTabType) {
      'PLATEFORME' => provider.canAddPlatform(),
      'CONSOMMABLE' => provider.canAddAmmo(),
      'ACCESSOIRE' => provider.canAddAccessory(),
      _ => true,
    };

    return Scaffold(
      backgroundColor: baseBackground,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final allowed = switch (_currentTabType) {
            'PLATEFORME' => provider.canAddPlatform(),
            'CONSOMMABLE' => provider.canAddAmmo(),
            'ACCESSOIRE' => provider.canAddAccessory(),
            _ => true,
          };

          if (!allowed) {
            final typeKey = switch (_currentTabType) {
              'PLATEFORME' => 'platform',
              'CONSOMMABLE' => 'ammo',
              'ACCESSOIRE' => 'accessory',
              _ => 'platform',
            };
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(provider.getLimitMessage(typeKey)),
                duration: const Duration(seconds: 3),
              ),
            );
            context.push('/pro');
            return;
          }

          context.push('/inventory/add?itemType=$_currentTabType');
        },
        icon: const Icon(Icons.add),
        label: canAddCurrent
            ? Text(
                _currentTabLabel,
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
                      _currentTabLabel,
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
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        backgroundColor: canAddCurrent ? colors.primary : colors.surface,
        foregroundColor: canAddCurrent ? colors.onPrimary : colors.secondary,
      ),
      body: SafeArea(
        top: false, // laisse l'image héro monter sous la status bar
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
                          _inventoryHeroAsset(context),
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
                      strings.inventorySubtitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                  Positioned(
                    left: 0,
                    right: 0,
                    top: panelTop,
                    child: Container(
                      decoration: BoxDecoration(
                        // Même couleur que le fond global pour le bandeau haut.
                        color: baseBackground,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            key: _menuSearchKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    AppSpacing.lg,
                                    20,
                                    AppSpacing.lg,
                                    10,
                                  ),
                                  child: _SlidingSegmentedSelector(
                                    selectedIndex: _tabController.index,
                                    labels: [
                                      strings.platformsTab,
                                      strings.ammosTab,
                                      strings.accessoriesTab,
                                    ],
                                    onSelected: (index) {
                                      _tabController.animateTo(index);
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontSize: 14),
                                    onChanged: (value) {
                                      setState(() => _searchQuery = value);
                                    },
                                    decoration: InputDecoration(
                                      hintText: strings.searchInventoryHint,
                                      hintStyle: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            fontSize: 14,
                                            color: colors.secondary,
                                          ),
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        size: 20,
                                      ),
                                      prefixIconConstraints:
                                          const BoxConstraints(
                                            minWidth: 40,
                                            minHeight: 40,
                                          ),
                                      suffixIcon: _searchQuery.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(
                                                Icons.clear,
                                                size: 18,
                                              ),
                                              splashRadius: 18,
                                              onPressed: () {
                                                _searchController.clear();
                                                setState(
                                                  () => _searchQuery = '',
                                                );
                                              },
                                            )
                                          : null,
                                      suffixIconConstraints:
                                          const BoxConstraints(
                                            minWidth: 40,
                                            minHeight: 40,
                                          ),
                                      filled: true,
                                      fillColor: searchFillColor,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: colors.outline,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: colors.outline,
                                        ),
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
                  ),
                ],
              ),
            ),
            Expanded(
              child: ColoredBox(
                color: baseBackground,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _InventoryList(
                      type: 'platform',
                      provider: provider,
                      searchQuery: _searchQuery,
                      compactView: _compactInventoryView,
                      onToggleCompactView: () {
                        setState(
                          () => _compactInventoryView = !_compactInventoryView,
                        );
                      },
                    ),
                    _InventoryList(
                      type: 'ammo',
                      provider: provider,
                      searchQuery: _searchQuery,
                      compactView: _compactInventoryView,
                      onToggleCompactView: () {
                        setState(
                          () => _compactInventoryView = !_compactInventoryView,
                        );
                      },
                    ),
                    _InventoryList(
                      type: 'accessory',
                      provider: provider,
                      searchQuery: _searchQuery,
                      compactView: _compactInventoryView,
                      onToggleCompactView: () {
                        setState(
                          () => _compactInventoryView = !_compactInventoryView,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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

class _InventoryList extends StatelessWidget {
  final String type;
  final ThotProvider provider;
  final String searchQuery;
  final bool compactView;
  final VoidCallback onToggleCompactView;

  const _InventoryList({
    required this.type,
    required this.provider,
    required this.searchQuery,
    required this.compactView,
    required this.onToggleCompactView,
  });
  String _formatLastUse(DateTime? lastUsed) {
    if (lastUsed == null) return '—';

    final days = DateTime.now().difference(lastUsed).inDays;
    if (days <= 0) return 'Aujourd’hui';
    if (days == 1) return 'Hier';
    return '$days j';
  }

  bool _isInactive(DateTime? lastUsed) {
    if (lastUsed == null) return false;
    return DateTime.now().difference(lastUsed).inDays >= 90;
  }

  Color _typeAccentColor(String type) {
    switch (type) {
      case 'platform':
        return const Color(0xFF6F7F4F);
      case 'ammo':
        return const Color(0xFFC9852B);
      case 'accessory':
      default:
        return const Color(0xFF4E7896);
    }
  }

  List<_InventoryStatusBadge> _platformBadges(Platform platform) {
    final badges = <_InventoryStatusBadge>[];

    if (platform.trackCleanliness && platform.cleaningProgress >= 0.8) {
      badges.add(
        const _InventoryStatusBadge(
          label: 'Nettoyage bientôt',
          color: Color(0xFFC9852B),
          icon: Icons.cleaning_services_rounded,
        ),
      );
    }

    if (platform.trackWear && platform.revisionProgress >= 0.8) {
      badges.add(
        const _InventoryStatusBadge(
          label: 'Révision bientôt',
          color: Color(0xFFB14A3E),
          icon: Icons.build_rounded,
        ),
      );
    }

    if (_isInactive(platform.lastUsed)) {
      badges.add(
        const _InventoryStatusBadge(
          label: 'Inactif',
          color: Color(0xFF7C8794),
          icon: Icons.schedule_rounded,
        ),
      );
    }

    return badges;
  }

  List<_InventoryStatusBadge> _ammoBadges(Ammo ammo) {
    final badges = <_InventoryStatusBadge>[];

    if (ammo.quantity <= ammo.lowStockThreshold) {
      badges.add(
        const _InventoryStatusBadge(
          label: 'Stock bas',
          color: Color(0xFFC9852B),
          icon: Icons.inventory_2_rounded,
        ),
      );
    }

    if (_isInactive(ammo.lastUsed)) {
      badges.add(
        const _InventoryStatusBadge(
          label: 'Inactif',
          color: Color(0xFF7C8794),
          icon: Icons.schedule_rounded,
        ),
      );
    }

    return badges;
  }

  List<_InventoryStatusBadge> _accessoryBadges(Accessory accessory) {
    final badges = <_InventoryStatusBadge>[];

    if (accessory.trackCleanliness && accessory.cleaningProgress >= 0.8) {
      badges.add(
        const _InventoryStatusBadge(
          label: 'Nettoyage bientôt',
          color: Color(0xFFC9852B),
          icon: Icons.cleaning_services_rounded,
        ),
      );
    }

    if (accessory.trackWear && accessory.revisionProgress >= 0.8) {
      badges.add(
        const _InventoryStatusBadge(
          label: 'Révision bientôt',
          color: Color(0xFFB14A3E),
          icon: Icons.build_rounded,
        ),
      );
    }

    if (_isInactive(accessory.lastUsed)) {
      badges.add(
        const _InventoryStatusBadge(
          label: 'Inactif',
          color: Color(0xFF7C8794),
          icon: Icons.schedule_rounded,
        ),
      );
    }

    return badges;
  }

  // Fonction pour retirer les accents et passer en minuscules
  String _normalize(String str) {
    const withDia =
        'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    const withoutDia =
        'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';

    String normalized = str.toLowerCase();
    for (int i = 0; i < withDia.length; i++) {
      normalized = normalized.replaceAll(
        withDia[i].toLowerCase(),
        withoutDia[i].toLowerCase(),
      );
    }
    return normalized;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    // Determine base list based on type
    final items = type == 'platform'
        ? provider.platforms
        : type == 'ammo'
        ? provider.ammos
        : provider.accessories;

    final q = _normalize(searchQuery.trim());

    final filtered = q.isEmpty
        ? items
        : items.where((item) {
            if (type == 'platform') {
              // Search only in platform fields
              final w = item as Platform;
              return (_normalize(w.name).contains(q) ||
                  _normalize(w.model).contains(q) ||
                  _normalize(w.caliber).contains(q) ||
                  _normalize(w.type).contains(q) ||
                  _normalize(w.comment).contains(q));
            } else if (type == 'ammo') {
              // Search only in ammo fields
              final a = item as Ammo;
              return (_normalize(a.name).contains(q) ||
                  _normalize(a.brand).contains(q) ||
                  _normalize(a.caliber).contains(q) ||
                  _normalize(a.projectileType).contains(q) ||
                  _normalize(a.comment).contains(q));
            } else {
              // Accessory: name/model/brand/type/comment
              final ac = item as Accessory;
              return (_normalize(ac.name).contains(q) ||
                  _normalize(ac.model).contains(q) ||
                  _normalize(ac.brand).contains(q) ||
                  _normalize(ac.type).contains(q) ||
                  _normalize(ac.comment).contains(q));
            }
          }).toList();

    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    if (filtered.isEmpty) {
      Widget iconWidget;
      String titleText;
      String subtitleText;

      if (type == 'platform') {
        iconWidget = SvgPicture.asset(
          'assets/images/tube.svg',
          width: 64,
          height: 64,
          colorFilter: ColorFilter.mode(
            colors.secondary.withValues(alpha: 0.5),
            BlendMode.srcIn,
          ),
        );
        titleText = strings.noPlatformFound;
        subtitleText = strings.addFirstPlatform;
      } else if (type == 'ammo') {
        iconWidget = SvgPicture.asset(
          'assets/images/pointe.svg',
          width: 64,
          height: 64,
          colorFilter: ColorFilter.mode(
            colors.secondary.withValues(alpha: 0.5),
            BlendMode.srcIn,
          ),
        );
        titleText = strings.noAmmoFound;
        subtitleText = strings.addFirstAmmo;
      } else {
        iconWidget = Icon(
          Icons.inventory_2_rounded,
          size: 64,
          color: colors.secondary.withValues(alpha: 0.5),
        );
        titleText = strings.noAccessoryFound;
        subtitleText = strings.addFirstAccessory;
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const Gap(AppSpacing.md),
            Text(
              titleText,
              style: textStyles.titleMedium?.copyWith(color: colors.secondary),
            ),
            const Gap(AppSpacing.sm),
            Text(
              subtitleText,
              style: textStyles.bodyMedium?.copyWith(color: colors.secondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      itemCount: filtered.length + 1,
      separatorBuilder: (_, __) => const Gap(16),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onToggleCompactView,
              icon: Icon(
                compactView
                    ? Icons.view_agenda_rounded
                    : Icons.view_compact_rounded,
                size: 18,
              ),
              label: Text(compactView ? 'Vue détaillée' : 'Vue compacte'),
            ),
          );
        }

        final itemIndex = index - 1;
        if (type == 'platform') {
          final w = filtered[itemIndex] as Platform;
          final originalIndex = provider.platforms.indexOf(w);
          final isLocked = provider.isPlatformLockedForFree(w, originalIndex);
          return _InventoryCard(
            itemId: w.id,
            title: w.name,
            subtitle: "${w.model} • ${w.caliber}",
            statLabel: strings.shotsFired,
            statValue: "${w.totalRounds}",
            // Show the localized platform type in the grey badge (top-right).
            category: strings.itemPlatformTypeLabel(w.type),
            isLow: false,
            lastUse: _formatLastUse(w.lastUsed),
            badges: _platformBadges(w),
            typeAccentColor: _typeAccentColor('platform'),
            compactView: compactView,
            svgIconAsset: 'assets/images/tube.svg',
            icon: Icons.security_rounded,
            photoPath: w.photoPath,
            isLocked: isLocked,
            onEdit: () => _showEditDialog(context, 'platform', w),
            onDelete: () =>
                _showDeleteConfirmation(context, 'platform', w.id, w.name),
            onDuplicate: () {
              final duplicated = provider.duplicatePlatform(w);
              if (!duplicated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.getLimitMessage('platform')),
                    duration: const Duration(seconds: 3),
                  ),
                );
                context.push('/pro');
              }
            },
          );
        } else if (type == 'ammo') {
          final a = filtered[itemIndex] as Ammo;
          final originalIndex = provider.ammos.indexOf(a);
          final isLocked = provider.isAmmoLockedForFree(a, originalIndex);
          return _InventoryCard(
            itemId: a.id,
            title: a.name,
            subtitle: "${a.brand} • ${a.caliber}",
            statLabel: strings.stock,
            statValue: "${a.quantity}",
            // Show projectile type in the grey badge (top-right).
            category: a.projectileType.isNotEmpty
                ? a.projectileType
                : 'Consommable',
            isLow: a.quantity < 100,
            lastUse: _formatLastUse(a.lastUsed),
            badges: _ammoBadges(a),
            typeAccentColor: _typeAccentColor('ammo'),
            compactView: compactView,
            svgIconAsset: 'assets/images/pointe.svg',
            icon: Icons.inventory_2_rounded,
            photoPath: a.photoPath,
            isLocked: isLocked,
            onEdit: () => _showEditDialog(context, 'ammo', a),
            onDelete: () =>
                _showDeleteConfirmation(context, 'ammo', a.id, a.name),
            onDuplicate: () {
              final duplicated = provider.duplicateAmmo(a);
              if (!duplicated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.getLimitMessage('ammo')),
                    duration: const Duration(seconds: 3),
                  ),
                );
                context.push('/pro');
              }
            },
          );
        } else {
          final ac = filtered[itemIndex] as Accessory;
          final originalIndex = provider.accessories.indexOf(ac);
          final isLocked = provider.isAccessoryLockedForFree(ac, originalIndex);
          return _InventoryCard(
            itemId: ac.id,
            // Accessory header: first line = model, second line = brand.
            // Fallbacks:
            // - if model empty, use name (legacy composed display) as title
            // - if brand empty, show type as subtitle
            title: ac.model.isNotEmpty ? ac.model : ac.name,
            subtitle: ac.brand.isNotEmpty
                ? ac.brand
                : (ac.type.isNotEmpty ? ac.type : ''),
            statLabel: strings.shotsFired,
            statValue: "${ac.totalRounds}",
            // Show the localized accessory type in the grey badge (top-right).
            category: strings.itemAccessoryTypeLabel(ac.type),
            // Accessories should not appear as critical indicators.
            isLow: false,
            lastUse: _formatLastUse(ac.lastUsed),
            badges: _accessoryBadges(ac),
            typeAccentColor: _typeAccentColor('accessory'),
            compactView: compactView,
            icon: Icons.inventory_2_rounded,
            photoPath: ac.photoPath,
            isLocked: isLocked,
            onEdit: () => _showEditDialog(context, 'accessory', ac),
            onDelete: () =>
                _showDeleteConfirmation(context, 'accessory', ac.id, ac.name),
            onDuplicate: () {
              final duplicated = provider.duplicateAccessory(ac);
              if (!duplicated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(provider.getLimitMessage('accessory')),
                    duration: const Duration(seconds: 3),
                  ),
                );
                context.push('/pro');
              }
            },
          );
        }
      },
    );
  }

  void _showEditDialog(BuildContext context, String type, dynamic item) {
    final typeMap = {
      'platform': 'PLATEFORME',
      'ammo': 'CONSOMMABLE',
      'accessory': 'ACCESSOIRE',
    };
    context.push('/inventory/add?itemId=${item.id}&itemType=${typeMap[type]}');
  }

  void _showDeleteConfirmation(
    BuildContext context,
    String type,
    String id,
    String name,
  ) {
    final strings = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.confirmDeletion),
        content: Text(
          strings.deleteConfirmationMessage.replaceAll('{name}', name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () {
              final provider = Provider.of<ThotProvider>(
                context,
                listen: false,
              );
              if (type == 'platform') {
                provider.deletePlatform(id);
              } else if (type == 'ammo') {
                provider.deleteAmmo(id);
              } else {
                provider.deleteAccessory(id);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    strings.deletedSnack.replaceAll('{name}', name),
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(strings.delete),
          ),
        ],
      ),
    );
  }
}

class _InventoryCard extends StatelessWidget {
  final String itemId;
  final String title;
  final String subtitle;
  final String statLabel;
  final String statValue;
  final String category;
  final bool isLow;
  final String lastUse;
  final List<_InventoryStatusBadge> badges;
  final Color typeAccentColor;
  final bool compactView;
  final String? svgIconAsset;
  final IconData icon;
  final String? photoPath;
  final bool isLocked;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  const _InventoryCard({
    required this.itemId,
    required this.title,
    required this.subtitle,
    required this.statLabel,
    required this.statValue,
    required this.category,
    required this.isLow,
    required this.lastUse,
    required this.badges,
    required this.typeAccentColor,
    required this.compactView,
    this.svgIconAsset,
    required this.icon,
    this.photoPath,
    required this.isLocked,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLocked
            ? () => context.push('/pro')
            : () => context.push('/inventory/detail/$itemId'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: compactView
              ? const EdgeInsets.all(12)
              : AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? colors.outline : LightColors.surfaceHighlight,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: compactView ? 48 : 60,
                      height: compactView ? 48 : 60,
                      decoration: BoxDecoration(
                        color: typeAccentColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: photoPath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CrossPlatformImage(
                                filePath: photoPath,
                                width: compactView ? 48 : 60,
                                height: compactView ? 48 : 60,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: svgIconAsset != null
                                  ? SvgPicture.asset(
                                      svgIconAsset!,
                                      width: compactView ? 40 : 52,
                                      height: compactView ? 40 : 52,
                                      colorFilter: ColorFilter.mode(
                                        typeAccentColor,
                                        BlendMode.srcIn,
                                      ),
                                    )
                                  : Icon(
                                      icon,
                                      size: compactView ? 40 : 52,
                                      color: typeAccentColor,
                                    ),
                            ),
                    ),
                    const Gap(AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: textStyles.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Gap(8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  category,
                                  style: textStyles.labelSmall?.copyWith(
                                    color: colors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            subtitle,
                            style: textStyles.bodySmall?.copyWith(
                              color: colors.secondary,
                            ),
                            maxLines: compactView ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (!compactView && badges.isNotEmpty) ...[
                            const Gap(8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: badges
                                  .map(
                                    (badge) => _StatusBadgeChip(badge: badge),
                                  )
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                if (!compactView) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                statLabel,
                                style: textStyles.labelSmall?.copyWith(
                                  color: colors.secondary,
                                ),
                              ),
                              Text(
                                statValue,
                                style: textStyles.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isLow
                                      ? colors.error
                                      : colors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const Gap(24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.lastSession,
                                style: textStyles.labelSmall?.copyWith(
                                  color: colors.secondary,
                                ),
                              ),
                              Text(
                                lastUse,
                                style: textStyles.bodyMedium?.copyWith(
                                  color: colors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      _InventoryCardMenu(
                        isLocked: isLocked,
                        onEdit: onEdit,
                        onDelete: onDelete,
                        onDuplicate: onDuplicate,
                      ),
                    ],
                  ),
                ],

                if (compactView) ...[
                  const Gap(8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (badges.isNotEmpty)
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: badges
                                .take(2)
                                .map((badge) => _StatusBadgeChip(badge: badge))
                                .toList(),
                          ),
                        )
                      else
                        Expanded(
                          child: Text(
                            '$statLabel : $statValue',
                            style: textStyles.labelSmall?.copyWith(
                              color: isLow ? colors.error : colors.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      _InventoryCardMenu(
                        isLocked: isLocked,
                        onEdit: onEdit,
                        onDelete: onDelete,
                        onDuplicate: onDuplicate,
                      ),
                    ],
                  ),
                ],
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
            right: 10,
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
}

class _InventoryCardMenu extends StatelessWidget {
  final bool isLocked;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  const _InventoryCardMenu({
    required this.isLocked,
    required this.onEdit,
    required this.onDelete,
    required this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final colors = Theme.of(context).colorScheme;

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: colors.onSurface),
      onSelected: (value) {
        if (value == 'delete') {
          onDelete();
          return;
        }

        if (isLocked) {
          context.push('/pro');
          return;
        }

        if (value == 'edit') {
          onEdit();
        } else if (value == 'duplicate') {
          onDuplicate();
        }
      },
      itemBuilder: (context) {
        if (isLocked) {
          return [
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete_rounded, size: 20),
                  const Gap(12),
                  Text(strings.delete),
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
                Text(strings.edit),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'duplicate',
            child: Row(
              children: [
                const Icon(Icons.content_copy_rounded, size: 20),
                const Gap(12),
                Text(strings.duplicate),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'delete',
            child: Row(
              children: [
                const Icon(Icons.delete_rounded, size: 20),
                const Gap(12),
                Text(strings.delete),
              ],
            ),
          ),
        ];
      },
    );
  }
}

class _InventoryStatusBadge {
  final String label;
  final Color color;
  final IconData icon;

  const _InventoryStatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });
}

class _StatusBadgeChip extends StatelessWidget {
  final _InventoryStatusBadge badge;

  const _StatusBadgeChip({required this.badge});

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badge.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: badge.color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badge.icon, size: 13, color: badge.color),
          const Gap(4),
          Text(
            badge.label,
            style: textStyles.labelSmall?.copyWith(
              color: badge.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
