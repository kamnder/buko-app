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
    apiKey: 'AIzaSyAtClN06FLtjOaMDzLnJeYspEIqTtV0Xj0',
    appId: '1:113136352409:android:c568ce9556ae2af5dc0c08',
    messagingSenderId: '113136352409',
    projectId: 'buko-6f769',
    storageBucket: 'buko-6f769.firebasestorage.app',
  );
}
