part of 'sign_up_bloc.dart';

@immutable
sealed class SignUpState extends Equatable{
  @override
  List<Object> get props => [];
}

final class SignUpInitialState extends SignUpState {}


final class SignUpLoadingState extends SignUpState {}

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



