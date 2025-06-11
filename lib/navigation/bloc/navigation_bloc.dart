import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:event_hub_and_navigation_app/navigation/widgets/map_marker.dart';
import 'package:meta/meta.dart';

import '../services/map_service.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {



  NavigationBloc() : super(NavigationInitial()) {
    on<LoadAllVenuesNameEvent>(_onLoadAllVenuesName);
    on<ShowVenueSelectionDialogEvent>(_onSelectSourceDialogShownState);

    // on<SelectSourceAndDestinationEvent>
  }

  Future<void> _onLoadAllVenuesName(LoadAllVenuesNameEvent event, Emitter<NavigationState> emit) async {

    try {
      final allVenuesName = await MapService.getAllVenuesName();
      emit(AllVenuesLoadedState(allVenuesName:allVenuesName));
    } catch (e) {
      emit(NavigationError(e.toString()));
    }
  }
  Future<void> _onSelectSourceDialogShownState(ShowVenueSelectionDialogEvent event, Emitter<NavigationState> emit) async {

    print(event.destination);
      emit(SelectSourceDialogShownState(destination: event.destination));
 // Immediately emit initial state to clear the event
    emit(NavigationInitial());
  }
}
