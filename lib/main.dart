import 'package:agro/screens/loading.dart';
import 'package:agro/screens/setting.dart';
import 'package:flutter/material.dart';
import 'package:agro/screens/dashboard.dart';

void main() {
  runApp(Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Agrobisnis',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Dashboard(products: [], storeName: '',),
    );
  }
}
