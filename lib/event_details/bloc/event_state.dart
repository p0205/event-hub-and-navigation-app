part of 'event_bloc.dart';

sealed class MyEventDetailsState extends Equatable {
  const MyEventDetailsState();

  @override
  List<Object> get props => [];
}

final class EventDetailsInitialState extends MyEventDetailsState {}

final class EventDetailsLoadingState extends MyEventDetailsState {}

final class EventDetailsLoadedState extends MyEventDetailsState {
  final Event event;

  const EventDetailsLoadedState(this.event);

  @override
  List<Object> get props => [event];
}

final class EventDetailsErrorState extends MyEventDetailsState {
  final String message;

  const EventDetailsErrorState(this.message);

  @override
  List<Object> get props => [message];
}

