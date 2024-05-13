import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter_platform_interface/src/types/marker.dart' as GoogleMarker;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perpennypartner/Widget_tree.dart';
import 'package:shimmer/shimmer.dart';


import '../api/apis.dart';
import '../models/prof.dart';
import '../models/restraunts.dart';
import '../utils/LocationService.dart';
import 'adddish.dart';
import 'home/HomeScreen.dart';

class RestScreen extends StatefulWidget {
  const RestScreen({Key? key}) : super(key: key);

  @override
  State<RestScreen> createState() => _PlatformFormScreenState();
}

class _PlatformFormScreenState extends State<RestScreen> {
  final _formKey = GlobalKey<FormState>();

  String? name;
  String? address;
  String? image;
  String? specs;
  double? latitude;
  double? longitude;

  List<Map<String, String>> fileData = [];
  String _image = "";

  List<File> selectedFiles = [];

  bool isLoading = true;
  bool filesUploadedSuccessfully = false;
  bool isUploading = false;
  double _latitude = 0.0;
  double _longitude = 0.0;
  PickResult? selectedFromPlace;
  PickResult? selectedToPlace;
  String _receivedText ="";
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specialtiesController = TextEditingController();
  String _receivedfrom = "Select Store Location";

  double _fromlatitude = 0.0;
  double _fromlongitude = 0.0;
  GoogleMapController? _controller;
  final Completer<GoogleMapController> _controller1 = Completer();



