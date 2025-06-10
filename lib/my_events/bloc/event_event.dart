part of 'event_bloc.dart';

@immutable
sealed class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object> get props => [];
}

final class FetchMyUpcomingEvents extends EventEvent {

  final int userId;

  const FetchMyUpcomingEvents({required this.userId});

  @override
  List<Object> get props => [];
}


final class FetchMyPastEvents extends EventEvent {

  final int userId;

  const FetchMyPastEvents({required this.userId});

  @override
  List<Object> get props => [];
}



class FetchMyCalendarEventsByMonth extends EventEvent {
  final int userId;
  final DateTime startDateTime;
  final DateTime endDateTime;

  const FetchMyCalendarEventsByMonth({required this.userId,required this.startDateTime,required this.endDateTime});

  @override
  List<Object> get props => [userId];
}



final class FetchEventDetails extends EventEvent {
 final int eventId;

  const FetchEventDetails({required this.eventId});


  @override
  List<Object> get props => [];
}
