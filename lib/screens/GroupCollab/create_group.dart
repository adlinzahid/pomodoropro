// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final TextEditingController _descriptionController = TextEditingController();

  // Get the current logged-in user ID
  String get userId {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? ''; // Returns user ID or empty string if not logged in
  }

  // Get the username from the input controller
  String get username => FirebaseAuth.instance.currentUser?.displayName ?? '';

  // Variable to store the selected due date
  DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
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
              // Group Name and Description Input
              _buildInputField(_groupNameController, 'Enter Group Name'),
              const SizedBox(height: 20),
              _buildInputField(
                  _descriptionController, 'Enter Group Description'),

              //Date Picker Button
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2021),
                    lastDate: DateTime(2100),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _selectedDueDate = pickedDate;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                    side: BorderSide(
                        color: Colors.grey[300]!, width: 1.0), // Outline
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 16), // Padding
                ),
                child: Text(
                  _selectedDueDate == null
                      ? 'Select Due Date'
                      : 'Due Date: ${_selectedDueDate!.toLocal()}'
                          .split(' ')[0],
                  style: GoogleFonts.poppins(
                    color: const Color.fromARGB(255, 38, 157, 87),
                    fontSize: 15,
                  ),
                ),
              ),

              // "CREATE" Button
              GestureDetector(
                onTap: () async {
                  final groupName = _groupNameController.text.trim();
                  final description = _descriptionController.text.trim();

                  // Check for empty fields
                  if (groupName.isEmpty ||
                      description.isEmpty ||
                      _selectedDueDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("All fields are required")),
                    );
                    return;
                  }

                  try {
                    // Add the current user as the first member with their info
                    List<Map<String, String>> members = [
                      {
                        'uid': userId,
                        'name': username,
                      }
                    ];

                    String uniqueCode = await groupDataHandler.createGroup(
                      context,
                      FirebaseAuth.instance.currentUser!.uid,
                      groupName,
                      description,
                      members: members,
                      dueDate: _selectedDueDate!, // Pass the selected due date
                    );

                    _groupNameController.clear();
                    _descriptionController.clear();

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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to create group: $e")),
                    );
                  }
                },
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'CREATE',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ],
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
    super.dispose();
  }
}
