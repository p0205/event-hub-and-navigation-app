part of 'event_bloc.dart';

sealed class MyEventsCalendarViewState extends Equatable {
  const MyEventsCalendarViewState();

  @override
  List<Object> get props => [];
}

final class CalendarEventInitialState extends MyEventsCalendarViewState {}

final class CalendarEventLoadingState extends MyEventsCalendarViewState {}

final class CalendarEventErrorState extends MyEventsCalendarViewState {
  final String message;

  const CalendarEventErrorState(this.message);

  @override
  List<Object> get props => [message];
}



final class CalenderEventLoadedState extends MyEventsCalendarViewState {
  final List<CalendarEvent> events;

  const CalenderEventLoadedState(this.events);

  @override
  List<Object> get props => [events];
}

