import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:event_hub_and_navigation_app/auth/models/user.dart';
import 'package:meta/meta.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/user_repository.dart';
import '../../services/secure_storage_service.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository = AuthRepository();
  final UserRepository userRepository = UserRepository();
  final SecureStorageService _storageService = SecureStorageService();

  AuthBloc() : super(AuthInitialState()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<AppStarted>(_onAuthCheckRequested);
    on<UpdateUserEvent>(_onUpdateUser);
    on<MustChangePasswordEvent>(_onMustChangePassword);
  }

  Future<void> _onAuthCheckRequested(AppStarted event,
      Emitter<AuthState> emit) async {
    final token = await _storageService.getToken();
    final user = await _storageService.getUser();

    if (token != null && token.isNotEmpty && user != null) {
      final isValidToken = await authRepository.validateToken();
      if (isValidToken) {
        print(user.id);
        print(user.name);
        print(user.mustChangePassword);
        emit(AuthenticatedState(user: user));
      } else {
        await _storageService.deleteToken();
        await _storageService.deleteUser();
        emit(UnAuthenticatedState());
      }
    } else {
      emit(UnAuthenticatedState());
    }
  }

  Future<void> _onSignInRequested(SignInRequested event,
      Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final user = await authRepository.signIn(event.email, event.password);
      if (user.mustChangePassword == true) {
        emit(MustChangePasswordState(user: user));
      } else {
        emit(AuthenticatedState(user: user));
      }
    } catch (e) {
      emit(ErrorState(error: e.toString()));
    }
  }

  Future<void> _onMustChangePassword(MustChangePasswordEvent event,
      Emitter<AuthState> emit) async {
    try {
      final success = await authRepository.updateOutsiderPassword(
          event.user, event.newPassword);
      if (success) {

        emit(AuthenticatedState(user: event.user.copyWith(
            mustChangePassword: false
        )));
      }
    } catch (e) {
      emit(ErrorState(error: e.toString()));
    }
  }


  Future<void> _onSignOutRequested(SignOutRequested event,
      Emitter<AuthState> emit) async {
    try {
      await _storageService.deleteToken();
      await _storageService.deleteUser();
      await authRepository.signOut();
      emit(UnAuthenticatedState());
    } catch (e) {
      emit(UnAuthenticatedState());
    }
  }

  Future<void> _onUpdateUser(UpdateUserEvent event,
      Emitter<AuthState> emit) async {
    await _storageService.saveUser(event.user);
    emit(AuthenticatedState(user: event.user));
  }

}
