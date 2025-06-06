// lib/models/turn_instruction.dart
import 'package:flutter/material.dart';

class TurnInstruction {
  final Offset location;
  final String instruction;
  final double angleDegrees;

  TurnInstruction({required this.location, required this.instruction, this.angleDegrees = 0.0});
}