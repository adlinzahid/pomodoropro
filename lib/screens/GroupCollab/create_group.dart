// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import for Firestore
import 'package:pomodororpo/screens/GroupCollab/group_data_handler.dart';
import 'created_group_details.dart'; // Import the CreatedGroupDetails file

class CreateGroup extends StatefulWidget {
  const CreateGroup({super.key});
  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  // Instance of the group data handler class
  final GroupDataHandler groupDataHandler = GroupDataHandler();

  // Controllers to handle the input fields
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Get the current logged-in user ID
  String get userId {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? ''; // Returns user ID or empty string if not logged in
  }

  // Get the username from the input controller
  String get username => _usernameController.text;

  @override
  void initState() {
    super.initState();
    fetchUsername(); // Auto-fill username on screen load
  }

  void fetchUsername() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      setState(() {
        _usernameController.text = userDoc.data()?['username'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () {
            Navigator.pop(context); // Go back to GroupScreen
          },
        ),
        title: Text(
          'Group Collaboration',
          style: GoogleFonts.quicksand(
            color: Colors.black87,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85, // Medium fit width
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.green[400],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Username Display Box
              Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white, // Background color for contrast
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center the row contents
                  children: [
                    Icon(Icons.person_2, color: Colors.grey), // User icon
                    SizedBox(width: 10), // Add space between icon and text
                    Text(
                      FirebaseAuth.instance.currentUser?.displayName ??
                          'Username',
                      style: GoogleFonts.poppins(
                        fontSize: 18, // Larger font size for prominence
                        color: Colors.grey, // Dark green text color
                      ),
                      textAlign: TextAlign.center, // Center-align the text
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20), // Add spacing between elements

              // Group Name Input
              Text(
                'Group Name',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              _buildInputField(_groupNameController, 'Enter Group Name'),
              const SizedBox(height: 20),

              // Group Description Input
              Text(
                'Group Description',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              _buildInputField(
                _descriptionController,
                'Enter Group Description',
              ),
              const SizedBox(height: 20),

              // "CREATE" Button
              GestureDetector(
                onTap: () async {
                  final user = FirebaseAuth.instance.currentUser;

                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("You must be logged in to create a group"),
                      ),
                    );
                    return;
                  }

                  String groupName = _groupNameController.text.trim();
                  String description = _descriptionController.text.trim();

                  // Validate input
                  if (groupName.isEmpty || description.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("All fields are required"),
                      ),
                    );
                    return;
                  }

                  try {
                    // Call createGroup to save group in Firestore
                    // Add creator to the members array during group creation
                    String uniqueCode = await groupDataHandler.createGroup(
                      context,
                      FirebaseAuth.instance.currentUser!.uid,
                      groupName,
                      description,
                      members: [
                        {
                          'id': FirebaseAuth.instance.currentUser!.uid,
                          'username':
                              FirebaseAuth.instance.currentUser!.displayName ??
                                  '',
                          'status': 'active',
                        },
                      ],
                    );

                    // Clear input fields
                    _groupNameController.clear();
                    _descriptionController.clear();
                    _usernameController.clear();

                    // Show dialog with the unique code and a view button
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Group Created"),
                            content: Text(
                              "Your group's unique code is: $uniqueCode",
                              style: const TextStyle(fontSize: 16),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close dialog
                                },
                                child: const Text("OK"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close dialog
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GroupDetailsScreen(
                                          uniqueCode: uniqueCode),
                                    ),
                                  );
                                },
                                child: const Text("View Group"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Failed to create group: $e"),
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  'CREATE',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Input Field Widget
  Widget _buildInputField(TextEditingController controller, String hintText) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(color: Colors.grey[800], fontSize: 15),
        textAlign: TextAlign.center, // Centers the text inside the input box
        keyboardType: TextInputType.text, // Set keyboard type to text
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 15), // Sets grey color for hint text
          contentPadding: EdgeInsets.all(5), // Ensures proper centering
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _descriptionController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
