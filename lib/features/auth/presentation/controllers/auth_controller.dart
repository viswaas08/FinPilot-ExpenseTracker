import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

class AuthState {
  final UserEntity? user;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final bool rememberMe;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.rememberMe = true,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool? rememberMe,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository)
      : super(AuthState(
          user: _authRepository.currentUser,
          rememberMe: _authRepository.isRememberMe,
        )) {
    _authRepository.authStateChanges.listen((user) {
      state = state.copyWith(user: user, clearUser: user == null);
    });
  }

  void toggleRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
    _authRepository.setRememberMe(value);
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      final user = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Failure(message: ', '').replaceAll(')', ''),
      );
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String displayName) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      final user = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Failure(message: ', '').replaceAll(')', ''),
      );
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      final user = await _authRepository.signInWithGoogle();
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Failure(message: ', '').replaceAll(')', ''),
      );
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      await _authRepository.sendPasswordResetEmail(email);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Password reset link sent to $email. Please check your inbox.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Failure(message: ', '').replaceAll(')', ''),
      );
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _authRepository.signOut();
    state = AuthState(user: null, isLoading: false, rememberMe: state.rememberMe);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});
