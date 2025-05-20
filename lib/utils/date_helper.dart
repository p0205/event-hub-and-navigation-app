// Helper functions for DateTime serialization/deserialization
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
}
