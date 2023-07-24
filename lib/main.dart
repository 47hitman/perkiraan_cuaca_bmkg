import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'splash_screen.dart';

void main() {
  runApp(Pokemon());
}

class Pokemon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokemon App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(), // Set the SplashScreen as the initial route
      routes: {
        '/home': (context) => HomeScreen(), // Add the HomeScreen route
      },
    );
  }
}
