part of 'navigation_bloc.dart';

@immutable
sealed class NavigationState extends Equatable{
  final Map<int, List<MapMarker>>? allVenuesName;

  const NavigationState({this.allVenuesName});

  @override
  List<Object?> get props => [allVenuesName];
}

final class NavigationInitial extends NavigationState {}

final class SelectSourceDialogShownState extends NavigationState {

  final String destination;

  const SelectSourceDialogShownState({required this.destination});
  @override
  List<Object> get props => [destination];
}

final class SelectDestinationFromDeepLinkState extends NavigationState {

  final String destination;

  const SelectDestinationFromDeepLinkState({required this.destination});
  @override
  List<Object> get props => [destination];
}


final class SelectSourceFromQRState extends NavigationState {

  final Map<String, dynamic> source;

  const SelectSourceFromQRState({required this.source});
  @override
  List<Object> get props => [source];
}

final class AllVenuesLoadedState extends NavigationState {
  // The 'super' call passes the venues up to the base state.
  const AllVenuesLoadedState({required Map<int, List<MapMarker>> allVenuesName})
      : super(allVenuesName: allVenuesName);
}


final class SourceAndDesSelectedState extends NavigationState{
  final String source;
  final String destination;

  const SourceAndDesSelectedState({required this.source, required this.destination});
  @override
  List<Object> get props => [source, destination];
}



final class NavigationError extends NavigationState {
  final String message;

  const NavigationError(this.message);

  @override
  List<Object> get props => [message];
}


