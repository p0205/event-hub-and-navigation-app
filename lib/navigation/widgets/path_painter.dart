import 'package:flutter/material.dart';

import '../models/nav_path.dart';

class PathPainter extends CustomPainter {
  final NavPath naviPath;
  const PathPainter({
    required this.naviPath,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paint for the path itself
    final pathPaint = Paint()
      ..color = naviPath.color // Path color comes from naviPath
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

    canvas.drawPath(pathDrawing, pathPaint); // Draw path with pathPaint

    // Call _drawArrows with the separate color for arrows
    _drawArrows(canvas, naviPath); // No longer passing 'pathPaint'
  }

  void _drawArrows(Canvas canvas, NavPath path) {
    // Paint for the arrows
    final arrowPaint = Paint()
      ..color = const Color.fromARGB(255, 39, 44, 49); // Set your desired arrow color here, e.g., Colors.black, Colors.red, etc.
      // You can also use Colors.white, Colors.orange, etc.
      // Or even a color derived from naviPath.color if you want a subtle difference
      // ..color = naviPath.color.withOpacity(0.8); // Example: slightly transparent version of path color
      
      arrowPaint.style = PaintingStyle.fill; // Arrows are typically filled

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
          arrowPaint, // Draw arrow with arrowPaint
        );

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(covariant PathPainter oldDelegate) {
    return oldDelegate.naviPath != naviPath;
  }
}