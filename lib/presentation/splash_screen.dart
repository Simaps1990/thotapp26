import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:thot/data/thot_provider.dart';
import 'package:thot/utils/timer_sound.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  double _opacity = 1.0;
  List<String> _warmupSvgs = const [];
  late VideoPlayerController _videoController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _initializeScaleAnimation();
    _bootstrap();
  }

  void _initializeScaleAnimation() {
    _scaleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();
    
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  void _initializeVideo() {
    _videoController = VideoPlayerController.asset('assets/video/fumee_loading.mp4')
      ..initialize().then((_) {
        if (mounted) {
          _videoController.setLooping(true);
          _videoController.play();
          debugPrint('Video initialized and playing');
          setState(() {});
        }
      }).catchError((error) {
        debugPrint('Video initialization error: $error');
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final provider = context.read<ThotProvider>();

    try {
      await _precacheAllAssets().timeout(const Duration(seconds: 8));
    } catch (_) {}

    try {
      await provider.initializeApp().timeout(const Duration(seconds: 10));
    } catch (_) {}
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
      });
    }

    try {
      await TimerSound.warmUp();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF05070B),
      body: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: _opacity,
        child: Container(
          color: Colors.black,
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
              if (_videoController.value.isInitialized)
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.fitHeight,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  ),
                ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: child,
                        );
                      },
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
