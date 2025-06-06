import 'package:flutter/material.dart';
import 'dart:math' as math; // For math.max
import 'venue_image_viewer.dart';

class MapMarker extends StatelessWidget {
  final Offset position; 
  final String? label;
  final Color color;
  final double radius;
  final double mapRotation;
  final IconData? customIconData;
  final String? imageUrl;
  final int floorId;

  MapMarker({
    super.key,
    required this.position,
    this.label,
    this.color = Colors.blue,
    this.radius = 10.0,
    this.mapRotation = 0.0,
    this.customIconData,
    this.imageUrl,
    required this.floorId,
  }) {
    // print('MapMarker constructor - imageUrl: $imageUrl'); // Debug log
  }

  factory MapMarker.fromJson(Map<String, dynamic> json) {
    final List<dynamic> coords = json['coordinates'] as List<dynamic>;
    if (coords.length != 2) {
      throw FormatException(
          'Coordinates must be a list of two numbers: [x, y]');
    }
    final double x = (coords[0] as num).toDouble();
    final double y = (coords[1] as num).toDouble();
    final String? name = json['name'] as String?;
    final int floorId = json['floor_id'] as int;
    
    // Debug print to see the full JSON
    print('MapMarker JSON data: $json');
    
    // Get the venue_image directly from the root of the JSON
    final String? image = json['venue_image'] as String?;
    print('Extracted image URL: $image'); // Debug print

    return MapMarker(
      position: Offset(x, y),
      label: name,
      imageUrl: image,
      floorId: floorId,
      color: floorId == 1 ? Colors.blue : Colors.green, // Different colors for different floors
    );
  }

