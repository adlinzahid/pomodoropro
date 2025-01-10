import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class GroupDataHandler {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Method to allow current logged in user to create a new group collaboration and store the group id (uniqueCode) in user's document
  Future<String> createGroup(
    BuildContext context,
    String uid,
    String groupName,
    String description, {
    required List<Map<String, String>> members,
    required DateTime dueDate,
  }) async {
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
    var uuid = Uuid();
    String uniqueCode = uuid.v4().substring(0, 8).toUpperCase();

    // Create group data
    Map<String, dynamic> groupData = {
      'createdBy': user.uid,
      'groupName': groupName,
      'uniqueCode': uniqueCode,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'active',
      // ignore: unnecessary_null_comparison
      'dueDate': dueDate != null
          ? Timestamp.fromDate(dueDate)
          : null, // The due date field can be added later when it's set
      'groupProgress': 0, // Starting the group progress at 0%
    };

    try {
      // Add the group to Firestore under the 'groups' collection
      await _firestore.collection('groups').doc(uniqueCode).set(groupData);

      //now update the user's data to store the uniqueCode in their 'groupCodes' field
      await _firestore.collection('users').doc(user.uid).update({
        'groupCodes': FieldValue.arrayUnion([uniqueCode]),
      });
      developer.log('Users groupCodes updated');

      //add the user's uid to the group's subcollection 'members', this will be used to track the group members, user.uid will be the document id for documents under 'members' subcollection
      await _firestore
          .collection('groups')
          .doc(uniqueCode)
          .collection('members')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'name': user.displayName ?? 'Anonymous',
        'progress': 'Not yet started',
        'joinedAt': FieldValue.serverTimestamp(),
        'tasks': [],
      });
      developer.log('User added to group members subcollection');

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
  Future<Map<String, dynamic>> fetchGroupDetails(String uniqueCode) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    try {
      //display groups where the user.uid is a member
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(uniqueCode)
          .get();

      if (!groupDoc.exists) {
        throw Exception("Group not found");
      }

      // Map Firestore document to group details
      return {
        'groupName': groupDoc.data()?['groupName'] ?? 'Unnamed Group',
        'uniqueCode': groupDoc.data()?['uniqueCode'] ?? '',
        'members': List<String>.from(
            groupDoc.data()?['members'] ?? []), // Safely parse members
      };
    } catch (e) {
      developer.log('Error fetching group details: $e');
      throw Exception("Error fetching group details");
    }
  }

//Fetch all groups where the user is a member or creator based on the groupCodes field in the users collection
  Future<List<Map<String, dynamic>>> fetchUserGroups() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    try {
      //fetch all groups where the user is a member or creator
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception("User document not found");
      }

      List<dynamic> groupCodes = userDoc.data()?['groupCodes'] ??
          []; //retrieve the groupCodes field from the user's document
      if (groupCodes.isEmpty) {
        return [];
      }

      // Fetch group details for each group code
      QuerySnapshot groupSnapshots = await FirebaseFirestore.instance
          .collection('groups')
          .where('uniqueCode', whereIn: groupCodes)
          .get();

      return groupSnapshots.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      developer.log('Error fetching user groups: $e');
      throw Exception("Error fetching user groups");
    }
  }

// Fetch the username for a given UID
  Future<String> fetchUsername(String uid) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    if (userDoc.exists) {
      return userDoc.data()?['username'] ?? 'Unknown';
    } else {
      throw Exception('User document not found for UID: $uid');
    }
  }

//method to allow members to add their task to the group and save it in firestore, a subcollection under 'members' named 'taskGroup'
  Future<String> addTaskToGroup(
    String uniqueCode,
    String taskName,
    String taskDescription,
    String assignedTo,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    // Check if the user is logged in
    if (user == null) {
      throw Exception("User not logged in");
    }

    // Validate input
    if (taskName.isEmpty) {
      throw Exception("Task name cannot be empty");
    }

    try {
      // Firestore reference
      final firestore = FirebaseFirestore.instance;

      //Generate a unique id for the task, start the id with GT (Group Task) to differentiate it from other tasks, length of 8
      final taskId = 'GT${Uuid().v4().substring(0, 6).toUpperCase()}';

      // Automatically creates the hierarchy if it doesn’t exist
      await firestore
          .collection('groups')
          .doc(uniqueCode)
          .collection('members')
          .doc(user.uid)
          .collection('taskGroup')
          .doc(taskId)
          .set({
        'taskName': taskName,
        'taskDescription': taskDescription,
        'taskId': taskId,
        'assignedTo': assignedTo,
        'status': 'Not yet started',
        'createdAt': FieldValue.serverTimestamp(),
      });

      developer
          .log('Task successfully added to the group with taskId: $taskId');
      return taskId;
    } catch (e) {
      // Log error
      developer.log('Error adding task to group: $e');
      throw Exception("Error adding task to group");
    }
  }

//method to allow members to fetch their tasks in the group from firestore from the subcollection 'taskGroup' under 'members' that they are assigned to
  Future<List<Map<String, dynamic>>> fetchUserTasks(
      String uniqueCode, String userId) async {
    try {
      // Path to the user's tasks
      final taskCollection = FirebaseFirestore.instance
          .collection('groups')
          .doc(uniqueCode)
          .collection('members')
          .doc(userId)
          .collection('taskGroup');

      // Get all tasks
      final querySnapshot = await taskCollection.get();

      if (querySnapshot.docs.isEmpty) {
        return []; // No tasks found
      }

      // Convert tasks to a list of maps
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception("Error fetching user tasks: $e");
    }
  }

  //method to fetch taskId from firestore from the subcollection 'taskGroup' under 'members' that they are assigned to
  Future<String> fetchTaskId(String uniqueCode, String userId) async {
    try {
      // Path to the user's tasks
      final taskCollection = FirebaseFirestore.instance
          .collection('groups')
          .doc(uniqueCode)
          .collection('members')
          .doc(userId)
          .collection('taskGroup');

      // Get all tasks
      final querySnapshot = await taskCollection.get();

      if (querySnapshot.docs.isEmpty) {
        return ''; // No tasks found
      }

      // Convert tasks to a list of maps
      return querySnapshot.docs.first.id;
    } catch (e) {
      throw Exception("Error fetching user tasks: $e");
    }
  }

  //method to allow members to update their task progress in the group with choice of 'Not yet started', 'In progress', 'Completed' and storing it in firestore using number values 0, 1, 2
  Future<void> updateTaskProgress(
    String uniqueCode,
    String taskId,
    int progress,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    try {
      // Update the task progress directly within the user's document under 'tasks'
      await FirebaseFirestore.instance
          .collection('groups') // Access the 'groups' collection
          .doc(uniqueCode) // Navigate to the specific group
          .collection('members') // Access the group's members subcollection
          .doc(user.uid) // Navigate to the current user's document
          .update({
        'tasks.$taskId.status':
            progress, // Update the status of the specific task
      });
    } catch (e) {
      developer.log('Error updating task progress: $e');
      throw Exception("Error updating task progress");
    }
  }
}
