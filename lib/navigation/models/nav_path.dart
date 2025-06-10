import 'package:flutter/material.dart';

class NavPath {
  final String? id;
  final int floorId;
  final List<Offset> points;
  final Color color;
  final double width;

  const NavPath({
     this.id,
    required this.floorId,
    required this.points,
    this.color = Colors.blue,
    this.width = 5.0,
  });
}