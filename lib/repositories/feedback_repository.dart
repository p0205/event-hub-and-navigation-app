import 'package:event_hub_and_navigation_app/models/feedback.dart';
import 'package:event_hub_and_navigation_app/services/api.dart';

class FeedbackRepository {


  Future<void> addFeedback(int eventId, Feedback feedback) async {
    try {
      await ApiService.post(
          '/event/$eventId/feedback', data: feedback.toJson());
    } catch (e) {
      // Catch any other exceptions
      print('UNEXPECTED_ERROR_DEBUG: $e');
      rethrow; // Re-throw the exception
    }
  }

  // Add this method to your FeedbackRepository class

  Future<bool> checkUserFeedbackExists({
    required int eventId,
    required int userId,
  }) async {
    try {
      // Replace this with your actual API endpoint
      final response = await ApiService.get('/event/$eventId/feedback?userId=$userId');

      if (response.statusCode == 200) {
        final data = response.data;
        return data['hasFeedback'] ?? false;
      } else {
        throw Exception('Failed to check feedback status');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

// Alternative implementation if you're using a local database:
/*
Future<bool> checkUserFeedbackExists({
  required int eventId,
  required int userId,
}) async {
  try {
    final db = await database;
    final result = await db.query(
      'feedback',
      where: 'event_id = ? AND user_id = ?',
      whereArgs: [eventId, userId],
      limit: 1,
    );

    return result.isNotEmpty;
  } catch (e) {
    throw Exception('Database error: ${e.toString()}');
  }
}
*/

}