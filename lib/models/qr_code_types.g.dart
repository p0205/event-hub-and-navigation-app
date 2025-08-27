// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_code_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VenueQRCode _$VenueQRCodeFromJson(Map<String, dynamic> json) => VenueQRCode(
      id: json['id'] as String?,
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
      eventId: (json['eventId'] as num).toInt(),
      sessionId: (json['sessionId'] as num).toInt(),
    );

Map<String, dynamic> _$AttendanceQRCodeToJson(AttendanceQRCode instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'sessionId': instance.sessionId,
    };
