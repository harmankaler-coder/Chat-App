import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color.fromRGBO(45, 194, 123, 1), // Equivalent to hsla(136, 48%, 54%, 1)
                Color.fromRGBO(213, 229, 54, 1), // Equivalent to hsla(58, 99%, 48%, 1)
              ],
            ),
          ),
        ),
      ),
    );
  }
}

