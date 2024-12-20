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
        return ios;
      case TargetPlatform.macOS:
        return macos;
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
    apiKey: 'AIzaSyDm-mK_4TxOQ8odzEyDseFNl28fm2V7QLA',
    appId: '1:521356203062:web:a27529126abf216ec37497',
    messagingSenderId: '521356203062',
    projectId: 'profile-app-a5399',
    authDomain: 'profile-app-a5399.firebaseapp.com',
    storageBucket: 'profile-app-a5399.firebasestorage.app',
    measurementId: 'G-JED75C4CBX',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBhP7CohTRCc1Jr740evibYXKH8Whk82jY',
    appId: '1:521356203062:android:975b297cf1bfe84ec37497',
    messagingSenderId: '521356203062',
    projectId: 'profile-app-a5399',
    storageBucket: 'profile-app-a5399.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBGfQ_etOhK5t3-AuhJTHMVr-E_QfbgfIs',
    appId: '1:521356203062:ios:8425ee2089e59d90c37497',
    messagingSenderId: '521356203062',
    projectId: 'profile-app-a5399',
    storageBucket: 'profile-app-a5399.firebasestorage.app',
    iosBundleId: 'com.example.profileapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBGfQ_etOhK5t3-AuhJTHMVr-E_QfbgfIs',
    appId: '1:521356203062:ios:8425ee2089e59d90c37497',
    messagingSenderId: '521356203062',
    projectId: 'profile-app-a5399',
    storageBucket: 'profile-app-a5399.firebasestorage.app',
    iosBundleId: 'com.example.profileapp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDm-mK_4TxOQ8odzEyDseFNl28fm2V7QLA',
    appId: '1:521356203062:web:76d6e17bbd301d36c37497',
    messagingSenderId: '521356203062',
    projectId: 'profile-app-a5399',
    authDomain: 'profile-app-a5399.firebaseapp.com',
    storageBucket: 'profile-app-a5399.firebasestorage.app',
    measurementId: 'G-1RZYZ9RQPV',
  );
}
