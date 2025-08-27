import 'dart:convert';
import 'package:event_hub_and_navigation_app/models/qr_code_types.dart';
import 'package:event_hub_and_navigation_app/navigation/bloc/navigation_bloc.dart';
import 'package:event_hub_and_navigation_app/repositories/event_repository.dart';


/// Service to handle different types of QR codes
class QRCodeHandlerService {
  static QRCodeData? parseQRCode(String qrDataString) {
    try {
      print(qrDataString);
      final Map<String, dynamic> jsonData = json.decode(qrDataString);

      print('Parsed JSON data: $jsonData');
      // Check if the QR code has a type field
      if (!jsonData.containsKey('type')) {
        // Try to infer type from available fields
        return _inferQRCodeType(jsonData);
      }

      return QRCodeData.fromJson(jsonData);
    } catch (e) {
      print('Error parsing QR code: $e');
      return null;
    }
  }

  /// Infer QR code type based on available fields
  static QRCodeData? _inferQRCodeType(Map<String, dynamic> data) {
    // Check for venue QR code (has coordinates and floor_level)
    if (data.containsKey('coordinates') && data.containsKey('floor_level')) {
      return VenueQRCode(
        id: data['id']?.toString() ?? '',
        name: data['name']?.toString() ?? '',
        coordinates: {
          'x': (data['coordinates']['x'] ?? 0.0).toDouble(),
          'y': (data['coordinates']['y'] ?? 0.0).toDouble(),
        },
        floorLevel: data['floor_level'] ?? 1,
        venueId: data['venue_id']?.toString(),
        nodeId: data['node_id']?.toString(),
        qrCodeId: data['qr_code_id']?.toString(),
      );
    }

    // Check for attendance QR code (has event and session info with startTime/endTime)
    if (data.containsKey('eventId') &&
        data.containsKey('sessionId') &&
        (data.containsKey('startTime') || data.containsKey('endTime'))) {
      return AttendanceQRCode(

        eventId: data['eventId'],

        sessionId: data['sessionId'],

      );
    }

    return null;
  }



  static void handleAttendanceQRCode(String qrCodePayload, int userId) async {
    print('📅 [QRCodeHandler] Handling Attendance QR Code:');
    try {
      EventRepository repo = EventRepository();
      await repo.takeAttendance(qrCodePayload, userId);
      print('✅ [QRCodeHandler] Attendance check-in request sent successfully.');
    } catch (e) {
      print('❌ [QRCodeHandler] Failed to send attendance check-in request: $e');
    }
  }
}
