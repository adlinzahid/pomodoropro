import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class GroupDetailsScreen extends StatefulWidget {
  final String uniqueCode; // Accept the unique code as a parameter

  const GroupDetailsScreen({super.key, required this.uniqueCode});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to fetch group details using the uniqueCode
  Future<DocumentSnapshot<Map<String, dynamic>>> fetchGroupDetails() async {
    // Query the 'groups' collection to get the document with the matching uniqueCode
    final querySnapshot = await _firestore
        .collection('groups')
        .where('uniqueCode', isEqualTo: widget.uniqueCode)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('Group not found.');
    }
    return querySnapshot.docs.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Group Details',
          style: GoogleFonts.quicksand(
            color: Colors.black87,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: fetchGroupDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final groupData = snapshot.data?.data();
            if (groupData == null) {
              return const Center(
                child: Text('Group not found.'),
              );
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  _buildGroupDetailsCard(groupData),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // Build group details card
  Widget _buildGroupDetailsCard(Map<String, dynamic> groupData) {
    Timestamp? dueDateTimestamp = groupData['dueDate']; // Get the due date
    String formattedDueDate = dueDateTimestamp != null
        ? DateFormat.yMMMd().format(dueDateTimestamp.toDate())
        : 'No Due Date';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Group Code: ${groupData['uniqueCode']}',
              style: GoogleFonts.quicksand(
                fontSize: 16,
              ),
            ),
            Text(
              groupData['groupName'] ?? 'Group Name',
              style: GoogleFonts.quicksand(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Description: ${groupData['description'] ?? 'Description'}",
              style: GoogleFonts.quicksand(
                fontSize: 16,
              ),
            ),
            //show the due date of the group project from firestore groups collection
            const SizedBox(height: 10),
            Text(
              "Due Date: $formattedDueDate",
              style: GoogleFonts.quicksand(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