  Future<void> _getCurrentLocation() async {
    Map<String, double> locationData = await _locationService.getCurrentLocation();
    setState(() {
      _controller1.future.then((value) {
        value.animateCamera(CameraUpdate.newLatLng(LatLng(_latitude, _longitude)));
      });
      isLoading = false;
      _latitude = locationData['latitude']!;
      _longitude = locationData['longitude']!;
    });
    print(_latitude);
    print(_longitude);

  }
  late LocationService _locationService;
  @override
  void initState() {
    super.initState();
    _locationService = LocationService();

    _getCurrentLocation();

  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: Text('Registration'),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(50)),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                imageUrl: _image==""?"https://cdn.dribbble.com/users/5258123/screenshots/20503791/media/ea983a2ca155f71b52d8fe2beb1bbdb4.png?resize=1600x1200&vertical=center":_image, // URL of the image
                                width: 100, // Double the radius to fit the CircleAvatar
                                height: 100, // Double the radius to fit the CircleAvatar
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    width: 100, // Double the radius to fit the CircleAvatar
                                    height: 100, // Double the radius to fit the CircleAvatar
                                    color: Colors.white,
                                  ),
                                ),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                            ),
                            Positioned(
                                right: 0,
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      color: Colors.pink.withOpacity(0.8),
                                      borderRadius: BorderRadius.all(Radius.circular(20))
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      _pickFiles();
                                    },
                                    icon: Icon(Icons.image, color: Colors.white),
                                  ),
                                )
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.0),

                      Container(
                        height: 60,
                        width: screenWidth * 0.94,
                        padding: EdgeInsets.only(left: 20, right: 10),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade200.withOpacity(0.3),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Center(
                          child: TextFormField(
                            controller: _nameController, // Assign controller

                            decoration: InputDecoration(labelText: 'Name',border: InputBorder.none,
                              labelStyle: TextStyle(
                                color: Colors.black54, // Change the color here
                              ),),
                            maxLines: 1,

                          ),
                        ),
                      ),


                      SizedBox(height: 16.0),
                      Container(
                        height: 60,
                        width: screenWidth * 0.94,
                        padding: EdgeInsets.only(left: 20, right: 10),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade200.withOpacity(0.3),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Center(
                          child: TextFormField(
                            controller: _specialtiesController, // Assign controller
                            decoration: InputDecoration(
                              labelText:
                              'Specialities',
                              border: InputBorder.none,
                              labelStyle: TextStyle(
                                color: Colors.black54, // Change the color here
                              ),
                            ),


                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      GestureDetector(
                        onTap: (){
                          LatLng? selectedLatLng;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return PlacePicker(
                                  resizeToAvoidBottomInset: false, // only works in page mode, less flickery
                                  apiKey: Platform.isAndroid
                                      ? 'AIzaSyCP-0eFkR6XjXB-X9NzMh0ZbrHZ1fQgdds'
                                      : 'AIzaSyCP-0eFkR6XjXB-X9NzMh0ZbrHZ1fQgdds',
                                  hintText: "Find a place ...",
                                  searchingText: "Please wait ...",
                                  selectText: "Select place",
                                  outsideOfPickAreaText: "Place not in area",
                                  initialPosition: LatLng(_latitude,_longitude),
                                  useCurrentLocation: true,
                                  selectInitialPosition: true,
                                  usePinPointingSearch: true,
                                  usePlaceDetailSearch: true,
                                  zoomGesturesEnabled: true,
                                  zoomControlsEnabled: true,
                                  ignoreLocationPermissionErrors: true,
                                  onMapCreated: (GoogleMapController controller) {
                                    print("Map created");
                                  },
                                  onPlacePicked: (PickResult result) {
                                    print("Place picked: ${result.formattedAddress}");
                                    setState(() {
                                      selectedFromPlace = result;
                                      selectedLatLng = result.geometry?.location != null
                                          ? LatLng(
                                        result.geometry!.location!.lat,
                                        result.geometry!.location!.lng,
                                      )
                                          : null;
                                      setState(() {
                                        _fromlatitude =  double.parse(selectedLatLng!.latitude.toStringAsFixed(6));
                                        _fromlongitude =  double.parse(selectedLatLng!.longitude.toStringAsFixed(6));
                                        _receivedfrom = selectedFromPlace!.formattedAddress.toString();
                                        _receivedText = _receivedfrom;

                                      });

                                      print(_fromlatitude.toString());
                                      print(_fromlongitude.toString());



                                      Navigator.of(context).pop();
                                    });
                                  },
                                  onMapTypeChanged: (MapType mapType) {
                                    print("Map type changed to ${mapType.toString()}");
                                  },
                                );
                              },
                            ),

                          );
                        },
                        child: Container(
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20)),
                                child: Container(
                                  height: screenHeight * 0.15,
                                  width: screenWidth * 0.9,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: GestureDetector(
                                    onTap: () async {
                                      LatLng? selectedLatLng;
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return PlacePicker(
                                              resizeToAvoidBottomInset: false, // only works in page mode, less flickery
                                              apiKey: Platform.isAndroid
                                                  ? 'AIzaSyCP-0eFkR6XjXB-X9NzMh0ZbrHZ1fQgdds'
                                                  : 'AIzaSyCP-0eFkR6XjXB-X9NzMh0ZbrHZ1fQgdds',
                                              hintText: "Find a place ...",
                                              searchingText: "Please wait ...",
                                              selectText: "Select place",
                                              outsideOfPickAreaText: "Place not in area",
                                              initialPosition: LatLng(_latitude,_longitude),
                                              useCurrentLocation: true,
                                              selectInitialPosition: true,
                                              usePinPointingSearch: true,
                                              usePlaceDetailSearch: true,
                                              zoomGesturesEnabled: true,
                                              zoomControlsEnabled: true,
                                              ignoreLocationPermissionErrors: true,
                                              onMapCreated: (GoogleMapController controller) {
                                                print("Map created");
                                              },
                                              onPlacePicked: (PickResult result) {
                                                print("Place picked: ${result.formattedAddress}");
                                                setState(() {
                                                  selectedFromPlace = result;
                                                  selectedLatLng = result.geometry?.location != null
                                                      ? LatLng(
                                                    result.geometry!.location!.lat,
                                                    result.geometry!.location!.lng,
                                                  )
                                                      : null;
                                                  setState(() {
                                                    _fromlatitude =  double.parse(selectedLatLng!.latitude.toStringAsFixed(6));
                                                    _fromlongitude =  double.parse(selectedLatLng!.longitude.toStringAsFixed(6));
                                                    _receivedfrom = selectedFromPlace!.formattedAddress.toString();
                                                    _receivedText = _receivedfrom;

                                                  });

                                                  print(_fromlatitude.toString());
                                                  print(_fromlongitude.toString());



                                                  Navigator.of(context).pop();
                                                });
                                              },
                                              onMapTypeChanged: (MapType mapType) {
                                                print("Map type changed to ${mapType.toString()}");
                                              },
                                            );
                                          },
                                        ),

                                      );

                                    },
                                    child: AbsorbPointer(
                                      absorbing: true, // Set to true to prevent interaction with the child widget
                                      child: GoogleMap(
                                        myLocationButtonEnabled: false,
                                        compassEnabled: false, // Hide the zoom buttons

                                        initialCameraPosition: CameraPosition(
                                          target: LatLng(_latitude, _longitude),
                                          zoom: 17,
                                        ),onMapCreated: (GoogleMapController controller) {
                                        _controller1.complete(controller);
                                      },
                                        markers: Set<GoogleMarker.Marker>.of([
                                          GoogleMarker.Marker(
                                            markerId: MarkerId('marker_1'),
                                            position: LatLng(_fromlatitude, _fromlongitude),
                                            infoWindow: InfoWindow(
                                              title: 'Marker Title',
                                              snippet: 'Marker Snippet',
                                            ),
                                          ),
                                        ]),

                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: screenWidth*0.94,
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(width: 1.0, color: Colors.grey.shade300),
                                    right: BorderSide(width: 1.0, color: Colors.grey.shade300),
                                    bottom: BorderSide(width: 1.0, color: Colors.grey.shade300),
                                  ),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12),bottomRight: Radius.circular(12)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Image.asset("assets/house.png",height: 30,width: 30,),
                                    Container(
                                      padding: EdgeInsets.only(left: 5,right: 5,top: 10,bottom: 10),
                                      width: MediaQuery.of(context).size.width*0.7,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(width: 7,),
                                          Text("Store Address",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                            ),),
                                          SizedBox(height: 4,),
                                          Text(_receivedfrom,
                                            maxLines: 2,
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 14,
                                            ),),
                                          SizedBox(height: 4,),


                                          SizedBox(width: 7,),

                                        ],
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios,color: Colors.black,size: 18,)
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),




                      SizedBox(height: 16.0),

                      Container(
                        height: 50,
                        width: screenWidth,
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: InkWell(
                          onTap: () async {
                            if(_image==""){
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please upload image of the restaurant'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                            else if(_nameController.text.isEmpty){
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please enter the name of your store'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                            else if(_specialtiesController.text.isEmpty){
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please enter the specialities of your store'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                            else if(_receivedText==""){
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please pick store location'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                            else{
                              setState(() {
                                isLoading = true;
                              });


                              Rests myprof = Rests(
                                  id: '',
                                  dishes: [],
                                  address: _receivedText,
                                  name: _nameController.text.toString(),
                                  time: '20-25',
                                  distance: '5',
                                  specs: _specialtiesController.text.toString(),
                                  latitude: _fromlatitude,
                                  longitude: _fromlongitude,
                                  rating: '4.8',
                                  image: _image,
                                  isopen: true

                              );



                              setState(() {
                                isLoading = false;
                              });
                              String? result = await APIs.addRest(myprof);
                              APIs.getSelfInfo();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => WidgetTree(name: '')),
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result ?? 'Unknown error occurred'),
                                  duration: Duration(seconds: 2),
                                ),
                              );

                            }
                          },
                          child: Center(
                            child: Text(
                              "Complete Onboarding",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),if (isLoading|| isUploading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                    child: Lottie.asset("assets/lottie/loading.json")
                ),
              ),
          ],
        )
    );
  }
  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        selectedFiles = result.paths.map((path) => File(path!)).toList();
      });
      setState(() {
        isUploading = true;
      });
      List<Map<String, String>> uploadedFiles = await _uploadFiles(selectedFiles);
      if (uploadedFiles.isNotEmpty) {
        setState(() {
          filesUploadedSuccessfully = true;
          isUploading = false;
        });
      }
    }
  }

  Future<List<Map<String, String>>> _uploadFiles(List<File> files) async {

    for (File file in files) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child('restrantsimage').child(fileName);
      UploadTask uploadTask = storageReference.putFile(file);
      await uploadTask.whenComplete(() async {
        String url = await storageReference.getDownloadURL();
        _image = url;

        // Extract file extension
        String fileType = file.path.split('.').last;

        // Store file URL and type as a pair
        fileData.add({'url': url, 'type': fileType});
      });
    }

    return fileData;
  }
}
