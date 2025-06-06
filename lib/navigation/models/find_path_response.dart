// Modified NavigationResponse class with multi-level support

import 'package:flutter/material.dart';
import 'nav_path.dart';
import 'nav_segment.dart';
import 'node.dart';

class NavigationResponse {
  final List<NavSegment> simplifiedSegments;
  final Node sourceNode;
  final Node desNode;

  NavigationResponse({
    required this.simplifiedSegments,
    required this.sourceNode,
    required this.desNode,
  });

  factory NavigationResponse.fromJson(Map<String, dynamic> json) {
    return NavigationResponse(
      simplifiedSegments: List<NavSegment>.from(
        json['simplified_segments']
            .map((segmentJson) => NavSegment.fromJson(segmentJson)),
      ),
      sourceNode: Node.fromJson(json['source_node']),
      desNode: Node.fromJson(json['destination_node']),
    );
  }

  // Original method - creates single path (doesn't handle multi-level properly)
  NavPath toNavPath({required int floorId, Color? color, double? width}) {
    List<Offset> allPoints = [];
    if (simplifiedSegments.isNotEmpty) {
      allPoints.add(simplifiedSegments.first.startCoord);
      for (var segment in simplifiedSegments) {
        allPoints.add(segment.endCoord);
      }
    }

    return NavPath(
      // id: floorId ?? 'generated_path_${DateTime.now().millisecondsSinceEpoch}',
      points: allPoints,
      floorId:  floorId,
      color: color ?? Colors.blue,
      width: width ?? 3.0,
    );
  }

  // Multi-level support - returns separate NavPath for each floor using toNavPath
  Map<int, NavPath> toMultiLevelNavPaths({
    Color? color,
    double? width,
  }) {
    Map<int, List<NavSegment>> segmentsByFloor = {};
    Map<int, NavPath> pathsByFloor = {};

    // Group segments by floor
    for (var segment in simplifiedSegments) {
      // Only process "segment" type (same-floor walking paths)
      // if (segment.segmentType == "segment" ||segment.segmentType == "stairs" ||) {
      int floorId = segment.startFloodId; // Same as endFloorId for segments
      segmentsByFloor.putIfAbsent(floorId, () => []);
      segmentsByFloor[floorId]!.add(segment);
    // }
    }

    // Create a temporary NavigationResponse for each floor and use toNavPath
    segmentsByFloor.forEach((floorId, segments) {
      if (segments.isNotEmpty) {
        // Create a temporary NavigationResponse with segments for this floor only
        NavigationResponse floorNavResponse = NavigationResponse(
          simplifiedSegments: segments,
          sourceNode: sourceNode,
          desNode: desNode,
        );

        // Use the existing toNavPath method
        pathsByFloor[floorId] = floorNavResponse.toNavPath(
          floorId: floorId,
          color: color,
          width: width,
        );
      }
    });

    return pathsByFloor;
  }

  // Get transition points (stairs, elevators) between floors
  List<NavSegment> getFloorTransitions() {
    return simplifiedSegments
        .where((segment) =>
    segment.segmentType == "inter_floor_transition" ||
        segment.segmentType == "stair")
        .toList();
  }

  // Get all unique floor IDs in the path
  Set<int> getInvolvedFloors() {
    Set<int> floors = {};
    for (var segment in simplifiedSegments) {
      floors.add(segment.startFloodId);
      floors.add(segment.endFloorId);
    }
    return floors;
  }

  // Check if this is a multi-floor navigation
  bool isMultiLevel() {
    return simplifiedSegments.any((segment) =>
    segment.segmentType == "inter_floor_transition" ||
        segment.segmentType == "stair");
  }

  // Get stair/transition entry points for each floor
  Map<int, List<Offset>> getTransitionPoints() {
    Map<int, List<Offset>> transitionsByFloor = {};

    for (var segment in simplifiedSegments) {
      if (segment.segmentType == "stair") {
        // Stair entry point
        int floorId = segment.startFloodId;
        transitionsByFloor.putIfAbsent(floorId, () => []);
        transitionsByFloor[floorId]!.add(segment.endCoord);
      } else if (segment.segmentType == "inter_floor_transition") {
        // Stair exit point on destination floor
        int floorId = segment.endFloorId;
        transitionsByFloor.putIfAbsent(floorId, () => []);
        transitionsByFloor[floorId]!.add(segment.endCoord);
      }
    }

    return transitionsByFloor;
  }
}