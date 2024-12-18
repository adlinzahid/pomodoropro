import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'create_group.dart'; // Import the CreateGroupPage file
import 'join_group.dart'; // Import the JoinGroupPage file

void main() {
  runApp(const GroupCollaborationApp());
}

class GroupCollaborationApp extends StatelessWidget {
  const GroupCollaborationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const GroupCollaborationPage(),
    );
  }
}

class GroupCollaborationPage extends StatelessWidget {
  const GroupCollaborationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Group Collaboration',
          style: GoogleFonts.quicksand(
            color: Colors.black87,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 30),
          _buildButton(
            context,
            label: 'Create Group',
            icon: Icons.add,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateGroupPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 15),
          _buildButton(
            context,
            label: 'Join Group',
            icon: Icons.link,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const JoinGroupPage(),
                ),
              );
            },
          ),
          const SizedBox(height: 50),
          const Center(
            child: Text(
              'No Groups Created',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable button widget
  Widget _buildButton(BuildContext context,
      {required String label,
      required IconData icon,
      required VoidCallback onPressed}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.green[400],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
