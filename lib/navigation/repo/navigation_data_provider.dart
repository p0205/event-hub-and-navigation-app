// lib/services/navigation_api.dart
import 'dart:collection';
import 'dart:convert';
import 'package:event_hub_and_navigation_app/utils/constant.dart';
import 'package:http/http.dart' as http;

import '../models/find_path_response.dart';
import '../widgets/map_marker.dart';

class NavigationDataProvider {
  // Cache for all venues and stairs
  static Map<String, List<MapMarker>>? _cachedVenues;
  static List<String> _allVenuesName = [];

  static bool _isInitialized = false;

  NavigationDataProvider({http.Client? httpClient});

  static Future<Map<String,dynamic>> getVenueNodes(int currentFloorId) async {
    // If not initialized, fetch all venues first
    if (!_isInitialized) {
      await _initializeVenues();
    }



    // Filter venues and stairs based on floor_id
    final List<MapMarker> filteredVenues = _cachedVenues!['venues']!
        .where((venue) => venue.floorId == currentFloorId)
        .toList();
    
    final List<MapMarker> filteredStairs = _cachedVenues!['stairs']!
        .where((stair) => stair.floorId == currentFloorId)
        .toList();



    return {
      'venues': filteredVenues,
      'stairs': filteredStairs,
      'allVenuesName' : _allVenuesName
    };
  }

  static Future<void> _initializeVenues() async {
    print("Initializing venues data");
    final url = Uri.parse('${AppConstants.BaseUrl}${AppConstants.NaviPort}/venues');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> venuesJson = data['venues'] as List<dynamic>;
        final List<dynamic> stairsJson = data['stair_nodes'] as List<dynamic>;
        
        final List<MapMarker> venues = venuesJson
            .map((venueJson) => MapMarker.fromJson(venueJson as Map<String, dynamic>))
            .toList();

        for(MapMarker venue in venues){
          _allVenuesName.add(venue.label!);
        }

        final List<MapMarker> stairs = stairsJson
            .map((stairJson) => MapMarker.fromJson(stairJson as Map<String, dynamic>))
            .toList();
        
        _cachedVenues = {
          'venues': venues,
          'stairs': stairs,
        };
        _isInitialized = true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load venues');
      }
    } catch (e) {
      print("error: ${e.toString()}");
      throw Exception('Failed to connect to server: $e');
    }
  }

  static Future<NavigationResponse> getNavigationPath({
    required String source,
    required String destination,
  }) async {
    print("data provider: getNavigationPath");
    final url = Uri.parse('${AppConstants.BaseUrl+AppConstants.NaviPort}/find_path');
    print(url);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'source': source,
          'destination': destination,
        }),
      );
      print(response.body);
      print(source);
      print(destination);
      print(jsonEncode({
        'source': source,
        'destination': destination,
      }));
      print(response.statusCode);

      if (response.statusCode == 200) {
        return NavigationResponse.fromJson(jsonDecode(response.body));
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to load navigation path');
      }
    } catch (e) {

      throw Exception('Failed to connect to server: $e');
    }
  }
}