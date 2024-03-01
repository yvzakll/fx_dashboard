import 'package:flutter/material.dart';

import 'dart:convert';

import 'package:fx_dashboard/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: const TextTheme(
          headline4: TextStyle(color: Colors.white70),
          headline5: TextStyle(color: Colors.white70),
        ),
        appBarTheme: const AppBarTheme(
          color: Colors.red,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      title: 'Web Service Demo',
      home: LoginPage(),
    );
  }
}
