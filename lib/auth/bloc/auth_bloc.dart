import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:event_hub_and_navigation_app/auth/models/user.dart';
import 'package:meta/meta.dart';
import '../../repositories/auth_repository.dart';
import '../../services/secure_storage_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final SecureStorageService _storageService = SecureStorageService();


  AuthBloc({required this.authRepository}) : super(AuthInitialState()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  // Future<void> _onAuthCheckRequested(SignOutRequested event, Emitter<AuthState> emit) async {
  //   final token = await _storageService.getToken();
  //
  //   if (token != null && token.isNotEmpty) {
  //     // Optionally validate token expiry here before emitting
  //     emit(AuthenticatedState(token));
  //     // Also set the token to ApiService header if needed
  //     ApiService.setAuthToken(token);
  //   } else {
  //     emit(Unauthenticated());
  //   }
  // }

  Future<void> _onSignInRequested(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoadingState());
    try {
      final user = await authRepository.signIn(event.email, event.password);

      emit(AuthenticatedState(user:user));
    } catch (e) {
      print(e.toString());
      emit(ErrorState( error: e.toString()));
    }
  }

  Future<void> _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) async {
    await authRepository.signOut();
    emit(AuthInitialState());
  }
}
