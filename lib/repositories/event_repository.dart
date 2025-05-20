import 'package:dio/dio.dart';
import 'package:event_hub_and_navigation_app/home/models/calendar_event.dart';

import '../services/api.dart';

class EventRepository {
  EventRepository();


  Future<List<CalendarEvent>> getCalendarEvents(int userId) async {
    try {
      final response = await ApiService.get(
        '/events/calendar', {'userId': userId}, // Pass userId as a query parameter
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
      // *** IMPORTANT: Print the full DioException object here ***
      print('DIO_EXCEPTION_DEBUG: Type: ${e.type}');
      print('DIO_EXCEPTION_DEBUG: Message: ${e.message}');
      print('DIO_EXCEPTION_DEBUG: Error: ${e.error}');
      print('DIO_EXCEPTION_DEBUG: Request Options: ${e.requestOptions.uri}');
      if (e.response != null) {
        print('DIO_EXCEPTION_DEBUG: Response Status Code: ${e.response?.statusCode}');
        print('DIO_EXCEPTION_DEBUG: Response Data: ${e.response?.data}');
        print('DIO_EXCEPTION_DEBUG: Response Headers: ${e.response?.headers}');
      } else {
        print('DIO_EXCEPTION_DEBUG: No response received.');
      }
      // Re-throw the exception so your BLoC still catches it
      rethrow;
    } catch (e) {
      // Catch any other exceptions
      print('UNEXPECTED_ERROR_DEBUG: $e');
      rethrow; // Re-throw the exception
    }
  }
}
