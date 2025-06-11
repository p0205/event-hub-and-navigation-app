part of 'home_bloc.dart';

@immutable
sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class FetchCalendarEvents extends HomeEvent {
  final int userId;

  const FetchCalendarEvents(this.userId);

  @override
  List<Object> get props => [userId];
}

class FetchAllCalendarEventsByMonth extends HomeEvent {

  final DateTime startDateTime;
  final DateTime endDateTime;

  const FetchAllCalendarEventsByMonth({required this.startDateTime,required this.endDateTime});

  @override
  List<Object> get props => [startDateTime,endDateTime];
}

