// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDQxzlscFMA4mnVdPSUZBjsnZGWUSjuzXY',
    appId: '1:191888201765:web:78fda1b5c1aa93dcbe87cc',
    messagingSenderId: '191888201765',
    projectId: 'agro-7a515',
    authDomain: 'agro-7a515.firebaseapp.com',
    storageBucket: 'agro-7a515.appspot.com',
    measurementId: 'G-837LPE53PC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC0SPmGqjrqnCAX8Qt2pYyU3vG5_AAtPpo',
    appId: '1:191888201765:android:aee78eda130333aebe87cc',
    messagingSenderId: '191888201765',
    projectId: 'agro-7a515',
    storageBucket: 'agro-7a515.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDQxzlscFMA4mnVdPSUZBjsnZGWUSjuzXY',
    appId: '1:191888201765:web:5d0f00d8709245d1be87cc',
    messagingSenderId: '191888201765',
    projectId: 'agro-7a515',
    authDomain: 'agro-7a515.firebaseapp.com',
    storageBucket: 'agro-7a515.appspot.com',
    measurementId: 'G-TND344EZ8Z',
  );
}
