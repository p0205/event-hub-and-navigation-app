import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:event_hub_and_navigation_app/home/models/calendar_event.dart';
import 'package:event_hub_and_navigation_app/models/event.dart';
import 'package:event_hub_and_navigation_app/repositories/event_repository.dart';
import 'package:meta/meta.dart';

part 'event_event.dart';
part 'event_state.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final EventRepository eventRepository = EventRepository();

  EventBloc() : super(EventInitialState()) {
    on<FetchMyUpcomingEvents>(_onFetchUpcomingEvents);

    on<FetchMyPastEvents>(_onFetchPastEvents);
    on<FetchMyCalendarEventsByMonth>(_onFetchMyCalendarEventsByMonth);
    on<FetchEventDetails>(_onFetchEventDetails);
  }

  Future<void> _onFetchUpcomingEvents(
      FetchMyUpcomingEvents event, Emitter<EventState> emit) async {
    emit(EventLoadingState());
    try {
      final events = await eventRepository.fetchMyUpcomingEvents(event.userId);
      emit(EventLoadedState(events));
    } catch (e) {
      emit(EventErrorState(e.toString()));
    }
  }

  Future<void> _onFetchMyCalendarEventsByMonth(
      FetchMyCalendarEventsByMonth event, Emitter<EventState> emit) async {
    emit(EventLoadingState());
    try {
      final events = await eventRepository.fetchMyCalendarEventsByMonth(event.userId, event.startDateTime,event.endDateTime);
      emit(CalenderEventLoadedState(events));
    } catch (e) {
      emit(EventErrorState(e.toString()));
    }
  }


  Future<void> _onFetchPastEvents(
      FetchMyPastEvents event, Emitter<EventState> emit) async {
    emit(EventLoadingState());
    try {
      final events = await eventRepository.fetchMyPastEvents(event.userId);
      emit(EventLoadedState(events));
    } catch (e) {
      emit(EventErrorState(e.toString()));
    }
  }

  Future<void> _onFetchEventDetails(
      FetchEventDetails event, Emitter<EventState> emit) async {
    emit(EventDetailsLoadingState());
    try {
      final eventDetails = await eventRepository.fetchEventDetails(event.eventId);
      emit(EventDetailsLoadedState(eventDetails));
    } catch (e) {
      emit(EventErrorState(e.toString()));
    }
  }
}
