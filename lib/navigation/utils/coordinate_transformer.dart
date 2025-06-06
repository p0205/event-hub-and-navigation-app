
import 'dart:ui';
class CoordinateTransformer {
  final Size svgSize;
  final Size displaySize;
  final double scale;
  final Offset offset;

  CoordinateTransformer({
    required this.svgSize,
    required this.displaySize,
    this.scale = 1.0,
    this.offset = Offset.zero,
  });

  CoordinateTransformer copyWith({
    Size? svgSize,
    Size? displaySize,
    double? scale,
    Offset? offset,
  }) {
    return CoordinateTransformer(
      svgSize: svgSize ?? this.svgSize,
      displaySize: displaySize ?? this.displaySize,
      scale: scale ?? this.scale,
      offset: offset ?? this.offset,
    );
  }

  Offset toDisplay(Offset svgOffset) {
    return Offset(
      svgOffset.dx * scale + offset.dx,
      svgOffset.dy * scale + offset.dy,
    );
  }
}