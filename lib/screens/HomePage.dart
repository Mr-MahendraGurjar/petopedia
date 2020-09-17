import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  FirebaseAuth _auth = FirebaseAuth.instance;
  //FirebaseUser _firebaseUser = await _auth.currentUser();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.white,
          child: Center(child: Text("Home Page",style: TextStyle(color: Colors.black),)),

        ),
      ),
    );
  }
}
