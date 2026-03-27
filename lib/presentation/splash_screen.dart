import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:thot/data/thot_provider.dart';
import 'package:thot/utils/timer_sound.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 1.0;
  List<String> _warmupSvgs = const [];
  double _progress = 0.0;
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      if (mounted) {
        setState(() => _progress = 0.1);
      }
      await _precacheAllAssets().timeout(const Duration(seconds: 8));
    } catch (_) {}

    try {
      final provider = context.read<ThotProvider>();
      if (mounted) {
        setState(() => _progress = 0.7);
      }
      await provider.initializeApp().timeout(const Duration(seconds: 10));
    } catch (_) {}
    if (mounted) {
      setState(() => _progress = 1.0);
    }
    if (!mounted) return;
    // Léger fondu avant de naviguer
    setState(() => _opacity = 0.0);
    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;
    context.go('/');
  }

  Future<void> _precacheAllAssets() async {
    // Préchargement très léger : on met surtout à jour la progression
    // et on réchauffe le son du timer. Les autres assets seront chargés
    // à la demande lors de la navigation et resteront ensuite en cache.

    if (mounted) {
      setState(() {
        _warmupSvgs = const [];
        _progress = 0.3;
      });
    }

    try {
      await TimerSound.warmUp();
      if (mounted) {
        setState(() => _progress = 0.5);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFF05070B),
      body: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: _opacity,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF05070B),
                Color(0xFF0B0F14),
                Color(0xFF151A24),
              ],
            ),
          ),
          child: Stack(
            children: [
              Offstage(
                offstage: true,
                child: Column(
                  children: [
                    for (final p in _warmupSvgs)
                      SvgPicture.asset(
                        p,
                        width: 1,
                        height: 1,
                      ),
                  ],
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutBack,
                      scale: _opacity == 1.0 ? 1.0 : 0.98,
                      child: SvgPicture.asset(
                        'assets/images/LOGO.svg',
                        width: 124,
                        height: 124,
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 44,
                      height: 44,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(colors.primary.withValues(alpha: 0.95)),
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
