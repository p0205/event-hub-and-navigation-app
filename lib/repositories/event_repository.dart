import 'dart:io';

import 'package:dio/dio.dart';
import 'package:event_hub_and_navigation_app/home/models/calendar_event.dart';
import 'package:event_hub_and_navigation_app/models/event.dart';

import '../services/api.dart';

class EventRepository {
  EventRepository();

  Future<List<CalendarEvent>> getCalendarEvents(int userId) async {
    try {
      final response = await ApiService.get(
        '/events/calendar',
        queryParameters: {'userId': userId}, // Pass userId as a query parameter
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
        print(
            'DIO_EXCEPTION_DEBUG: Response Status Code: ${e.response?.statusCode}');
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

  Future<List<Event>> fetchMyUpcomingEvents(int userId) async {
    try {
      final response = await ApiService.get(
          '/events/participant/upcoming-events',  queryParameters:{'userId': userId});
      if (response.statusCode == HttpStatus.ok) {
        List<Event> events = Event.fromJsonArray(response.data);
        return events;
      } else {
        throw Exception(
            'Failed to load upcoming events: ${response.statusCode}');
      }
    }  catch (e) {
      // Catch any other exceptions
      print('UNEXPECTED_ERROR_DEBUG: $e');
      rethrow; // Re-throw the exception
    }
  }

  Future<List<CalendarEvent>> fetchAllCalendarEventsByMonth(DateTime startDateTime, DateTime endDateTime) async {
    try {
      print('DEBUG: Requesting all calendar events with params:');

      print('DEBUG: startDateTime: ${startDateTime.toIso8601String()}');
      print('DEBUG: endDateTime: ${endDateTime.toIso8601String()}');

      final response = await ApiService.get(
          '/events/calendar/all-events',
          queryParameters: {

            'startDateTime': startDateTime.toIso8601String(),
            'endDateTime': endDateTime.toIso8601String()
          }
      );

      print('DEBUG: Response status code: ${response.statusCode}');
      print('DEBUG: Response data: ${response.data}');

      if (response.statusCode == HttpStatus.ok) {
        List<dynamic> eventJsonList = response.data;
        return eventJsonList
            .map((json) => CalendarEvent.fromJson(json))
            .toList();

      } else {
        throw Exception(
            'Failed to load upcoming events: ${response.statusCode}');
      }
    }  catch (e) {
      // Catch any other exceptions
      print('UNEXPECTED_ERROR_DEBUG: $e');
      rethrow; // Re-throw the exception
    }
  }



  Future<List<CalendarEvent>> fetchMyCalendarEventsByMonth(int userId, DateTime startDateTime, DateTime endDateTime) async {
    try {
      print('DEBUG: Requesting calendar events with params:');
      print('DEBUG: userId: $userId');
      print('DEBUG: startDateTime: ${startDateTime.toIso8601String()}');
      print('DEBUG: endDateTime: ${endDateTime.toIso8601String()}');
      
      final response = await ApiService.get(
          '/events/participant/calendar-events',  
          queryParameters: {
            'userId': userId, 
            'startDateTime': startDateTime.toIso8601String(), 
            'endDateTime': endDateTime.toIso8601String()
          }
      );
      
      print('DEBUG: Response status code: ${response.statusCode}');
      print('DEBUG: Response data: ${response.data}');
      
      if (response.statusCode == HttpStatus.ok) {
        List<dynamic> eventJsonList = response.data;
        return eventJsonList
            .map((json) => CalendarEvent.fromJson(json))
            .toList();

      } else {
        throw Exception(
            'Failed to load upcoming events: ${response.statusCode}');
      }
    }  catch (e) {
      // Catch any other exceptions
      print('UNEXPECTED_ERROR_DEBUG: $e');
      rethrow; // Re-throw the exception
    }
  }

  Future<List<Event>> fetchMyPastEvents(int userId) async {
    try {
      final response = await ApiService.get(
          '/events/participant/past-events',  queryParameters:{'userId': userId});
      if (response.statusCode == HttpStatus.ok) {
        List<Event> events = Event.fromJsonArray(response.data);
        return events;
      } else {
        throw Exception(
            'Failed to load upcoming events: ${response.statusCode}');
      }
    }  catch (e) {
      // Catch any other exceptions
      print('UNEXPECTED_ERROR_DEBUG: $e');
      rethrow; // Re-throw the exception
    }
  }


  Future<Event> fetchEventDetails(int eventId) async {
    try {
      final response = await ApiService.get(
          '/events/$eventId/details');
      if (response.statusCode == HttpStatus.ok) {
        Event eventDetails = Event.fromJson(response.data);
        return eventDetails;
      } else {
        throw Exception(
            'Failed to load event details: ${response.statusCode}');
      }
    }  catch (e) {
      // Catch any other exceptions
      print('UNEXPECTED_ERROR_DEBUG: $e');
      rethrow; // Re-throw the exception
    }
  }

  Future<void> takeAttendance(String qrCodePayload, int userId) async {
    try {
      final response = await ApiService.post(
          '/check-in', data: {
            "qrCodePayload": qrCodePayload,
        "participantId": userId
      });
      if (response.statusCode != HttpStatus.ok) {
        throw Exception(
            'Failed to check in: ${response.data}');
      }

    } catch (e) {
      // Catch any other exceptions
      print('Failed to check inÏ: $e');
      rethrow; // Re-throw the exception
    }
  }
}
