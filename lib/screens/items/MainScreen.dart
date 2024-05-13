import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:perpennypartner/screens/updatedish.dart';
import 'package:shimmer/shimmer.dart';

import '../../api/apis.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool restopen = true;

  void getdate() {
    FirebaseFirestore.instance.collection('userrest').doc(APIs.me.id).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {
        restopen = snapshot['isopen'] ?? true;


      });
    });
  }
  @override
  void initState() {
    super.initState();
    getdate();

  }

  @override
  Widget build(BuildContext context) {
    bool _switchValue = false;
    void _onSwitchChanged(bool value,String dishId) {
      setState(() {
        _switchValue = value;
        APIs.dishavailable(APIs.me.restid,dishId,value);
        // Call your function here with the updated value
        print('Switch value changed: $_switchValue');
      });
    }
    void _onrestaurantswitch(bool value) {
      setState(() {
        _switchValue = restopen;
        APIs.restopen(value);
        // Call your function here with the updated value
        print('Switch value changed: $_switchValue');
      });
    }
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final CollectionReference dishesCollection =
    FirebaseFirestore.instance.collection('restraunts');

    final Stream<QuerySnapshot> _usersStream = dishesCollection
        .doc(APIs.me.restid) // Specify the document ID
        .collection('dishes') // Reference the "dishes" subcollection
        .snapshots();
    return Scaffold(
      appBar: AppBar(
        title: Text('Store Open'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0), // Adjust the right padding as needed
            child: Switch(
              value: restopen,
              onChanged: (value) => _onrestaurantswitch(value),
              activeColor: Colors.pink.withOpacity(0.8),
            ),
          ),
        ],
      ),

        body: restopen?Column(
        children: [
          Expanded(child: StreamBuilder<QuerySnapshot>(
            stream: _usersStream,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading");
              }

              var documents = snapshot.data!.docs.toList();


              if (documents.isEmpty) {
                return Center(
                  child: Container(
                    margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.1),


                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Lottie.asset('assets/lottie/empty.json'),
                        Text("No Items Added")

                      ],
                    ),
                  ),
                );
              } else {
                return Container(
                  height: screenHeight*0.8-screenHeight*0.02,


                  child: ListView.builder(
                    padding: EdgeInsets.only(top: 5),
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data = documents[index].data()! as Map<String, dynamic>;



// At this point, workImage will either be set to the default URL or the URL of the first image of type jpeg, png, or jpg.



                      return GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) =>   UpdateDish(dishId: data['id'])),
                          );
                        },
                        child: Container(
                          height: 160,
                          margin: EdgeInsets.only(left: 15,right: 15,bottom: 7),
                          child: Card(
                            elevation: 3, // Adjust the shadow level
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              padding: EdgeInsets.only(left: 18, right: 18),
                              width: screenWidth,
                              height: 160,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: screenWidth * 0.45,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['name'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            height: 0.9, // Adjust the lineHeight to reduce the gap
                                          ),
                                        ),
                                        Text(
                                          '₹ '+data['restprice'].toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.black.withOpacity(0.85),
                                            fontSize: 19,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        SizedBox(height: 9,),
                                        Switch(
                                          value: data['available'],
                                          onChanged: (value) => _onSwitchChanged(value, data['id']),
                                          activeColor: Colors.pink.withOpacity(0.8),
                                        ),


                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: screenWidth*0.14,
                                          backgroundColor: Colors.transparent, // Set background color for the circle
                                          child: ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: data['image'], // URL of the image
                                              width: screenWidth*0.4, // Double the radius to fit the CircleAvatar
                                              height: screenWidth*0.4, // Double the radius to fit the CircleAvatar
                                              placeholder: (context, url) => Shimmer.fromColors(
                                                baseColor: Colors.grey[300]!,
                                                highlightColor: Colors.grey[100]!,
                                                child: Container(
                                                  width: screenWidth*0.4, // Double the radius to fit the CircleAvatar
                                                  height: screenWidth*0.4, // Double the radius to fit the CircleAvatar
                                                  color: Colors.white,
                                                ),
                                              ),
                                              errorWidget: (context, url, error) => Icon(Icons.error),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            // Dynamically generate stars based on rating
                                            for (int i = 0; i < data['review']; i++)
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    "assets/star2.png",
                                                    height: 18,
                                                    width: 18,
                                                  ),
                                                  SizedBox(width: 4), // Add space between stars
                                                ],
                                              ),
                                            for (int i = 0; i < 5 - data['review']; i++)
                                              Row(
                                                children: [
                                                  Image.asset(
                                                    "assets/emptystar.png", // Assuming this is your empty star image
                                                    height: 18,
                                                    width: 18,
                                                  ),
                                                  SizedBox(width: 4), // Add space between stars
                                                ],
                                              ),
                                          ],
                                        )

                                      ],
                                    ),
                                  )

                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                      ;
                    },
                  ),
                );
              }
            },
          )
          )
        ],
      ):Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset("assets/lottie/restraunt.json"),
          Text("Currently Closed!",style: TextStyle(color:
          Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: 21),)
        ],
    )
    );
  }
}
