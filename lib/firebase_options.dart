// PLACEHOLDER — replaced automatically when you run:
//   flutterfire configure
//
// That command connects this app to YOUR Firebase project and regenerates
// this file with real keys. Until then the app cannot reach Firebase.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
            'DefaultFirebaseOptions are not configured for this platform. '
            'Run `flutterfire configure`.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAfm4uciLTHQhg6yl0A195JhbmRZrUYcLE',
    appId: '1:718376636613:android:1581a34a414698532620ac',
    messagingSenderId: '718376636613',
    projectId: 'al-salah-17ee2',
    storageBucket: 'al-salah-17ee2.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE-ME',
    appId: 'REPLACE-ME',
    messagingSenderId: 'REPLACE-ME',
    projectId: 'REPLACE-ME',
    iosBundleId: 'com.alifsalah.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDkv0qM4gFfxL-uTqI-Fu12k2CO-F0pRlg',
    appId: '1:718376636613:web:89ae95da1176f79d2620ac',
    messagingSenderId: '718376636613',
    projectId: 'al-salah-17ee2',
    authDomain: 'al-salah-17ee2.firebaseapp.com',
    storageBucket: 'al-salah-17ee2.firebasestorage.app',
    measurementId: 'G-9E29K6N165',
  );
}
