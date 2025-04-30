import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

class SmartFabApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartFab Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: LoginScreen(),
    );
  }
}
