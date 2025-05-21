part of 'auth_bloc.dart';

@immutable
sealed class AuthState extends Equatable{
  @override
  List<Object> get props => [];
}

final class AuthInitialState extends AuthState {}

final class AuthLoadingState extends AuthState {}

final class AuthenticatedState extends AuthState {
  final User user;

  AuthenticatedState({required this.user});

  @override
  List<Object> get props => [user];
}

final class UnAuthenticatedState extends AuthState {}

final class PasswordUpdatedState extends AuthState {}

final class LoadingState extends AuthState {}

final class ErrorState extends AuthState {
  final String error;

  ErrorState({required this.error});
  @override
  List<Object> get props => [error];

}



