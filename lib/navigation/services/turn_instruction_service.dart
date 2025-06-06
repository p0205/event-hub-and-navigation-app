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

      print("Current segment startCoord:  ${currentSegment.startCoord}");
      print("desCoord:  ${desNode?.coord}");
      print("Current segment startFloodId:  ${currentSegment.startFloodId}");
      print("currentFloorId: ${desNode?.floorId}");
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
      } else if (currentSegment.segmentType == "stair") {
        instructionText =
            "Go straight for ${currentSegment.distanceMeters.toStringAsFixed(1)} meters to stair.";
      } else if (currentSegment.segmentType == "inter_floor_transition") {
        String toFloor = currentSegment.endFloorId == 0
            ? "Ground Floor"
            : "Floor ${currentSegment.endFloorId}";
        if (currentSegment.startFloodId < currentSegment.endFloorId) {
          instructionText = "Go upstairs to $toFloor";
        } else {
          instructionText = "Go downstairs to $toFloor";
        }
      }

      if (i < simplifiedSegments.length - 1) {
        final NavSegment nextSegment = simplifiedSegments[i + 1];

        if (nextSegment.segmentType == "stair") {
          instructionText =
              "Go straight for ${currentSegment.distanceMeters.toStringAsFixed(1)} meters to stair.";
        }
      }

      instructionsByFloor[currentFloorId]!.add(TurnInstruction(
        location: currentSegment.startCoord,
        // Instruction applies to reaching the end of this straight segment
        instruction: instructionText,
      ));



      if (i < simplifiedSegments.length - 1) {
        final NavSegment nextSegment = simplifiedSegments[i + 1];

        final Offset p1 = currentSegment.startCoord; // Not strictly needed for turn angle if using segments
        final Offset p2 = currentSegment.endCoord; // The point of the turn
        final Offset p3 = nextSegment.endCoord; // A point after the turn

        final Offset v1 = Offset(p2.dx - p1.dx, p2.dy - p1.dy);
        final Offset v2 = Offset(p3.dx - p2.dx, p3.dy - p2.dy);

        final double turnAngleRad = getTurnAngle(v1, v2);

        // Turn instruction logic (as before)
        const double straightThreshold = 10 * (math.pi / 180);
        const double gentleTurnThreshold = 45 * (math.pi / 180);
        const double sharpTurnThreshold = 135 * (math.pi / 180);

        if (turnAngleRad.abs() > straightThreshold) {
          if (turnAngleRad > 0) {
            // Right turn
            if (turnAngleRad < gentleTurnThreshold) {
              instructionText = "Bear right";
            } else if (turnAngleRad < sharpTurnThreshold) {
              instructionText = "Turn right";
            } else {
              instructionText = "Make a sharp right turn";
            }
          } else {
            // Left turn
            if (turnAngleRad.abs() < gentleTurnThreshold) {
              instructionText = "Bear left";
            } else if (turnAngleRad.abs() < sharpTurnThreshold) {
              instructionText = "Turn left";
            } else {
              instructionText = "Make a sharp left turn";
            }
          }
          // Add the turn instruction, location is the end of the current segment (start of next)
          instructionsByFloor[currentFloorId]!.add(TurnInstruction(
            location: currentSegment.endCoord,
            instruction: instructionText,
          ));
        }
      }
    }

    // Print each instruction for debugging
    instructionsByFloor.forEach((floorId, instructions) {
      print("Floor $floorId Instructions:");
      for (int i = 0; i < instructions.length; i++) {
        print("  Instruction ${i + 1}: ${instructions[i].instruction}");
        print("  Location: ${instructions[i].location}");
      }
      print("---");
    });
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
