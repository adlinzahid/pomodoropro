import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import '../authentication/login_page.dart'; // Ensure this is created

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
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState(); // Call the super method to initialize the state
    _initializeApp(); // Initialize the app
  }

  // method to initialize the splash screen
  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 5));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoginPage()), // Replace with your login page
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFA8E6A3), Color(0xFF74B16F)],
          ),
        ),
        child: Stack(
          children: [
        // Top left bubble
        Positioned(
          top: -50,
          left: -50,
          child: _buildBubble(200, const Color(0xFFA8E6A3)), // Soft green
        ),
        // Bottom right bubble
        Positioned(
          bottom: -50,
          right: -50,
          child: _buildBubble(200, const Color(0xFF74B16F)), // Dark green
        ),
        // Additional bubbles
        Positioned(
          top: 150,
          right: -80,
          child: _buildBubble(150, const Color(0xFFA8E6A3)), // Soft green
        ),
        Positioned(
          bottom: 150,
          left: -80,
          child: _buildBubble(120, const Color(0xFF74B16F)), // Dark green
        ),
        Positioned(
          top: 300,
          left: 50,
          child: _buildBubble(100, const Color(0xFFA8E6A3)), // Soft green
        ),
        Positioned(
          bottom: 300,
          right: 50,
          child: _buildBubble(80, const Color(0xFF74B16F)), // Dark green
        ),
        // Centered logo and text
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Tilted "P"
              Transform.rotate(
            angle: -0.2, // Tilt the "P" slightly
            child: Text(
              "P",
              style: GoogleFonts.angkor(
                fontSize: 128,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
              ),
              Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "omodoro",
                style: GoogleFonts.angkor(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height:
                  0.5, // Adjust the height for tighter spacing
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.grey.shade600,
                ),
              ],
                ),
              ),
              Text(
                "ro",
                style: GoogleFonts.angkor(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.green,
                ),
              ),
            ],
              ),
              const SizedBox(width: 10),
              Icon(
            Icons.alarm,
            size: 80,
            color: Colors.black,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.grey.shade600,
              ),
            ],
              ),
            ],
          ),
            ],
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
