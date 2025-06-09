part of 'navigation_bloc.dart';

@immutable
sealed class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object> get props => [];
}

class LoadAllVenuesNameEvent extends NavigationEvent {


  const LoadAllVenuesNameEvent();

}

class ShowVenueSelectionDialogEvent extends NavigationEvent {
  final String destination;

  const ShowVenueSelectionDialogEvent({required this.destination});

  @override
  List<Object> get props => [destination];

}

class SelectSourceAndDestinationEvent extends NavigationEvent {
  final String source;
  final String destination;

  const SelectSourceAndDestinationEvent({required this.source, required this.destination});

  @override
  List<Object> get props => [source, destination];
}


