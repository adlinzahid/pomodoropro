import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupCollaborationPage extends StatefulWidget {
  const GroupCollaborationPage({super.key});

  @override
  State<GroupCollaborationPage> createState() => _GroupCollaborationPageState();
}

class _GroupCollaborationPageState extends State<GroupCollaborationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Group Collaboration', // Set the title of the app bar
          style: GoogleFonts.quicksand(
            fontSize: 25, // Set the font size
            fontWeight: FontWeight.bold, // Set the font weight
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Your main content or task list
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Your groups will appear here.",
                      style: GoogleFonts.quicksand(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // "Create Task" Button at the Bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      log('Create Group button pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 215, 253, 179), // Green background
                      foregroundColor: Colors.black, // Black text
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: Text(
                      "Create Group Collaboration",
                      style: GoogleFonts.quicksand(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                // Add some space between the buttons
                const SizedBox(height: 10.0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      log('Join Group button pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 215, 253, 179), // Green background
                      foregroundColor: Colors.black, // Black text
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.add, color: Colors.black),
                    label: Text(
                      "Join Group Collaboration",
                      style: GoogleFonts.quicksand(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
