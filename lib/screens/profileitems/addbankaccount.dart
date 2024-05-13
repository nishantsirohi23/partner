import 'dart:convert';
import 'dart:core';
import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../api/apis.dart';

class BankDetails {
  final String branch;
  final String centre;
  final String district;
  final String state;
  final String address;
  final String contact;
  final bool imps;
  final String city;
  final bool upi;
  final String micr;
  final bool rtgs;
  final bool neft;
  final String swift;
  final String iso3166;
  final String bank;
  final String bankCode;
  final String ifsc;

  BankDetails({
    required this.branch,
    required this.centre,
    required this.district,
    required this.state,
    required this.address,
    required this.contact,
    required this.imps,
    required this.city,
    required this.upi,
    required this.micr,
    required this.rtgs,
    required this.neft,
    required this.swift,
    required this.iso3166,
    required this.bank,
    required this.bankCode,
    required this.ifsc,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      branch: json['BRANCH'] ?? '',
      centre: json['CENTRE'] ?? '',
      district: json['DISTRICT'] ?? '',
      state: json['STATE'] ?? '',
      address: json['ADDRESS'] ?? '',
      contact: json['CONTACT'] ?? '',
      imps: json['IMPS'] ?? false,
      city: json['CITY'] ?? '',
      upi: json['UPI'] ?? false,
      micr: json['MICR'] ?? '',
      rtgs: json['RTGS'] ?? false,
      neft: json['NEFT'] ?? false,
      swift: json['SWIFT'] ?? '',
      iso3166: json['ISO3166'] ?? '',
      bank: json['BANK'] ?? '',
      bankCode: json['BANKCODE'] ?? '',
      ifsc: json['IFSC'] ?? '',
    );
  }
}

Future<BankDetails?> fetchBankDetails(String ifscCode) async {
  final response = await http.get(Uri.parse('https://ifsc.razorpay.com/$ifscCode'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = jsonDecode(response.body);
    return BankDetails.fromJson(data);
  } else {
    return null;
  }
}

class BankDetailsPage extends StatefulWidget {
  @override
  _BankDetailsPageState createState() => _BankDetailsPageState();
}

class _BankDetailsPageState extends State<BankDetailsPage> {
  bool showAddButton = false;
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _beneficiaryNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _confirmAccountNumberController = TextEditingController();
  BankDetails? _bankDetails;
  bool islaoding = false;
  bool bankAdded = false;
  String bankname = "";
  String ifsc = "";
  String beneficiary = "";
  String accountnumber = "";



  void getData() {
    FirebaseFirestore.instance.collection('userrest').doc(APIs.me.id).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {
        bankAdded = snapshot['bankadded'] ?? false;
        bankname = snapshot['bankname'] ?? '';
        ifsc = snapshot['ifsccode'] ?? '';
        beneficiary = snapshot['benificiary'] ?? '';
        accountnumber = snapshot['accountnumber'] ?? '';


      });
    });
    print(bankname);
  }
  @override
  void initState() {
    super.initState();
    getData();
  }
  void postbankdetails(){
    if (_accountNumberController.text == _confirmAccountNumberController.text) {
      print('Same');
      APIs.addBankDetails(_bankDetails!.bank,
          _accountNumberController.text,
          _ifscController.text,
          _beneficiaryNameController.text
      );
      setState(() {
        islaoding = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bank Account Added'),
          duration: Duration(seconds: 4),
        ),
      );

    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account numbers do not match'),
          duration: Duration(seconds: 2),
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
        title: Text('Bank Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 60,
              width: screenWidth * 0.9,
              padding: EdgeInsets.only(left: 20, right: 10),
              decoration: BoxDecoration(
                color: Colors.pink.shade200.withOpacity(0.3),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Center(
                child: TextField(
                  controller: _beneficiaryNameController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: bankAdded?beneficiary:'Enter Beneficiary Name',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Container(
              height: 60,
              width: screenWidth * 0.9,
              padding: EdgeInsets.only(left: 20, right: 10),
              decoration: BoxDecoration(
                color: Colors.pink.shade200.withOpacity(0.3),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Center(
                child: TextField(
                  controller: _accountNumberController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: bankAdded?accountnumber:'Enter Account Number',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Container(
              height: 60,
              width: screenWidth * 0.9,
              padding: EdgeInsets.only(left: 20, right: 10),
              decoration: BoxDecoration(
                color: Colors.pink.shade200.withOpacity(0.3),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Center(
                child: TextField(
                  controller: _confirmAccountNumberController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: bankAdded?accountnumber:'Confirm Account Number',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Container(
              height: 60,
              width: screenWidth * 0.9,
              padding: EdgeInsets.only(left: 20, right: 10),
              decoration: BoxDecoration(
                color: Colors.pink.shade200.withOpacity(0.3),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Center(
                child: TextField(
                  controller: _ifscController,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: bankAdded?ifsc:'Enter IFSC Code',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            GestureDetector(
              onTap: (){
                _fetchBankDetails();
              },
              child:  Container(
                height: 50,
                width: screenWidth,
                decoration: BoxDecoration(
                  color: Colors.pink,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    "Fetch Bank Details",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.0),
            if (_bankDetails != null) ...[
              Text('Bank Name: ${_bankDetails!.bank}'),
              Text('Branch: ${_bankDetails!.branch}'),
              Text('Address: ${_bankDetails!.address}'),
            ],
            SizedBox(height: 7,),
            Visibility(
              visible: showAddButton,
              child: Container(
                height: 50,
                width: screenWidth,
                decoration: BoxDecoration(
                  color: Colors.pink,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      islaoding = true;
                    });
                    postbankdetails();
                  },
                  child: Center(
                    child: Text(
                      "Add Bank Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _fetchBankDetails() async {
    String ifscCode = _ifscController.text;
    BankDetails? details = await fetchBankDetails(ifscCode);
    if (details != null) {
      setState(() {
        showAddButton = true;
        _bankDetails = details;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('IFSC code is not correct or an error occurred.'),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {
        showAddButton = false;
        _bankDetails = null;
      });
    }
  }

}