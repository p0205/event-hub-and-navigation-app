import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:event_hub_and_navigation_app/models/event.dart';
import 'package:event_hub_and_navigation_app/repositories/event_repository.dart';
import 'package:meta/meta.dart';

part 'event_event.dart';
part 'event_state.dart';

class EventDetailsBloc extends Bloc<MyEventDetailsEvent, MyEventDetailsState> {
  final EventRepository eventRepository = EventRepository();

  EventDetailsBloc() : super(EventDetailsInitialState()) {

    on<FetchEventDetails>(_onFetchEventDetails);
  }



  Future<void> _onFetchEventDetails(
      FetchEventDetails event, Emitter<MyEventDetailsState> emit) async {
    emit(EventDetailsLoadingState());
    try {
      final eventDetails = await eventRepository.fetchEventDetails(event.eventId);
      emit(EventDetailsLoadedState(eventDetails));
    } catch (e) {
      emit(EventDetailsErrorState(e.toString()));
    }
  }
}
