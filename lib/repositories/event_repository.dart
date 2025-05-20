import 'package:dio/dio.dart';
import 'package:event_hub_and_navigation_app/home/models/calendar_event.dart';

import '../services/api.dart';

class EventRepository {
  EventRepository();

  Future<List<CalendarEvent>> getCalendarEvents(int userId) async {
    try {
      final response = await ApiService.get(
        '/calendar', {'userId': userId}, // Pass userId as a query parameter
      );

      if (response.statusCode == 200) {
        // Assuming the backend returns a list of JSON objects
        List<dynamic> eventJsonList = response.data;
        return eventJsonList
            .map((json) => CalendarEvent.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to load calendar events: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      if (e.response != null) {
        // Server responded with an error status code
        throw Exception(
            'Server error fetching events: ${e.response?.statusCode} - ${e.response?.data}');
      } else {
        // Request error (e.g., network issues)
        throw Exception('Network error fetching events: ${e.message}');
      }
    } catch (e) {
      // Catch any other exceptions
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
