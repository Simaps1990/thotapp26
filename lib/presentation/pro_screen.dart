import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:thot/data/thot_provider.dart';
import 'package:thot/theme.dart';
import 'package:thot/l10n/app_strings.dart';

void showProModal(BuildContext context) {
  // Always navigate to the Pro screen. The Pro screen itself decides
  // whether to display the paywall or the "already Pro" state based on
  // `provider.isPremium`. The freemium flag is enforced at the call sites
  // (every paywall-trigger call should be guarded by an `if (!isPremium)`
  // or an `isXLockedForFree` check).
  context.push('/pro');
}

class ProScreen extends StatefulWidget {
  const ProScreen({super.key});

  @override
  State<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen>
    with SingleTickerProviderStateMixin {
  /// false = mensuel sélectionné (défaut, conforme à la maquette : badge RECOMMANDÉ + trial)
  /// true  = annuel sélectionné
  bool _yearlySelected = false;

  bool _showCloseButton = false;
  late AnimationController _closeButtonAnimationController;
  late Animation<double> _closeButtonAnimation;

  @override
  void initState() {
    super.initState();
    _closeButtonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _closeButtonAnimation = CurvedAnimation(
      parent: _closeButtonAnimationController,
      curve: Curves.easeOut,
    );
    // Show close button after 7 seconds
    Future.delayed(const Duration(seconds: 7), () {
      if (mounted) {
        setState(() => _showCloseButton = true);
        _closeButtonAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _closeButtonAnimationController.dispose();
    super.dispose();
  }

  static final Uri _privacyUri = Uri.parse('https://thotbook.fr/privacy');
  static final Uri _cguUri = Uri.parse('https://thotbook.fr/cgu');

  // ── Couleurs paywall ───────────────────────────────────────────────────────
  static const _bgDark = Color(0xFF0E0F0A);
  static const _cardBg = Color(0xFF1A1C12);
  static const _cardBorder = Color(0xFF2D3320);
  static const _kakiOlive = LightColors.primary;
  static const _kakiOliveLight = Color(0xFFB8B07A);
  static const _creamWhite = Color(0xFFE5E0CD);
  static const _mutedText = Color(0xFFB5B097);

  Future<void> _openExternalLink(BuildContext context, Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _showPurchaseUnavailableSnackBar(BuildContext context) {
    final strings = AppStrings.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.proPurchaseUnavailable),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _restorePurchases(
    BuildContext context,
    ThotProvider provider,
  ) async {
    final strings = AppStrings.of(context);
    try {
      await provider.restorePurchases();
      if (!context.mounted) return;
      final message = provider.isPremium
          ? strings.proRestorePurchasesSuccess
          : strings.proRestorePurchasesNoActiveSubscription;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.proRestorePurchasesError),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleCta(BuildContext context, ThotProvider provider) async {
    if (!provider.purchaseAvailable) {
      _showPurchaseUnavailableSnackBar(context);
      return;
    }
    if (_yearlySelected) {
      await provider.purchaseYearly();
    } else {
      await provider.purchaseMonthly();
    }
    if (provider.isPremium && context.mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThotProvider>();
    final strings = AppStrings.of(context);
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _ProHeader(bgColor: _bgDark),

                Transform.translate(
                  offset: const Offset(0, -120),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: Column(
                          children: [
                            Text(
                              strings.proHeaderTagline,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _creamWhite.withValues(alpha: 0.92),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Gap(6),
                            _TrialBannerText(
                              rawText: strings.proTrialBanner,
                              normalColor: _creamWhite.withValues(alpha: 0.85),
                              emphasisColor: _kakiOliveLight,
                            ),
                            const Gap(AppSpacing.lg),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: _ProBenefitsCard(
                          bgColor: _cardBg,
                          borderColor: _cardBorder,
                          benefits: [
                            _ProBenefitData(
                              icon: const Icon(
                                Icons.all_inclusive,
                                color: _kakiOliveLight,
                                size: 22,
                              ),
                              title: strings.proBenefitCreateTitle,
                              subtitle: strings.proBenefitCreateSubtitle,
                            ),
                            _ProBenefitData(
                              icon: const Icon(
                                Icons.auto_fix_high_rounded,
                                color: _kakiOliveLight,
                                size: 22,
                              ),
                              title: strings.proBenefitToolsTitle,
                              subtitle: strings.proBenefitToolsSubtitle,
                            ),
                            _ProBenefitData(
                              icon: const Icon(
                                Icons.inventory_2_rounded,
                                color: _kakiOliveLight,
                                size: 22,
                              ),
                              title: strings.proBenefitStoreTitle,
                              subtitle: strings.proBenefitStoreSubtitle,
                            ),
                          ],
                        ),
                      ),

                      if (!provider.isPremium) ...[
                        const Gap(AppSpacing.lg),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          child: _ProOfferCardsRow(
                            yearlySelected: _yearlySelected,
                            onSelectMonthly: () =>
                                setState(() => _yearlySelected = false),
                            onSelectYearly: () =>
                                setState(() => _yearlySelected = true),
                            kakiOlive: _kakiOlive,
                            kakiOliveLight: _kakiOliveLight,
                            cardBg: _cardBg,
                            cardBorder: _cardBorder,
                            creamWhite: _creamWhite,
                            mutedText: _mutedText,
                          ),
                        ),

                        const Gap(AppSpacing.lg),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          child: _ProCtaButton(
                            label: _yearlySelected
                                ? strings.proSubscribeNowCta
                                : strings.proStartTrialCta,
                            onTap: () => _handleCta(context, provider),
                            kakiOlive: _kakiOlive,
                          ),
                        ),

                        const Gap(AppSpacing.sm),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          child: Text(
                            strings.proNoPaymentToday,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: _mutedText,
                              fontSize: 12.5,
                              height: 1.4,
                            ),
                          ),
                        ),

                        const Gap(AppSpacing.md),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          child: _ProFooterLinks(
                            onPrivacy: () =>
                                _openExternalLink(context, _privacyUri),
                            onTos: () => _openExternalLink(context, _cguUri),
                            onRestore: () =>
                                _restorePurchases(context, provider),
                            mutedText: _mutedText,
                            kakiOliveLight: _kakiOliveLight,
                          ),
                        ),

                        const Gap(AppSpacing.lg),
                      ] else ...[
                        const Gap(AppSpacing.lg),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          child: Container(
                            padding: AppSpacing.paddingLg,
                            decoration: BoxDecoration(
                              color: _cardBg,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: _cardBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.verified_rounded,
                                  color: _kakiOliveLight,
                                ),
                                const Gap(AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    strings.proActiveOnAccount,
                                    style: const TextStyle(
                                      color: _creamWhite,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Gap(AppSpacing.lg),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () =>
                                  _restorePurchases(context, provider),
                              icon: const Icon(
                                Icons.refresh_rounded,
                                color: _kakiOliveLight,
                              ),
                              label: Text(
                                strings.proRestorePurchases,
                                style: const TextStyle(color: _kakiOliveLight),
                              ),
                            ),
                          ),
                        ),

                        const Gap(AppSpacing.lg),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: topInset - 8,
            right: 8,
            child: FadeTransition(
              opacity: _closeButtonAnimation,
              child: Material(
                color: Colors.black.withValues(alpha: 0.35),
                shape: const CircleBorder(),
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  splashRadius: 22,
                  iconSize: 22,
                  color: Colors.white,
                  icon: const Icon(Icons.close_rounded),
                  tooltip: strings.close,
                  onPressed: () => context.pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER : image avec dégradé vers le fond
// ─────────────────────────────────────────────────────────────────────────────
class _ProHeader extends StatelessWidget {
  final Color bgColor;
  const _ProHeader({required this.bgColor});

  @override
  Widget build(BuildContext context) {
    final headerHeight = MediaQuery.of(context).size.height * 0.42;
    return SizedBox(
      width: double.infinity,
      height: headerHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/payment.webp',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            excludeFromSemantics: true,
            errorBuilder: (_, __, ___) => Container(color: bgColor),
          ),
          // Léger voile sombre uniforme (cohérence visuelle)
          Container(color: Colors.black.withValues(alpha: 0.10)),
          // Dégradé fade vers le bas pour fondre avec le fond de page
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  bgColor.withValues(alpha: 0.0),
                  bgColor.withValues(alpha: 0.55),
                  bgColor,
                ],
                stops: const [0.0, 0.50, 0.80, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TITRE BICOLORE THOT PRO
// ─────────────────────────────────────────────────────────────────────────────
class _ProTitleText extends StatelessWidget {
  const _ProTitleText();

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'THOT ',
            style: TextStyle(
              color: Color(0xFFE5E0CD),
              fontSize: 46,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
              height: 1.0,
            ),
          ),
          TextSpan(
            text: 'PRO',
            style: TextStyle(
              color: LightColors.primary,
              fontSize: 46,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BANNIÈRE D'ESSAI : "Essayez **gratuitement** pendant 3 jours"
// Parse les ** comme indicateurs d'emphase (couleur kaki light)
// ─────────────────────────────────────────────────────────────────────────────
class _TrialBannerText extends StatelessWidget {
  final String rawText;
  final Color normalColor;
  final Color emphasisColor;

  const _TrialBannerText({
    required this.rawText,
    required this.normalColor,
    required this.emphasisColor,
  });

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    final baseStyle = TextStyle(
      color: normalColor,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      height: 1.3,
    );
    final emphasisStyle = baseStyle.copyWith(
      color: emphasisColor,
      fontWeight: FontWeight.w800,
    );

    for (final match in regex.allMatches(rawText)) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: rawText.substring(lastIndex, match.start),
            style: baseStyle,
          ),
        );
      }
      spans.add(TextSpan(text: match.group(1), style: emphasisStyle));
      lastIndex = match.end;
    }
    if (lastIndex < rawText.length) {
      spans.add(TextSpan(text: rawText.substring(lastIndex), style: baseStyle));
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: spans),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BLOC AVANTAGES (5 lignes)
// ─────────────────────────────────────────────────────────────────────────────
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
  final Color bgColor;
  final Color borderColor;
  final List<_ProBenefitData> benefits;

  const _ProBenefitsCard({
    required this.bgColor,
    required this.borderColor,
    required this.benefits,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          children: [
            for (int i = 0; i < benefits.length; i++)
              _ProBenefitRow(
                icon: benefits[i].icon,
                title: benefits[i].title,
                subtitle: benefits[i].subtitle,
                showDivider: i != benefits.length - 1,
                dividerColor: borderColor.withValues(alpha: 0.6),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProBenefitRow extends StatelessWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final bool showDivider;
  final Color dividerColor;

  const _ProBenefitRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.showDivider,
    required this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: showDivider
            ? Border(bottom: BorderSide(color: dividerColor))
            : null,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: LightColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(child: icon),
          ),
          const Gap(AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFE5E0CD),
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const Gap(2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFFB5B097),
                    fontSize: 13,
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

// Badge "NO ADS" pour le dernier avantage
class _NoAdsBadge extends StatelessWidget {
  final Color color;
  const _NoAdsBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 22,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.8),
      ),
      child: Center(
        child: Text(
          'NO\nADS',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: 7,
            fontWeight: FontWeight.w900,
            height: 1.0,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CARTES D'OFFRES CÔTE À CÔTE
// ─────────────────────────────────────────────────────────────────────────────
class _ProOfferCardsRow extends StatelessWidget {
  final bool yearlySelected;
  final VoidCallback onSelectMonthly;
  final VoidCallback onSelectYearly;
  final Color kakiOlive;
  final Color kakiOliveLight;
  final Color cardBg;
  final Color cardBorder;
  final Color creamWhite;
  final Color mutedText;

  const _ProOfferCardsRow({
    required this.yearlySelected,
    required this.onSelectMonthly,
    required this.onSelectYearly,
    required this.kakiOlive,
    required this.kakiOliveLight,
    required this.cardBg,
    required this.cardBorder,
    required this.creamWhite,
    required this.mutedText,
  });

  // Réutilise la logique de parsing des prix de l'ancien code
  double? _parsePriceValue(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final cleaned = trimmed.replaceAll(RegExp(r'[^0-9,\.]'), '');
    if (cleaned.isEmpty) return null;
    final lastComma = cleaned.lastIndexOf(',');
    final lastDot = cleaned.lastIndexOf('.');
    final decimalSepIndex = lastComma > lastDot ? lastComma : lastDot;
    String normalized;
    if (decimalSepIndex == -1) {
      normalized = cleaned;
    } else {
      final intPart = cleaned
          .substring(0, decimalSepIndex)
          .replaceAll(RegExp(r'[,\.]'), '');
      final fracPart = cleaned
          .substring(decimalSepIndex + 1)
          .replaceAll(RegExp(r'[,\.]'), '');
      normalized = '$intPart.$fracPart';
    }
    return double.tryParse(normalized);
  }

  String _formatPriceLikeStore(
    double value,
    String? storePriceRaw,
    String languageCode,
  ) {
    final localeUsesComma =
        languageCode == 'fr' ||
        languageCode == 'de' ||
        languageCode == 'it' ||
        languageCode == 'es';
    final numeric = value.toStringAsFixed(2);
    final localizedNumeric = localeUsesComma
        ? numeric.replaceAll('.', ',')
        : numeric;
    final raw = storePriceRaw?.trim() ?? '';
    if (raw.isEmpty) return localizedNumeric;
    final symbolPrefixMatch = RegExp(r'^[^0-9]+').firstMatch(raw);
    final symbolSuffixMatch = RegExp(r'[^0-9]+$').firstMatch(raw);
    if (symbolPrefixMatch != null) {
      return '${symbolPrefixMatch.group(0)!.trim()}$localizedNumeric';
    }
    if (symbolSuffixMatch != null) {
      return '$localizedNumeric ${symbolSuffixMatch.group(0)!.trim()}';
    }
    return localizedNumeric;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ThotProvider>();
    final strings = AppStrings.of(context);

    final yearlyValue = _parsePriceValue(provider.yearlyPrice);
    final monthlyValue = _parsePriceValue(provider.monthlyPrice);

    String? yearlyEquivalentLabel;
    int? savingsPercent;

    if (yearlyValue != null && monthlyValue != null && monthlyValue > 0) {
      final equivalent = yearlyValue / 12;
      savingsPercent = ((1 - (equivalent / monthlyValue)) * 100).round().clamp(
        0,
        99,
      );
      yearlyEquivalentLabel = strings.proPerMonthEquivalent(
        _formatPriceLikeStore(
          equivalent,
          provider.monthlyPrice,
          strings.languageCode,
        ),
      );
    }

    final monthlyPriceDisplay = provider.monthlyPrice?.trim().isNotEmpty == true
        ? provider.monthlyPrice!
        : '—';
    final yearlyPriceDisplay = provider.yearlyPrice?.trim().isNotEmpty == true
        ? provider.yearlyPrice!
        : '—';

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _ProOfferCard(
              isSelected: !yearlySelected,
              onTap: onSelectMonthly,
              topBadge: strings.proTrialDaysBadge,
              showRecommendedBadge: false,
              recommendedLabel: '',
              title: strings.proMonthlyLabel,
              priceText: monthlyPriceDisplay,
              priceSuffix: strings.proPerMonthSuffix,
              footerText: strings.proCancelAnytime,
              kakiOlive: kakiOlive,
              kakiOliveLight: kakiOliveLight,
              cardBg: cardBg,
              cardBorder: cardBorder,
              creamWhite: creamWhite,
              mutedText: mutedText,
            ),
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: _ProOfferCard(
              isSelected: yearlySelected,
              onTap: onSelectYearly,
              topBadge: strings.proTrialDaysBadge,
              showRecommendedBadge: true,
              recommendedLabel: strings.proRecommendedBadge.toUpperCase(),
              savingsLabel: savingsPercent != null
                  ? strings.proSavingsBadge(savingsPercent)
                  : null,
              title: strings.proYearlyLabel,
              priceText: yearlyPriceDisplay,
              priceSuffix: strings.proPerYearSuffix,
              footerText: yearlyEquivalentLabel ?? '',
              kakiOlive: kakiOlive,
              kakiOliveLight: kakiOliveLight,
              cardBg: cardBg,
              cardBorder: cardBorder,
              creamWhite: creamWhite,
              mutedText: mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProOfferCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final String? topBadge; // "7 JOURS OFFERTS" ou null
  final bool showRecommendedBadge;
  final String recommendedLabel;
  final String? savingsLabel; // "-25%" ou null
  final String title;
  final String priceText;
  final String priceSuffix;
  final String footerText;

  final Color kakiOlive;
  final Color kakiOliveLight;
  final Color cardBg;
  final Color cardBorder;
  final Color creamWhite;
  final Color mutedText;

  const _ProOfferCard({
    required this.isSelected,
    required this.onTap,
    required this.topBadge,
    required this.showRecommendedBadge,
    required this.recommendedLabel,
    this.savingsLabel,
    required this.title,
    required this.priceText,
    required this.priceSuffix,
    required this.footerText,
    required this.kakiOlive,
    required this.kakiOliveLight,
    required this.cardBg,
    required this.cardBorder,
    required this.creamWhite,
    required this.mutedText,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected ? kakiOlive : cardBorder;
    final borderWidth = isSelected ? 2.0 : 1.2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Carte principale (avec marge top pour laisser place au badge si présent)
        Padding(
          padding: EdgeInsets.only(top: topBadge != null ? 12 : 0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: borderWidth),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: kakiOlive.withValues(alpha: 0.25),
                            blurRadius: 14,
                          ),
                        ]
                      : null,
                ),
                padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ligne titre + badge inline (recommandé OU savings)
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: creamWhite,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (showRecommendedBadge) ...[
                          const Gap(12),
                          _InlineRecommendedBadge(
                            label: recommendedLabel,
                            color: kakiOliveLight,
                          ),
                        ] else if (savingsLabel != null) ...[
                          const Gap(6),
                          _SavingsBadge(
                            label: savingsLabel!,
                            color: kakiOliveLight,
                          ),
                        ],
                      ],
                    ),
                    const Gap(10),
                    // Prix
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: priceText,
                            style: TextStyle(
                              color: creamWhite,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                            ),
                          ),
                          TextSpan(
                            text: ' $priceSuffix',
                            style: TextStyle(
                              color: mutedText,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(8),
                    Text(
                      footerText,
                      style: TextStyle(
                        color: mutedText,
                        fontSize: 10,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Badge top "7 JOURS OFFERTS"
        if (topBadge != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF363725),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFF6c6948),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  topBadge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _InlineRecommendedBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _InlineRecommendedBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 10, color: color),
          const Gap(2),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _SavingsBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOUTON CTA PRINCIPAL
// ─────────────────────────────────────────────────────────────────────────────
class _ProCtaButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color kakiOlive;

  const _ProCtaButton({
    required this.label,
    required this.onTap,
    required this.kakiOlive,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: kakiOlive,
          foregroundColor: const Color(0xFFE5E0CD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Gap(8),
            const Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LIENS FOOTER INLINE (Conditions • Confidentialité • Restaurer)
// ─────────────────────────────────────────────────────────────────────────────
class _ProFooterLinks extends StatelessWidget {
  final VoidCallback onPrivacy;
  final VoidCallback onTos;
  final VoidCallback onRestore;
  final Color mutedText;
  final Color kakiOliveLight;

  const _ProFooterLinks({
    required this.onPrivacy,
    required this.onTos,
    required this.onRestore,
    required this.mutedText,
    required this.kakiOliveLight,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    Widget linkText(String text, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Text(
            text,
            style: TextStyle(
              color: mutedText,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    Widget separator() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '•',
        style: TextStyle(
          color: mutedText.withValues(alpha: 0.5),
          fontSize: 11.5,
        ),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: linkText(strings.settingsAboutTos, onTos)),
        separator(),
        Flexible(child: linkText(strings.settingsAboutPrivacy, onPrivacy)),
        separator(),
        Flexible(child: linkText(strings.proRestorePurchases, onRestore)),
      ],
    );
  }
}
