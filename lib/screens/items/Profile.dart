import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:perpennypartner/screens/items/profile_menu.dart';
import 'package:perpennypartner/screens/profileitems/addbankaccount.dart';
import 'package:perpennypartner/screens/profileitems/editrestaurants.dart';
import 'package:shimmer/shimmer.dart';

import '../../api/apis.dart';
import '../onboding/OnboardingScreen.dart';
import '../profileitems/completedfood.dart';
import '../profileitems/reviews.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => OnboardingScreen()), // Replace LoginScreen with your actual login screen widget
          (Route<dynamic> route) => false,
    );
  }
  String getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    } else if (hour < 17) {
      return 'Afternoon';
    } else {
      return 'Evening';
    }
  }
  int bookingCount = 0;
  String restimage = "";
  String restname = "";
  String restaddress = "";
  String restspec = "";


  void getdate() {
    FirebaseFirestore.instance.collection('restraunts').doc(APIs.me.restid).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {
        restimage = snapshot['image'] ?? '';
        restname = snapshot['name'] ?? '';
        restaddress = snapshot['address'] ?? '';
        restspec = snapshot['specs'] ?? '';


      });
    });
  }
  @override
  void initState() {
    super.initState();
    getdate();

  }


  final FirebaseFirestore _firestore = FirebaseFirestore.instance;





  @override
  Widget build(BuildContext context) {
    bool isLoading = true;
    bool addmobile = false;
    if(APIs.me.mobile==""){
      addmobile= true;
    }


    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
              height: screenHeight * 0.20,
              decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/backappbar1.png"),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25))),
              child: Container(
                child: Stack(

                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 20, right: 20, top: screenHeight*0.005),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [

                              Container(

                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                ),
                                margin: EdgeInsets.only(right: 12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(10)),
                                  child: CachedNetworkImage(
                                    fit: BoxFit.cover,
                                    imageUrl: restimage, // URL of the image
                                    width: 60,
                                    height: 60,
                                    placeholder: (context, url) => Shimmer.fromColors(
                                      baseColor: Colors.grey[200]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.white,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  ),
                                ),
                              ),


                              SizedBox(width: 6,),

                              Container(
                                width: screenWidth*0.65,
                                child:  Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [

                                    Text(
                                      restname,
                                      style: TextStyle(color: CupertinoColors.white, fontSize: 19, fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      maxLines: 1,
                                      overflow: TextOverflow.clip,
                                      restaddress,
                                      style: TextStyle(color: CupertinoColors.white, fontSize: 16, fontWeight: FontWeight.w400),
                                    ),
                                    Text(
                                      maxLines: 1,
                                      overflow: TextOverflow.clip,
                                      restspec,
                                      style: TextStyle(color: CupertinoColors.white, fontSize: 16, fontWeight: FontWeight.w400),
                                    ),
                                    GestureDetector(
                                      onTap: (){
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) =>   UpdateRestaurant()),
                                        );

                                      },
                                      child: Visibility(
                                        visible: addmobile,
                                        child: Text(
                                          "Edit Profile",
                                          style: TextStyle(color: Colors.pink, fontSize: 19, fontWeight: FontWeight.w500),
                                        ),),
                                    )


                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              )
          ),
          Container(
            margin: EdgeInsets.only(top: screenHeight*0.20),
            width: screenWidth,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10,),

                  ProfileMenu(
                    text: "Completed Orders",
                    icon: "assets/food.png",
                    press: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>   CompletedFood()),
                      )
                    },
                  ),
                  ProfileMenu(
                    text: "Bank Account",
                    icon: "assets/payment.png",
                    press: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>   BankDetailsPage()),
                      )
                    },
                  ),
                  ProfileMenu(
                    text: "Store Reviews",
                    icon: "assets/star.png",
                    press: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>   TaskerMyReview()),
                      )
                    },
                  ),

                  ProfileMenu(
                    text: "Log Out",
                    icon: "assets/logout.png",
                    press: () => {
                      _signOut(context)
                    },
                  ),
                  SizedBox(height: 20,)





                ],
              ),
            ),

          )
        ],
      ),
    );
  }

  // Function to calculate the number of days until a date
  int _calculateDaysLeft(DateTime endDate) {
    DateTime today = DateTime.now();
    Duration difference = endDate.difference(today);
    return difference.inDays;
  }
}
