part of '../shooting_tables_screen.dart';

class _TargetPainter extends CustomPainter {
  const _TargetPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        (size.width < size.height ? size.width : size.height) /
        2 *
        _ShootingTablesScreenState._targetVisualRadiusFactor;
    final ringStep = radius / 10;
    final blackVisualRadius =
        radius *
        (_ShootingTablesScreenState._c50VisualBlackRadiusMm /
            _ShootingTablesScreenState._c50OuterRadiusMm);
    final tenRadius =
        radius *
        (_ShootingTablesScreenState._c50TenRadiusMm /
            _ShootingTablesScreenState._c50OuterRadiusMm);

    final whiteFill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    final blackFill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black;

    canvas.drawCircle(center, radius, whiteFill);
    canvas.drawCircle(center, blackVisualRadius, blackFill);

    for (var i = 1; i <= 10; i++) {
      final inBlackVisual = i <= 4;
      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = inBlackVisual ? Colors.white : Colors.black;
      canvas.drawCircle(center, ringStep * i, ringPaint);
    }

    for (var score = 1; score <= 9; score++) {
      final outerRadiusMm = (11 - score) * 25.0;
      final innerRadiusMm = (10 - score) * 25.0;
      final labelRadiusMm = (outerRadiusMm + innerRadiusMm) / 2;
      final labelRadiusPx =
          radius *
          (labelRadiusMm / _ShootingTablesScreenState._c50OuterRadiusMm);
      final inBlackVisual =
          labelRadiusMm <= _ShootingTablesScreenState._c50VisualBlackRadiusMm;

      final label = TextSpan(
        text: '$score',
        style: TextStyle(
          color: inBlackVisual ? Colors.white : Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      );
      final textPainter = TextPainter(
        text: label,
        textDirection: TextDirection.ltr,
      )..layout();

      void paintAt(Offset point) {
        textPainter.paint(
          canvas,
          Offset(
            point.dx - (textPainter.width / 2),
            point.dy - (textPainter.height / 2),
          ),
        );
      }

      paintAt(Offset(center.dx, center.dy - labelRadiusPx));
      paintAt(Offset(center.dx, center.dy + labelRadiusPx));
      paintAt(Offset(center.dx - labelRadiusPx, center.dy));
      paintAt(Offset(center.dx + labelRadiusPx, center.dy));
    }

    canvas.drawCircle(center, tenRadius, whiteFill);
    canvas.drawCircle(
      center,
      tenRadius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.black,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.black,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

