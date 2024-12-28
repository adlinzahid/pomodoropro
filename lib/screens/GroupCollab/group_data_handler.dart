import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class GroupDataHandler {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Method to allow current logged in user to create a new group collaboration and store the group id (uniqueCode) in user's document
  Future<String> createGroup(
      BuildContext context, String uid, String groupName, String description,
      {required List<Map<String, String>> members}) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    if (groupName.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Group name or description cannot be empty')),
      );
      throw Exception("Validation failed: Group name or description is empty");
    }

    // Generate a unique code for the group using the Uuid package
    // This code will be 8 characters long and uppercase using 1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ and abcdefghijklmnopqrstuvwxyz
    var uuid = Uuid();
    String uniqueCode = uuid.v4().substring(0, 8).toUpperCase();

    // Create the group data
    Map<String, dynamic> groupData = {
      'createdBy': user.uid,
      'groupName': groupName,
      'members': [user.uid], // Store only UIDs for querying simplicity
      'uniqueCode': uniqueCode,
      'createdAt': FieldValue.serverTimestamp(),
      'description': description,
      'status': 'active',
    };

    try {
      // Add the group to Firestore under the 'groups' collection
      await _firestore.collection('groups').doc(uniqueCode).set(groupData);

      // Now, update the user's data to store the uniqueCode in their `groupCodes` field
      await _firestore.collection('users').doc(user.uid).update({
        'groupCodes':
            FieldValue.arrayUnion([uniqueCode]), // Store the uniqueCode here
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Group created successfully")),
        );
      }

      // Return the uniqueCode for navigation or further use
      return uniqueCode;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error creating group: $e")),
        );
      }
      throw Exception("Error creating group: $e");
    }
  }

  // Fetch group details using uniqueCode
  Future<List<DocumentSnapshot<Map<String, dynamic>>>>
      fetchGroupDetails() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    try {
      // Query groups where the user is a member
      final querySnapshot = await _firestore
          .collection('groups')
          .where('members', arrayContains: user.uid)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("No groups found");
      }

      return querySnapshot.docs; // Return all matching group documents
    } catch (e) {
      developer.log('Error fetching group details: $e');
      throw Exception("Error fetching group details");
    }
  }

// Fetch all groups where the user is a member or creator
  Future<List<Map<String, dynamic>>> fetchUserGroups() async {
    final user = FirebaseAuth.instance.currentUser;

    // Ensure the user is logged in
    if (user == null) {
      throw Exception("User not logged in");
    }

    try {
      // Fetch all groups where the user is a member
      final groupQuery = await FirebaseFirestore.instance
          .collection('groups')
          .where('members', arrayContains: user.uid)
          .get();

      if (groupQuery.docs.isEmpty) {
        return []; // No groups found, return an empty list
      }

      // Map Firestore documents to group details
      return groupQuery.docs.map((doc) {
        return {
          'groupName': doc.data()['groupName'] ?? 'Unnamed Group',
          'uniqueCode': doc.data()['uniqueCode'] ?? '',
          'members': List<String>.from(
              doc.data()['members'] ?? []), // Safely parse members
        };
      }).toList();
    } catch (e) {
      developer.log('Error fetching user groups: $e');
      throw Exception("Error fetching user groups");
    }
  }

  // Add a new message to the group collaboration collection
  Future<void> addMessage(String message) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('group_collaboration').add({
        'userName': user.displayName ?? "Anonymous",
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // Fetch all messages from the group collaboration collection
  Stream<List<Map<String, dynamic>>> getMessages() {
    return _firestore
        .collection('group_collaboration')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return {
                'userName': doc['userName'],
                'message': doc['message'],
                'timestamp': doc['timestamp'],
              };
            }).toList());
  }
}
