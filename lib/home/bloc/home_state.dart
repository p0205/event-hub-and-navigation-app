part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();
  
  @override
  List<Object> get props => [];
}

final class HomeInitial extends HomeState {}

final class CalendarEventLoading extends HomeState {}

final class CalendarEventLoaded extends HomeState {
  final List<CalendarEvent> events;

  const CalendarEventLoaded(this.events);

  @override
  List<Object> get props => [events];
}

final class CalendarEventError extends HomeState {
  final String message;

  const CalendarEventError(this.message);

  @override
  List<Object> get props => [message];
}
