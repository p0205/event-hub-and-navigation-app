// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_code_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VenueQRCode _$VenueQRCodeFromJson(Map<String, dynamic> json) => VenueQRCode(
      id: json['id'] as String,
      name: json['name'] as String,
      coordinates: (json['coordinates'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      floorLevel: (json['floorLevel'] as num).toInt(),
      venueId: json['venueId'] as String?,
      nodeId: json['nodeId'] as String?,
      qrCodeId: json['qrCodeId'] as String?,
    );

Map<String, dynamic> _$VenueQRCodeToJson(VenueQRCode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'coordinates': instance.coordinates,
      'floorLevel': instance.floorLevel,
      'venueId': instance.venueId,
      'nodeId': instance.nodeId,
      'qrCodeId': instance.qrCodeId,
    };

AttendanceQRCode _$AttendanceQRCodeFromJson(Map<String, dynamic> json) =>
    AttendanceQRCode(
      id: json['id'] as String,
      eventId: (json['eventId'] as num).toInt(),
      eventName: json['eventName'] as String,
      sessionId: (json['sessionId'] as num).toInt(),
      sessionName: json['sessionName'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      venueName: json['venueName'] as String?,
      qrCodeId: json['qrCodeId'] as String?,
    );

Map<String, dynamic> _$AttendanceQRCodeToJson(AttendanceQRCode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'eventId': instance.eventId,
      'eventName': instance.eventName,
      'sessionId': instance.sessionId,
      'sessionName': instance.sessionName,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'venueName': instance.venueName,
      'qrCodeId': instance.qrCodeId,
    };


