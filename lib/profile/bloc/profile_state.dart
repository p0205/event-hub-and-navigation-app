part of 'profile_bloc.dart';

@immutable
sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileError extends ProfileState {
  final String error;

  const ProfileError({required this.error});

  @override
  List<Object> get props => [error];
}

final class ProfileSuccess extends ProfileState {
  final String message;
  final User user;

  const ProfileSuccess({
    required this.message,
    required this.user,
  });

  @override
  List<Object> get props => [message, user ];
}

final class PasswordUpdatedSuccessState extends ProfileState {}



