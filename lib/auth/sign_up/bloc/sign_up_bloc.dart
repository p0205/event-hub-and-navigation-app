import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:event_hub_and_navigation_app/auth/models/user.dart';
import 'package:meta/meta.dart';

import '../../../repositories/auth_repository.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final AuthRepository authRepository = AuthRepository();

  SignUpBloc() : super(SignUpInitialState()) {
    on<CheckEmailRequestedEvent>(_onCheckEmailRequested);
    on<VerifyCodeRequestedEvent>(_onVerifyCodeRequested);
    on<ResendCodeRequestedEvent>(_onResendCodeRequested);
    on<SignUpRequestEvent>(_onSignUpRequest);
    // on<SignOutRequested>(_onSignOutRequested);
    // on<AppStarted>(_onAuthCheckRequested);
  }

  Future<void> _onCheckEmailRequested(
      CheckEmailRequestedEvent event, Emitter<SignUpState> emit) async {
    emit(SignUpLoadingState());
    try {
     final message = await authRepository.checkEmail(event.email);
      emit(EmailSentState(email: event.email, message: message));
    } catch (e) {
      emit(SignUpErrorState(error: e.toString()));
    }
  }

  Future<void> _onVerifyCodeRequested(
      VerifyCodeRequestedEvent event, Emitter<SignUpState> emit) async {
    emit(SignUpLoadingState());
    try {
      final user = await authRepository.verifyCode(event.email, event.code);
      emit(ValidSignUpRequestState(user: user!));
    } catch (e) {
      emit(SignUpErrorState(error: e.toString()));
    }
  }

  Future<void> _onResendCodeRequested(
      ResendCodeRequestedEvent event, Emitter<SignUpState> emit) async {
    emit(SignUpLoadingState());
    try {
      final message = await authRepository.checkEmail(event.email);
      emit(CodeResentState(message: message));
    } catch (e) {
      emit(SignUpErrorState(error: e.toString()));
    }
  }

  Future<void> _onSignUpRequest(
      SignUpRequestEvent event, Emitter<SignUpState> emit) async {
    emit(SignUpLoadingState());
    try {
      final message = await authRepository.signUp(
          event.email, event.phoneNo, event.rawPassword);
      emit(SignUpSuccessState(message: message));
    } catch (e) {
      emit(SignUpErrorState(error: e.toString()));
    }
  }
}
