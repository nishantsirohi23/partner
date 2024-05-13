import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:perpennypartner/screens/home/HomeScreen.dart';

import '../api/apis.dart';
import '../models/dishes.dart';

class UpdateDish extends StatefulWidget {
  final String dishId;

  const UpdateDish({Key? key, required this.dishId}) : super(key: key);

  @override
  State<UpdateDish> createState() => _PlatformFormScreenState();
}

class _PlatformFormScreenState extends State<UpdateDish> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
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
        .collection('restraunts')
        .doc(APIs.me.restid)
        .collection('dishes');
    DocumentSnapshot dishSnapshot = await dishCollection.doc(widget.dishId).get();

    setState(() {
      _nameController.text = dishSnapshot['name'];
      _priceController.text = dishSnapshot['restprice'].toString();
      _image = dishSnapshot['image'];
      _isLoading = false;
    });
  }

  void updateDish() async {
    String newName = _nameController.text.trim();
    int newPrice = int.parse(_priceController.text.trim());

    if (newName.isNotEmpty && newPrice != 0) {
      try {
        await APIs.UpdateDish(newName, newPrice, _image, widget.dishId);
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Item'),
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
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  controller: _nameController,
                  maxLines: 1,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter dish name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Price'),
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a price';
                    }
                    // Check if the entered value can be parsed into an integer
                    if (int.tryParse(value!) == null) {
                      return 'Please enter a valid integer for the price';
                    }
                    return null;
                  },
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
          .child(widget.dishId)
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