  @override
  Widget build(BuildContext context) {
    // print('MapMarker build - imageUrl: $imageUrl'); // Debug log
    // 1. Calculate TextSpan size for the label
    final textStyle = TextStyle(
      fontSize: 12,
      color: Colors.black87,
      fontWeight: FontWeight.w500,
    );
    final textSpan = TextSpan(text: label, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    );
    textPainter.layout();
    final labelSize = textPainter.size;
    final labelVerticalPadding = 2.0;
    final labelHorizontalPadding = 4.0;
    final actualLabelHeight = labelSize.height + (labelVerticalPadding * 2);
    final actualLabelWidth = labelSize.width + (labelHorizontalPadding * 2);

    // 2. Determine screen width (or map container width if available)
    final screenWidth = MediaQuery.of(context).size.width;
    final iconDiameter = radius * 2;
    final paddingBetweenIconAndLabel = 5.0;

    // 3. Decision logic for label placement
    bool putLabelLeft;
    final iconCenterDx = position.dx;

    // Adjust space needed calculations if label is null
    final double effectiveLabelWidth = label != null ? actualLabelWidth : 0.0;
    final double effectivePadding = label != null ? paddingBetweenIconAndLabel : 0.0;


    final spaceNeededForRightLabel = radius + effectivePadding + effectiveLabelWidth;
    final spaceNeededForLeftLabel = effectiveLabelWidth + effectivePadding + radius;

    final wouldOverflowRight = (iconCenterDx + spaceNeededForRightLabel - radius) > screenWidth;
    final wouldOverflowLeft = (iconCenterDx - spaceNeededForLeftLabel + radius) < 0;

    if (wouldOverflowRight) {
      if (wouldOverflowLeft) {
        putLabelLeft = false; // Default to right if overflows both ways
      } else {
        putLabelLeft = true; // Must place on left
      }
    } else {
      if (wouldOverflowLeft) {
        putLabelLeft = false; // Must place on right
      } else {
        putLabelLeft = iconCenterDx > screenWidth / 2; // Heuristic: place away from nearest edge
      }
    }

    // 4. Create the icon widget
    final iconWidget = Container(
      width: iconDiameter,
      height: iconDiameter,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          customIconData ?? Icons.place,
          color: Colors.white,
          size: radius * 1.2,
        ),
      ),
    );

    // 5. Create the label widget (conditionally)
    final labelWidget = label != null
        ? Container(
            padding: EdgeInsets.symmetric(horizontal: labelHorizontalPadding, vertical: labelVerticalPadding),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              label!,
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        : const SizedBox.shrink(); // Use SizedBox.shrink if label is null

    // 6. Assemble icon and label in a Row
    Widget markerContentRow;
    if (putLabelLeft) {
      markerContentRow = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) labelWidget, // Only add label if it exists
          if (label != null) SizedBox(width: paddingBetweenIconAndLabel), // Only add padding if label exists
          iconWidget,
        ],
      );
    } else {
      markerContentRow = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          if (label != null) SizedBox(width: paddingBetweenIconAndLabel), // Only add padding if label exists
          if (label != null) labelWidget, // Only add label if it exists
        ],
      );
    }

    // 7. Calculate the top-left position for the `Positioned` widget
    // The `position` offset is the CENTER of the icon.
    // We need to calculate the top-left of the entire markerContentRow
    // such that the icon's center aligns with `position`.

    double xOffsetOfIconCenterFromRowLeft; // How far is the icon's center from the row's left edge
    if (putLabelLeft) {
      xOffsetOfIconCenterFromRowLeft = effectiveLabelWidth + effectivePadding + radius;
    } else {
      xOffsetOfIconCenterFromRowLeft = radius;
    }

    double finalLeft = position.dx - xOffsetOfIconCenterFromRowLeft;
    double finalTop = position.dy - (iconDiameter / 2); // Vertically align the icon's center with position.dy

    // Calculate markerRowWidth and markerRowHeight for alignment purposes
    // These need to be correct for the Transform.rotate alignment.
    final markerRowWidth = (label != null
        ? actualLabelWidth + paddingBetweenIconAndLabel + iconDiameter
        : iconDiameter);
    final markerRowHeight = math.max(iconDiameter, (label != null ? actualLabelHeight : 0.0));


    // --- Calculate the alignment for rotation around the icon's center ---
    // This part remains mostly the same as the previous correct implementation,
    // ensuring rotation around the icon's center *within* the markerContentRow.
    double xAlignmentRelativeToRowTopLeft;
    double yAlignmentRelativeToRowTopLeft = markerRowHeight / 2; // Icon is vertically centered in the row

    if (putLabelLeft) {
      xAlignmentRelativeToRowTopLeft = effectiveLabelWidth + effectivePadding + radius;
    } else {
      xAlignmentRelativeToRowTopLeft = radius;
    }

    final alignmentX = markerRowWidth > 0 ? xAlignmentRelativeToRowTopLeft / markerRowWidth : 0.5;
    final alignmentY = markerRowHeight > 0 ? yAlignmentRelativeToRowTopLeft / markerRowHeight : 0.5;

    final rotationAlignment = FractionalOffset(alignmentX, alignmentY);
    // ---------------------------------------------------------------------

    return Positioned(
      left: finalLeft,
      top: finalTop,
      child: GestureDetector(
        onTap: () => _showInfo(context),
        child: Transform.rotate(
          angle: -mapRotation, // Inverse of map's rotation
          alignment: rotationAlignment,
          child: markerContentRow,
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    // print("MapMarker - Image URL: $imageUrl"); // Debug log
    // print("MapMarker - Label: $label"); // Debug log

    if (imageUrl == null || imageUrl!.isEmpty) {
      print("MapMarker - No image URL available"); // Debug log
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(label ?? "Venue"),
          content: Text('No image available for ${label ?? "this venue"}.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
      return;
    }

    print("MapMarker - Showing image viewer with URL: $imageUrl"); // Debug log
    showDialog(
      context: context,
      builder: (context) => VenueImageViewer(
        title: label ?? "Venue",
        imageUrl: imageUrl!,
      ),
    );
  }
}