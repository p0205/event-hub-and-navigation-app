part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitialState extends AuthState {}

final class AuthenticatedState extends AuthState {}

final class UnAuthenticatedState extends AuthState {}

final class PasswordUpdatedState extends AuthState {}

final class LoadingState extends AuthState {}

final class ErrorState extends AuthState {}



final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthAuthenticated extends AuthState {}

final class AuthError extends AuthState {
  final String message;

  AuthError(this.message);


  List<Object> get props => [message];
}