import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perpennypartner/screens/SuccessScreen.dart';
import 'package:perpennypartner/screens/home/HomeScreen.dart';
import 'package:shimmer/shimmer.dart';

import '../api/apis.dart';
import '../models/dishes.dart';
import '../models/prof.dart';
import '../models/restraunts.dart';

class Adddishes extends StatefulWidget {
  final String restId;
  const Adddishes({Key? key, required this.restId}) : super(key: key);

  @override
  State<Adddishes> createState() => _PlatformFormScreenState();
}

class _PlatformFormScreenState extends State<Adddishes> {
  final _formKey = GlobalKey<FormState>();

  String? name;
  String _image = "https://cdn.dribbble.com/userupload/2842276/file/original-dc3f20958e704153bc3409b16d8dd3f0.jpeg?resize=2048x1536"; // Default image URL
  int review = 0;
  int price = 0;

  List<String> _specialities = []; // Ensure it's initialized as an empty list
  bool _isLoading = false;
  List<Map<String, String>> fileData = [];

  TextEditingController _specialityController = TextEditingController();
  bool _loading = false;
  List<File> selectedFiles = [];

  bool isLoading = false;
  bool filesUploadedSuccessfully = false;
  bool isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Add Items'),
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
                                imageUrl: _image, // URL of the image
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
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: IconButton(
                                    onPressed: () {
                                      _pickFiles();
                                    },
                                    icon: Icon(Icons.image, color: Colors.white),
                                  ),
                                )),
                          ],
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Name'),
                        maxLines: 1,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter the name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          name = value;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Price'),
                        maxLines: 1,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Please enter the price';
                          }
                          // Check if the entered value can be parsed into an integer
                          if (int.tryParse(value!) == null || int.parse(value) <= 0) {
                            return 'Please enter a valid positive integer for the price';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          // Parse the string value to an integer and assign it to price
                          price = int.parse(value!);
                        },
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            _formKey.currentState?.save();
                            // Process form data here, for example, send it to backend or display it in a dialog
                            setState(() {
                              _loading = true;
                            });
                            int finalPrice = (price * 1.04).round(); // Calculate the final price with 4% increase
                            int remainder = finalPrice % 5; // Calculate the remainder when divided by 5

                            if (remainder != 0) {
                              // If the remainder is not 0, adjust the price to make it divisible by 5
                              finalPrice += 5 - remainder;
                            }

                            Dishesss myprof = Dishesss(
                              id: '',
                              name: name.toString(),
                              price: finalPrice,
                              restprice: price,
                              review: 5,
                              image: _image,
                              available: true,
                            );

                            setState(() {
                              _loading = false;
                            });
                            String? result = await APIs.addDish(myprof, widget.restId);
                            if(result!=null){
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => SuccessScreen()),
                              );
                            }
                            else{
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('An Unexpected Error!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }



                          }
                        },
                        child: _loading
                            ? CircularProgressIndicator() // Show loading indicator if _loading is true
                            : Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading || isUploading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(child: Lottie.asset("assets/lottie/loading.json")),
              ),
          ],
        ));
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
      Reference storageReference = FirebaseStorage.instance.ref().child('restrantsimage').child(widget.restId).child(fileName);
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
