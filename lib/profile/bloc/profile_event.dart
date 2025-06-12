part of 'profile_bloc.dart';

@immutable
sealed class ProfileEvent extends Equatable {
  const ProfileEvent();
}

final class UpdatePhoneNoEvent extends ProfileEvent {
  final int userId;
  final String phoneNo;

  const UpdatePhoneNoEvent({
    required this.userId,
    required this.phoneNo,
  });

  @override
  List<Object> get props => [userId, phoneNo];
}

final class UpdatePasswordEvent extends ProfileEvent {
  final int userId;
  final String currentPassword;
  final String newPassword;

  const UpdatePasswordEvent({
    required this.userId,
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [userId, currentPassword, newPassword];
}
