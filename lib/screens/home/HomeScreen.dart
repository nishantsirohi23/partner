import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:perpennypartner/screens/adddish.dart';

import '../../api/apis.dart';
import '../items/MainScreen.dart';
import '../items/Orders.dart';
import '../items/Profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _showDot = false; // Control whether to show the dot

  static List<Widget> _widgetOptions = <Widget>[
    MainScreen(),
    Orders(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void getdate() {
    FirebaseFirestore.instance.collection('userrest').doc(APIs.me.id).snapshots().listen((DocumentSnapshot snapshot) {
      setState(() {
        int neworder = snapshot['neworder'] ?? 0;
        if(neworder!=0){
          setState(() {
            _showDot = true;
          });
        }
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
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.menu),
                if (_showDot)
                  Positioned(
                    top: 2,
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Adddishes(restId: APIs.me.restid)),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.white,
        shape: CircleBorder(),
      ),
    );
  }
}
