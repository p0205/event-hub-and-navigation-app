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



final class FetchEventDetails extends EventEvent {
 final int eventId;

  const FetchEventDetails({required this.eventId});


  @override
  List<Object> get props => [];
}
