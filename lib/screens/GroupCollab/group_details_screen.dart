// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pomodororpo/screens/GroupCollab/group_data_handler.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

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
  /// Convert progress integer to text for display
  String _progressText(int progress) {
    const progressMapping = {
      0: "Not started yet",
      1: "In progress",
      2: "Completed"
    };
    return progressMapping[progress] ?? "Unknown";
  }

  Map<String, String> memberNameToUid = {};

  @override
  void initState() {
    super.initState();
    _fetchGroupDueDate();
    _fetchMemberUids(); // Fetch UIDs for members
  }

  Future<void> _fetchMemberUids() async {
    try {
      final groupDoc = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.uniqueCode)
          .get();

      if (groupDoc.exists) {
        final List<Map<String, dynamic>>? membersData =
            (groupDoc.data()?['membersData'] as List<dynamic>?)
                ?.cast<Map<String, dynamic>>();

        if (membersData != null) {
          setState(() {
            memberNameToUid = {
              for (var member in membersData)
                member['name']:
                    member['uid'], // Ensure Firestore structure matches
            };
          });
        }
      }
    } catch (e) {
      debugPrint("Failed to fetch member UIDs: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching members' details: $e")),
      );
    }
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

                if (taskName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Task name cannot be empty"),
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
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100.0),
                child: ListView.builder(
                  itemCount: widget.members.length,
                  itemBuilder: (context, index) {
                    final memberName = widget.members[index];

                    return Card(
                      child: ListTile(
                          title: Text(memberName),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.info_outline,
                              color: Colors.blue[900],
                            ),
                            onPressed: () {
                              // Assuming `widget.uniqueCode` and `widget.members[index]` are properly set
                              final userId = widget.members[
                                  index]; // Or use user.uid depending on your structure

                              // Show the dialog when the icon button is pressed
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                      'Tasks for ${widget.members[index]}'),
                                  content:
                                      FutureBuilder<List<Map<String, dynamic>>>(
                                    future: _groupDataHandler.fetchUserTasks(
                                        widget.uniqueCode,
                                        userId), // Use the correct userId
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      }

                                      if (snapshot.hasError) {
                                        return Text('Error: ${snapshot.error}');
                                      }

                                      final tasks = snapshot.data;

                                      if (tasks == null || tasks.isEmpty) {
                                        return const Text(
                                            'No tasks found for this user.');
                                      }

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          for (var task in tasks)
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Task Name: ${task['taskName']}',
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                    'Description: ${task['taskDescription']}'),
                                                Text(
                                                    'Status: ${task['status']}'),
                                                const Divider(),
                                              ],
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          )),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      //add two floating buttons here: add task and update progress of the task for the current user
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
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
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    int? selectedProgress;
                    return AlertDialog(
                      title: Text("Update Task Progress"),
                      content: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DropdownButton<int>(
                                value: selectedProgress,
                                hint: Text("Select Progress"),
                                items: const [
                                  DropdownMenuItem(
                                    value: 0,
                                    child: Text("Not started yet"),
                                  ),
                                  DropdownMenuItem(
                                    value: 1,
                                    child: Text("In progress"),
                                  ),
                                  DropdownMenuItem(
                                    value: 2,
                                    child: Text("Completed"),
                                  ),
                                ],
                                onChanged: (int? value) {
                                  setState(() {
                                    selectedProgress = value;
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context), // Close dialog
                          child: Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () async {
                            if (selectedProgress != null) {
                              try {
                                // Fetch the taskId using the uniqueCode and userId
                                final taskId =
                                    await _groupDataHandler.fetchTaskId(
                                        widget.uniqueCode,
                                        FirebaseAuth.instance.currentUser!.uid);

                                // Proceed only if a taskId is found
                                if (taskId.isNotEmpty) {
                                  // Show the loading indicator
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => Center(
                                        child: CircularProgressIndicator()),
                                  );

                                  // Call the _updateTaskProgress method with the fetched taskId
                                  await _updateTaskProgress(
                                    context,
                                    widget.uniqueCode,
                                    taskId, // Use the fetched taskId here
                                    selectedProgress!,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'No tasks found for the user')),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Error fetching taskId: $e')),
                                );
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Please select a progress option')),
                              );
                            }
                          },
                          child: Text("Update"),
                        )
                      ],
                    );
                  },
                );
              },
              tooltip: 'Update Task Progress',
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

  Future<void> _updateTaskProgress(
    BuildContext context,
    String uniqueCode,
    String taskId,
    int progress,
  ) async {
    try {
      await _groupDataHandler.updateTaskProgress(uniqueCode, taskId, progress);
      Navigator.pop(context); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Progress updated to "${_progressText(progress)}"')),
      );
    } catch (e) {
      Navigator.pop(context); // Close the dialog on error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update progress: $e')),
      );
    }
  }

  Future<Map<String, dynamic>> fetchMemberTasksAndProgress(
      String uniqueCode, String uid) async {
    try {
      final taskSnapshots = await FirebaseFirestore.instance
          .collection('groups')
          .doc(uniqueCode)
          .collection('members')
          .doc(uid)
          .collection('taskGroup')
          .get();

      final tasks = taskSnapshots.docs.map((doc) => doc.data()).toList();
      final totalTasks = tasks.length;
      final completedTasks =
          tasks.where((task) => task['isCompleted'] == true).length;

      final progress = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

      return {
        'tasks': tasks,
        'progress': progress,
      };
    } catch (e) {
      developer.log('Error fetching member tasks: $e');
      return {
        'tasks': [],
        'progress': 0,
      };
    }
  }

  Future<Map<String, String>> fetchMemberNameToUid(String uniqueCode) async {
    try {
      final membersSnapshot = await FirebaseFirestore.instance
          .collection('groups')
          .doc(uniqueCode)
          .collection('members')
          .get();

      final Map<String, String> memberNameToUid = {};

      for (var doc in membersSnapshot.docs) {
        final uid = doc.id;
        final name = doc.data()['name'] as String? ?? 'Unknown';

        memberNameToUid[name] = uid;
      }

      developer.log('Fetched memberNameToUid: $memberNameToUid');
      return memberNameToUid;
    } catch (e) {
      developer.log('Error fetching memberNameToUid: $e');
      return {};
    }
  }
}
