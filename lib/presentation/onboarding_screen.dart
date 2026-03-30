import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:thot/l10n/app_strings.dart';
import '../data/thot_provider.dart';
import '../theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  static const List<String> _backgroundAssets = [
    'assets/images/fondstand.webp',
    'assets/images/fondsable.webp',
    'assets/images/fondforet.webp',
  ];
  bool _didPrecacheBackgrounds = false;
  int _currentPage = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecacheBackgrounds) return;

    for (final asset in _backgroundAssets) {
      precacheImage(AssetImage(asset), context);
    }
    _didPrecacheBackgrounds = true;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Sur la dernière page, on démarre simplement l'app
      // sans marquer l'onboarding comme "vu pour toujours".
      final provider = Provider.of<ThotProvider>(context, listen: false);
      provider.dismissOnboardingForSession();
      if (context.mounted) {
        context.go('/');
      }
    }
  }

  void _finishOnboarding() async {
    final provider = Provider.of<ThotProvider>(context, listen: false);
    await provider.completeOnboarding();
    if (context.mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppStrings.of(context);
    final isPhotoPage = _currentPage == 0 || _currentPage == 1 || _currentPage == 2;
    final indicatorActiveColor = isPhotoPage ? Colors.white : colors.primary;
    final indicatorInactiveColor = isPhotoPage
        ? Colors.white.withValues(alpha: 0.35)
        : colors.onSurface.withValues(alpha: 0.2);
    final nextButtonBackground = isPhotoPage ? Colors.white : colors.primary;
    final nextButtonForeground = isPhotoPage ? Colors.black : colors.onPrimary;

    final backgroundAsset = _backgroundAssets[_currentPage];

    final pages = [
      _buildPage(
        icon: Icons.shield_rounded,
        invertedColors: true,
        header: _buildCircleHeader(
          colors: colors,
          child: Image.asset(
            'assets/images/logoft.png',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
        ),
        title: strings.onboardingTitle1,
        description: strings.onboardingDescription1,
        colors: colors,
      ),
      _buildPage(
        icon: Icons.lock_outline_rounded,
        invertedColors: true,
        title: strings.onboardingTitle2,
        description: strings.onboardingDescription2,
        colors: colors,
      ),
      _buildPage(
        icon: Icons.track_changes_rounded,
        invertedColors: true,
        header: _buildCircleHeader(
          colors: colors,
          child: SvgPicture.asset(
            'assets/images/material.svg',
            width: 140,
            height: 140,
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
        ),
        title: strings.onboardingTitle3,
        description: strings.onboardingDescription3,
        colors: colors,
      ),
    ];

    final content = SafeArea(
      child: Column(
        children: [
          // Bouton top-bar: "Ne plus afficher" (gauche)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: TextButton(
                    onPressed: _finishOnboarding,
                    child: Text(
                      strings.onboardingDontShowAgain,
                      style: TextStyle(
                        color: isPhotoPage
                            ? Colors.white.withValues(alpha: 0.85)
                            : colors.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenu du PageView
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: pages,
            ),
          ),

          // Indicateurs et Boutons du bas
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    3,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? indicatorActiveColor
                            : indicatorInactiveColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: nextButtonBackground,
                    foregroundColor: nextButtonForeground,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentPage == 2
                        ? strings.onboardingStart
                        : strings.onboardingNext,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (isPhotoPage) ...[
            Image.asset(
              backgroundAsset,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.25),
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
          ],
          content,
        ],
      ),
    );
  }

  Widget _buildPage({
    required IconData icon,
    String? backgroundAsset,
    Widget? header,
    bool invertedColors = false,
    required String title,
    required String description,
    required ColorScheme colors,
  }) {
    final hasBackground = backgroundAsset != null;
    final useInvertedColors = invertedColors || hasBackground;
    final titleColor = useInvertedColors ? Colors.white : colors.onSurface;
    final descriptionColor = useInvertedColors
        ? Colors.white.withValues(alpha: 0.85)
        : colors.onSurface.withValues(alpha: 0.7);

    final content = Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (header != null)
            header
          else
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 138,
                color: useInvertedColors ? Colors.white : colors.primary,
              ),
            ),
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: descriptionColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );

    if (backgroundAsset == null) {
      return content;
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          backgroundAsset,
          fit: BoxFit.cover,
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.25),
                Colors.black.withValues(alpha: 0.55),
              ],
            ),
          ),
        ),
        content,
      ],
    );
  }

  Widget _buildCircleHeader({
    required ColorScheme colors,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}
