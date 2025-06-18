part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent extends Equatable {
  const AuthEvent();
}

final class AppStarted extends AuthEvent {
  @override
  List<Object> get props => [];
}

final class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

final class SignOutRequested extends AuthEvent {
  @override
  List<Object> get props => [];
}

final class UpdateUserEvent extends AuthEvent {
  final User user;

  const UpdateUserEvent({required this.user});

  @override
  List<Object> get props => [user];
}

final class MustChangePasswordEvent extends AuthEvent {
  final User user;
  final String newPassword;

  const MustChangePasswordEvent({required this.user, required this.newPassword});

  @override
  List<Object> get props => [user, newPassword];
}