import 'package:flutter/material.dart';

import '../models/floor_data.dart';

class FloorNavigation extends StatelessWidget {
  final List<FloorData> floors;
  final int currentFloorId;
  final Function(int) onFloorSelected;

  const FloorNavigation({
    super.key,
    required this.floors,
    required this.currentFloorId,
    required this.onFloorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).dialogBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Floor Navigation Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Select Floor',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Floor Buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            direction: Axis.vertical,
            children: floors.map((floor) {
              final isSelected = floor.floorId == currentFloorId;
              return ElevatedButton(
                onPressed: () => onFloorSelected(floor.floorId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor,
                  foregroundColor: isSelected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyLarge?.color,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: Text(
                  floor.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
} 