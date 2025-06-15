import 'package:flutter/material.dart';
import '../widgets/map_marker.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/navigation_bloc.dart';

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
  final List<MapMarker> venueNodes;
  final Function(MapMarker)? onSetAsSource;
  final Function(MapMarker)? onSetAsDestination;

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
    required this.showLocationPin,
    required this.venueNodes,
    this.onSetAsSource,
    this.onSetAsDestination,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InfoButton(
              venueNodes: venueNodes,
              onPressed: () {
                _showSearchDialog(context);
              },
            ),
          ),

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

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => VenueSearchDialog(
        onSetAsSource: onSetAsSource,
        onSetAsDestination: onSetAsDestination,
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
      backgroundColor: isEnabled ?  Color.fromARGB(255, 245, 197, 66) : Colors.grey,
      foregroundColor: Colors.black,
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
      backgroundColor:  Color.fromARGB(255, 245, 197, 66),
      foregroundColor: Colors.black,
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
      backgroundColor: isLoading||isEnabled
          ?  Color.fromARGB(255, 245, 197, 66) : Colors.grey,
      foregroundColor: Colors.black,
      child: Icon(
        Icons.arrow_forward,
        // color: (isLoading || !isEnabled) ? Colors.grey : Colors.white,
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
      backgroundColor:  Color.fromARGB(255, 245, 197, 66),
      foregroundColor: Colors.black,
      onPressed: onPressed,
      child: Icon(
        Icons.layers,
        // color: (isLoading || !isEnabled) ? Colors.grey : Colors.white,
      ),
    );
  }
}

class InfoButton extends StatelessWidget {
  final VoidCallback onPressed;
  final List<MapMarker> venueNodes;

  const InfoButton({
    super.key,
    required this.onPressed,
    required this.venueNodes,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'info',
      backgroundColor: Color.fromARGB(255, 245, 197, 66),
      foregroundColor: Colors.black,
      onPressed: onPressed,
      child: const Icon(Icons.info_outline),
    );
  }
}

class VenueSearchDialog extends StatefulWidget {
  final Function(MapMarker)? onSetAsSource;
  final Function(MapMarker)? onSetAsDestination;

  const VenueSearchDialog({
    super.key,
    this.onSetAsSource,
    this.onSetAsDestination,
  });

  @override
  State<VenueSearchDialog> createState() => _VenueSearchDialogState();
}

class _VenueSearchDialogState extends State<VenueSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<MapMarker> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    final state = context.read<NavigationBloc>().state;
    if (state is AllVenuesLoadedState && state.allVenuesName != null) {
      setState(() {
        _isSearching = true;
        // Flatten all venues from all floors into a single list
        final allVenues = state.allVenuesName!.values.expand((venues) => venues).toList();
        _searchResults = allVenues.where((marker) {
          final name = marker.label?.toLowerCase() ?? '';
          final fullName = marker.venueFullName?.toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();
          return name.contains(searchQuery) || fullName.contains(searchQuery);
        }).toList();
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () {
      _performSearch(query);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, state) {
        if (state is! AllVenuesLoadedState) {
          context.read<NavigationBloc>().add(LoadAllVenueNodesEvent());
          return const Dialog(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Enter venue name',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => _performSearch(_searchController.text),
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 16),
                if (_isSearching)
                  Expanded(
                    child: _searchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No venues found for "${_searchController.text}"',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final marker = _searchResults[index];
                              // Create a new marker with the callbacks
                              final markerWithCallbacks = MapMarker(
                                position: marker.position,
                                label: marker.label,
                                venueFullName: marker.venueFullName,
                                color: marker.color,
                                radius: marker.radius,
                                mapRotation: marker.mapRotation,
                                customIconData: marker.customIconData,
                                imageUrl: marker.imageUrl,
                                floorId: marker.floorId,
                                onSetAsSource: widget.onSetAsSource,
                                onSetAsDestination: widget.onSetAsDestination,
                              );
                              return ListTile(
                                title: Text(marker.label ?? 'Unknown Venue'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(marker.venueFullName ?? ''),
                                    Text(
                                      'Floor ${marker.floorId}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  markerWithCallbacks.showInfo(context);
                                },
                              );
                            },
                          ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}


