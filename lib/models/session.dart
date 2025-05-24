
import 'package:event_hub_and_navigation_app/models/venue.dart';

class Session {
  final int id;
  final String sessionName;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final List<Venue>? venues;

  Session({
    required this.id,
    required this.sessionName,
    required this.startDateTime,
    required this.endDateTime,
    this.venues = const [], // Default to empty list
  });


  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'] ,
      sessionName: json['sessionName'] as String,
      startDateTime: DateTime.parse(json['startDateTime'] as String),
      endDateTime: DateTime.parse(json['endDateTime'] as String),
      venues: (json['venues'] as List<dynamic>?)
          ?.map((v) => Venue.fromJson(v as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  static List<Session> fromJsonArray(List<dynamic> jsonArray){
    return jsonArray.map((json) => Session.fromJson(json)).toList();
  }
}