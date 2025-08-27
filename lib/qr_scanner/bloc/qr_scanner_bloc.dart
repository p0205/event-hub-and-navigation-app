import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:event_hub_and_navigation_app/auth/models/user.dart';
import 'package:event_hub_and_navigation_app/repositories/event_repository.dart';
import 'package:meta/meta.dart';

import '../../../repositories/user_repository.dart';

part 'qr_scanner_event.dart';
part 'qr_scanner_state.dart';

class QrScannerBloc extends Bloc<QrScannerEvent, QrScannerState> {
  final EventRepository eventRepository =  EventRepository();

  QrScannerBloc() : super(QRScannerInitial()) {
    on<TakeAttendanceEvent>(_onTakeAttendance);

  }

  Future<void> _onTakeAttendance(TakeAttendanceEvent event, Emitter<QrScannerState> emit) async {
    emit(QRScannerLoading());
    try {
      if(event.userId != null) {
        await eventRepository.takeAttendance(event.qrPayloadString, event.userId!);

        emit(TakeAttendanceSuccess(
          message: 'Check In Successfully',

        ));
      }else{
        emit(UserIsUnAuthenticatedState(
          message: 'Please sign in to take attendace',

        ));
      }


    } catch (e) {
      emit(QRScannerError(error: e.toString()));
    }
  }


}
