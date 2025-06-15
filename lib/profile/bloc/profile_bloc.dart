import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:event_hub_and_navigation_app/auth/models/user.dart';
import 'package:meta/meta.dart';

import '../../../repositories/user_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserRepository userRepository =  UserRepository();

  ProfileBloc() : super(ProfileInitial()) {
    on<UpdatePhoneNoEvent>(_onUpdatePhoneNo);
    on<UpdatePasswordEvent>(_onUpdatePassword);
  }

  Future<void> _onUpdatePhoneNo(UpdatePhoneNoEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final updatedUser = await userRepository.updatePhoneNo(event.userId, event.phoneNo);
      if (updatedUser != null) {
        emit(ProfileSuccess(
          message: 'Phone number updated successfully',
          user: updatedUser,
        ));
      } else {
        emit(const ProfileError(error: 'Failed to update phone number'));
      }
    } catch (e) {
      emit(ProfileError(error: e.toString()));
    }
  }

  Future<void> _onUpdatePassword(UpdatePasswordEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    try {
      final success = await userRepository.updatePassword(
        event.userId,
        event.currentPassword,
        event.newPassword,
      );
      if (success) {
        emit(PasswordUpdatedSuccessState());
      } else {
        emit(const ProfileError(error: 'Failed to update password'));
      }
    } catch (e) {
      emit(ProfileError(error: e.toString()));
    }
  }
}
