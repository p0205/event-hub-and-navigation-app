part of 'event_bloc.dart';

@immutable
sealed class MyEventsCalendarViewEvent extends Equatable {
  const MyEventsCalendarViewEvent();

  @override
  List<Object> get props => [];
}

final class FetchMyUpcomingEvents extends MyEventsCalendarViewEvent {

  final int userId;

  const FetchMyUpcomingEvents({required this.userId});

  @override
  List<Object> get props => [];
}


final class FetchMyPastEvents extends MyEventsCalendarViewEvent {

  final int userId;

  const FetchMyPastEvents({required this.userId});

  @override
  List<Object> get props => [];
}

