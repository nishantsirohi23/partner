import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:perpennypartner/screens/home/HomeScreen.dart';
import 'package:google_maps_flutter_platform_interface/src/types/marker.dart' as GoogleMarker;

import '../../api/apis.dart';


class UpdateRestaurant extends StatefulWidget {

  const UpdateRestaurant({Key? key}) : super(key: key);

  @override
  State<UpdateRestaurant> createState() => _PlatformFormScreenState();
}

class _PlatformFormScreenState extends State<UpdateRestaurant> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _specsController = TextEditingController();
  final Completer<GoogleMapController> _controller1 = Completer();

  String _image = "";

  bool _isLoading = false;
  List<Map<String, Object>> fileData = [];

  @override
  void initState() {
    super.initState();
    getDishData();
  }

  void getDishData() async {
    final CollectionReference dishCollection = FirebaseFirestore.instance
        .collection('restraunts');
    DocumentSnapshot dishSnapshot = await dishCollection.doc(APIs.me.restid).get();

    setState(() {
      _nameController.text = dishSnapshot['name'];
      _addressController.text = dishSnapshot['address'];
      _specsController.text = dishSnapshot['specs'];

      _image = dishSnapshot['image'];
      _isLoading = false;
    });
  }

  void updateDish() async {
    String newName = _nameController.text.trim();
    String newaddress = _addressController.text.trim();
    String newspecs = _specsController.text.trim();


    if (newName.isNotEmpty && newaddress.isNotEmpty && newspecs.isNotEmpty) {
      try {
        await APIs.UpdateRestaurant(newName, newaddress, newspecs, _image);

        // If the update is successful, navigate to the new screen
        Navigator.pop(context);
      } catch (e) {
        // If there's an error, show a snackbar with the error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating dish: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Show error if name or price is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Name and Price are required'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Restaurant'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        backgroundImage: _image.isNotEmpty
                            ? NetworkImage(_image)
                            : null,
                        child: _image.isEmpty
                            ? CircularProgressIndicator()
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: Colors.pink.withOpacity(0.8),
                            borderRadius:
                            BorderRadius.all(Radius.circular(20)),
                          ),
                          child: IconButton(
                            onPressed: () {
                              _pickFiles();
                            },
                            icon: Icon(Icons.image, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.0),

                Container(
                  height: 60,
                  width: screenWidth * 0.9,
                  padding: EdgeInsets.only(left: 20, right: 10),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade200.withOpacity(0.3),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Center(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Restaurnat Name',border: InputBorder.none,),
                      controller: _nameController,
                      maxLines: 1,

                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter restaurant name';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                Container(
                  height: 60,
                  width: screenWidth * 0.9,
                  padding: EdgeInsets.only(left: 20, right: 10),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade200.withOpacity(0.3),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Center(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Restaurnat Speciality',border: InputBorder.none),
                      controller: _specsController,
                      maxLines: 1,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter Specialities';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(height: 16.0),

                Container(
                  height: 60,
                  width: screenWidth * 0.9,
                  padding: EdgeInsets.only(left: 20, right: 10),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade200.withOpacity(0.3),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Center(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Address',border: InputBorder.none),
                      controller: _addressController,
                      maxLines: 1,
                    ),
                  ),
                ),

                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      _formKey.currentState?.save();
                      // Process form data here, for example, send it to backend or display it in a dialog
                      updateDish();
                    }
                  },
                  child: Text('Update'),
                ),
              ],
            ),
          ),
        ),
      ),
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
        fileData = result.paths
            .map((path) => {'path': path!, 'uploaded': false})
            .toList();
      });
      setState(() {
        _isLoading = true;
      });
      await _uploadFiles();
    }
  }

  Future<void> _uploadFiles() async {
    for (Map<String, Object> file in fileData) {
      File pickedFile = File(file['path']! as String);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('restrantsimage')
          .child(APIs.me.restid)
          .child(fileName);
      UploadTask uploadTask = storageReference.putFile(pickedFile);
      await uploadTask.whenComplete(() async {
        String url = await storageReference.getDownloadURL();

        setState(() {
          _image = url;
          _isLoading = false;
        });
      });
    }
  }
}
