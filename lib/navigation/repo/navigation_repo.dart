// lib/services/navigation_api.dart
import 'package:event_hub_and_navigation_app/navigation/widgets/map_marker.dart';

import '../models/find_path_response.dart';
import 'navigation_data_provider.dart';

class NavigationRepo {
  final NavigationDataProvider dataProvider = NavigationDataProvider();

  static Future<NavigationResponse> getNavigationPath({
    required String source,
    required String destination,
  }) async {
    return await NavigationDataProvider.getNavigationPath(
        source: source, destination: destination);
  }

  static Future<Map<String, dynamic>> getVenueNodes(int currentFloorId) async {

    return await NavigationDataProvider.getVenueNodes(currentFloorId);
  }

  static Future<Map<int, List<MapMarker>>> getAllVenuesName() async {

    return await NavigationDataProvider.getAllVenuesName();
  }
}
