import 'package:flutter/material.dart';

import '../models/find_path_response.dart';
import '../models/nav_path.dart';
import '../repo/navigation_repo.dart';

class NavigationService {
  // This is the static method provided in the original prompt, now updated
  static Future<Map<String, dynamic>> getNavigationPath(
      String source, String destination) async {
    final NavigationResponse navResponse = await NavigationRepo.getNavigationPath(source: source, destination: destination);
    // Check if this is multi-level navigation

    Map<int, NavPath> pathsByFloor = navResponse.toMultiLevelNavPaths();
    Map<int, List<Offset>> transitionPoints = navResponse.getTransitionPoints();
    Set<int> involvedFloors = navResponse.getInvolvedFloors();
    Map<String, dynamic> result = {
      'navigationResponse': navResponse,
      'sourceNode': navResponse.sourceNode,
      'desNode': navResponse.desNode,
      'userLocationOnMap': navResponse.sourceNode.coord,
      'simplifiedSegments': navResponse.simplifiedSegments,
      'pathsByFloor': pathsByFloor,
      'transitionPoints': transitionPoints,
      'involvedFloors': involvedFloors,
    };

    return result;
  }

  static bool isDestinationReached(
      Offset userLocation, Offset destination, double threshold) {
    return (userLocation - destination).distance < threshold;
  }

  static bool isMovingToDestination(
      Offset nextPoint, Offset destination, double threshold) {
    return (nextPoint - destination).distance < threshold;
  }
}
