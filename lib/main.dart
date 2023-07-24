import 'package:flutter/material.dart';
import 'package:random_quotes/screens/Home_page.dart';
import 'package:random_quotes/screens/loading_screen.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoadingScreen(),
    ),
  );
}
