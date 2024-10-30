// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAzZI32suYKBLpfMsKr629puIY5ILxEgK8',
    appId: '1:96632359885:web:54607650eac8452fab9284',
    messagingSenderId: '96632359885',
    projectId: 'vetement-app',
    authDomain: 'vetement-app.firebaseapp.com',
    storageBucket: 'vetement-app.appspot.com',
    measurementId: 'G-3CMJR2RW19',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBUjUg0CJuthX0aeK2gnAxaao-RpqAO0RI',
    appId: '1:96632359885:android:be540615a3fa85beab9284',
    messagingSenderId: '96632359885',
    projectId: 'vetement-app',
    storageBucket: 'vetement-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCFbFyDniDA65WbQj0ikl7R3aaKl-5R5MU',
    appId: '1:96632359885:ios:0746d1ea0c2d42dfab9284',
    messagingSenderId: '96632359885',
    projectId: 'vetement-app',
    storageBucket: 'vetement-app.appspot.com',
    iosClientId: '96632359885-h5n0edbq5tied1frbkurl9glju0280h2.apps.googleusercontent.com',
    iosBundleId: 'com.example.vetementsApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCFbFyDniDA65WbQj0ikl7R3aaKl-5R5MU',
    appId: '1:96632359885:ios:0746d1ea0c2d42dfab9284',
    messagingSenderId: '96632359885',
    projectId: 'vetement-app',
    storageBucket: 'vetement-app.appspot.com',
    iosClientId: '96632359885-h5n0edbq5tied1frbkurl9glju0280h2.apps.googleusercontent.com',
    iosBundleId: 'com.example.vetementsApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAzZI32suYKBLpfMsKr629puIY5ILxEgK8',
    appId: '1:96632359885:web:fd3805d156f0ac2eab9284',
    messagingSenderId: '96632359885',
    projectId: 'vetement-app',
    authDomain: 'vetement-app.firebaseapp.com',
    storageBucket: 'vetement-app.appspot.com',
    measurementId: 'G-49G8C491QE',
  );
}
