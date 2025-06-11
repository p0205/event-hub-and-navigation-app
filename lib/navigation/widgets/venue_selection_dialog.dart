import 'package:event_hub_and_navigation_app/navigation/widgets/map_marker.dart';
import 'package:flutter/material.dart';

class VenueSelectionDialog extends StatefulWidget {
  final Map<int, List<MapMarker>> venues;
  final String title;
  final Function(MapMarker) onVenueSelected;

  const VenueSelectionDialog({
    super.key,
    required this.venues,
    required this.title,
    required this.onVenueSelected,
  });

  @override
  State<VenueSelectionDialog> createState() => _VenueSelectionDialogState();
}

class _VenueSelectionDialogState extends State<VenueSelectionDialog> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Map<int, List<MapMarker>> _filteredVenues = {};

  @override
  void initState() {
    super.initState();
    _filteredVenues = Map.from(widget.venues);
    _searchController.addListener(_filterVenues);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterVenues);
    _searchController.dispose();
    super.dispose();
  }

  void _filterVenues() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredVenues = Map.from(widget.venues);
      } else {
        _filteredVenues = {};
        widget.venues.forEach((floorId, venues) {
          final matchingVenues = venues
              .where((venue) => venue.label!.toLowerCase().contains(query))
              .toList();
          if (matchingVenues.isNotEmpty) {
            _filteredVenues[floorId] = matchingVenues;
          }
        });
      }
    });
  }

  String _getFloorName(int floorId) {
    switch (floorId) {
      case 1:
        return 'Ground Floor';
      default:
        return 'Level $floorId';
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedFloorIds = _filteredVenues.keys.toList()..sort((a, b) => b.compareTo(a));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search venues...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterVenues();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              ),
              onChanged: (value) {
                // onChanged calls _filterVenues directly
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: sortedFloorIds.isEmpty && _searchQuery.isNotEmpty
                  ? Center(
                      child: Text(
                        'No venues found matching "${_searchQuery}".',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: sortedFloorIds.length,
                      itemBuilder: (context, index) {
                        final floorId = sortedFloorIds[index];
                        final venuesOnFloor = _filteredVenues[floorId]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 8.0,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                _getFloorName(floorId),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...venuesOnFloor.map((venue) => ListTile(
                              leading: Icon(Icons.location_on, 
                                color: Theme.of(context).primaryColor.withOpacity(0.7)
                              ),
                              title: Text(venue.label!),
                              onTap: () {
                                widget.onVenueSelected(venue);
                                Navigator.pop(context);
                              },
                            )),
                            if (index < sortedFloorIds.length - 1)
                              const Divider(height: 24, thickness: 0.8, indent: 16, endIndent: 16),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}