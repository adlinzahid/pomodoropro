import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pomodoro_pro/screens/Homepage/homepage.dart';
import 'package:pomodoro_pro/screens/authentication/login_page.dart';
import 'package:pomodoro_pro/services/auth.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser;
  final TextEditingController _nameController = TextEditingController();
  bool _isEditing = false; // Flag to track whether we are editing the name

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    // Initialize the text controller with the current user's display name
    if (currentUser?.displayName != null) {
      _nameController.text = currentUser!.displayName!;
    }
  }

  // Method to update the user's display name in Firebase Authentication
  Future<void> updateUserName() async {
    String newName = _nameController.text;
    if (newName.isNotEmpty && newName != currentUser?.displayName) {
      try {
        await currentUser?.updateDisplayName(newName);
        await currentUser?.reload(); // Refresh user data after update
        setState(() {
          currentUser = _auth.currentUser; // Update current user data
          _isEditing = false; // Stop editing after saving
        });
      } catch (e) {
        // Show error dialog in case of a failure
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to update name: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  // Helper widget to build the text fields
  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.green.shade700),
          title: _isEditing
              ? TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: label,
                    labelStyle: TextStyle(color: Colors.green.shade700),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(color: Colors.green.shade800),
                )
              : Text(
                  controller.text.isEmpty
                      ? 'No Name Available'
                      : controller.text,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                ),
          subtitle: _isEditing
              ? null
              : Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
          onTap: () {
            if (!_isEditing) {
              setState(() {
                _isEditing = true; // Enable editing mode
              });
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(232, 245, 233, 1),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 50, bottom: 20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(currentUser?.photoURL ?? ''),
                    child: currentUser?.photoURL == null
                        ? Icon(Icons.person, size: 60, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    currentUser?.displayName ?? 'Your Name',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildTextField(
                    'Edit Your Name',
                    _nameController,
                    Icons.edit,
                  ),
                  _buildTextField(
                    'Your Email',
                    TextEditingController(
                        text: currentUser?.email ?? 'example@email.com'),
                    Icons.email,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_isEditing) // Show the "Save Changes" button only in editing mode
              ElevatedButton(
                onPressed: updateUserName,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Save Changes',
                  style:
                      GoogleFonts.quicksand(fontSize: 13, color: Colors.white),
                ),
              ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Wrap both buttons in a SizedBox with the same width
                SizedBox(
                  width: 200, // Specify the same width for both buttons
                  child: ElevatedButton(
                    onPressed: () async {
                      // Navigate to the home page
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyHomePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Back Home',
                      style: GoogleFonts.quicksand(
                          fontSize: 13, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: 200, // Specify the same width for both buttons
                  child: ElevatedButton(
                    onPressed: () async {
                      await Auth().signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Sign Out',
                      style: GoogleFonts.quicksand(
                          fontSize: 13, color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
