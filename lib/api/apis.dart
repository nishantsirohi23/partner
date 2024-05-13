import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:perpennypartner/screens/profileitems/editrestaurants.dart';

import '../models/chat_user.dart';
import '../models/dishcart.dart';
import '../models/dishes.dart';
import '../models/foodcart.dart';
import '../models/prof.dart';
import '../models/restraunts.dart';
import '../models/work.dart';

class APIs {
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;
  static late ChatUser me;

  static User get user => auth.currentUser!;
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('Push Token: $t');
      }
    });
  }

  static Future<void> sendPushNotification(String title,String pushToken, String msg) async {
    try {
      final body = {
        "to": pushToken,
        "notification": {
          "title": title, //our name should be send
          "body": msg,
          "android_channel_id": "chats",
          // Title received as a parameter
          "amount": 1200, // Amount received as a parameter
          "distance": "1.2 KM", // Distance received as a parameter
          "background_color": "#FFFFFF",
          "click_action": "FLUTTER_NOTIFICATION_CLICK",

        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "sound": "default",
          "status": "done",
          "screen": "screen1",
          "background_color": "#FFFFFF",

        }
        // "data": {
        //   "some_data": "User ID: ${me.id}",
        // },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
            'key=AAAA9KAlkWY:APA91bHuwBkjOJXba305JReU4hlXP_r3hIs7qI96o3_qV7fUbmNx06RO2a2D3nPpNsFDtOuughbpt_F-xuU-0dLp0KPqJqBMaJ65KWsb1PKoAE0vDX8c02N7SosJfGyjDAr9DNNTCEZi'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }
  static Future<void> storeOrUpdateDishes(String restId, String restName,String restImage, Map<String, Dish> dishes) async {
    // Reference to the Firestore collection 'foodcart'
    final CollectionReference restaurantsCollection = FirebaseFirestore.instance.collection("users").doc(APIs.me.id).collection('foodcart');

    // Calculate the total item count
    int totalItem = 0;
    dishes.forEach((_, dish) {
      totalItem += dish.quantity;
    });

    // Check if the restaurant document already exists
    final DocumentSnapshot restaurantDoc = await restaurantsCollection.doc(restId).get();

    if (restaurantDoc.exists) {
      // If the restaurant document exists, update the dishes subcollection
      if (dishes.isEmpty) {
        // If dishes map is empty, delete the restaurant document
        await restaurantsCollection.doc(restId).delete();
      } else {
        // If dishes map is not empty, update the dishes subcollection
        await restaurantsCollection.doc(restId).update({
          'restName': restName,
          'restImage': restImage,
          'total': totalItem
        }); // Update restaurant details and total item count

        // Convert dishes map to a List<Map<String, dynamic>>
        final List<Map<String, dynamic>> dishesList = dishes.values.map((dish) => dish.toMap()).toList();
        await restaurantsCollection.doc(restId).collection('dishes').doc('dishes').set({'dishes': dishesList});
      }
    } else {
      // If the restaurant document doesn't exist, create it with the dishes subcollection
      await restaurantsCollection.doc(restId).set({
        'restId': restId,
        'restName': restName,
        'restImage': restImage,
        'total': totalItem
      }); // Add restaurant details and total item count to the document

      // Convert dishes map to a List<Map<String, dynamic>>
      final List<Map<String, dynamic>> dishesList = dishes.values.map((dish) => dish.toMap()).toList();
      await restaurantsCollection.doc(restId).collection('dishes').doc('dishes').set({'dishes': dishesList});
    }
  }
  static Future<int> doesDishExistInFoodCart(String foodCartDocId, String dishId) async {
    try {
      // Reference to the "dishes" subcollection of a specific document in the "food cart" collection
      CollectionReference dishesCollection = FirebaseFirestore.instance.collection('users').doc(APIs.me.id).collection('foodcart').doc(foodCartDocId).collection('dishes');

      // Get the document snapshot of the specified document in the "food cart" collection
      DocumentSnapshot foodCartDocSnapshot = await dishesCollection.doc(foodCartDocId).get();

      // Check if the document exists and contains the "dishes" array
      if (foodCartDocSnapshot.exists && foodCartDocSnapshot.data() != null) {
        // Cast the data to Map<String, dynamic>
        Map<String, dynamic> data = foodCartDocSnapshot.data()! as Map<String, dynamic>;

        // Check if the "dishes" array exists and contains a dish with the specified ID
        if (data.containsKey('dishes')) {
          List<dynamic>? dishesArray = data['dishes'];

          if (dishesArray != null) {
            // Check if the dish with the specified ID exists in the "dishes" array
            for (var dish in dishesArray) {
              if (dish['id'] == dishId) {
                return dish['quantity'] as int;
              }
            }
          }
        }
      }

      // Return 0 if the dish does not exist in the food cart
      return 0;
    } catch (e) {
      print('Error checking dish existence: $e');
      return 0;
    }
  }
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime
          .now()
          .millisecondsSinceEpoch
          .toString(),
      'push_token': me.pushToken,
    });
  }
  static Future<String?> addWork(Work work,String name) async {
    try {
      // Convert work object to a map
      Map<String, dynamic> workData = work.toMap();
      // Reference to the 'work' collection in Firestore
      CollectionReference workCollection = firestore.collection('work');
      // Add the work data to Firestore with an auto-generated ID
      DocumentReference workDocumentRef = await workCollection.add(workData);
      // Get the auto-generated document ID and update the workData
      String documentID = workDocumentRef.id;
      workData['id'] = documentID;
      // Update the document with the ID field
      await workDocumentRef.update({'id': documentID});
      print('Work added to Firestore successfully!');
      // Reference to the 'work' collection in Firestore
      CollectionReference userCollection = firestore.collection('users');
      // Document reference to the specific user document
      DocumentReference userDocRef = userCollection.doc(user.uid);
      CollectionReference workCollectionuser = userDocRef.collection('work');
      DocumentReference workDocumentRefuser = await workCollectionuser.add(
          workData);
      await workDocumentRefuser.update(
          {'id': documentID, 'status': 'uncompleted'});
      CollectionReference tracksCollectionuser = userDocRef.collection('tracks');
      DocumentReference tracksDocumentRef = tracksCollectionuser.doc(documentID);

      await tracksDocumentRef.set({
        'id': documentID,
        'image': 'https://cdn.dribbble.com/users/620539/screenshots/16497048/media/5529c7155e2de6aae3ae9c39a18df610.png?resize=1600x1200&vertical=center',
        'name': name,
        'type': 'work'
      });


      CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

// Reference to the specific user's document
      DocumentReference userDocRef1 = usersCollection.doc(user.uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userDocRef1);
        int previousValue = snapshot['totalorder'] ?? 0;
        transaction.update(userDocRef1, {'totalorder': previousValue + 1});
      });



      print('Work added to Firestore successfully!');
      return 'Work added successfully!';
    } catch (e) {
      print('Error adding work to Firestore: $e');
      return 'Error adding work. Please try again.';
    }
  }
  static Future<void> addworktotracks(String docid,String name , String image) async {
    CollectionReference userCollection = firestore.collection('users');
    // Document reference to the specific user document
    DocumentReference userDocRef = userCollection.doc(user.uid);

    CollectionReference tracksCollectionuser = userDocRef.collection('tracks');
    DocumentReference tracksDocumentRef = tracksCollectionuser.doc(docid);

    await tracksDocumentRef.set({
      'id': docid,
      'image': image,
      'name': name,
      'type': 'booking'
    });


    CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

// Reference to the specific user's document
    DocumentReference userDocRef1 = usersCollection.doc(user.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userDocRef1);
      int previousValue = snapshot['totalorder'] ?? 0;
      transaction.update(userDocRef1, {'totalorder': previousValue + 1});
    });


  }
  static Future<void> addfoodtotracks(String docid,String restimage,String name) async {
    CollectionReference userCollection = firestore.collection('users');
    // Document reference to the specific user document
    DocumentReference userDocRef = userCollection.doc(user.uid);


    CollectionReference tracksCollectionuser = userDocRef.collection('tracks');
    DocumentReference tracksDocumentRef = tracksCollectionuser.doc(docid);

    await tracksDocumentRef.set({
      'id': docid,
      'image': restimage,
      'name': name,
      'type': 'food'
    });

    CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

// Reference to the specific user's document
    DocumentReference userDocRef1 = usersCollection.doc(user.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(userDocRef1);
      int previousValue = snapshot['totalorder'] ?? 0;
      transaction.update(userDocRef1, {'totalorder': previousValue + 1});
    });


  }
  static Future<void> makefoodordercomplete(String orderId) async {
    final CollectionReference workCollection = FirebaseFirestore.instance
        .collection('orders');
    DocumentSnapshot workSnapshot = await workCollection.doc(orderId).get();
    String orderBy = workSnapshot['orderBy'];
    CollectionReference profCollection = FirebaseFirestore.instance
        .collection('orders');
    await profCollection
        .doc(orderId)
        .update({
      'status': 'completed',
    });
    DocumentReference docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(orderBy) // Specify the document ID here
        .collection('tracks')
        .doc(orderId); // Specify the sub-collection and its document ID here

    // Delete the document
    await docRef.delete();
    final CollectionReference collectionReference1 = FirebaseFirestore.instance.collection('users');

// Increment the value of the existing field by one
    collectionReference1.doc(orderBy).update({
      "totalorder": FieldValue.increment(-1), // Replace 'fieldName' with the name of your existing field
    }).then((value) {
      print("Field value incremented successfully!");
    }).catchError((error) {
      print("Failed to increment field value: $error");
    });


  }
  static Future<String?> addProf(Professional prof) async {
    try {
      // Convert work object to a map
      Map<String, dynamic> profData = prof.toMap();

      // Reference to the 'work' collection in Firestore
      CollectionReference workCollection = firestore.collection('prof');

      // Set the document ID to the passed ID
      String documentID = prof.id;

      // Add the work data to Firestore with the specified ID
      await workCollection.doc(documentID).set(profData);

      print('Work added to Firestore successfully!');
      return 'Work added successfully!';
    } catch (e) {
      print('Error adding work to Firestore: $e');
      return 'Error adding work. Please try again.';
    }
  }
  static Future<String?> addRest(Rests prof) async {
    try {
      // Convert work object to a map
      Map<String, dynamic> profData = prof.toMap();

      // Reference to the 'work' collection in Firestore
      CollectionReference workCollection = firestore.collection('restraunts');

      // Add the work data to Firestore and auto-generate a document ID
      DocumentReference docRef = await workCollection.add(profData);

      // Get the auto-generated document ID
      String docId = docRef.id;

      // Set the document ID to the Rests object
      prof.id = docId;
      CollectionReference usersCollection = FirebaseFirestore.instance
          .collection('restraunts');

      // Reference to the specific user's document
      DocumentReference userDocRef = usersCollection.doc(docId);
      await userDocRef.update({
        'id': docId
      });
      CollectionReference usercollectyio = FirebaseFirestore.instance
          .collection('userrest');

      // Reference to the specific user's document
      DocumentReference userupdate = usercollectyio.doc(user.uid);
      await userupdate.update({
        'detailsdone': true,
        'bankadded': false,
        'restid': docId,
        'restimage': prof.image,
        'restaddress': prof.address,
        'restname': prof.name,
        'restspecs': prof.specs
      });

      print('Work added to Firestore successfully with ID: $docId');
      return docId; // Return the document ID
    } catch (e) {
      print('Error adding work to Firestore: $e');
      return null; // Return null in case of error
    }
  }
  static Future<void> dishavailable(String restId,String dishId,bool value) async{
    CollectionReference usercollectyio = FirebaseFirestore.instance
        .collection('restraunts').doc(APIs.me.restid).collection('dishes');

    // Reference to the specific user's document
    DocumentReference userupdate = usercollectyio.doc(dishId);
    await userupdate.update({
      'available': value
    });
  }
  static Future<void> restopen(bool value) async{
    CollectionReference usercollectyio = FirebaseFirestore.instance
        .collection('restraunts');

    // Reference to the specific user's document
    DocumentReference userupdate = usercollectyio.doc(APIs.me.restid);
    await userupdate.update({
      'isopen': value
    });
    CollectionReference userrestcollection = FirebaseFirestore.instance
        .collection('userrest');

    // Reference to the specific user's document
    DocumentReference userrestupdate = userrestcollection.doc(APIs.me.id);
    await userrestupdate.update({
      'isopen': value
    });

  }
  static Future<String?> addDish(Dishesss prof,String restid) async {
    try {
      Map<String, dynamic> profData = prof.toMap();

      // Convert work object to a map
      DocumentReference restaurantRef =
      FirebaseFirestore.instance.collection('restraunts').doc(restid);

      // Update the array field 'namelist' by appending the new name
      await restaurantRef.update({
        'dishes': FieldValue.arrayUnion([prof.name])
      });

      // Reference to the 'work' collection in Firestore
      CollectionReference workCollection = firestore.collection('restraunts').doc(restid).collection('dishes');

      // Add the work data to Firestore and auto-generate a document ID
      DocumentReference docRef = await workCollection.add(profData);

      // Get the auto-generated document ID
      String docId = docRef.id;

      // Set the document ID to the Rests object
      prof.id = docId;
      CollectionReference usersCollection = FirebaseFirestore.instance
          .collection('restraunts').doc(restid).collection('dishes');

      // Reference to the specific user's document
      DocumentReference userDocRef = usersCollection.doc(docId);
      await userDocRef.update({
        'id': docId
      });
      print('Work added to Firestore successfully with ID: $docId');

      CollectionReference dishesCollection =
      FirebaseFirestore.instance.collection('dishes');
      QuerySnapshot existingDishesQuery = await dishesCollection
          .where('name', isEqualTo: prof.name)
          .limit(1)
          .get();

      // Check if the query result has any documents (dish with the same name exists)
      if (existingDishesQuery.docs.isNotEmpty) {
        try {
          DocumentReference docRef = FirebaseFirestore.instance.collection('dishes').doc(existingDishesQuery.docs.first.id).collection('restraunts').doc(restid);

          // Add a new document with the name "nishant"
          await docRef.set({
            'id': restid,
          });
        } catch (e) {
          print('Error adding document: $e');
        }

        print('Dish with the same name already exists');
      } else {
        try {
          try {
            // Get a reference to the Firestore database
            final CollectionReference dishesCollection =
            FirebaseFirestore.instance.collection('dishes');

            // Add document to the collection with autogenerated ID
            DocumentReference newDishRef = await dishesCollection.add({
              'name': prof.name,
              'image': prof.image,
              'price': prof.price,
            });

            // Update the document ID to match the autogenerated ID
            await newDishRef.update({'id': newDishRef.id});
            DocumentReference docRef = FirebaseFirestore.instance.collection('dishes').doc(newDishRef.id).collection('restraunts').doc(restid);

            // Add a new document with the name "nishant"
            await docRef.set({
              'id': restid,
            });
          } catch (e) {
            print("Error adding dish: $e");
          }
        } catch (e) {
          print('Error adding document: $e');
        }


        print('Dish with the same name not exists');
      }
      return docId; // Return the document ID
    } catch (e) {
      print('Error adding work to Firestore: $e');
      return null; // Return null in case of error
    }
  }


  static Future<void> createUser() async {
    final time = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();

    final chatUser = ChatUser(
        id: user.uid,
        neworder: 0,
        completedorder: 0,
        pendingorder: 0,
        name: user.displayName.toString(),
        email: user.email.toString(),
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        isopen: true,
        type: "restaurant",
        pushToken: '',
        nmessage: 0,
        nnotibooking: 0,
        nnotiwork: 0,
        mobile: '',
        restid: '',
        restimage: '',
        latitude: 0.0,
        longitude: 0.0,
        restname: '',
        restspecs: '',
        restaddress: '',
        detailsdone: false,
        bankadded: false,
        freeplatform: 5
    );

    return await firestore
        .collection('userrest')
        .doc(user.uid)
        .set(chatUser.toJson());
  }
  static Future<bool> userExists() async {
    return (await firestore.collection('userrest').doc(user.uid).get()).exists;
  }
  static Future<void> getSelfInfo() async {
    await firestore.collection('userrest').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();

        //for setting user status to active
        APIs.updateActiveStatus(true);
        log('My Data: ${user.data()}');
      }
    });
  }
  static Future<void> sendnotificationtowork(String msg,String type)async{
    try{
      final QuerySnapshot profSnapshot =
      await FirebaseFirestore.instance.collection('prof').get();

      List<Map<String, dynamic>> documentsData = [];

      profSnapshot.docs.forEach((DocumentSnapshot document) async {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        String workerId = data['id'];
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(workerId)
            .get();

        if (userSnapshot.exists) {
          if((userSnapshot.data() as Map<String, dynamic>)['type']==type){
            String pushToken = (userSnapshot.data() as Map<String, dynamic>)['push_token'];
            APIs.sendPushNotification("New Work",pushToken,msg);
          }

          // Now you have the pushToken for this user, proceed with sending the notification
          // For example, you can use a push notification service like Firebase Cloud Messaging (FCM)
          // to send a notification to this pushToken
        }
        //fetch the pushToken form users with doc id equal to worker id
      });


    }
    catch(e){

    }
  }
  static Future<void> applyToWork(String workID, String workerID, double amount,
      String name) async {
    try {
      double increasedAmount = amount * (1 + 7.5 / 100);
      String roundedAmountString = increasedAmount.toStringAsFixed(2); // Convert to string with 2 decimal places
      if (!roundedAmountString.contains('.')) {
        // If there is no decimal point, add .00 at the end
        roundedAmountString += '.00';
      }
      double roundedAmount = double.parse(roundedAmountString);
      final CollectionReference workCollection = FirebaseFirestore.instance
          .collection('work');
      DocumentSnapshot workSnapshot = await workCollection.doc(workID).get();
      String workBy = workSnapshot['workBy'];

      String workname = workSnapshot['name'];
      print("hey");
      print(workBy);

      // Add worker details to the subcollection
      await workCollection
          .doc(workID)
          .collection('workers')
          .add({
        'workerID': workerID,
        'amount': roundedAmount,
        'workeram': amount
      });
      String workername = "";
      final DocumentSnapshot profileSnapshot1 = await FirebaseFirestore.instance
          .collection('prof').doc(workerID).get();
      if (profileSnapshot1.exists) {
        workername = profileSnapshot1['name'];

      }
      final DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection('users').doc(workBy).get();
      if (profileSnapshot.exists) {
        print("hey 1");
        String pushToken = profileSnapshot['push_token'];
        APIs.sendPushNotification("New Worker Applied",pushToken, "$workername applied to $name work");
      }
      int nnotiwork = profileSnapshot['nnotiwork'];
      try {
        // Get the current user's UID


        // Reference to the Firestore collection "users"
        CollectionReference usersCollection = FirebaseFirestore.instance
            .collection('users');

        // Reference to the specific user's document
        print(workBy);
        DocumentReference userDocRef = usersCollection.doc(workBy);
        await userDocRef.update({
          'nnotiwork': nnotiwork + 1
        });

        // Reference to the "notiwork" subcollection
        CollectionReference notiWorkCollection = userDocRef.collection(
            'notiwork');

        // Add a new document to the "notiwork" subcollection
        await notiWorkCollection.add({
          'workID': workID,
          'workerID': workerID,
          'amount': amount,
          'seen': false,
          'name': workname,
          'message': "accept",
          'timestamp': FieldValue.serverTimestamp(),
          // Add a timestamp for sorting purposes
        });


        print('Notification added successfully.');
      } catch (e) {
        print('Error adding notification: $e');
        // Handle errors here
      }

      // Change the status in the work collection
      await workCollection.doc(workID).update({'status': 'posted'});

      // Add the workID to the subcollection inside the profile document
      final DocumentReference profileDocRef = FirebaseFirestore.instance
          .collection('prof').doc(workerID);
      await profileDocRef.collection('workIDs').add({
        'workID': workID,
        'status': "applied",
      });
    } catch (e) {
      print('Error applying to work: $e');
      throw e;
    }
  }
  static Future<void> statusbooking(String bookingId, String status) async {
    try {
      CollectionReference workCollection = FirebaseFirestore.instance
          .collection('bookings');
      DocumentSnapshot workSnapshot = await workCollection.doc(bookingId).get();
      String workerId = workSnapshot['workerId'];
      int newFinalAmount = 0;
      int totalamount = 0;
      if(workSnapshot['type']=="hours"){
        totalamount = workSnapshot['totalamount'];
        double deduction1 = (15 / 100) * totalamount;
        newFinalAmount = (totalamount - deduction1).round();
      }
      else{
        totalamount = workSnapshot['workeramount'];
        double deduction2 = (7.5 / 100) * totalamount;
        newFinalAmount = (totalamount - deduction2).round();
      }


      await workCollection.doc(bookingId).set({
        'status': status
      }, SetOptions(merge: true));
      CollectionReference profCollection = FirebaseFirestore.instance
          .collection('prof');
      await profCollection
          .doc(workerId)
          .collection('requests')
          .doc(bookingId)
          .update({
        'status': status,

      });

      if(status=="completed"){

        CollectionReference workCollection = FirebaseFirestore.instance.collection(
            'bookings');
        DocumentSnapshot workSnapshot = await workCollection.doc(bookingId).get();
        String  workby = workSnapshot['userId'];
        DocumentReference docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(workby) // Specify the document ID here
            .collection('tracks')
            .doc(bookingId); // Specify the sub-collection and its document ID here

        // Delete the document
        await docRef.delete();
        final CollectionReference collectionReference12 = FirebaseFirestore.instance.collection('users');

// Increment the value of the existing field by one
        collectionReference12.doc(workby).update({
          "totalorder": FieldValue.increment(-1), // Replace 'fieldName' with the name of your existing field
        }).then((value) {
          print("Field value incremented successfully!");
        }).catchError((error) {
          print("Failed to increment field value: $error");
        });
        await profCollection
            .doc(workerId)
            .collection('payment')
            .add({
          'add': true,
          'payable':newFinalAmount,
          'finalamount':totalamount,
          'workID': bookingId,
          'workname': "Booking",
          'type': "booking",
          'time':DateTime.now()

        });
        final CollectionReference collectionReference1 = FirebaseFirestore.instance.collection('prof');

// Increment the value of the existing field by one
        collectionReference1.doc(workerId).update({
          "walletamount": FieldValue.increment(newFinalAmount), // Replace 'fieldName' with the name of your existing field
        }).then((value) {
          print("Field value incremented successfully!");
        }).catchError((error) {
          print("Failed to increment field value: $error");
        });
      }
      CollectionReference usersCollection = FirebaseFirestore.instance
          .collection('users');
      await usersCollection
          .doc(workSnapshot['userId'])
          .collection('booking')
          .doc(bookingId)
          .update({
        'status': status,

      });
      final DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection('users').doc(workSnapshot['userId']).get();
      if (profileSnapshot.exists) {
        String pushToken = profileSnapshot['push_token'];
        APIs.sendPushNotification("Your Booking Update",
            pushToken,
            "The status of your recent booking changed to " + status);
      }
      int nnotibooking = profileSnapshot['nnotibooking'];
      try {
        // Get the current user's UID


        // Reference to the Firestore collection "users"
        CollectionReference usersCollection = FirebaseFirestore.instance
            .collection('users');

        // Reference to the specific user's document
        DocumentReference userDocRef = usersCollection.doc(
            workSnapshot['userId']);
        await userDocRef.update({
          'nnotibooking': nnotibooking + 1
        });

        // Reference to the "notiwork" subcollection
        CollectionReference notiWorkCollection = userDocRef.collection(
            'notibooking');

        // Add a new document to the "notiwork" subcollection
        await notiWorkCollection.add({
          'bookingid': bookingId,
          'workerID': workerId,
          'seen': false,
          'message': status,
          'timestamp': FieldValue.serverTimestamp(),
          // Add a timestamp for sorting purposes
        });

        print('Notification added successfully.');
      } catch (e) {
        print('Error adding notification: $e');
        // Handle errors here
      }


      print("status chaged succesfully");
    }
    catch (e) {
      // Handle any errors that occur during the process
      print('Error updating document: $e');
    }
  }
  static Future<void> acceptfoodorder(String orderid) async{
    try {
      CollectionReference users = FirebaseFirestore.instance.collection(
          'orders');

      // Update data in Firestore
      await users.doc(orderid).update({
        'assigned': APIs.me.id,
        'status': 'track',
      });
      await APIs.getSelfInfo();
    }
    catch (e) {
      print("error");
      print(e);
    }

  }
  static Future<void> deletesuperpoints() async{
    try {
      CollectionReference users = FirebaseFirestore.instance.collection(
          'users');

      // Update data in Firestore
      await users.doc(APIs.me.id).update({
        'points': 0,
      });
      await APIs.getSelfInfo();
    }
    catch (e) {
      print("error");
      print(e);
    }

  }
  static Future<void> addMessageNotification(String userID, String ChatID,
      String profid) async {
    CollectionReference workCollection = FirebaseFirestore.instance.collection(
        'users');
    DocumentSnapshot workSnapshot = await workCollection.doc(userID).get();
    int nmessage = workSnapshot['nmessage'];
    await workCollection.doc(userID).set({
      'nmessage': nmessage + 1
    }, SetOptions(merge: true));
    QuerySnapshot querySnapshot = await workCollection.doc(userID)
        .collection('chat_user')
        .where('chatId', isEqualTo: ChatID).get();
    print(querySnapshot);
    querySnapshot.docs.forEach((doc) {
      doc.reference.set({
        userID: false,
        "asfdas": "asdfas" // Set the 'status' field to 'accepted'
        // Add more details if needed
      }, SetOptions(
          merge: true)); // merge: true ensures that existing fields are preserved
    });
    QuerySnapshot querySnapshot2 = await workCollection.doc(profid)
        .collection('chat_user')
        .where('chatId', isEqualTo: ChatID).get();
    print(querySnapshot);
    querySnapshot2.docs.forEach((doc) {
      doc.reference.set({
        profid: false,
        "asfdas": "asdfas" // Set the 'status' field to 'accepted'
// Set the 'status' field to 'accepted'
        // Add more details if needed
      },); // merge: true ensures that existing fields are preserved
    });
  }
  static Future<void> makeWorkComplete(String workId) async {
    try {
      final CollectionReference workCollection = FirebaseFirestore.instance
          .collection('work');
      DocumentSnapshot workSnapshot = await workCollection.doc(workId).get();
      String workBy = workSnapshot['workBy'];
      String assigned = workSnapshot['assigned'];
      String workname = workSnapshot['name'];
      double finalamount = workSnapshot['workeramount'];
      double deduction = (7.5 / 100) * finalamount;
      int newFinalAmount = (finalamount - deduction).round();
      print(workBy);
      print(workId);
      print(assigned);
      await workCollection
          .doc(workId)
          .update({
        'status': "completed",
      });
      CollectionReference usersCollection = FirebaseFirestore.instance
          .collection('users');
      final DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection('users').doc(workBy).get();
      if (profileSnapshot.exists) {
        print("hey 1");
        String pushToken = profileSnapshot['push_token'];
        APIs.sendPushNotification("Work Completed!",
            pushToken, "$workname work has been completed successfully");
      }
      int nnotiwork = profileSnapshot['nnotiwork'];

      QuerySnapshot querySnapshot = await usersCollection.doc(workBy)
          .collection('work')
          .where('id',
          isEqualTo: workId) // Use 'isEqualTo' instead of '==' for clarity
          .get();


      querySnapshot.docs.forEach((doc) {
        doc.reference.set({
          'status': 'completed', // Set the 'status' field to 'accepted'
          // Add more details if needed
        }, SetOptions(
            merge: true)); // merge: true ensures that existing fields are preserved
      });
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(workBy) // Specify the document ID here
          .collection('tracks')
          .doc(workId); // Specify the sub-collection and its document ID here

      // Delete the document
      await docRef.delete();
      final CollectionReference collectionReference12 = FirebaseFirestore.instance.collection('users');

// Increment the value of the existing field by one
      collectionReference12.doc(workBy).update({
        "totalorder": FieldValue.increment(-1), // Replace 'fieldName' with the name of your existing field
      }).then((value) {
        print("Field value incremented successfully!");
      }).catchError((error) {
        print("Failed to increment field value: $error");
      });


      /// add code here to make the work completed
      CollectionReference profCollection = FirebaseFirestore.instance
          .collection('prof');
      await profCollection.doc(assigned).collection('uncompleted').doc(workId).delete();
      await profCollection
          .doc(assigned)
          .collection('completed')
          .add({
        'payable':newFinalAmount,
        'finalamount':finalamount,
        'workID': workId
      });
      final CollectionReference collectionReference1 = FirebaseFirestore.instance.collection('prof');

// Increment the value of the existing field by one
      collectionReference1.doc(assigned).update({
        "walletamount": FieldValue.increment(newFinalAmount), // Replace 'fieldName' with the name of your existing field
      }).then((value) {
        print("Field value incremented successfully!");
      }).catchError((error) {
        print("Failed to increment field value: $error");
      });

      await profCollection
          .doc(assigned)
          .collection('payment')
          .add({
        'add': true,

        'payable':newFinalAmount,
        'finalamount':finalamount,
        'workID': finalamount,
        'workname': workname,
        'type': "work",
        'time':DateTime.now()

      });

      try {
        // Get the current user's UID


        // Reference to the Firestore collection "users"
        CollectionReference usersCollection = FirebaseFirestore.instance
            .collection('users');

        // Reference to the specific user's document
        print(workBy);
        DocumentReference userDocRef = usersCollection.doc(workBy);

        await userDocRef.update({
          'nnotiwork': nnotiwork + 1
        });

        // Reference to the "notiwork" subcollection
        CollectionReference notiWorkCollection = userDocRef.collection(
            'notiwork');

        // Add a new document to the "notiwork" subcollection
        await notiWorkCollection.add({
          'workID': workId,
          'workerID': assigned,
          'amount': 0.0,
          'seen': false,
          'name': workname,
          'message': "completed",
          'timestamp': FieldValue.serverTimestamp(),
          // Add a timestamp for sorting purposes
        });

        print('Notification added successfully.');
      } catch (e) {
        print('Error adding notification: $e');
        // Handle errors here
      }
    }
    catch (e) {
      print("error");
      print(e);
    }
  }
  static Future<void> acceptWork(String workID, double amount, String workerID,double workerAmountcut) async {
    try {
      // Reference to the 'work' collection in Firestore
      CollectionReference workCollection = FirebaseFirestore.instance
          .collection('work');

      // Set the document in the 'work' collection
      await workCollection.doc(workID).set({
        'assigned': workerID,
        'finalamount': amount,
        'workeramount': workerAmountcut,
        'status': 'track'
      }, SetOptions(
          merge: true)); // Use merge: true to merge new data with existing data

      // Reference to the 'prof' collection in Firestore
      CollectionReference profCollection = FirebaseFirestore.instance
          .collection('prof');

      // Add the workID to the 'uncompleted' subcollection inside the 'prof' collection
      await profCollection.doc(workerID).collection('uncompleted')
          .doc(workID)
          .set({
        'workID': workID,
        'amount': amount,
        // You can add more details if needed
      });

      // Update the status in the 'workIDs' subcollection inside the 'prof' collection
      QuerySnapshot querySnapshot = await profCollection.doc(workerID)
          .collection('workIDs')
          .where('workID',
          isEqualTo: workID) // Use 'isEqualTo' instead of '==' for clarity
          .get();

      querySnapshot.docs.forEach((doc) {
        doc.reference.set({
          'status': 'accepted', // Set the 'status' field to 'accepted'
          // Add more details if needed
        }, SetOptions(
            merge: true));
        // merge: true ensures that existing fields are preserved
      });
      final CollectionReference workCollection1 = FirebaseFirestore.instance
          .collection('users');
      DocumentSnapshot workSnapshot = await workCollection1.doc(workerID).get();
      String pushToken = workSnapshot['push_token'];
      //send accept notification
      APIs.sendPushNotification("Work Update",pushToken,"Your work application accepted");
      //

      //
      //




      //send rejection notification
      final QuerySnapshot profSnapshot =
      await FirebaseFirestore.instance.collection('work').doc(workID).collection('workers').get();

      List<Map<String, dynamic>> documentsData = [];

      profSnapshot.docs.forEach((DocumentSnapshot document) async {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        String workerId1 = data['workerID'];
        print(workerId1);

        if(workerId1!=workerID){
          print("rejected ids");
          CollectionReference profileCollection = FirebaseFirestore.instance.collection('prof');

          // Update the status in the profile collection
// Reference to the profile collec
          // Query for documents where the "workID" field matches the specified workID
          QuerySnapshot workIDDocs = await profileCollection
              .doc(workerId1)
              .collection('workIDs')
              .where('workID', isEqualTo: workID)
              .get();

          // Update the status in the matching documents
          for (QueryDocumentSnapshot workIDDoc in workIDDocs.docs) {
            await workIDDoc.reference.update({'status': 'rejected'});
          }
          DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(workerId1)
              .get();

          if (userSnapshot.exists) {
            String pushToken = (userSnapshot.data() as Map<String, dynamic>)['push_token'];
            APIs.sendPushNotification("Work Update",pushToken,"Your work application rejected");
            // Now you have the pushToken for this user, proceed with sending the notification
            // For example, you can use a push notification service like Firebase Cloud Messaging (FCM)
            // to send a notification to this pushToken
          }
        }
        //fetch the pushToken form users with doc id equal to worker id
      });

      print('Work accepted and added to Firestore successfully!');

    } catch (e) {
      // Handle any errors that occur during the process
      print('Error updating document: $e');
    }
  }
  static Future<void> makePayment(String workID, String paymentId) async {
    try {
      // Set the document in the Firestore collection
      await FirebaseFirestore.instance.collection('work').doc(workID).set({
        'payment': true,
        'paymentID': paymentId
      }, SetOptions(
          merge: true)); // Use merge: true to merge new data with existing data
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error updating document: $e');
    }
  }
  static Future<void> makefoodPayment(String workID, String paymentId) async {
    try {
      // Set the document in the Firestore collection
      await FirebaseFirestore.instance.collection('orders').doc(workID).set({
        'payment': true,
        'paymentID': paymentId
      }, SetOptions(
          merge: true)); // Use merge: true to merge new data with existing data
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error updating document: $e');
    }
  }
  static Future<void> makeBookingPayment(String bookingID,
      String paymentId) async {
    try {
      // Set the document in the Firestore collection
      await FirebaseFirestore.instance.collection('bookings')
          .doc(bookingID)
          .set({
        'payment': true,
        'paymentID': paymentId
      }, SetOptions(
          merge: true)); // Use merge: true to merge new data with existing data
    } catch (e) {
      // Handle any errors that occur during the process
      print('Error updating document: $e');
    }
  }

  static Future<void> updateMyInfo(String name, String mobile, String image,
      String bookingID) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection(
          'users');

      // Update data in Firestore
      await users.doc(APIs.me.id).update({
        'name': name,
        'mobile': mobile,
        'image': image
      });
      await APIs.getSelfInfo();
    }
    catch (e) {
      print("error");
      print(e);
    }
  }

  static Future<void> UpdateDish(String name, int price, String image,
      String dishId) async {
    try {
      int finalPrice = (price * 1.04).round(); // Calculate the final price with 4% increase
      int remainder = finalPrice % 5; // Calculate the remainder when divided by 5

      if (remainder != 0) {
        // If the remainder is not 0, adjust the price to make it divisible by 5
        finalPrice += 5 - remainder;
      }
      CollectionReference users = FirebaseFirestore.instance.collection(
          'restraunts').doc(APIs.me.restid).collection('dishes');

      // Update data in Firestore
      await users.doc(dishId).update({
        'name': name,
        'restprice': price,
        'price': finalPrice,
        'image': image
      });
      await APIs.getSelfInfo();
    }
    catch (e) {
      print("error");
      print(e);
    }
  }
  static Future<void> UpdateRestaurant(String name, String address, String specs,String image) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection(
          'restraunts');

      // Update data in Firestore
      await users.doc(APIs.me.restid).update({
        'name': name,
        'address': address,
        'specs': specs
      });
      await APIs.getSelfInfo();
    }
    catch (e) {
      print("error");
      print(e);
    }
  }
  static Future<void> addBankDetails(String bankName, String accountNumber, String ifsccode,String benificiary) async {
    CollectionReference users = FirebaseFirestore.instance.collection('userrest');

    // Get the document reference
    DocumentReference userDocRef = users.doc(APIs.me.id);

    // Check if the document exists
    DocumentSnapshot docSnapshot = await userDocRef.get();

    // If the document exists, update it with bank details
    if (docSnapshot.exists) {
      // Update data in Firestore
      await userDocRef.update({
        'bankname': bankName,
        'accountnumber': accountNumber,
        'ifsccode': ifsccode,
        'benificiary': benificiary,
        'bankadded': true, // Set bankAdded to true to indicate that bank details are added
      });
    } else {
      // If the document does not exist, create it with bank details
      await userDocRef.set({
        'bankname': bankName,
        'accountnumber': accountNumber,
        'ifsccode': ifsccode,
        'benificiary': benificiary,
        'bankadded': true, // Set bankAdded to true to indicate that bank details are added
      });
    }
  }

  static Future<void> withdrawamount(int amount) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection(
          'prof');

      // Update data in Firestore
      await users.doc(APIs.me.id).update({
        'walletamount': FieldValue.increment(-amount),
      });
      CollectionReference paymentcollection = FirebaseFirestore.instance
          .collection('prof');
      await paymentcollection
          .doc(APIs.me.id)
          .collection('payment')
          .add({
        'add': false,
        'payable':amount,
        'finalamount':amount,
        'workID': "",
        'workname': "Withdraw",
        'type': "Withdraw",
        'time':DateTime.now()
      });

      await APIs.getSelfInfo();
    }
    catch (e) {
      print("error");
      print(e);
    }
  }
  static Future<void> pickedupitem(String workid) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection(
          'work');

      // Update data in Firestore
      await users.doc(workid).update({
        'picked': true,
      });
    }
    catch (e) {
      print("error");
      print(e);
    }
  }
  static Future<void> pickedupitemfood(String workid) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection(
          'orders');

      // Update data in Firestore
      await users.doc(workid).update({
        'picked': true,
      });
    }
    catch (e) {
      print("error");
      print(e);
    }
  }
  static Future<void> reachedLocation(String workid) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection(
          'work');
      DocumentSnapshot workSnapshot12 = await users.doc(workid).get();

      // Update data in Firestore
      await users.doc(workid).update({
        'reached': true,
      });
      final DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection('users').doc(workSnapshot12['workBy']).get();
      if (profileSnapshot.exists) {
        print("hey 1");
        String pushToken = profileSnapshot['push_token'];
        APIs.sendPushNotification(workSnapshot12['name'],pushToken, "Your worker reached your location");
      }
    }
    catch (e) {
      print("error");
      print(e);
    }
  }
  static Future<void> reachedLocationfood(String workid) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection(
          'orders');
      DocumentSnapshot workSnapshot12 = await users.doc(workid).get();

      // Update data in Firestore
      await users.doc(workid).update({
        'reached': true,
      });
      final DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection('users').doc(workSnapshot12['orderBy']).get();
      if (profileSnapshot.exists) {
        print("hey 1");
        String pushToken = profileSnapshot['push_token'];
        APIs.sendPushNotification(workSnapshot12['name'],pushToken, "Your worker reached your location");
      }
    }
    catch (e) {
      print("error");
      print(e);
    }
  }
  static Future<void> updatelatlongprof(double lat, double long) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection(
          'users');

      // Update data in Firestore
      await users.doc(APIs.me.id).update({
        'latitude': lat,
        'longitude': long,
      });
      CollectionReference prof = FirebaseFirestore.instance.collection(
          'prof');

      // Update data in Firestore
      await prof.doc(APIs.me.id).update({
        'latitude': lat,
        'longitude': long,
      });
      await APIs.getSelfInfo();
    }
    catch (e) {
      print("error");
      print(e);
    }
  }
  static Future<void> updateMyInfomain(String name, String mobile,
      String image) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection(
          'users');

      // Update data in Firestore
      await users.doc(APIs.me.id).update({
        'name': name,
        'mobile': mobile,
        'image': image
      });
      if(APIs.me.type=='delivery'||APIs.me.type=='others'){
        CollectionReference prof = FirebaseFirestore.instance.collection(
            'users');

        // Update data in Firestore
        await prof.doc(APIs.me.id).update({
          'name': name,
          'phone_number': mobile,
          'profile_image_url': image
        });
      }
      await APIs.getSelfInfo();
    }
    catch (e) {
      print("error");
      print(e);
    }
  }
  static Future<void> AddAmounttoBooking(String bookingId,int amount) async {
    CollectionReference profCollection = FirebaseFirestore.instance
        .collection('bookings');
    double percentage = 7.5; // 7.5%
    double increasedAmount = amount * (1 + percentage / 100);
    String roundedAmountString = increasedAmount.toStringAsFixed(2); // Convert to string with 2 decimal places
    if (!roundedAmountString.contains('.')) {
      // If there is no decimal point, add .00 at the end
      roundedAmountString += '.00';
    }
    double roundedAmount = double.parse(roundedAmountString);

// Convert roundedAmount to integer by multiplying by 100
    int finalAmount = (roundedAmount).toInt();
    await profCollection
        .doc(bookingId)
        .update({
      'workeramount': amount,
      'totalamount': finalAmount
    });
  }

  static Future<void> AddTiptoWork(String workId,int grandtotal,int tip) async {
    CollectionReference profCollection = FirebaseFirestore.instance
        .collection('work');

    await profCollection
        .doc(workId)
        .update({
      'grandtotal': grandtotal,
      'tip': tip,

    });

    DocumentSnapshot workSnapshot = await profCollection.doc(workId).get();
    String assigned = workSnapshot['assigned'];
    if(tip!=0){
      CollectionReference paymentcollection = FirebaseFirestore.instance
          .collection('prof');
      await paymentcollection
          .doc(assigned)
          .collection('payment')
          .add({
        'add': true,
        'payable':tip,
        'finalamount':tip,
        'workID': workId,
        'workname': "Tip Work",
        'type': "tipwork",
        'time':DateTime.now()

      });
      final CollectionReference collectionReference1 = FirebaseFirestore.instance.collection('prof');

// Increment the value of the existing field by one
      collectionReference1.doc(assigned).update({
        "walletamount": FieldValue.increment(tip), // Replace 'fieldName' with the name of your existing field
      }).then((value) {
        print("Field value incremented successfully!");
      }).catchError((error) {
        print("Failed to increment field value: $error");
      });
    }

  }
  static Future<void> AddTiptoFood(String workId,int grandtotal,int tip) async {
    CollectionReference profCollection = FirebaseFirestore.instance
        .collection('orders');

    await profCollection
        .doc(workId)
        .update({
      'orderamount': grandtotal,
      'tip': tip,

    });

  }
  static Future<void> ItemPickedUp(String workid) async {
    CollectionReference profCollection = FirebaseFirestore.instance
        .collection('work');

    await profCollection
        .doc(workid)
        .update({
      'picked': true,

    });
  }
  static Future<void> ReachedLocation(String workid) async {
    CollectionReference profCollection = FirebaseFirestore.instance
        .collection('work');

    await profCollection
        .doc(workid)
        .update({
      'reached': true,

    });
  }
  static Future<void> AddTiptoBooking(String bookingId,int grandtotal,int tip) async {
    CollectionReference profCollection = FirebaseFirestore.instance
        .collection('bookings');

    await profCollection
        .doc(bookingId)
        .update({
      'grandtotal': grandtotal,
      'tip': tip,

    });

    DocumentSnapshot workSnapshot = await profCollection.doc(bookingId).get();
    String assigned = workSnapshot['workerId'];
    if(tip!=0){
      CollectionReference paymentcollection = FirebaseFirestore.instance
          .collection('prof');
      await paymentcollection
          .doc(assigned)
          .collection('payment')
          .add({
        'add': true,
        'payable':tip,
        'finalamount':tip,
        'workID': bookingId,
        'workname': "Tip Booking",
        'type': "tipbooking",
        'time':DateTime.now()

      });
      final CollectionReference collectionReference1 = FirebaseFirestore.instance.collection('prof');

// Increment the value of the existing field by one
      collectionReference1.doc(assigned).update({
        "walletamount": FieldValue.increment(tip), // Replace 'fieldName' with the name of your existing field
      }).then((value) {
        print("Field value incremented successfully!");
      }).catchError((error) {
        print("Failed to increment field value: $error");
      });
    }
  }
  static Future<void> BuySuper(int months) async {
    CollectionReference profCollection = FirebaseFirestore.instance.collection('users');

    // Calculate start and end date
    DateTime startDate = DateTime.now();
    DateTime endDate = startDate.add(Duration(days: months * 30)); // Assuming each month has 30 days

    await profCollection.doc(APIs.me.id).update({
      'months': months,
      'havepremium': true,
      'superStartDate': Timestamp.fromDate(startDate),
      'superEndDate': Timestamp.fromDate(endDate),
    });
  }
  static Future<void> MakeAllSeen(String collectI) async {
    try {
      final CollectionReference workCollection = FirebaseFirestore.instance
          .collection('chat');
      DocumentSnapshot workSnapshot = await workCollection.doc(collectI).get();
      int workBy = workSnapshot[APIs.me.id];
      final CollectionReference collectionReference1 = FirebaseFirestore.instance.collection('users');

// Increment the value of the existing field by one
      collectionReference1.doc(APIs.me.id).update({
        "nmessage": FieldValue.increment(-workBy), // Replace 'fieldName' with the name of your existing field
      }).then((value) {
        print("Field value incremented successfully!");
      }).catchError((error) {
        print("Failed to increment field value: $error");
      });

      final CollectionReference collectionReference = FirebaseFirestore.instance.collection('chat');
      final String docId  = collectI;

// Increment the value of the existing field by one
      collectionReference.doc(docId).update({
        APIs.me.id: 0, // Replace 'fieldName' with the name of your existing field
      }).then((value) {
        print("Field value incremented successfully!");
      }).catchError((error) {
        print("Failed to increment field value: $error");
      });


    }
    catch (e) {
      print("error");
      print(e);
    }
  }
}








