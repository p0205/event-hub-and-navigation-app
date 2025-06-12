part of 'sign_up_bloc.dart';

@immutable
sealed class SignUpEvent extends Equatable {
  const SignUpEvent();
}
final class AppStarted extends SignUpEvent {
  @override
  List<Object> get props => [];
}


final class CheckEmailRequestedEvent extends SignUpEvent {
  final String email;

  const CheckEmailRequestedEvent({required this.email});

  @override
  List<Object> get props => [email];
}
final class SignUpRequestEvent extends SignUpEvent {
  final String email;
  final String phoneNo;
  final String rawPassword;


  const SignUpRequestEvent({required this.email, required this.phoneNo,required this.rawPassword});

  @override
  List<Object> get props => [email, phoneNo, rawPassword];
}

