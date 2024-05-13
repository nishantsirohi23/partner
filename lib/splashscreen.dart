import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Widget_tree.dart';

class SplashScreen extends StatefulWidget {
  final String name;

  const SplashScreen({Key? key, required this.name}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initializeSharedPreferences().then((_) {
      Timer(Duration(seconds: 2), () {
        bool isFirstTime = _prefs.getBool('isFirstTime') ?? true;
        if (isFirstTime) {
          // If it's the first time, navigate to OnboardingPage
          _prefs.setBool('isFirstTime', false);
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) =>  WidgetTree(name: widget.name),
          ));
        } else {
          // If not the first time, navigate to WidgetTree
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => WidgetTree(name: widget.name),
          ));
        }
      });
    });
  }

  Future<void> _initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Perpenny.gif',
              width: 300,
              height: 300,
            ),
            Text(widget.name)
          ],
        ),
      ),
    );
  }
}