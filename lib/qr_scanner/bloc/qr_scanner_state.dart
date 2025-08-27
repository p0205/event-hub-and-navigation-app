part of 'qr_scanner_bloc.dart';

@immutable
sealed class QrScannerState extends Equatable {
  const QrScannerState();

  @override
  List<Object> get props => [];
}

final class QRScannerInitial extends QrScannerState {}

final class QRScannerLoading extends QrScannerState {}

final class QRScannerError extends QrScannerState {
  final String error;


  const QRScannerError({
    required this.error,

  });

  @override
  List<Object> get props => [error ];
}


final class TakeAttendanceSuccess extends QrScannerState {
  final String message;


  const TakeAttendanceSuccess({
    required this.message,

  });

  @override
  List<Object> get props => [message ];
}

final class UserIsUnAuthenticatedState extends QrScannerState {
  final String message;


  const UserIsUnAuthenticatedState({
    required this.message,

  });

  @override
  List<Object> get props => [message ];
}



