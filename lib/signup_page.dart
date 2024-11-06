import 'package:flutter/material.dart';
import 'main.dart'; // Import the main.dart file
import 'login_page.dart';

class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.green.shade50, // Light green background for a fresh look
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App logo or illustration
            Center(
              child: Image.asset(
                'assets/images/PomodoroProLogo.png', // Add your app's logo here
                height: 100,
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Text(
              'Create Your Account',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            // Input fields
            _buildTextField(
              hintText: 'Full Name',
              icon: Icons.person,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              hintText: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              hintText: 'Password',
              icon: Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 40),
            // Sign up button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MyHomePage())); // Handle sign-up logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(
                'Sign Up',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            // Alternative navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: TextStyle(fontSize: 16, color: Colors.green.shade900),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                LoginPage())); // Navigate to the login page
                  },
                  child: Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for building text fields
  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.green.shade700),
        hintText: hintText,
        filled: true,
        fillColor: Colors.green.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SignUpPage(),
  ));
}
