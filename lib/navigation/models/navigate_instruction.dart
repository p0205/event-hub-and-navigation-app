// lib/models/turn_instruction.dart
import 'package:flutter/material.dart';

class TurnInstruction {
  final Offset location;
  final String instruction;
  final double angleDegrees;
  final Icon? icon;

  TurnInstruction({
    required this.location, 
    required this.instruction, 
    this.angleDegrees = 0.0,
    this.icon,
  });
}