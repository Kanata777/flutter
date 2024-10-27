import 'package:flutter/material.dart';
import 'dart:async';
import 'package:agro/screens/login.dart';
import 'package:agro/screens/dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 5));

   
    SharedPreferences prefs = await SharedPreferences.getInstance();


    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Dashboard(products: [], storeName: '',), 
        ),
      );
    } else {

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Login(), 
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue,
        child: Center(
          child: Image.asset(
            'assets/images/newrls.png',
            width: 200,
            height: 2000,
          ),
        ),
      ),
    ); 
  }
}
