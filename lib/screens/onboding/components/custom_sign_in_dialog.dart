import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:google_sign_in/google_sign_in.dart';


import '../../../Widget_tree.dart';
import '../../../api/apis.dart';
import '../../addrest.dart';



final FirebaseAuth auth = FirebaseAuth.instance;
final User? user = auth.currentUser;
final uid = user?.uid;

final _firestore = FirebaseFirestore.instance;

late Stream<List<DocumentSnapshot>> stream;

Future<Object?> customSigninDialog(BuildContext context, bool isWorker,
    {required ValueChanged onCLosed}) {
  bool isLoading = false;
  print(isWorker);// Track loading state

  Future<UserCredential?> _signInWithGoogle() async {
    // Set loading state to true when starting sign-in process
    isLoading = true;
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log('\n_signInWithGoogle: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('something went wrong'),
          duration: Duration(seconds: 2),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              // Optional: Add any action when the user clicks on the SnackBar action
            },
          ),
        ),
      );
      return null;
    } finally {
      // Set loading state to false when sign-in process is complete
      isLoading = false;
    }
  }

  _handleGoogleBtnClick() {
    isLoading = true;

    // for showing progress bar
    _signInWithGoogle().then((user) async {
      // for hiding progress bar
      if (user != null) {
        log('\nUser: ${user.user}');
        log('\nUserAdditionalInfo: ${user.additionalUserInfo}');

        if (await APIs.userExists()) {

          Navigator.pushAndRemoveUntil(

            context,
            MaterialPageRoute(builder: (context) => WidgetTree(name: "",)),
                (route) => false, // Remove all routes below HomeScreen
          );
        } else {
          isLoading = false;

          await APIs.createUser().then((value) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => RestScreen()),
                  (route) => false, // Remove all routes below HomeScreen
            );
          });
        }
      }
    });
  }

  return showGeneralDialog(
    barrierDismissible: true,
    barrierLabel: "Sign In",
    context: context,
    transitionDuration: const Duration(milliseconds: 400),
    transitionBuilder: (_, animation, __, child) {
      Tween<Offset> tween;
      tween = Tween(begin: const Offset(0, -1), end: Offset.zero);
      return SlideTransition(
        position: tween.animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        ),
        child: child,
      );
    },
    pageBuilder: (context, _, __) => Center(
      child: Container(
        height: 270,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.94),
          borderRadius: const BorderRadius.all(Radius.circular(40)),
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  const Text(
                    "Sign In",
                    style: TextStyle(fontSize: 34, fontFamily: "Poppins"),
                  ),
                   Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      isWorker?"Access to 100+ Categories of professionals. PerPenny: Your Genie for Getting Things Done":"Find the best work for you and at your price and ease and fast payments",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: _handleGoogleBtnClick,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: (){},
                          icon: SvgPicture.asset(
                            "assets/icons/google_box.svg",
                            height: 64,
                            width: 64,
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text(
                          "Google Sign In",
                          style: TextStyle(fontSize: 17),
                        ),

                      ],
                    ),
                  ),
                  // Show CircularProgressIndicator when isLoading is true
                  if (isLoading)
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.05),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(
                              height: 0.05,
                            ),
                            Text(
                              "Loading...",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w400),
                            )
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const Positioned(
                left: 0,
                right: 0,
                bottom: -48,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.close,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ).then(onCLosed);
}
