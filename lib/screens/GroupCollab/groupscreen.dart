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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment:
                MainAxisAlignment.start, // Aligns everything at the top
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  log('Create Group button pressed');
                  // Handle Create Group button press
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                icon: Icon(Icons.add, color: Colors.white),
                label: Text(
                  "Create Group",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  log('Join Group button pressed');
                  // Handle Join Group button press
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                icon: Icon(Icons.link, color: Colors.white),
                label: Text(
                  "Join Group",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              SizedBox(height: 100),
              Text(
                "No Groups Created",
                style: TextStyle(color: Colors.grey, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
