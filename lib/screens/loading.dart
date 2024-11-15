import 'package:agro/consts/gambar.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agro/screens/login.dart';
import 'package:agro/screens/dashboard.dart';

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

    // Mengambil instance FirebaseAuth
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Jika user sudah login, arahkan ke halaman Dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => Dashboard(products: []),
        ),
      );
    } else {
      // Jika user belum login, arahkan ke halaman Login
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
        color: Color.fromRGBO(255, 255, 255, 1),
        child: Center(
          child: Image.asset(
            IconAgro,
            width: 200,
            height: 200,
          ),
        ),
      ),
    );
  }
}
