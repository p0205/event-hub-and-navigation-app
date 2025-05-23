// Helper functions for DateTime serialization/deserialization
import 'package:intl/intl.dart';

class DateHelper {
  static DateTime? dateTimeFromString(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }
    try {
      return DateTime.parse(jsonString)
          .toLocal(); // Parse and convert to local time
    } catch (e) {
      print('Error parsing DateTime: $jsonString - $e');
      return null;
    }
  }

  static String? dateTimeToString(DateTime? dateTime) {
    // Convert to UTC and then to ISO 8601 string for consistent backend handling
    return dateTime?.toUtc().toIso8601String();
  }

  // Formats a DateTime object to a readable date string (e.g., "Fri, 21 March 2025")
  static String formatDate(DateTime dateTime) {
    return DateFormat('EEE, dd MMMM yyyy').format(dateTime);
  }

  // Formats a DateTime object to a readable time string (e.g., "10:30 AM")
  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }



}
