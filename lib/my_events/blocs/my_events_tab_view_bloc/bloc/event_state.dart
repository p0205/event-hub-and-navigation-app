part of 'event_bloc.dart';

sealed class MyEventsTabViewState extends Equatable {
  const MyEventsTabViewState();

  @override
  List<Object> get props => [];
}

final class EventInitialState extends MyEventsTabViewState {}

final class EventLoadingState extends MyEventsTabViewState {}

final class EventErrorState extends MyEventsTabViewState {
  final String message;

  const EventErrorState(this.message);

  @override
  List<Object> get props => [message];
}

final class UpcomingEventsLoadedState extends MyEventsTabViewState {
  final List<Event> event;

  const UpcomingEventsLoadedState(this.event);

  @override
  List<Object> get props => [event];
}

final class PastEventsLoadedState extends MyEventsTabViewState {
  final List<Event> event;

  const PastEventsLoadedState(this.event);

  @override
  List<Object> get props => [event];
}

