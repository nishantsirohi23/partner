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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBraScb_s26cbbpnoA76kl0TaFS0rohPH8',
    appId: '1:1050658836838:android:1cf6f6cc26c14e481b38a7',
    messagingSenderId: '1050658836838',
    projectId: 'perwork',
    storageBucket: 'perwork.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCB0tPZizJUbp7l6dur7TdC6IY9WCxGCXI',
    appId: '1:1050658836838:ios:51e7bb61bf97477a1b38a7',
    messagingSenderId: '1050658836838',
    projectId: 'perwork',
    storageBucket: 'perwork.appspot.com',
    androidClientId: '1050658836838-4uh55kt97cvguck237clcklgke62h0as.apps.googleusercontent.com',
    iosClientId: '1050658836838-7pfllqtoc5i71689jchtli49o1mnjjlo.apps.googleusercontent.com',
    iosBundleId: 'com.perpenny.partner.perpennypartner',
  );

}