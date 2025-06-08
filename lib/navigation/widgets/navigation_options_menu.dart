import 'package:flutter/material.dart';

class NavigationOptionsMenu extends StatefulWidget {
  final Function(bool isStepByStep) onNavigationOptionSelected;

  const NavigationOptionsMenu({
    super.key,
    required this.onNavigationOptionSelected,
  });

  @override
  State<NavigationOptionsMenu> createState() => _NavigationOptionsMenuState();
}

class _NavigationOptionsMenuState extends State<NavigationOptionsMenu> {
  bool isStepByStepNavigation = true;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Navigation Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onNavigationOptionSelected(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:  Color.fromARGB(255, 245, 197, 66),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_walk),
                  SizedBox(width: 8),
                  Text(
                    'Start Navigation',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onNavigationOptionSelected(false);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:  Color.fromARGB(255, 245, 197, 66),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map),
                  SizedBox(width: 8),
                  Text(
                    'View Path on Map',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}