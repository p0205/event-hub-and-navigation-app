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
