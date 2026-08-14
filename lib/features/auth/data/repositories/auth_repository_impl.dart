import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:expense_tracker/core/errors/failures.dart';
import 'package:expense_tracker/core/firebase/firebase_service.dart';
import 'package:expense_tracker/core/services/brevo_email_service.dart';
import 'package:expense_tracker/core/storage/hive_service.dart';
import 'package:expense_tracker/features/auth/domain/entities/user_entity.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:expense_tracker/features/auth/data/models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseService _firebaseService;
  final HiveService _hiveService;
  final BrevoEmailService _brevoEmailService;
  final StreamController<UserEntity?> _authStateController = StreamController<UserEntity?>.broadcast();

  UserEntity? _cachedUser;
  bool _rememberMe = true;

  AuthRepositoryImpl({
    required FirebaseService firebaseService,
    required HiveService hiveService,
    required BrevoEmailService brevoEmailService,
  })  : _firebaseService = firebaseService,
        _hiveService = hiveService,
        _brevoEmailService = brevoEmailService {
    _initSession();
  }

  void _initSession() {
    final rawSession = _hiveService.getUserSession();
    final session = rawSession != null ? Map<String, dynamic>.from(rawSession as Map) : null;
    final savedRemember = session?['rememberMe'] as bool?;
    _rememberMe = savedRemember ?? true;

    if (session != null && _rememberMe) {
      _cachedUser = UserModel.fromJson(session);
      _authStateController.add(_cachedUser);
    } else {
      _authStateController.add(null);
    }

    if (_firebaseService.isInitialized) {
      fb.FirebaseAuth.instance.authStateChanges().listen((fbUser) {
        if (fbUser != null && _rememberMe) {
          final user = UserEntity(
            id: fbUser.uid,
            email: fbUser.email ?? '',
            displayName: fbUser.displayName ?? 'Expense User',
            photoUrl: fbUser.photoURL,
            createdAt: DateTime.now(),
          );
          _cachedUser = user;
          final json = UserModel.fromEntity(user).toJson();
          json['rememberMe'] = _rememberMe;
          _hiveService.saveUserSession(json);
          _authStateController.add(user);
        }
      });
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges => _authStateController.stream;

  @override
  UserEntity? get currentUser => _cachedUser;

  @override
  bool get isRememberMe => _rememberMe;

  @override
  Future<void> setRememberMe(bool remember) async {
    _rememberMe = remember;
    if (_cachedUser != null) {
      final json = UserModel.fromEntity(_cachedUser!).toJson();
      json['rememberMe'] = remember;
      await _hiveService.saveUserSession(json);
    }
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (_firebaseService.isInitialized) {
        final credential = await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final fbUser = credential.user;
        if (fbUser == null) {
          throw const AuthFailure(message: 'User authentication failed: user profile is empty');
        }
        final user = UserEntity(
          id: fbUser.uid,
          email: fbUser.email ?? email,
          displayName: fbUser.displayName ?? email.split('@').first,
          photoUrl: fbUser.photoURL,
          createdAt: DateTime.now(),
        );
        _cachedUser = user;
        if (_rememberMe) {
          final json = UserModel.fromEntity(user).toJson();
          json['rememberMe'] = true;
          await _hiveService.saveUserSession(json);
        }
        _authStateController.add(user);
        return user;
      } else {
        final user = UserEntity(
          id: 'local_user_${email.hashCode}',
          email: email,
          displayName: email.split('@').first,
          createdAt: DateTime.now(),
        );
        _cachedUser = user;
        if (_rememberMe) {
          final json = UserModel.fromEntity(user).toJson();
          json['rememberMe'] = true;
          await _hiveService.saveUserSession(json);
        }
        _authStateController.add(user);
        return user;
      }
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw const AuthFailure(
          message: 'Invalid email or password. If you signed up using Google, please tap "Continue with Google" or use "Forgot Password" to set a password.',
          code: 'invalid-credential',
        );
      }
      throw AuthFailure(message: e.message ?? 'Authentication failed', code: e.code);
    } catch (e) {
      throw AuthFailure(message: e.toString());
    }
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      if (_firebaseService.isInitialized) {
        final credential = await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final fbUser = credential.user;
        if (fbUser == null) {
          throw const AuthFailure(message: 'User registration failed: user profile is empty');
        }
        await fbUser.updateDisplayName(displayName);
        final user = UserEntity(
          id: fbUser.uid,
          email: email,
          displayName: displayName,
          createdAt: DateTime.now(),
        );
        _cachedUser = user;
        if (_rememberMe) {
          final json = UserModel.fromEntity(user).toJson();
          json['rememberMe'] = true;
          await _hiveService.saveUserSession(json);
        }
        _authStateController.add(user);
        return user;
      } else {
        final user = UserEntity(
          id: 'local_user_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          displayName: displayName,
          createdAt: DateTime.now(),
        );
        _cachedUser = user;
        if (_rememberMe) {
          final json = UserModel.fromEntity(user).toJson();
          json['rememberMe'] = true;
          await _hiveService.saveUserSession(json);
        }
        _authStateController.add(user);
        return user;
      }
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use' || e.code == 'account-exists-with-different-credential') {
        throw const AuthFailure(
          message: 'An account already exists with this email address. Try signing in with "Continue with Google" or use "Forgot Password".',
          code: 'email-already-in-use',
        );
      }
      throw AuthFailure(message: e.message ?? 'Registration failed', code: e.code);
    } catch (e) {
      throw AuthFailure(message: e.toString());
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      if (_firebaseService.isInitialized) {
        fb.User? fbUser;

        if (kIsWeb) {
          final googleProvider = fb.GoogleAuthProvider();
          final userCredential = await fb.FirebaseAuth.instance.signInWithPopup(googleProvider);
          fbUser = userCredential.user;
        } else {
          final GoogleSignIn googleSignIn = GoogleSignIn(
            serverClientId: '1003469021217-u03c8jgqri0lfjp93rbs070m3f0nb445.apps.googleusercontent.com',
            scopes: ['email', 'profile'],
          );

          try {
            await googleSignIn.signOut();
          } catch (_) {}

          final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
          if (googleUser == null) {
            throw const AuthFailure(message: 'Google Sign-In canceled by user');
          }

          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
          final fb.AuthCredential credential = fb.GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          final userCredential = await fb.FirebaseAuth.instance.signInWithCredential(credential);
          fbUser = userCredential.user;
        }

        if (fbUser == null) {
          throw const AuthFailure(message: 'Google Sign-In failed: user profile is empty');
        }

        final user = UserEntity(
          id: fbUser.uid,
          email: fbUser.email ?? 'google.user@expensetracker.app',
          displayName: fbUser.displayName ?? 'Google User',
          photoUrl: fbUser.photoURL,
          createdAt: DateTime.now(),
        );

        _cachedUser = user;
        if (_rememberMe) {
          final json = UserModel.fromEntity(user).toJson();
          json['rememberMe'] = true;
          await _hiveService.saveUserSession(json);
        }
        _authStateController.add(user);
        return user;
      } else {
        // Fallback local Google Auth simulation
        final user = UserEntity(
          id: 'google_user_${DateTime.now().millisecondsSinceEpoch}',
          email: 'google.user@expensetracker.app',
          displayName: 'Google Account User',
          photoUrl: 'https://picsum.photos/seed/googleuser/200',
          createdAt: DateTime.now(),
        );
        _cachedUser = user;
        if (_rememberMe) {
          final json = UserModel.fromEntity(user).toJson();
          json['rememberMe'] = true;
          await _hiveService.saveUserSession(json);
        }
        _authStateController.add(user);
        return user;
      }
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('10') || errStr.contains('sign_in_failed') || errStr.contains('API key')) {
        throw const AuthFailure(
          message: 'Google Sign-In failed on Android (ApiException 10). Step to fix:\n1. Open Firebase Console -> Project Settings -> Android App (com.finpilot.expensetracker).\n2. Add your SHA-1 fingerprint (run `cd android && gradlew signingReport` to get it).\n3. Re-download google-services.json.',
          code: 'google-sha1-missing',
        );
      }
      throw AuthFailure(message: errStr.replaceAll('AuthFailure(message: ', '').replaceAll(')', ''));
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      if (_firebaseService.isInitialized) {
        await fb.FirebaseAuth.instance.sendPasswordResetEmail(
          email: email,
          actionCodeSettings: fb.ActionCodeSettings(
            url: 'https://expense-tracker-f9567.web.app/reset-password',
            handleCodeInApp: true,
            androidPackageName: 'com.finpilot.expensetracker',
            androidInstallApp: true,
          ),
        );
      }
      
      // Dispatch custom HTML password reset email via Brevo API
      await _brevoEmailService.sendPasswordResetEmail(
        recipientEmail: email,
        resetLink: 'https://expense-tracker-f9567.web.app/reset-password?email=$email',
        displayName: email.contains('@') ? email.split('@').first : 'Valued User',
      );
    } on fb.FirebaseAuthException catch (e) {
      throw AuthFailure(message: e.message ?? 'Failed to send password reset email', code: e.code);
    } catch (e) {
      throw AuthFailure(message: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    if (_firebaseService.isInitialized) {
      await fb.FirebaseAuth.instance.signOut();
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
    }
    _cachedUser = null;
    await _hiveService.clearUserSession();
    _authStateController.add(null);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  final hiveService = ref.watch(hiveServiceProvider);
  final brevoService = ref.watch(brevoEmailServiceProvider);
  return AuthRepositoryImpl(
    firebaseService: firebaseService,
    hiveService: hiveService,
    brevoEmailService: brevoService,
  );
});
