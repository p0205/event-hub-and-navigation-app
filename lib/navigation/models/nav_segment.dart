// lib/models/nav_segment.dart
import 'dart:ui'; // For Offset

class NavSegment {
  final Offset startCoord;
  final int startFloodId;
  final int startNodeId;
  final Offset endCoord;
  final int endFloorId;
  final int endNodeId;
  final String segmentType;
  final double distanceMeters;


  NavSegment({
    required this.startCoord,
    required this.startFloodId,
    required this.startNodeId,
    required this.endCoord,
    required this.endFloorId,
    required this.endNodeId,
    required this.segmentType,
    required this.distanceMeters
  });

  factory NavSegment.fromJson(Map<String, dynamic> json) {
    return NavSegment(
      startCoord: Offset(
          (json['start_coord'] as List<dynamic>)[0].toDouble(),
          (json['start_coord'] as List<dynamic>)[1].toDouble()),
      startFloodId: json['start_floor_id'],
      startNodeId: json['start_node_id'],
      endCoord: Offset(
          (json['end_coord'] as List<dynamic>)[0].toDouble(),
          (json['end_coord'] as List<dynamic>)[1].toDouble()),
      endFloorId: json['end_floor_id'],
      endNodeId: json['end_node_id'],
      distanceMeters: json['distance_meters'].toDouble(),
      segmentType: json['segment_type'],
    );
  }
}