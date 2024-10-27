import 'dart:async';
import 'package:flutter/material.dart';
//import 'todo_page.dart'; // Import the To-Do List Page
import 'main.dart'; // Import main homepage
import 'signup_page.dart';
import 'dart:ui' show lerpDouble;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to To-Do List page after 5 seconds
    Timer(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                SignUpPage()), //_SignUpPageState createState() => _SignUpPageState();
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Stack(
          children: <Widget>[
            // Bubbles in the background
            Positioned(
              top: 100,
              left: 50,
              child: _buildBubble(100, const Color(0xFF74B16F)),
            ),
            Positioned(
              top: 300,
              right: 70,
              child: _buildBubble(150, Colors.green.shade800),
            ),
            Positioned(
              top: 500,
              left: 100,
              child: _buildBubble(80, Colors.green.shade700),
            ),
            Positioned(
              bottom: 200,
              right: 90,
              child: _buildBubble(130, Colors.green.shade600),
            ),
            // Center Text
            const Center(
              child: Text(
                'Pomodoro Pro',
                style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
                  fontFamily: 'Angkor',
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to create bubbles
  Widget _buildBubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
