import 'package:flutter/material.dart';

class NavigationButtonGroup extends StatelessWidget {
  final bool isNavigatingStatus ;
  final VoidCallback onCenterPressed;
  final VoidCallback onNavigationPressed;
  final VoidCallback onShowLocationPinPressed;
  final VoidCallback onChangeFloorButtonPressed;
  final bool isCenterEnabled;
  final bool isNavigationEnabled;
  final bool isLoading;
  final bool showLocationPin;

  const NavigationButtonGroup({
    super.key,
    required this.isNavigatingStatus,
    required this.onCenterPressed,
    required this.onNavigationPressed,
    required this.onShowLocationPinPressed,
    required this.onChangeFloorButtonPressed,
    required this.isCenterEnabled,
    required this.isNavigationEnabled,
    required this.isLoading,
    required this.showLocationPin
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          if(isNavigatingStatus)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: NavigationButton(
              onPressed: onNavigationPressed,
              isEnabled: isNavigationEnabled,
              isLoading: isLoading,
            ),
          ),

          if(isNavigatingStatus)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CenterLocationButton(
              onPressed: onCenterPressed,
              isEnabled: isCenterEnabled,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TogglePinVisibilityButton(
              showLocationPin: showLocationPin,
              onPressed: onShowLocationPinPressed,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChangeFloorButton(
              onPressed: onChangeFloorButtonPressed,
            ),
          )
        ],
      ),
    );
  }
}

class CenterLocationButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isEnabled;

  const CenterLocationButton({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'centerLocation',
      onPressed: isEnabled ? onPressed : null,
      backgroundColor: isEnabled ? Theme.of(context).primaryColor : Colors.grey,
      foregroundColor: Colors.white,
      child: const Icon(Icons.my_location),
    );
  }
}

class TogglePinVisibilityButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool showLocationPin;

  const TogglePinVisibilityButton({
    super.key,
    required this.onPressed,
    this.showLocationPin = true,
  });

  @override
  State<TogglePinVisibilityButton> createState() => _TogglePinVisibilityButtonState();
}



class _TogglePinVisibilityButtonState extends State<TogglePinVisibilityButton> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'toggleVisibility',
      onPressed: widget.onPressed,
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      child: Icon(
        widget.showLocationPin ? Icons.visibility : Icons.visibility_off,
      ),
    );
  }
}

class NavigationButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isEnabled;
  final bool isLoading;

  const NavigationButton({
    super.key,
    required this.onPressed,
    required this.isEnabled,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'navigation',
      onPressed: isEnabled ? onPressed : null,
      backgroundColor: isLoading
          ? Colors.grey.withOpacity(0.5)
          : Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      child: Icon(
        Icons.arrow_forward,
        color: (isLoading || !isEnabled) ? Colors.grey : Colors.white,
      ),
    );
  }
}


class ChangeFloorButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ChangeFloorButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'change_floor',

      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      onPressed: onPressed,
      child: Icon(
        Icons.layers,
        // color: (isLoading || !isEnabled) ? Colors.grey : Colors.white,
      ),
    );
  }
}


