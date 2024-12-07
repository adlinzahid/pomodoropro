import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pomodoro_pro/screens/authentication/login_page.dart';
import 'package:pomodoro_pro/services/auth.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // Firebase Authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? currentUser;

  @override
  void initState() {
    super.initState();
    // Fetch the current user when the profile screen is loaded
    currentUser = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.green.shade700,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Icon(
                Icons.account_circle,
                size: 100,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              currentUser!.displayName?.isNotEmpty == true
                  ? currentUser?.displayName ?? 'No Name Available'
                  : 'No Name Available',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              currentUser?.email?.isNotEmpty == true
                  ? currentUser?.email ?? 'No Email Available'
                  : 'No Email Available',
              style: TextStyle(fontSize: 18, color: Colors.green.shade600),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                await Auth()
                    .signOut(); // Sign out the user using your Auth service
                Navigator.pushReplacementNamed(
                    context, LoginPage() as String); // Navigate to login screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 50.0),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
