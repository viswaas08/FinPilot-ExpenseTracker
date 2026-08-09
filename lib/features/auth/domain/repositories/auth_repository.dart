import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  UserEntity? get currentUser;
  bool get isRememberMe;

  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  Future<UserEntity> signInWithGoogle();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> setRememberMe(bool remember);

  Future<void> signOut();
}
