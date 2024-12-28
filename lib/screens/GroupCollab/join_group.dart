// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pomodororpo/screens/GroupCollab/created_group_details.dart';

class JoinGroupPage extends StatefulWidget {
  const JoinGroupPage({super.key});

  @override
  State<JoinGroupPage> createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends State<JoinGroupPage> {
  final TextEditingController _codeController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current user ID
  String get userId {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid ?? '';
  }

  // Join group function
  Future<void> _joinGroup() async {
    final uniqueCode = _codeController.text.trim();

    try {
      // Fetch the group with the matching unique code
      final groupSnapshot =
          await _firestore.collection('groups').doc(uniqueCode).get();

      if (groupSnapshot.exists) {
        final groupData = groupSnapshot.data();
        final List<dynamic> members = groupData?['members'] ?? [];

        // Check if the user is already a member
        if (!members.contains(userId)) {
          members.add(userId); // Add user ID as a string

          // Update Firestore document
          await _firestore
              .collection('groups')
              .doc(uniqueCode)
              .update({'members': members});

          // Navigate to GroupDetailsScreen with the unique code
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    GroupDetailsScreen(uniqueCode: uniqueCode)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('You are already a member of this group.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Invalid group code. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to join group: $e')),
      );
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
          onPressed: () => Navigator.pop(context),
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
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.green[400],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Username Display Box
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_2, color: Colors.grey),
                    const SizedBox(width: 10),
                    Text(
                      FirebaseAuth.instance.currentUser?.displayName ??
                          'Username',
                      style:
                          GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Group Code Input
              Text(
                'Group Code',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              _buildInputField(),
              const SizedBox(height: 10),

              // Instructions
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '• Enter the group code to join',
                  style:
                      GoogleFonts.poppins(fontSize: 12, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 30),

              // Join Button
              GestureDetector(
                onTap: _joinGroup,
                child: Text(
                  'JOIN',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Input Field Widget
  Widget _buildInputField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
              color: Colors.black26, blurRadius: 2, offset: const Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: _codeController,
        style: GoogleFonts.poppins(color: Colors.black87),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
