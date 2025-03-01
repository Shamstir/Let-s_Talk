import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lets_talk/home.dart';
import 'package:lets_talk/login%20page.dart';
import 'package:lets_talk/sign%20up.dart';

class splash extends StatefulWidget {
  const splash({super.key});




  @override
  State<splash> createState() => _splashState();
}

class _splashState extends State<splash> {

  void initState(){
    super.initState();
    Timer(Duration(seconds: 1),(){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData) {
            return Homepage();
          }

          return Signup();
        },
      ),));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Image.asset('images/img.png',height: MediaQuery.of(context).size.height*1,width: MediaQuery.of(context).size.width*1,
        fit: BoxFit.fill,),

      ),
    );
  }
}
