
// Helper functions for DateTime serialization/deserialization
import 'package:event_hub_and_navigation_app/utils/date_helper.dart';
import 'package:json_annotation/json_annotation.dart';


@JsonSerializable()
class CalendarEvent {
  final int? eventId;
  final String? eventName;
  final int? sessionId;
  final String? sessionName;

  final String? startDateTime;

  final String? endDateTime;
  final String? venueNames;

  CalendarEvent({
    this.eventId,
    this.eventName,
    this.sessionId,
    this.sessionName,
    this.startDateTime,
    this.endDateTime,
    this.venueNames,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      eventId: json['eventId'],
      eventName: json['eventName'],
      sessionId: json['sessionId'],
      sessionName: json['sessionName'],
      startDateTime: json['startDateTime'],
      endDateTime: json['endDateTime'],
      venueNames: json['venueNames'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventId': eventId,
      'eventName': eventName,
      'sessionId': sessionId,
      'sessionName': sessionName,
      'startDateTime':startDateTime,
      'endDateTime': endDateTime,
      'venueNames': venueNames,
    };
  }
}
