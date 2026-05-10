import 'package:flutter/material.dart';

class ExerciseCountdownBackground extends StatelessWidget {
  final Widget child;

  const ExerciseCountdownBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              radius: 1.5,
              colors: [Color(0xFF2A3550), Color(0xFF1A1F2E)],
            ),
          ),
        ),
        // Smoke blobs
        const _ReflexSmokeBlob(
          top: -120,
          left: -100,
          size: 380,
          color: Color(0xFF3D2A55),
          delay: 0,
        ),
        const _ReflexSmokeBlob(
          top: 150,
          right: -140,
          size: 320,
          color: Color(0xFF2D3A50),
          delay: 800,
        ),
        const _ReflexSmokeBlob(
          bottom: -120,
          left: 50,
          size: 400,
          color: Color(0xFF1F3F50),
          delay: 1600,
        ),
        child,
      ],
    );
  }
}

class _ReflexSmokeBlob extends StatefulWidget {
  final double? top, left, right, bottom;
  final double size;
  final Color color;
  final int delay;

  const _ReflexSmokeBlob({
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.size,
    required this.color,
    required this.delay,
  });

  @override
  State<_ReflexSmokeBlob> createState() => _ReflexSmokeBlobState();
}

class _ReflexSmokeBlobState extends State<_ReflexSmokeBlob>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _x;
  late Animation<double> _y;
  late Animation<double> _s;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );
    _x = Tween<double>(begin: -20, end: 20).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
    _y = Tween<double>(begin: -15, end: 15).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.3, 0.8, curve: Curves.easeInOut),
      ),
    );
    _s = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      left: widget.left,
      right: widget.right,
      bottom: widget.bottom,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Transform.translate(
            offset: Offset(_x.value, _y.value),
            child: Transform.scale(
              scale: _s.value,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.4),
                      blurRadius: 100,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
