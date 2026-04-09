
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyDZQa6WPG_KsMVhefkjO1dx_rnr0LAGEXI',
    appId: '1:829403071480:web:f44552e1b6b859d64a0c0d',
    messagingSenderId: '829403071480',
    projectId: 'movieapp-1911b',
    authDomain: 'movieapp-1911b.firebaseapp.com',
    storageBucket: 'movieapp-1911b.firebasestorage.app',
    measurementId: 'G-PJR9BBRSSP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAew1Pxj70s1Ne_b0sE3MT_TdxM3TgKp7E',
    appId: '1:829403071480:android:f3563fcb6d18d1cd4a0c0d',
    messagingSenderId: '829403071480',
    projectId: 'movieapp-1911b',
    storageBucket: 'movieapp-1911b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCEbU9nAt9FgdfGu45r0kUF6c2-EzDRPGY',
    appId: '1:829403071480:ios:bd2229f189fa7a224a0c0d',
    messagingSenderId: '829403071480',
    projectId: 'movieapp-1911b',
    storageBucket: 'movieapp-1911b.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCEbU9nAt9FgdfGu45r0kUF6c2-EzDRPGY',
    appId: '1:829403071480:ios:bd2229f189fa7a224a0c0d',
    messagingSenderId: '829403071480',
    projectId: 'movieapp-1911b',
    storageBucket: 'movieapp-1911b.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDZQa6WPG_KsMVhefkjO1dx_rnr0LAGEXI',
    appId: '1:829403071480:web:fbf5ad0508a416344a0c0d',
    messagingSenderId: '829403071480',
    projectId: 'movieapp-1911b',
    authDomain: 'movieapp-1911b.firebaseapp.com',
    storageBucket: 'movieapp-1911b.firebasestorage.app',
    measurementId: 'G-X76XZZVJRE',
  );

}
