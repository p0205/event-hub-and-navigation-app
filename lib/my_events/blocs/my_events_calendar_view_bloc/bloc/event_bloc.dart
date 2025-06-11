import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:event_hub_and_navigation_app/home/models/calendar_event.dart';
import 'package:event_hub_and_navigation_app/models/event.dart';
import 'package:event_hub_and_navigation_app/repositories/event_repository.dart';
import 'package:meta/meta.dart';

part 'event_event.dart';
part 'event_state.dart';

class MyEventsCalendarViewBloc extends Bloc<CalendarViewEvent, MyEventsCalendarViewState> {
  final EventRepository eventRepository = EventRepository();

  MyEventsCalendarViewBloc() : super(CalendarEventInitialState()) {

    on<FetchMyCalendarEventsByMonth>(_onFetchMyCalendarEventsByMonth);

  }



  Future<void> _onFetchMyCalendarEventsByMonth(
      FetchMyCalendarEventsByMonth event, Emitter<MyEventsCalendarViewState> emit) async {
    emit(CalendarEventLoadingState());
    try {
      final events = await eventRepository.fetchMyCalendarEventsByMonth(event.userId, event.startDateTime,event.endDateTime);
      emit(CalenderEventLoadedState(events));
    } catch (e) {
      emit(CalendarEventErrorState(e.toString()));
    }
  }





}
