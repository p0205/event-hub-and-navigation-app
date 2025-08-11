import 'package:json_annotation/json_annotation.dart';

part 'qr_code_types.g.dart';

/// Base class for all QR code types
abstract class QRCodeData {
  final String type;
  final String id;

  const QRCodeData({required this.type, required this.id});

  factory QRCodeData.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    
    switch (type) {
      case 'venue':
        return VenueQRCode.fromJson(json);
      case 'attendance':
        return AttendanceQRCode.fromJson(json);
      // case 'event':
      //   return EventQRCode.fromJson(json);
      // case 'session':
      //   return SessionQRCode.fromJson(json);
      default:
        throw FormatException('Unknown QR code type: $type');
    }
  }
}

/// Venue QR code for navigation purposes
@JsonSerializable()
class VenueQRCode extends QRCodeData {
  final String name;
  final Map<String, double> coordinates;
  final int floorLevel;
  final String? venueId;
  final String? nodeId;
  final String? qrCodeId;

  const VenueQRCode({
    required super.id,
    required this.name,
    required this.coordinates,
    required this.floorLevel,
    this.venueId,
    this.nodeId,
    this.qrCodeId,
  }) : super(type: 'venue');

  factory VenueQRCode.fromJson(Map<String, dynamic> json) => 
      _$VenueQRCodeFromJson(json);
  
  Map<String, dynamic> toJson() => _$VenueQRCodeToJson(this);
}

/// Attendance QR code for marking attendance
@JsonSerializable()
class AttendanceQRCode extends QRCodeData {
  final int eventId;
  final String eventName;
  final int sessionId;
  final String sessionName;
  final DateTime startTime;
  final DateTime endTime;
  final String? venueName;
  final String? qrCodeId;

  const AttendanceQRCode({
    required super.id,
    required this.eventId,
    required this.eventName,
    required this.sessionId,
    required this.sessionName,
    required this.startTime,
    required this.endTime,
    this.venueName,
    this.qrCodeId,
  }) : super(type: 'attendance');

  factory AttendanceQRCode.fromJson(Map<String, dynamic> json) => 
      _$AttendanceQRCodeFromJson(json);
  
  Map<String, dynamic> toJson() => _$AttendanceQRCodeToJson(this);
}

// /// Event QR code for event information
// @JsonSerializable()
// class EventQRCode extends QRCodeData {
//   final String eventName;
//   final String? description;
//   final DateTime startDateTime;
//   final DateTime endDateTime;
//   final String? organizer;
//   final String? qrCodeId;

//   const EventQRCode({
//     required super.id,
//     required this.eventName,
//     this.description,
//     required this.startDateTime,
//     required this.endDateTime,
//     this.organizer,
//     this.qrCodeId,
//   }) : super(type: 'event');

//   factory EventQRCode.fromJson(Map<String, dynamic> json) => 
//       _$EventQRCodeFromJson(json);
  
//   Map<String, dynamic> toJson() => _$EventQRCodeToJson(this);
// }

// /// Session QR code for session information
// @JsonSerializable()
// class SessionQRCode extends QRCodeData {
//   final String sessionName;
//   final int eventId;
//   final String eventName;
//   final DateTime startDateTime;
//   final DateTime endDateTime;
//   final String? venueName;
//   final String? qrCodeId;

//   const SessionQRCode({
//     required super.id,
//     required this.sessionName,
//     required this.eventId,
//     required this.eventName,
//     required this.startDateTime,
//     required this.endDateTime,
//     this.venueName,
//     this.qrCodeId,
//   }) : super(type: 'session');

//   factory SessionQRCode.fromJson(Map<String, dynamic> json) => 
//       _$SessionQRCodeFromJson(json);
  
//   Map<String, dynamic> toJson() => _$SessionQRCodeToJson(this);
// }
