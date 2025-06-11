import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:event_hub_and_navigation_app/models/event.dart';
import 'package:event_hub_and_navigation_app/my_events/blocs/my_events_calendar_view_bloc/bloc/event_bloc.dart';
import 'package:event_hub_and_navigation_app/repositories/event_repository.dart';
import 'package:meta/meta.dart';

part 'event_event.dart';
part 'event_state.dart';

class MyEventsTabViewBloc extends Bloc<MyEventsCalendarViewEvent, MyEventsTabViewState> {
  final EventRepository eventRepository = EventRepository();

  MyEventsTabViewBloc() : super(EventInitialState()) {
    on<FetchMyUpcomingEvents>(_onFetchUpcomingEvents);
    on<FetchMyPastEvents>(_onFetchPastEvents);

  }

  Future<void> _onFetchUpcomingEvents(
      FetchMyUpcomingEvents event, Emitter<MyEventsTabViewState> emit) async {
    emit(EventLoadingState());
    try {
      final events = await eventRepository.fetchMyUpcomingEvents(event.userId);
      emit(UpcomingEventsLoadedState(events));
    } catch (e) {
      emit(EventErrorState(e.toString()));
    }
  }



  Future<void> _onFetchPastEvents(
      FetchMyPastEvents event, Emitter<MyEventsTabViewState> emit) async {
    emit(EventLoadingState());
    try {
      final events = await eventRepository.fetchMyPastEvents(event.userId);
      emit(PastEventsLoadedState(events));
    } catch (e) {
      emit(EventErrorState(e.toString()));
    }
  }


}
