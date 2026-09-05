// Generated from the Firebase Android app configuration for BUKO.
// Do not place service-account credentials in this file.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('BUKO Firebase web configuration is not set up yet.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('BUKO Firebase is currently configured for Android only.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBKqjZK0iszVDwyqpAdpV4hXirG8G4X9mUQ',
    appId: '1:979669010060:android:09477f79e84e5156339da9',
    messagingSenderId: '979669010060',
    projectId: 'mrioda',
    storageBucket: 'mrioda.firebasestorage.app',
  );
}
