import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thot/data/thot_provider.dart';
import 'package:thot/theme.dart';
import 'package:thot/l10n/app_strings.dart';

void showProModal(BuildContext context) {
  context.push('/pro');
}

class ProScreen extends StatelessWidget {
  const ProScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThotProvider>();
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProHeroCard(
          isPro: provider.isPremium,
        ),
        const Gap(AppSpacing.lg),
        Text(
          strings.benefits,
          style: textStyles.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.secondary,
          ),
        ),
        const Gap(AppSpacing.sm),
        _ProBenefitsCard(
          benefits: [
            _ProBenefitData(
              icon: Icon(
Icons.all_inclusive_rounded,
                color: colors.primary,
                size: 22,
              ),
              title: strings.proBenefitUnlimitedSessionsTitle,
              subtitle: strings.proBenefitUnlimitedSessionsSubtitle,
            ),

            _ProBenefitData(
              icon: Icon(
                Icons.timer_rounded,
                color: colors.primary,
                size: 22,
              ),
              title: strings.proBenefitTimerTitle,
              subtitle: strings.proBenefitTimerSubtitle,
            ),
            _ProBenefitData(
              icon: Icon(
                Icons.report_problem_rounded,
                color: colors.primary,
                size: 22,
              ),
              title: strings.proBenefitDiagnosticTitle,
              subtitle: strings.proBenefitDiagnosticSubtitle,
            ),
            _ProBenefitData(
              icon: Icon(
                Icons.straighten_rounded,
                color: colors.primary,
                size: 22,
              ),
              title: strings.proBenefitMilliemeTitle,
              subtitle: strings.proBenefitMilliemeSubtitle,
            ),
            _ProBenefitData(
              icon: Icon(
                Icons.picture_as_pdf_rounded,
                color: colors.primary,
                size: 22,
              ),
              title: strings.proBenefitLogbookExportTitle,
              subtitle: strings.proBenefitLogbookExportSubtitle,
            ),
            _ProBenefitData(
              icon: Icon(
                Icons.shield_rounded,
                color: colors.primary,
                size: 22,
              ),
              title: strings.proBenefitUnlimitedDocumentsTitle,
              subtitle: strings.proBenefitUnlimitedDocumentsSubtitle,
            ),
          ],
        ),
        const Gap(AppSpacing.lg),
        if (!provider.isPremium) ...[
          _ProOfferCards(
            onTapYearly: () async {
              if (!provider.purchaseAvailable) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Paiement indisponible pour le moment.'),
                    ),
                  );
                }
                return;
              }

              await provider.purchaseYearly();
              if (provider.isPremium && context.mounted) {
                context.pop();
              }
            },
            onTapMonthly: () async {
              if (!provider.purchaseAvailable) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Paiement indisponible pour le moment.'),
                    ),
                  );
                }
                return;
              }

              await provider.purchaseMonthly();
              if (provider.isPremium && context.mounted) {
                context.pop();
              }
            },
          ),
          const Gap(AppSpacing.md),
          Text(
            strings.proSubscriptionDisclaimer,
            style: textStyles.bodySmall?.copyWith(
              color: colors.secondary,
              height: 1.4,
            ),
          ),
        ] else ...[
          Container(
            padding: AppSpacing.paddingLg,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: colors.outline),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: colors.primary,
                ),
                const Gap(AppSpacing.md),
                Expanded(
                  child: Text(
                    strings.proActiveOnAccount,
                    style: textStyles.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final margin = AppSpacing.lg;
            final maxWidth =
                (constraints.maxWidth - margin * 2).clamp(0.0, constraints.maxWidth);
            final maxHeight = (constraints.maxHeight - margin * 2)
                .clamp(0.0, constraints.maxHeight);

            return Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: maxHeight,
                ),
                child: Material(
                  color: colors.surface,
                  elevation: 14,
                  borderRadius: BorderRadius.circular(24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: content,
                        ),
                        Positioned(
                          top: AppSpacing.md,
                          right: AppSpacing.md,
                          child: IconButton(
                            visualDensity: VisualDensity.compact,
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  colors.surface.withValues(alpha: 0.15),
                              foregroundColor:
                                  colors.onSurface.withValues(alpha: 0.85),
                            ),
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => context.pop(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProHeroCard extends StatelessWidget {
  final bool isPro;

  const _ProHeroCard({
    required this.isPro,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    return Stack(
      children: [
        Container(
          padding: AppSpacing.paddingLg,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF3F4A30),
                Color(0xFF6E7C4A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.onPrimary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: colors.onPrimary,
                  size: 28,
                ),
              ),
              const Gap(AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPro
                          ? strings.proHeroActiveTitle
                          : strings.proHeroUnlockTitle,
                      style: textStyles.titleLarge?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      isPro
                          ? strings.proHeroActiveSubtitle
                          : strings.proHeroUnlockSubtitle,
                      style: textStyles.bodyMedium?.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.90),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProOfferCards extends StatelessWidget {
  final VoidCallback onTapYearly;
  final VoidCallback onTapMonthly;

  const _ProOfferCards({
    required this.onTapYearly,
    required this.onTapMonthly,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final provider = context.watch<ThotProvider>();

    String _buildSubtitle({
      required String marketingLabel,
      required String? storePrice,
    }) {
      final hasStorePrice = storePrice != null && storePrice.trim().isNotEmpty;
      if (!hasStorePrice) {
        return marketingLabel;
      }
      final price = storePrice!.trim();
      return '$price — $marketingLabel';
    }

    final yearlySubtitle = _buildSubtitle(
      marketingLabel: strings.proYearlyOfferSubtitle,
      storePrice: provider.yearlyPrice,
    );

    final monthlySubtitle = _buildSubtitle(
      marketingLabel: strings.proMonthlyOfferSubtitle,
      storePrice: provider.monthlyPrice,
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _ProOfferCard(
              recommended: true,
              bestSeller: false,
              title: strings.proYearlyOfferTitle,
              subtitle: yearlySubtitle,
              icon: Icons.workspace_premium_rounded,
              primary: true,
              onTap: onTapYearly,
            ),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: _ProOfferCard(
              recommended: false,
              bestSeller: true,
              title: strings.proMonthlyOfferTitle,
              subtitle: monthlySubtitle,
              icon: Icons.calendar_month_rounded,
              primary: false,
              onTap: onTapMonthly,
            ),
          ),
        ],
      ),
    );
  }
}


class _ProOfferCard extends StatelessWidget {
  final bool recommended;
  final bool bestSeller;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;

  const _ProOfferCard({
    required this.recommended,
    required this.bestSeller,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textStyles = Theme.of(context).textTheme;
    final strings = AppStrings.of(context);

    final titleUpper = title.toUpperCase();
    final subtitleParts = subtitle.split('—');
    final priceLine =
        subtitleParts.isNotEmpty ? subtitleParts.first.trim() : subtitle;
    final commentLine = subtitleParts.length > 1
        ? subtitleParts.sublist(1).join('—').trim()
        : '';

    final isPrimary = primary;

    final textColor = isPrimary ? Colors.white : const Color(0xFF1F1D18);
    final mutedTextColor = isPrimary
        ? Colors.white.withValues(alpha: 0.88)
        : const Color(0xFF4E4A3F);
    final dividerColor = isPrimary
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.08);

    final badgeText = bestSeller
        ? 'BEST SELLER'
        : strings.proRecommendedBadge.toUpperCase();

    final badgeIcon = bestSeller
        ? Icons.calendar_month_rounded
        : Icons.workspace_premium_rounded;

    final gradient = isPrimary
        ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF445233),
              Color(0xFF5C6D44),
              Color(0xFF728454),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF1EBD3),
              Color(0xFFE4D9AF),
              Color(0xFFD6C98F),
            ],
          );

    final borderColor = isPrimary
        ? Colors.white.withValues(alpha: 0.10)
        : const Color(0xFFD7CC9F);

    final buttonBackground =
        isPrimary ? const Color(0xFFA3B168) : const Color(0xFF2A241F);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Ink(
decoration: BoxDecoration(
  borderRadius: BorderRadius.circular(26),
  gradient: gradient,
  border: Border.all(color: borderColor),
),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: isPrimary ? 0.95 : 0.80,
                      ),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.04),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          badgeIcon,
                          size: 12,
                          color: const Color(0xFF34536A),
                        ),
                        const Gap(4),
                        Text(
                          badgeText,
                          style: textStyles.labelSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            letterSpacing: 0.25,
                            color: const Color(0xFF34536A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Gap(14),
                Text(
                  titleUpper,
                  textAlign: TextAlign.center,
                  style: textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: (textStyles.titleMedium?.fontSize ?? 16) - 1,
                    color: textColor,
                    height: 1.0,
                    letterSpacing: 0.2,
                  ),
                ),
                const Gap(10),
                Container(
                  height: 1,
                  color: dividerColor,
                ),
                const Gap(10),
                Text(
                  priceLine,
                  textAlign: TextAlign.center,
                  style: textStyles.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    height: 1.0,
                  ),
                ),
                if (commentLine.isNotEmpty) ...[
                  const Gap(6),
                  Text(
                    commentLine,
                    textAlign: TextAlign.center,
                    style: textStyles.bodyMedium?.copyWith(
                      color: mutedTextColor,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    maxLines: 2,
                  ),
                ],

              ],
            ),
          ),
        ),
      ),
    );
  }
}



class _ProBenefitData {
  final Widget icon;
  final String title;
  final String subtitle;

  const _ProBenefitData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _ProBenefitsCard extends StatelessWidget {
  final List<_ProBenefitData> benefits;

  const _ProBenefitsCard({required this.benefits});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < benefits.length; i++)
            _ProBenefitRow(
              icon: benefits[i].icon,
              title: benefits[i].title,
              subtitle: benefits[i].subtitle,
              showDivider: i != benefits.length - 1,
            ),
        ],
      ),
    );
  }
}

class _ProBenefitRow extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final bool showDivider;

  const _ProBenefitRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textStyles = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(color: colors.outline),
              )
            : null,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Center(child: icon),
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textStyles.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(2),
                Text(
                  subtitle,
                  style: textStyles.bodySmall?.copyWith(
                    color: colors.secondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}