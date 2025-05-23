import 'package:event_hub_and_navigation_app/models/session.dart';

class Event {
  final int id;
  final String eventName;
  final String? description;
  final String? registerDate;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String? organizer;
  final String? picName;
  final String? picContact;
  final List<Session>? sessions;

  Event({
    required this.id,
    required this.eventName,
    this.description,
    this.registerDate,
    required this.startDateTime,
    required this.endDateTime,
    this.organizer,
    this.picName,
    this.picContact,
    this.sessions = const [], // Default to empty list
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      eventName: json['eventName'] as String,
      description: json['description'] as String?,
      registerDate: json['registerDate'] as String?,
      startDateTime: DateTime.parse(json['startDateTime'] as String),
      endDateTime: DateTime.parse(json['endDateTime'] as String),
      organizer: json['organizer'] as String?,
      picName: json['picName'] as String?,
      picContact: json['picContact'] as String?,
      sessions: (json['sessions'] as List<dynamic>?)
              ?.map((s) => Session.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static List<Event> fromJsonArray(List<dynamic> jsonArrray){
    return jsonArrray.map((json) => Event.fromJson(json)).toList();
  }
}
