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

const _inventoryHeroAsset = 'assets/images/panel.webp';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, initialIndex: widget.initialIndex, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String get _currentTabLabel {
    final strings = AppStrings.of(context);
    switch (_tabController.index) {
      case 0:
        return strings.addWeapon;
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
        return "ARME";
      case 1:
        return "MUNITION";
      case 2:
        return "ACCESSOIRE";
      default:
        return "ARME";
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
    final subtleBorderColor = colors.outline.withValues(alpha: 0.45);
    // Fond global (même que la home) pour la page et le bandeau.
    final baseBackground = Theme.of(context).scaffoldBackgroundColor;
    // Légère variation plus foncée que le fond global pour les champs de recherche.
    final searchFillColor = Color.alphaBlend(
      colors.outline.withValues(alpha: 0.8),
      baseBackground,
    );

    final canAddCurrent = switch (_currentTabType) {
      'ARME' => provider.canAddWeapon(),
      'MUNITION' => provider.canAddAmmo(),
      'ACCESSOIRE' => provider.canAddAccessory(),
      _ => true,
    };

    return Scaffold(
      backgroundColor: baseBackground,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final allowed = switch (_currentTabType) {
            'ARME' => provider.canAddWeapon(),
            'MUNITION' => provider.canAddAmmo(),
            'ACCESSOIRE' => provider.canAddAccessory(),
            _ => true,
          };

          if (!allowed) {
            final typeKey = switch (_currentTabType) {
              'ARME' => 'weapon',
              'MUNITION' => 'ammo',
              'ACCESSOIRE' => 'accessory',
              _ => 'weapon',
            };
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(provider.getLimitMessage(typeKey))),
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
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
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
                        _inventoryHeroAsset,
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
                      color: baseBackground,
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
                            selectedIndex: _tabController.index,
                            labels: [
                              strings.weaponsTab,
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
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 14,
                                ),
                            onChanged: (value) {
                              setState(() => _searchQuery = value);
                            },
                            decoration: InputDecoration(
                              hintText: strings.searchInventoryHint,
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
                color: baseBackground,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _InventoryList(type: 'weapon', provider: provider, searchQuery: _searchQuery),
                    _InventoryList(type: 'ammo', provider: provider, searchQuery: _searchQuery),
                    _InventoryList(type: 'accessory', provider: provider, searchQuery: _searchQuery),
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

class _InventoryList extends StatelessWidget {
  final String type;
  final ThotProvider provider;
  final String searchQuery;

  const _InventoryList({required this.type, required this.provider, required this.searchQuery});

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

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    // Determine base list based on type
    final items = type == 'weapon'
        ? provider.weapons
        : type == 'ammo'
            ? provider.ammos
            : provider.accessories;
    
    final q = _normalize(searchQuery.trim());
    
    final filtered = q.isEmpty
        ? items
        : items.where((item) {
            if (type == 'weapon') {
              // Search only in weapon fields
              final w = item as Weapon;
              return (
                    _normalize(w.name).contains(q) ||
                    _normalize(w.model).contains(q) ||
                    _normalize(w.caliber).contains(q) ||
                    _normalize(w.type).contains(q) ||
                    _normalize(w.comment).contains(q)
                  );
            } else if (type == 'ammo') {
              // Search only in ammo fields
              final a = item as Ammo;
              return (
                    _normalize(a.name).contains(q) ||
                    _normalize(a.brand).contains(q) ||
                    _normalize(a.caliber).contains(q) ||
                    _normalize(a.projectileType).contains(q) ||
                    _normalize(a.comment).contains(q)
                  );
            } else {
              // Accessory: name/model/brand/type/comment
              final ac = item as Accessory;
              return (
                    _normalize(ac.name).contains(q) ||
                    _normalize(ac.model).contains(q) ||
                    _normalize(ac.brand).contains(q) ||
                    _normalize(ac.type).contains(q) ||
                    _normalize(ac.comment).contains(q)
                  );
            }
          }).toList();
            
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    if (filtered.isEmpty) {
      Widget iconWidget;
      String titleText;
      String subtitleText;

      if (type == 'weapon') {
        iconWidget = SvgPicture.asset(
          'assets/images/gun.svg',
          width: 64,
          height: 64,
          colorFilter: ColorFilter.mode(colors.secondary.withValues(alpha: 0.5), BlendMode.srcIn),
        );
        titleText = strings.noWeaponFound;
        subtitleText = strings.addFirstWeapon;
      } else if (type == 'ammo') {
        iconWidget = SvgPicture.asset(
          'assets/images/bullet.svg',
          width: 64,
          height: 64,
          colorFilter: ColorFilter.mode(colors.secondary.withValues(alpha: 0.5), BlendMode.srcIn),
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
              style: textStyles.titleMedium?.copyWith(
                color: colors.secondary,
              ),
            ),
            const Gap(AppSpacing.sm),
            Text(
              subtitleText,
              style: textStyles.bodyMedium?.copyWith(
                color: colors.secondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const Gap(16),
      itemBuilder: (context, index) {
        if (type == 'weapon') {
          final w = filtered[index] as Weapon;
          final originalIndex = provider.weapons.indexOf(w);
          final isLocked = provider.isWeaponLockedForFree(w, originalIndex);
          return _InventoryCard(
            itemId: w.id,
            title: w.name,
            subtitle: "${w.model} • ${w.caliber}",
            statLabel: strings.shotsFired,
            statValue: "${w.totalRounds}",
            // Show the localized weapon type in the grey badge (top-right).
            category: strings.itemWeaponTypeLabel(w.type),
            isLow: false,
            lastUse: strings.yesterday,
            svgIconAsset: 'assets/images/gun.svg',
            icon: Icons.security_rounded,
            photoPath: w.photoPath,
            isLocked: isLocked,
            onEdit: () => _showEditDialog(context, 'weapon', w),
            onDelete: () =>
                _showDeleteConfirmation(context, 'weapon', w.id, w.name),
            onDuplicate: () {
              final duplicated = provider.duplicateWeapon(w);
              if (!duplicated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(provider.getLimitMessage('weapon'))),
                );
                context.push('/pro');
              }
            },
          );
        } else if (type == 'ammo') {
          final a = filtered[index] as Ammo;
          final originalIndex = provider.ammos.indexOf(a);
          final isLocked = provider.isAmmoLockedForFree(a, originalIndex);
          return _InventoryCard(
            itemId: a.id,
            title: a.name,
            subtitle: "${a.brand} • ${a.caliber}",
            statLabel: strings.stock,
            statValue: "${a.quantity}",
            // Show projectile type in the grey badge (top-right).
            category: a.projectileType.isNotEmpty ? a.projectileType : 'Munition',
            isLow: a.quantity < 100,
            lastUse: strings.yesterday,
            svgIconAsset: 'assets/images/bullet.svg',
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
                  SnackBar(content: Text(provider.getLimitMessage('ammo'))),
                );
                context.push('/pro');
              }
            },
          );
        } else {
          final ac = filtered[index] as Accessory;
          final originalIndex = provider.accessories.indexOf(ac);
          final isLocked = provider.isAccessoryLockedForFree(ac, originalIndex);
          return _InventoryCard(
            itemId: ac.id,
            // Accessory header: first line = model, second line = brand.
            // Fallbacks:
            // - if model empty, use name (legacy composed display) as title
            // - if brand empty, show type as subtitle
            title: ac.model.isNotEmpty ? ac.model : ac.name,
            subtitle:
                ac.brand.isNotEmpty ? ac.brand : (ac.type.isNotEmpty ? ac.type : ''),
            statLabel: strings.shotsFired,
            statValue: "${ac.totalRounds}",
            // Show the localized accessory type in the grey badge (top-right).
            category: strings.itemAccessoryTypeLabel(ac.type),
            // Accessories should not appear as critical indicators.
            isLow: false,
            lastUse: strings.yesterday,
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
                  SnackBar(content: Text(provider.getLimitMessage('accessory'))),
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
      'weapon': 'ARME',
      'ammo': 'MUNITION',
      'accessory': 'ACCESSOIRE',
    };
    context.push('/inventory/add?itemId=${item.id}&itemType=${typeMap[type]}');
  }

  void _showDeleteConfirmation(
      BuildContext context, String type, String id, String name) {
    final strings = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.confirmDeletion),
        content: Text(strings.deleteConfirmationMessage.replaceAll('{name}', name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () {
              final provider =
                  Provider.of<ThotProvider>(context, listen: false);
              if (type == 'weapon') {
                provider.deleteWeapon(id);
              } else if (type == 'ammo') {
                provider.deleteAmmo(id);
              } else {
                provider.deleteAccessory(id);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(strings.deletedSnack.replaceAll('{name}', name))),
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
          padding: AppSpacing.paddingMd,
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
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: photoPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: CrossPlatformImage(
                              filePath: photoPath,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Center(
                            child: svgIconAsset != null
                                ? SvgPicture.asset(
                                    svgIconAsset!,
                                    width: 52,
                                    height: 52,
                                    colorFilter: ColorFilter.mode(
                                      colors.secondary,
                                      BlendMode.srcIn,
                                    ),
                                  )
                                : Icon(
                                    icon,
                                    size: 52,
                                    color: colors.secondary,
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
                              child: Text(title,
                                  style: textStyles.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colors.onSurface),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(category,
                                  style: textStyles.labelSmall
                                      ?.copyWith(color: colors.secondary)),
                            ),
                          ],
                        ),
                        Text(subtitle,
                            style: textStyles.bodySmall
                                ?.copyWith(color: colors.secondary)),
                      ],
                    ),
                  ),
                ],
              ),
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
                            style: textStyles.labelSmall
                                ?.copyWith(color: colors.secondary),
                          ),
                          Text(
                            statValue,
                            style: textStyles.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isLow ? colors.error : colors.onSurface,
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
                            style: textStyles.labelSmall
                                ?.copyWith(color: colors.secondary),
                          ),
                          Text(
                            lastUse,
                            style: textStyles.bodyMedium
                                ?.copyWith(color: colors.onSurface),
                          ),
                        ],
                      ),
                    ],
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert_rounded,
                      color: colors.onSurface,
                    ),
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
                                const Icon(Icons.delete_outline_rounded,
                                    size: 20),
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
                              const Icon(Icons.content_copy_rounded,
                                  size: 20),
                              const Gap(12),
                              Text(strings.duplicate),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline_rounded,
                                  size: 20),
                              const Gap(12),
                              Text(strings.delete),
                            ],
                          ),
                        ),
                      ];
                    },
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
            right: 10,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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