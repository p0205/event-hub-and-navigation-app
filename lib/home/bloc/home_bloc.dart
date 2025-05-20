import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:event_hub_and_navigation_app/home/models/calendar_event.dart';
import 'package:event_hub_and_navigation_app/repositories/event_repository.dart';
import 'package:meta/meta.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final EventRepository eventService = EventRepository();

  HomeBloc() : super(HomeInitial()) {
    on<FetchCalendarEvents>(_onFetchEvents);
  }

  Future<void> _onFetchEvents(FetchCalendarEvents event, Emitter<HomeState> emit) async {
    emit(CalendarEventLoading());
    try {
      final events = await eventService.getCalendarEvents(event.userId);
      emit(CalendarEventLoaded(events));
    } catch (e) {
      emit(CalendarEventError(e.toString()));
    }
  }
}
