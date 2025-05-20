class CalendarEvent {
  final int? eventId;
  final String? eventName;
  final int? sessionId;
  final String? sessionName;
  final DateTime? startDateTime; // Maps to LocalDateTime
  final DateTime? endDateTime; // Maps to LocalDateTime
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
      'startDateTime': startDateTime,
      'endDateTime': endDateTime,
      'venueNames': venueNames,
    };
  }
}
