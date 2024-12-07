import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pomodoro_pro/services/auth.dart';
import 'package:pomodoro_pro/widgets/wrapper.dart';
import 'login_page.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const SignUpPage({super.key, required this.showLoginPage});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _auth = Auth(); // Create an instance of the Auth class

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              style: GoogleFonts.quicksand(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            // Input fields
            _buildTextField(
              controller: _fullNameController,
              hintText: 'Full Name',
              icon: Icons.person,
            ),
            const SizedBox(height: 5),
            _buildTextField(
              controller: _emailController,
              hintText: 'Email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 5),
            _buildTextField(
              controller: _passwordController,
              hintText: 'Password',
              icon: Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 40),
// Sign up button
            ElevatedButton(
              onPressed: _isLoading
                  ? null // Disable button while loading
                  : () {
                      _signup(); // Call the signup method
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(
                    vertical: 15.0, horizontal: 32.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 15, // Size of the loading indicator
                      width: 15,
                      child: CircularProgressIndicator(
                        color: Colors.white, // Spinner color
                        strokeWidth: 2.0, // Thickness of the spinner
                      ),
                    )
                  : Text(
                      'Sign Up',
                      style:
                          GoogleFonts.roboto(fontSize: 18, color: Colors.white),
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
                  onPressed: _isLoading
                      ? null
                      : () {
                          goToLogin(context); // Navigate to the login page
                        },
                  child: Text(
                    'Sign In',
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
    TextEditingController? controller, // Add controller parameter
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller, // Assign the controller
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
      ),
    );
  }

//method to sign up the user
  _signup() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    try {
      final user = await _auth.createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _fullNameController.text.trim(),
      );
      if (user != null) {
        log('User signed up successfully');
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Wrapper()));
      }
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

//methods to navigate tologin page

  goToLogin(BuildContext context) => {
        log("Navigating to Login Page"),
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        )
      };
}
