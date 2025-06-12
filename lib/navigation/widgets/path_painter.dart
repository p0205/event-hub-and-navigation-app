import 'package:flutter/material.dart';

import '../models/nav_path.dart';

class PathPainter extends CustomPainter {
  final List<NavPath> naviPaths;
  const PathPainter({
    required this.naviPaths,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var naviPath in naviPaths) {
      // Paint for the path itself
      final pathPaint = Paint()
        ..color = naviPath.color
        ..strokeWidth = naviPath.width
        ..style = PaintingStyle.stroke;

      final pathDrawing = Path()
        ..moveTo(
          naviPath.points[0].dx,
          naviPath.points[0].dy,
        );

      for (var i = 1; i < naviPath.points.length; i++) {
        final point = (naviPath.points[i]);
        pathDrawing.lineTo(point.dx, point.dy);
      }

      canvas.drawPath(pathDrawing, pathPaint);

      // Draw arrows for this path
      _drawArrows(canvas, naviPath);
    }
  }

  void _drawArrows(Canvas canvas, NavPath path) {
    // Paint for the arrows
    final arrowPaint = Paint()
      ..color = const Color.fromARGB(255, 39, 44, 49)
      ..style = PaintingStyle.fill;

    const double arrowTipLength = 7.0;
    const double arrowBaseSpread = 7.0;

    for (var i = 0; i < path.points.length - 1; i++) {
      final start = (path.points[i]);
      final end = (path.points[i + 1]);
      final direction = (end - start).direction;

      if (i % 2 == 0) {
        final middle = start + (end - start) * 0.7;

        canvas.save();
        canvas.translate(middle.dx, middle.dy);
        canvas.rotate(direction);

        canvas.drawPath(
          Path()
            ..moveTo(arrowTipLength, 0)
            ..lineTo(-arrowTipLength, arrowBaseSpread)
            ..lineTo(-arrowTipLength, -arrowBaseSpread)
            ..close(),
          arrowPaint,
        );

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) {
    return oldDelegate.naviPaths != naviPaths;
  }
}