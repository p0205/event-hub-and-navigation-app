import 'dart:convert';
import 'package:event_hub_and_navigation_app/models/qr_code_types.dart';
import 'package:event_hub_and_navigation_app/navigation/bloc/navigation_bloc.dart';


/// Service to handle different types of QR codes
class QRCodeHandlerService {
  static QRCodeData? parseQRCode(String qrDataString) {
    try {
      final Map<String, dynamic> jsonData = json.decode(qrDataString);

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
        id: data['id']?.toString() ?? '',
        eventId: data['eventId'],
        eventName: data['eventName']?.toString() ?? '',
        sessionId: data['sessionId'],
        sessionName: data['sessionName']?.toString() ?? '',
        startTime: DateTime.tryParse(data['startTime']?.toString() ?? '') ??
            DateTime.now(),
        endTime: DateTime.tryParse(data['endTime']?.toString() ?? '') ??
            DateTime.now(),
        venueName: data['venueName']?.toString(),
        qrCodeId: data['qr_code_id']?.toString(),
      );
    }

    return null;
  }

  /// Handle QR code based on its type and dispatch events if needed
static void _handleVenueQRCode(
    VenueQRCode venueQR, NavigationBloc? navigationBloc) {
  print('📍 [QRCodeHandler] Handling Venue QR Code:');
  print('  Name: ${venueQR.name}');
  print('  Floor: ${venueQR.floorLevel}');
  print('  Coordinates: (${venueQR.coordinates['x']}, ${venueQR.coordinates['y']})');

  // If navigation bloc is provided, dispatch SelectSourceFromQR event
  if (navigationBloc != null) {
    final qrData = {
      'id': venueQR.id,
      'name': venueQR.name,
      'coordinates': venueQR.coordinates,
      'floor_level': venueQR.floorLevel,
      'venue_id': venueQR.venueId,
      'node_id': venueQR.nodeId,
      'qr_code_id': venueQR.qrCodeId,
    };

    navigationBloc.add(SelectSourceFromQR(qrData: qrData));
    print('✅ [QRCodeHandler] SelectSourceFromQR event dispatched successfully');
  } else {
    print('⚠️ [QRCodeHandler] No navigation bloc provided - cannot dispatch event');
  }
}

// Update the main handleQRCode method signature (remove context parameter)
static void handleQRCode(QRCodeData qrCode, {NavigationBloc? navigationBloc}) {
  print('🔍 [QRCodeHandler] Handling QR code of type: ${qrCode.runtimeType}');

  switch (qrCode.runtimeType) {
    case VenueQRCode:
      print('📍 [QRCodeHandler] Processing Venue QR Code');
      _handleVenueQRCode(qrCode as VenueQRCode, navigationBloc);
      break;
    case AttendanceQRCode:
      print('📅 [QRCodeHandler] Processing Attendance QR Code');
      _handleAttendanceQRCode(qrCode as AttendanceQRCode);
      break;
    default:
      print('❓ [QRCodeHandler] Unknown QR code type: ${qrCode.runtimeType}');
  }
}

  static void _handleAttendanceQRCode(AttendanceQRCode attendanceQR) {
    print('📅 [QRCodeHandler] Handling Attendance QR Code:');
    print('  Event: ${attendanceQR.eventName}');
    print('  Session: ${attendanceQR.sessionName}');
    print('  Time: ${attendanceQR.startTime} - ${attendanceQR.endTime}');
    print('  Venue: ${attendanceQR.venueName ?? 'Not specified'}');
    // This should trigger attendance marking - the QR scanner will handle the UI
    print(
        '✅ [QRCodeHandler] Attendance QR code processed - UI will be handled by scanner');
  }
}
