part of '../new_session_screen.dart';

class _SessionSummary extends StatelessWidget {
  final List<Exercise> exercises;
  final ThotProvider provider;

  const _SessionSummary({required this.exercises, required this.provider});

  String _getCurrencySymbol(String? currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'CAD':
        return 'CA\$';
      case 'GBP':
        return '£';
      case 'CHF':
        return 'CHF';
      case 'JPY':
        return '¥';
      case 'AUD':
        return 'A\$';
      case 'EUR':
      default:
        return '€';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    final totalShots = exercises.fold(0, (sum, ex) => sum + ex.shotsFired);

    // Impact on ammo (inventory only)
    final Map<String, int> ammoImpact = {};
    for (final ex in exercises) {
      ex.ammoShotImpact.forEach((ammoId, shots) {
        final ammo = provider.getAmmoById(ammoId);
        if (ammo == null) return;
        ammoImpact[ammo.id] = (ammoImpact[ammo.id] ?? 0) + shots;
      });
    }

    // Impact on platforms (inventory only)
    final Map<String, int> platformImpact = {};
    for (final ex in exercises) {
      ex.platformShotImpact.forEach((platformId, shots) {
        final platform = provider.getPlatformById(platformId);
        if (platform == null) return;
        platformImpact[platform.id] =
            (platformImpact[platform.id] ?? 0) + shots;
      });
    }

    // Impact on equipment
    final Map<String, int> equipmentImpact = {};
    for (final ex in exercises) {
      ex.equipmentShotImpact.forEach((equipmentId, shots) {
        equipmentImpact[equipmentId] =
            (equipmentImpact[equipmentId] ?? 0) + shots;
      });
    }

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.sessionSummaryTotalShots(totalShots),
            style: textStyles.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(AppSpacing.md),

          // Platforms impact
          if (platformImpact.isNotEmpty) ...[
            Text(
              strings.platformsUsedLabel,
              style: textStyles.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(4),
            ...platformImpact.entries.map((e) {
              final platform = provider.getPlatformById(e.key);
              if (platform == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  '• ${platform.name}: ${e.value} coups',
                  style: textStyles.bodySmall,
                ),
              );
            }),
            const Gap(AppSpacing.md),
          ],

          // Ammo impact
          if (ammoImpact.isNotEmpty) ...[
            Text(
              strings.consumablesUsedLabel,
              style: textStyles.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(4),
            ...ammoImpact.entries.map((e) {
              final ammo = provider.getAmmoById(e.key);
              if (ammo == null) return const SizedBox.shrink();
              final remaining = (ammo.quantity - e.value)
                  .clamp(0, 1 << 30)
                  .toInt();
              final lineCost = ammo.unitPrice != null
                  ? (e.value * ammo.unitPrice!).toStringAsFixed(2)
                  : null;
              final currencySymbol = _getCurrencySymbol(ammo.currency);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  lineCost == null
                      ? strings.sessionSummaryAmmoImpactLine(
                          ammo.name,
                          e.value,
                          remaining,
                        )
                      : strings.sessionSummaryAmmoImpactLineWithCost(
                          ammo.name,
                          e.value,
                          remaining,
                          lineCost,
                          currencySymbol,
                        ),
                  style: textStyles.bodySmall,
                ),
              );
            }),
            const Gap(AppSpacing.md),
          ],

          // Equipment impact
          if (equipmentImpact.isNotEmpty) ...[
            Text(
              strings.sessionSummaryAccessoriesImpactTitle,
              style: textStyles.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(4),
            ...equipmentImpact.entries.map((e) {
              final accessory = provider.accessories
                  .where((a) => a.id == e.key)
                  .firstOrNull;
              if (accessory == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  strings.sessionSummaryAccessoryImpactLine(
                    accessory.name,
                    e.value,
                  ),
                  style: textStyles.bodySmall,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

