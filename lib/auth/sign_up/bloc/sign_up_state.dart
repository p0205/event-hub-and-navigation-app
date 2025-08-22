part of 'sign_up_bloc.dart';

@immutable
sealed class SignUpState extends Equatable{
  @override
  List<Object> get props => [];
}

final class SignUpInitialState extends SignUpState {}


final class SignUpLoadingState extends SignUpState {}


class EmailSentState extends SignUpState {
  final String email;
  final String message;

  EmailSentState({
    required this.email,
    required this.message,
  });

  @override
  List<Object> get props => [email, message];
}

class CodeResentState extends SignUpState {
  final String message;

  CodeResentState({required this.message});

  @override
  List<Object> get props => [message];
}


final class SignUpSuccessState extends SignUpState {
  final String message;

  SignUpSuccessState({required this.message});
  @override
  List<Object> get props => [message];

}

final class ValidSignUpRequestState extends SignUpState {
  final User user;

   ValidSignUpRequestState({required this.user});
  @override
  List<Object> get props => [user];
}


final class SignUpErrorState extends SignUpState {
  final String error;

  SignUpErrorState({required this.error});
  @override
  List<Object> get props => [error];

}



