import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../../../api/apis.dart';



class TaskerMyReview extends StatefulWidget {
  const TaskerMyReview({Key? key}) : super(key: key);

  @override
  State<TaskerMyReview> createState() => _ShowAllReviewState();
}

class _ShowAllReviewState extends State<TaskerMyReview> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text("Store Reviews"),
      ),
      body: Column(
        children: [

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('prof').doc(APIs.me.id).collection('reviews').snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> playerSnapshot) {
              if (playerSnapshot.hasError) {
                return Text('Something went wrong');
              }

              if (playerSnapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading");
              }

              List<DocumentSnapshot> playerDocs = playerSnapshot.data!.docs;
              if(playerDocs.isEmpty){
                return Center(
                  child: Container(
                    margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.1),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Lottie.asset('assets/lottie/empty.json'),
                      ],
                    ),
                  ),
                );
              }

              return Container(
                margin: EdgeInsets.only(left: 15,right: 15),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height*0.8, // Set height as needed
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.vertical,
                    itemCount: playerDocs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> playerData = playerDocs[index].data() as Map<String, dynamic>;
                      String userId = playerData['userId'];
                      // Adjust the UI according to your requirements
                      return Container(
                        width: MediaQuery.of(context).size.width*0.9,
                        margin: EdgeInsets.only(left: 0,top: 8,right: 8,bottom: 8),

                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Column(
                                children: [
                                  StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
                                    builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                                      if (userSnapshot.hasError) {
                                        return Text('Something went wrong');
                                      }

                                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                                        return CircularProgressIndicator(); // Or any other loading indicator
                                      }

                                      Map<String, dynamic> userData = userSnapshot.data!.data() as Map<String, dynamic>;
                                      String imageUrl = userData['image'];
                                      String name = userData['name'];

                                      return Container(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,

                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 50.0,
                                                      height: 50.0,
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xff7c94b6),
                                                        image: DecorationImage(
                                                          image: NetworkImage(imageUrl),
                                                          fit: BoxFit.cover,
                                                        ),
                                                        border: Border.all(
                                                          color: Colors.white,
                                                          width: 2.0,
                                                        ),
                                                        borderRadius: BorderRadius.all(Radius.circular(50.0)),
                                                      ),
                                                    ),
                                                    SizedBox(width: 15),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Container(
                                                          width: screenWidth*0.27,
                                                          child: Text(
                                                            name,
                                                            maxLines: 2,
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: screenWidth*0.04,
                                                              overflow: TextOverflow.clip, // or TextOverflow.ellipsis, etc.
                                                            ),
                                                          ),
                                                        ),

                                                        Text(
                                                          DateFormat('dd/MM/yyyy').format(playerData['date'].toDate()),
                                                          style: TextStyle(fontWeight: FontWeight.w300, fontSize: screenWidth*0.035, color: Colors.grey.shade500),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),

                                                Container(
                                                  height: 32,
                                                  width: 60,
                                                  decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.all(Radius.circular(20))),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Image.asset("assets/star.png",height: 25,width: 25,),
                                                      Text(
                                                        playerData['star'].toString(),
                                                        style: TextStyle(color: Colors.deepOrange),
                                                      )
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                              playerData['subject'],
                                              style: TextStyle(fontSize: screenWidth*0.034),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}