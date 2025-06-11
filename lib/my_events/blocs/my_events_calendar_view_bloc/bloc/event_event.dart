part of 'event_bloc.dart';

@immutable
sealed class CalendarViewEvent extends Equatable {
  const CalendarViewEvent();

  @override
  List<Object> get props => [];
}

final class FetchMyUpcomingEvents extends CalendarViewEvent {

  final int userId;

  const FetchMyUpcomingEvents({required this.userId});

  @override
  List<Object> get props => [];
}


final class FetchMyPastEvents extends CalendarViewEvent {

  final int userId;

  const FetchMyPastEvents({required this.userId});

  @override
  List<Object> get props => [];
}



class FetchMyCalendarEventsByMonth extends CalendarViewEvent {
  final int userId;
  final DateTime startDateTime;
  final DateTime endDateTime;

  const FetchMyCalendarEventsByMonth({required this.userId,required this.startDateTime,required this.endDateTime});

  @override
  List<Object> get props => [userId];
}



final class FetchEventDetails extends CalendarViewEvent {
 final int eventId;

  const FetchEventDetails({required this.eventId});


  @override
  List<Object> get props => [];
}
