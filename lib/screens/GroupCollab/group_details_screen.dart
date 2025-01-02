// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pomodororpo/screens/GroupCollab/group_data_handler.dart';
import 'package:intl/intl.dart';

class GroupDetailsScreen extends StatefulWidget {
  final String groupName;
  final String uniqueCode;
  final List<String> members;

  const GroupDetailsScreen({
    super.key,
    required this.groupName,
    required this.uniqueCode,
    required this.members,
  });

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final GroupDataHandler _groupDataHandler = GroupDataHandler();
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController taskDescriptionController =
      TextEditingController();
  DateTime? groupDueDate; // Due date for the group

  @override
  void initState() {
    super.initState();
    _fetchGroupDueDate();
  }

  // Fetch the due date for the group from Firestore
  Future<void> _fetchGroupDueDate() async {
    try {
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.uniqueCode)
          .get();

      if (groupDoc.exists) {
        // Check the field name matches Firestore structure
        final dueDateTimestamp = groupDoc.data()?['dueDate'] as Timestamp?;

        setState(() {
          groupDueDate = dueDateTimestamp?.toDate();
        });

        // Debug: Print fetched due date
        debugPrint("Fetched due date: ${groupDueDate?.toLocal()}");
      }
    } catch (e) {
      debugPrint("Failed to fetch due date: $e");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch due date: $e")),
      );
    }
  }

  /// Opens the date picker to set the group's due date
  Future<void> pickGroupDueDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: groupDueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        groupDueDate = pickedDate;
      });

      // Save the picked due date to Firestore
      try {
        await FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.uniqueCode)
            .update({'dueDate': pickedDate});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Group due date updated successfully")),
        );
      } catch (e) {
        debugPrint("Failed to update due date: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update due date: $e")),
        );
      }
    }
  }

  /// Opens a dialog to get task details input from the current user
  Future<void> showAddTaskDialog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('User: ${user.displayName ?? user.email}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              TextField(
                controller: taskNameController,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                ),
              ),
              TextField(
                controller: taskDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Task Description',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final taskName = taskNameController.text;
                final taskDescription = taskDescriptionController.text;

                if (taskName.isEmpty || taskDescription.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("Task name and description cannot be empty"),
                    ),
                  );
                  return;
                }

                try {
                  await _groupDataHandler.addTaskToGroup(
                    widget.uniqueCode,
                    taskName,
                    taskDescription,
                    user.uid,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Task added successfully")),
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error adding task: $e")),
                  );
                }
              },
              child: const Text('Add Task'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.groupName,
          style: GoogleFonts.outfit(
              color: const Color.fromARGB(255, 4, 48, 41), fontSize: 25),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.amber[100],
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Group Code: ${widget.uniqueCode}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Display the fetched due date
                    Text(
                      groupDueDate == null
                          ? 'Due Date: Not Set'
                          : 'Due Date: ${DateFormat('yMMMd').format(groupDueDate!)}',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 8),
                    //display the progress of the group
                    Text(
                      'Progress: 0%',
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Members:',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.members.length,
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Member's Name with Progress Dropdown Card
                      Expanded(
                        flex: 3, // Adjust the width for this card
                        child: Card(
                          color: Colors.blue[50],
                          margin: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 4.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Member Name
                                Row(
                                  children: [
                                    const Icon(Icons.person),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        widget.members[index],
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        style:
                                            GoogleFonts.poppins(fontSize: 20),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.info_outline),
                                      onPressed: () {
                                        // Handle info button press
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title:
                                                  Text(widget.members[index]),
                                              content: Text(
                                                  'Additional information about ${widget.members[index]}'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Close'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      //add two floating buttons here: add task and update progress of the task for the current user
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 80.0,
            right: 16.0,
            child: FloatingActionButton(
              backgroundColor: Colors.blue[50],
              onPressed: showAddTaskDialog,
              tooltip: 'Add Task',
              child: Icon(Icons.add, color: Colors.blue[900]),
            ),
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              backgroundColor: Colors.blue[50],
              onPressed: () async {
                await _groupDataHandler.updateTaskProgress(widget.uniqueCode,
                    taskNameController.text, taskDescriptionController.text);
              },
              tooltip: 'Set Due Date',
              child: Icon(
                Icons.update,
                color: Colors.blue[900],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
