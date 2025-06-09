import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:event_hub_and_navigation_app/auth/models/user.dart';
import 'package:meta/meta.dart';
import '../../repositories/auth_repository.dart';
import '../../services/secure_storage_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository = AuthRepository();
  final SecureStorageService _storageService = SecureStorageService();


  AuthBloc() : super(AuthInitialState()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<AppStarted>(_onAuthCheckRequested);
  }

  Future<void> _onAuthCheckRequested(AppStarted event, Emitter<AuthState> emit) async {

    final token = await _storageService.getToken();
    final user = await _storageService.getUser();

    if (token != null && token.isNotEmpty && user != null) {
      // AWAIT the validation and use its boolean result
      final isValidToken = await authRepository.validateToken();
      if (isValidToken) {
        // Only set the token if it's valid. The ApiService interceptor already adds it,
        // but if you have a global default, you might want to set it here.
        // ApiService.setAuthToken(token); // This line is typically handled by Dio interceptor
        emit(AuthenticatedState(user: user));
      } else {
        await _storageService.deleteToken(); // Clear expired token
        await _storageService.deleteUser(); // Clear associated user data
        emit(UnAuthenticatedState());
      }

    } else {
      emit(UnAuthenticatedState());
    }
  }


  Future<void> _onSignInRequested(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final user = await authRepository.signIn(event.email, event.password);

      emit(AuthenticatedState(user:user));
    } catch (e) {
      emit(ErrorState( error: e.toString()));
    }
  }

  Future<void> _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) async {
    await authRepository.signOut();
    emit(AuthInitialState());
  }
}
