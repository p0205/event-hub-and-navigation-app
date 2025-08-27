part of 'qr_scanner_bloc.dart';

@immutable
sealed class QrScannerEvent extends Equatable {
  const QrScannerEvent();
}

final class UpdatePhoneNoEvent extends QrScannerEvent {
  final int userId;
  final String phoneNo;

  const UpdatePhoneNoEvent({
    required this.userId,
    required this.phoneNo,
  });

  @override
  List<Object> get props => [userId, phoneNo];
}

final class TakeAttendanceEvent extends QrScannerEvent {
  final int? userId;
  final String qrPayloadString;


  const TakeAttendanceEvent({
     this.userId,
    required this.qrPayloadString
  });

  @override
  List<Object> get props => [ qrPayloadString];
}
