part of 'event_bloc.dart';

@immutable
sealed class MyEventDetailsEvent extends Equatable {
  const MyEventDetailsEvent();

  @override
  List<Object> get props => [];
}




final class FetchEventDetails extends MyEventDetailsEvent {
 final int eventId;

  const FetchEventDetails({required this.eventId});


  @override
  List<Object> get props => [];
}
