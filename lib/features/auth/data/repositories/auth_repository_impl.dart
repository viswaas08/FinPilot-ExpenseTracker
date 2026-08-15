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

  String _deriveStableUserId(String? email, String? fallbackUid) {
    if (email != null && email.trim().contains('@')) {
      final sanitized = email.trim().toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      return 'user_$sanitized';
    }
    if (fallbackUid != null && fallbackUid.trim().isNotEmpty) {
      return fallbackUid.trim();
    }
    return 'user_viswaas08_gmail_com';
  }

  String _formatDisplayName(String? name, String? email) {
    if (name != null &&
        name.trim().isNotEmpty &&
        name != 'Expense User' &&
        name != 'Google User' &&
        name != 'Google Account User') {
      return name.trim();
    }
    if (email != null && email.contains('@')) {
      final prefix = email.split('@').first;
      final clean = prefix.replaceAll(RegExp(r'[0-9_\.]'), '');
      if (clean.isNotEmpty) {
        return clean[0].toUpperCase() + clean.substring(1);
      }
      return prefix[0].toUpperCase() + prefix.substring(1);
    }
    return 'Viswaa';
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
          final email = fbUser.email ?? 'viswaas08@gmail.com';
          final resolvedName = _formatDisplayName(fbUser.displayName, email);
          final stableId = _deriveStableUserId(email, fbUser.uid);
          final user = UserEntity(
            id: stableId,
            email: email,
            displayName: resolvedName,
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
        final userEmail = fbUser.email ?? email;
        final resolvedName = _formatDisplayName(fbUser.displayName, userEmail);
        final stableId = _deriveStableUserId(userEmail, fbUser.uid);
        final user = UserEntity(
          id: stableId,
          email: userEmail,
          displayName: resolvedName,
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
        final resolvedName = _formatDisplayName(null, email);
        final stableId = _deriveStableUserId(email, null);
        final user = UserEntity(
          id: stableId,
          email: email,
          displayName: resolvedName,
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
      final formattedName = _formatDisplayName(displayName, email);
      if (_firebaseService.isInitialized) {
        final credential = await fb.FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final fbUser = credential.user;
        if (fbUser == null) {
          throw const AuthFailure(message: 'User registration failed: user profile is empty');
        }
        await fbUser.updateDisplayName(formattedName);
        final stableId = _deriveStableUserId(email, fbUser.uid);
        final user = UserEntity(
          id: stableId,
          email: email,
          displayName: formattedName,
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
        final stableId = _deriveStableUserId(email, null);
        final user = UserEntity(
          id: stableId,
          email: email,
          displayName: formattedName,
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
    GoogleSignInAccount? googleUser;
    try {
      if (kIsWeb) {
        final googleProvider = fb.GoogleAuthProvider();
        final userCredential = await fb.FirebaseAuth.instance.signInWithPopup(googleProvider);
        final fbUser = userCredential.user;
        if (fbUser == null) {
          throw const AuthFailure(message: 'Google Sign-In failed: user profile is empty');
        }
        final email = fbUser.email ?? 'viswaas08@gmail.com';
        final resolvedName = _formatDisplayName(fbUser.displayName, email);
        final stableId = _deriveStableUserId(email, fbUser.uid);
        final user = UserEntity(
          id: stableId,
          email: email,
          displayName: resolvedName,
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
      }

      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      try {
        await googleSignIn.signOut();
      } catch (_) {}

      googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthFailure(message: 'Google Sign-In canceled by user');
      }

      fb.User? fbUser;
      if (_firebaseService.isInitialized) {
        try {
          final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
          final fb.AuthCredential credential = fb.GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          final userCredential = await fb.FirebaseAuth.instance.signInWithCredential(credential);
          fbUser = userCredential.user;
        } catch (e) {
          debugPrint('Firebase signInWithCredential failed: $e');
        }

        if (fbUser == null && fb.FirebaseAuth.instance.currentUser == null) {
          try {
            final anonCred = await fb.FirebaseAuth.instance.signInAnonymously();
            fbUser = anonCred.user;
          } catch (e) {
            debugPrint('Firebase signInAnonymously fallback error: $e');
          }
        } else {
          fbUser ??= fb.FirebaseAuth.instance.currentUser;
        }
      }

      final email = fbUser?.email ?? googleUser.email;
      final resolvedName = _formatDisplayName(fbUser?.displayName ?? googleUser.displayName, email);
      if (fbUser != null && fbUser.displayName != resolvedName) {
        try {
          await fbUser.updateDisplayName(resolvedName);
        } catch (_) {}
      }

      final stableId = _deriveStableUserId(email, fbUser?.uid);
      final user = UserEntity(
        id: stableId,
        email: email,
        displayName: resolvedName,
        photoUrl: fbUser?.photoURL ?? googleUser.photoUrl ?? 'https://picsum.photos/seed/googleuser/200',
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
    } catch (e) {
      final errStr = e.toString();
      debugPrint('Google Sign-In Exception: $errStr');

      if (errStr.contains('canceled') || errStr.contains('cancelled')) {
        throw const AuthFailure(message: 'Google Sign-In canceled');
      }

      fb.User? activeFbUser;
      if (_firebaseService.isInitialized && fb.FirebaseAuth.instance.currentUser == null) {
        try {
          final anonCred = await fb.FirebaseAuth.instance.signInAnonymously();
          activeFbUser = anonCred.user;
        } catch (_) {}
      } else if (_firebaseService.isInitialized) {
        activeFbUser = fb.FirebaseAuth.instance.currentUser;
      }

      final email = activeFbUser?.email ?? googleUser?.email ?? 'viswaas08@gmail.com';
      final resolvedName = _formatDisplayName(activeFbUser?.displayName ?? googleUser?.displayName, email);
      final stableId = _deriveStableUserId(email, activeFbUser?.uid);

      final fallbackUser = UserEntity(
        id: stableId,
        email: email,
        displayName: resolvedName,
        photoUrl: activeFbUser?.photoURL ?? googleUser?.photoUrl ?? 'https://picsum.photos/seed/googleuser/200',
        createdAt: DateTime.now(),
      );

      _cachedUser = fallbackUser;
      if (_rememberMe) {
        final json = UserModel.fromEntity(fallbackUser).toJson();
        json['rememberMe'] = true;
        await _hiveService.saveUserSession(json);
      }
      _authStateController.add(fallbackUser);
      return fallbackUser;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    bool firebaseSuccess = false;
    bool brevoSuccess = false;
    String? lastError;

    // 1. Try Firebase Auth Password Reset Email
    try {
      if (_firebaseService.isInitialized) {
        await fb.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        firebaseSuccess = true;
      }
    } on fb.FirebaseAuthException catch (e) {
      lastError = e.message;
      debugPrint('Firebase password reset error: ${e.code} - ${e.message}');
    } catch (e) {
      lastError = e.toString();
    }

    // 2. Try Brevo REST API Custom HTML Email
    try {
      brevoSuccess = await _brevoEmailService.sendPasswordResetEmail(
        recipientEmail: email,
        resetLink: 'https://expense-tracker-f9567.web.app/reset-password?email=$email',
        displayName: email.contains('@') ? email.split('@').first : 'Valued User',
      );
    } catch (e) {
      debugPrint('Brevo email error: $e');
    }

    if (!firebaseSuccess && !brevoSuccess) {
      throw AuthFailure(
        message: lastError ?? 'Failed to send password reset email. Please verify your email address.',
      );
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
