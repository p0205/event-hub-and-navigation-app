// lib/models/nav_segment.dart
import 'dart:ui'; // For Offset

class Node {
  final int floorId;
  final int nodeId;
  final String name;
  final Offset coord;

  Node({
    required this.floorId,
    required this.nodeId,
    required this.name,
    required this.coord,
  });

  factory Node.fromJson(Map<String, dynamic> json) {
    return Node(
      floorId: json['floor_id'],
      nodeId: json['id'],
      name: json['name'],
      coord: Offset(
    (json['x_coord']).toDouble(),
    (json['y_coord']).toDouble()),
    );
  }
}