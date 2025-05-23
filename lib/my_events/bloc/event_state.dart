part of 'event_bloc.dart';

sealed class EventState extends Equatable {
  const EventState();

  @override
  List<Object> get props => [];
}

final class EventInitialState extends EventState {}

final class EventLoadingState extends EventState {}

final class EventErrorState extends EventState {
  final String message;

  const EventErrorState(this.message);

  @override
  List<Object> get props => [message];
}

final class EventLoadedState extends EventState {
  final List<Event> event;

  const EventLoadedState(this.event);

  @override
  List<Object> get props => [event];
}


final class PastEventLoadedState extends EventState {}

final class EventDetailsLoadedState extends EventState {}
