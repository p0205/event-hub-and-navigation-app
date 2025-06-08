import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../models/nav_segment.dart';
import '../models/navigate_instruction.dart';
import '../models/node.dart';


class TurnInstructionService {
  static double getTurnAngle(Offset v1, Offset v2) {
    final double dotProduct = v1.dx * v2.dx + v1.dy * v2.dy;
    final double magnitudeV1 = v1.distance;
    final double magnitudeV2 = v2.distance;
    if (magnitudeV1 == 0 || magnitudeV2 == 0) return 0.0;

    final double angleMagnitude =
        math.acos((dotProduct / (magnitudeV1 * magnitudeV2)).clamp(-1.0, 1.0));

    final double crossProduct = v1.dx * v2.dy - v1.dy * v2.dx;

    if (crossProduct < 0) {
      return -angleMagnitude;
    } else if (crossProduct > 0) {
      return angleMagnitude;
    } else {
      return 0.0;
    }
  }

  static Map<int, List<TurnInstruction>> generateTurnInstructions(
      List<NavSegment> simplifiedSegments, Node? desNode) {
    Map<int, List<TurnInstruction>> instructionsByFloor = {};

    // Iterate through the simplified segments
    for (int i = 0; i < simplifiedSegments.length; i++) {
      final NavSegment currentSegment = simplifiedSegments[i];
      int currentFloorId = currentSegment.startFloodId;
      String instructionText = "";

      instructionsByFloor.putIfAbsent(currentFloorId, () => []);

      if (currentSegment.startCoord == desNode?.coord &&
          currentFloorId == desNode?.floorId) {

        instructionText = "Arrive at your destination.";
        instructionsByFloor[currentFloorId]!.add(TurnInstruction(
          location: currentSegment.startCoord,
          instruction: instructionText,
        ));
        break;
      }

      if (currentSegment.segmentType == "segment") {
        instructionText =
            "Go straight for ${currentSegment.distanceMeters.toStringAsFixed(1)} meters.";
        instructionsByFloor[currentFloorId]!.add(TurnInstruction(
          location: currentSegment.startCoord,
          instruction: instructionText,
          icon: Icon(
            Icons.arrow_upward,
            color: Colors.white,
            size: 35,
          ),
        ));
      } else if (currentSegment.segmentType == "stair") {
        instructionText =
            "Go straight for ${currentSegment.distanceMeters.toStringAsFixed(1)} meters to stair.";
        instructionsByFloor[currentFloorId]!.add(TurnInstruction(
          location: currentSegment.startCoord,
          instruction: instructionText,
          icon: Icon(
            Icons.arrow_upward,
            color: Colors.white,
            size: 35,
          ),

        ));
      } else if (currentSegment.segmentType == "inter_floor_transition") {
        String toFloor = currentSegment.endFloorId == 0
            ? "Ground Floor"
            : "Floor ${currentSegment.endFloorId}";
        if (currentSegment.startFloodId < currentSegment.endFloorId) {
          instructionText = "Go upstairs to $toFloor";
          instructionsByFloor[currentFloorId]!.add(TurnInstruction(
            location: currentSegment.startCoord,
            instruction: instructionText,
            icon:
            Icon(
              Icons.stairs,
              color: Colors.white,
              size: 35,
            ),
          ));
        } else {
          instructionText = "Go downstairs to $toFloor";
          instructionsByFloor[currentFloorId]!.add(TurnInstruction(
            location: currentSegment.startCoord,
            instruction: instructionText,

            icon: Icon(
              Icons.stairs,
              color: Colors.white,
              size: 35,
            ),
          ));
        }
      }

      if (i < simplifiedSegments.length - 1) {
        final NavSegment nextSegment = simplifiedSegments[i + 1];

        final Offset p1 = currentSegment.startCoord;
        final Offset p2 = currentSegment.endCoord;
        final Offset p3 = nextSegment.endCoord;

        final Offset v1 = Offset(p2.dx - p1.dx, p2.dy - p1.dy);
        final Offset v2 = Offset(p3.dx - p2.dx, p3.dy - p2.dy);

        final double turnAngleRad = getTurnAngle(v1, v2);

        const double straightThreshold = 10 * (math.pi / 180);
        const double gentleTurnThreshold = 45 * (math.pi / 180);
        const double sharpTurnThreshold = 135 * (math.pi / 180);

        if (turnAngleRad.abs() > straightThreshold) {

          if (turnAngleRad > 0) {
            // Right turn
            if (turnAngleRad < gentleTurnThreshold) {
              instructionText = "Bear right";

              instructionsByFloor[currentFloorId]!.add(TurnInstruction(
                location: currentSegment.endCoord,
                instruction: instructionText,
                icon:
                Icon(
                  Icons.turn_slight_right,
                  color: Colors.white,
                  size: 35,
                ),
              ));
            } else if (turnAngleRad < sharpTurnThreshold) {
              instructionText = "Turn right";
              instructionsByFloor[currentFloorId]!.add(TurnInstruction(
                location: currentSegment.endCoord,
                instruction: instructionText,
                icon:
                Icon(
                  Icons.turn_right,
                  color: Colors.white,
                  size: 35,
                ),
              ));

            } else {
              instructionText = "Make a sharp right turn";
              instructionsByFloor[currentFloorId]!.add(TurnInstruction(
                location: currentSegment.endCoord,
                instruction: instructionText,
                icon:
                Icon(
                  Icons.turn_right,
                  color: Colors.white,
                  size: 35,
                ),
              ));
            }
          } else {
            // Left turn
            if (turnAngleRad.abs() < gentleTurnThreshold) {
              instructionText = "Bear left";
              instructionsByFloor[currentFloorId]!.add(TurnInstruction(
                location: currentSegment.endCoord,
                instruction: instructionText,
                icon:
                Icon(
                  Icons.turn_slight_left,
                  color: Colors.white,
                  size: 35,
                ),
              ));
            } else if (turnAngleRad.abs() < sharpTurnThreshold) {
              instructionText = "Turn left";
              instructionsByFloor[currentFloorId]!.add(TurnInstruction(
                location: currentSegment.endCoord,
                instruction: instructionText,
                icon:
                Icon(Icons.turn_left,

                  color: Colors.white,
                  size: 35,
                ),
              ));
            } else {
              instructionText = "Make a sharp left turn";
              instructionsByFloor[currentFloorId]!.add(TurnInstruction(
                location: currentSegment.endCoord,
                instruction: instructionText,
                icon:
                Icon(
                  Icons.turn_left,
                  color: Colors.white,
                  size: 35,
                ),
              ));
            }
          }
        }
      }
    }


    return instructionsByFloor;
  }

  static List<TurnInstruction> findInstructionForLocation(
      List<TurnInstruction> instructions, Offset location) {
    List<TurnInstruction> instruction = [];
    for (var instr in instructions) {
      if ((instr.location - location).distanceSquared < 1.0) {
        instruction.add(instr);
      }
    }

    return instruction;
  }
}
