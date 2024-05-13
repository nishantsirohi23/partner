import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';

import '../../api/apis.dart';

class Orders extends StatefulWidget {
  const Orders({Key? key}) : super(key: key);

  @override
  State<Orders> createState() => _MainScreenState();
}

class _MainScreenState extends State<Orders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Orders"),),
      body: Expanded(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('orders').snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Container();
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return  Container(
                height: MediaQuery.of(context).size.height*0.86,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3), // Adjust the sigmaX and sigmaY values for the blur effect
                  child: Container(
                    // Your content here
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black.withOpacity(0), // Adjust the opacity as needed
                    child: Center(
                        child: Lottie.asset("assets/lottie/loading.json")
                    ),
                  ),
                ),
              );
            }

            // Filter documents based on search term
            final List<QueryDocumentSnapshot> filteredDocuments =
            snapshot.data!.docs.toList();

            // Filtered list of documents where userId matches user.uid
            final List<QueryDocumentSnapshot<Map<String, dynamic>>> userBookings = filteredDocuments
                .cast<QueryDocumentSnapshot<Map<String, dynamic>>>()
                .where((doc) => doc['restID'] == APIs.me.restid  && doc['status']!="completed")
                .toList();
            // Sort the user bookings based on the 'createdAt' field
            userBookings.sort((a, b) {
              // Convert 'createdAt' field from string to integer
              int aCreatedAt = int.parse(a['createdAt']);
              int bCreatedAt = int.parse(b['createdAt']);
              // Compare the integers to sort in descending order
              return bCreatedAt.compareTo(aCreatedAt);
            });

            if (userBookings.isEmpty) {
              return Center(
                child: Container(


                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Lottie.asset('assets/lottie/empty.json'),

                    ],
                  ),
                ),
              );
            }



            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 10),
                    scrollDirection: Axis.vertical,
                    itemCount: userBookings.length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document = userBookings[index];
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      List<Map<String, dynamic>> dishesData = (data['dishes'] as List<dynamic>).cast<Map<String, dynamic>>();

                      return GestureDetector(
                        onTap: (){

                        },
                        child: Container(
                          margin: EdgeInsets.only(left: 15, right: 10, top: 5, bottom: 5), // Adjust margins here
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(top: 4,left: 9,bottom: 4),
                                height:dishesData.length*46,
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: dishesData.length,
                                  itemBuilder: (context, index) {
                                    final dish = dishesData[index];
                                    return Container(
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.all(Radius.circular(25)),
                                            child: CachedNetworkImage(
                                              fit: BoxFit.cover,
                                              imageUrl: dish['image'],
                                              width: 40, // Double the radius to fit the CircleAvatar
                                              height: 40, // Double the radius to fit the CircleAvatar
                                              placeholder: (context, url) => Shimmer.fromColors(
                                                baseColor: Colors.grey[300]!,
                                                highlightColor: Colors.grey[100]!,
                                                child: Container(
                                                  width: 40, // Double the radius to fit the CircleAvatar
                                                  height: 40, // Double the radius to fit the CircleAvatar
                                                  color: Colors.white,
                                                ),
                                              ),
                                              errorWidget: (context, url, error) => Icon(Icons.error),
                                            ),
                                          ),

                                          SizedBox(width: 5),
                                          Text(dish['quantity'].toString()+" x ",style: TextStyle(color: Colors.black,fontSize: 17),),
                                          Expanded(
                                            child: Text(
                                              dish['name'],
                                              style: TextStyle(color: Colors.black,fontSize: 17),
                                              maxLines: 1,
                                              overflow: TextOverflow.clip,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              DashedLine(height: 0.8,color: Colors.black54,),
                              Container(
                                padding: EdgeInsets.all(4),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Total Amount",
                                      style: TextStyle(
                                          fontSize: 17
                                      ),),
                                    Row(
                                      children: [
                                        Image.asset('assets/rupee.png',height: 30,width: 30,),
                                        Text(data['restamount'].toString(),style: TextStyle(
                                          fontSize: 17
                                        ),)
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),

                        ),
                      );
                    },
                  ),
                ),
              ],
            );


          },
        ),
      ),
    );
  }
}
class DashedLine extends StatelessWidget {
  final double height;
  final Color color;

  const DashedLine({Key? key, this.height = 1, this.color = Colors.black}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, height),
      painter: _DashedLinePainter(color),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    final double dashWidth = 5;
    final double dashSpace = 5;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
