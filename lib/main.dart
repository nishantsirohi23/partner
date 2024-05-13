import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:perpennypartner/screens/addrest.dart';
import 'package:perpennypartner/screens/onboding/OnboardingScreen.dart';
import 'package:perpennypartner/splashscreen.dart';


import 'api/apis.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  _initializeFirebase();

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );



  // Set fullscreen mode for Android





  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String? screen;

  const MyApp({Key? key, this.screen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(name: '',),
      debugShowCheckedModeBanner: false,
    );
  }
}
_initializeFirebase() async {

  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Showing Message Notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );
  log('\nNotification Channel Result: $result');
}