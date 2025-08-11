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
    if (data.containsKey('eventId') && data.containsKey('sessionId') && 
        (data.containsKey('startTime') || data.containsKey('endTime'))) {
      return AttendanceQRCode(
        id: data['id']?.toString() ?? '',
        eventId: data['eventId'],
        eventName: data['eventName']?.toString() ?? '',
        sessionId: data['sessionId'],
        sessionName: data['sessionName']?.toString() ?? '',
        startTime: DateTime.tryParse(data['startTime']?.toString() ?? '') ?? DateTime.now(),
        endTime: DateTime.tryParse(data['endTime']?.toString() ?? '') ?? DateTime.now(),
        venueName: data['venueName']?.toString(),
        qrCodeId: data['qr_code_id']?.toString(),
      );
    }
    
    return null;
  }

  /// Handle QR code based on its type and dispatch events if needed
  static void handleQRCode(QRCodeData qrCode, {NavigationBloc? navigationBloc}) {
    switch (qrCode.runtimeType) {
      case VenueQRCode:
        _handleVenueQRCode(qrCode as VenueQRCode, navigationBloc);
        break;
      case AttendanceQRCode:
        _handleAttendanceQRCode(qrCode as AttendanceQRCode);
        break;
      default:
        print('Unknown QR code type: ${qrCode.runtimeType}');
    }
  }

  static void _handleVenueQRCode(VenueQRCode venueQR, NavigationBloc? navigationBloc) {
    print('Handling Venue QR Code:');
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
      
      print('Dispatching SelectSourceFromQR event with data: $qrData');
      navigationBloc.add(SelectSourceFromQR(qrData: qrData));
    }
  }

  static void _handleAttendanceQRCode(AttendanceQRCode attendanceQR) {
    print('Handling Attendance QR Code:');
    print('  Event: ${attendanceQR.eventName}');
    print('  Session: ${attendanceQR.sessionName}');
    print('  Time: ${attendanceQR.startTime} - ${attendanceQR.endTime}');
    // This should trigger attendance marking
  }
}
