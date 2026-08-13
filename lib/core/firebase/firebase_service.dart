import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../firebase_options.dart';

class FirebaseService {
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isInitialized = true;

      // Configure Firestore Settings for Offline Persistence
      try {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      } catch (e) {
        debugPrint('Firestore settings already initialized or web platform: $e');
      }

      debugPrint('Firebase successfully initialized');
    } catch (e) {
      _isInitialized = false;
      debugPrint('Firebase initialization skipped/failed: $e. Operating in offline/local mode.');
    }
  }
}

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});
