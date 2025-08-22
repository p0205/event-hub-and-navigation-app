import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:event_hub_and_navigation_app/navigation/widgets/map_marker.dart';
import 'package:meta/meta.dart';

import '../services/map_service.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationInitial()) {
    on<LoadAllVenueNodesEvent>(_onLoadAllVenueNodes);
    on<ShowVenueSelectionDialogEvent>(_onSelectSourceDialogShownState);
    on<SelectSourceFromQR>(_onSelectSourceFromQR);

    // on<SelectSourceAndDestinationEvent>
  }

  Future<void> _onLoadAllVenueNodes(
      LoadAllVenueNodesEvent event, Emitter<NavigationState> emit) async {
    try {
      final allVenueNodes = await MapService.getAllVenuesName();
      emit(AllVenuesLoadedState(allVenuesName: allVenueNodes));
    } catch (e) {
      emit(NavigationError(e.toString()));
    }
  }

  Future<void> _onSelectSourceDialogShownState(
      ShowVenueSelectionDialogEvent event,
      Emitter<NavigationState> emit) async {
    emit(SelectSourceDialogShownState(destination: event.destination));
  }


  Future<void> _onSelectSourceFromQR(
      SelectSourceFromQR event, Emitter<NavigationState> emit) async {
    print('🎯 [NavigationBloc] _onSelectSourceFromQR called with data: ${event.qrData}');

    final Map<String, dynamic> source = await _convertQRToVenue(event.qrData);
    print('📍 [NavigationBloc] Converted QR data to venue: $source');
    
    print('📤 [NavigationBloc] Emitting SelectSourceFrovmQRState');
    emit(SelectSourceFromQRState(source: source));
    
    print('✅ [NavigationBloc] SelectSourceFromQRState emitted successfully');
  }
}

Future<Map<String, dynamic>> _convertQRToVenue(
    Map<String, dynamic> qrData) async {
  return {
    'id': qrData['id']?.toString() ?? '',
    'name': qrData['name']?.toString() ?? '',
    'coordinates': {
      'x': qrData['coordinates']?['x'] ?? 0.0,
      'y': qrData['coordinates']?['y'] ?? 0.0,
    },
    'floor_level': qrData['floor_level'] ?? 1,
  };
}
