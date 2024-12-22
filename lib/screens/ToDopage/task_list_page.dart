// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../services/tasksdata.dart';
import 'pomodoro_timer_page.dart';

class Tasklistpage extends StatefulWidget {
  const Tasklistpage({super.key});

  @override
  State<Tasklistpage> createState() => _TasklistpageState();
}

class _TasklistpageState extends State<Tasklistpage> {
  final Tasksdata tasksdata = Tasksdata();
  List<Map<String, dynamic>> filteredTasks = [];
  List<Map<String, dynamic>> allTasks = [];
  String searchQuery = "";

  @override
  void initState() {
    super.initState();

    // Fetch all tasks and initialize filteredTasks
    tasksdata.getTasksStream().listen((tasks) {
      if (mounted) {
        // Ensuring the widget is still mounted
        setState(() {
          allTasks = tasks;
          filteredTasks = tasks;
        });
      }
    });
  }

  void _filterTasks(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredTasks = allTasks; // Reset to all tasks if query is empty
      } else {
        filteredTasks = allTasks
            .where((task) => task['Name']
                .toLowerCase()
                .contains(query.toLowerCase())) // Filter by task name
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterTasks,
              decoration: InputDecoration(
                hintText: 'Search tasks',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          // Task List
          Expanded(
            child: filteredTasks.isEmpty
                ? const Center(
                    child: Text('No tasks found'),
                  )
                : ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];

                      // Safely format the date and time
                      final formattedDate = task['date'] != null
                          ? DateFormat.yMMMd().format(
                              task['date'].toDate(),
                            )
                          : 'No Date';

                      final formattedTime = task['time'] != null
                          ? DateFormat.jm().format((task['time'] as Timestamp)
                              .toDate()) // Convert to DateTime
                          : 'No time specified';

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: Colors.grey, width: 1.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        task['Name'] ?? 'No Task Name',
                                        style: GoogleFonts.quicksand(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.timer,
                                            color: Colors.green,
                                            size: 18.0,
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PomodoroTimerPage(
                                                  taskName: task['Name'] ?? '',
                                                  taskDateTime:
                                                      task['date'] != null
                                                          ? task['date']
                                                              .toDate()
                                                              .toString()
                                                          : '',
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.check_circle_outline,
                                            color: Colors.grey,
                                            size: 18.0,
                                          ),
                                          onPressed: () async {
                                            bool shouldComplete =
                                                await _showConfirmationCompleteTask(
                                              context,
                                              task['id'],
                                            );

                                            if (shouldComplete) {
                                              try {
                                                // Mark task as completed
                                                await tasksdata
                                                    .markTaskCompleted(
                                                        task['id']);

                                                // Update points and streak after marking task as completed
                                                await tasksdata
                                                    .updateUserPoints();

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Task completed and points updated!'),
                                                  ),
                                                );

                                                log('Task ${task['id']} completed, moved to CompletedTasks, and points updated.');
                                              } catch (e) {
                                                log('Error completing task: $e');
                                              }
                                              if (mounted) {
                                                setState(() {
                                                  filteredTasks.remove(task);
                                                });
                                              }
                                            } else {
                                              log('Task ${task['id']} not completed');
                                            }
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 18.0,
                                          ),
                                          onPressed: () async {
                                            log('Attempting to delete task ${task['id']}');
                                            bool shouldDelete =
                                                await _showConfirmationDeleteTask(
                                              context,
                                              task['id'],
                                            );
                                            if (shouldDelete) {
                                              tasksdata.deleteTask(task['id']);
                                              log('Task ${task['id']} deleted');
                                            } else {
                                              log('Task ${task['id']} not deleted');
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // Task Notes
                                if (task['Notes'] != null &&
                                    task['Notes'].isNotEmpty) ...[
                                  const SizedBox(height: 8.0),
                                  Text(
                                    "Notes: ${task['Notes']}",
                                    style: GoogleFonts.quicksand(
                                      fontSize: 12.0,
                                      color: const Color.fromARGB(
                                          255, 101, 99, 99),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8.0),
                                // Task Date and Time
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16.0,
                                      color: const Color.fromARGB(
                                          255, 92, 171, 95),
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text('Date: $formattedDate'),
                                    const SizedBox(width: 6.0),
                                    Icon(
                                      Icons.access_time,
                                      size: 16.0,
                                      color: const Color.fromARGB(
                                          255, 92, 171, 95),
                                    ),
                                    const SizedBox(width: 4.0),
                                    Text('Time: $formattedTime'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  //method to confirm delete task
  Future<bool> _showConfirmationDeleteTask(
      BuildContext context, String taskId) async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: const Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return shouldDelete ?? false;
  }

  //method to confirm complete task
  Future<bool> _showConfirmationCompleteTask(
      BuildContext context, String taskId) async {
    bool? shouldComplete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Complete Task'),
          content: Text('Are you sure you have completed this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Complete'),
            ),
          ],
        );
      },
    );

    return shouldComplete ?? false;
  }
}
