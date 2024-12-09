import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pomodoro_pro/services/tasksdata.dart';

class Tasklistpage extends StatefulWidget {
  const Tasklistpage({super.key});

  @override
  State<Tasklistpage> createState() => _TasklistpageState();
}

class _TasklistpageState extends State<Tasklistpage> {
  final Tasksdata tasksdata = Tasksdata();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // StreamBuilder to listen to the changes in the tasks collection
        stream: tasksdata.getTasksStream(), // Get the stream of tasks
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(), // Show a loading spinner
            );
          }
          final tasks = snapshot.data ?? []; // Get the tasks from the snapshot
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              // Format the date and time fields
              final formattedDate =
                  DateFormat.yMd().format(task['date'].toDate());
              final formattedTime =
                  DateFormat.jm().format(task['time'].toDate());

              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Background color for the container
                    borderRadius:
                        BorderRadius.circular(12.0), // Rounded corners
                    border: Border.all(color: Colors.grey, width: 1.0),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(10.0), // Padding inside the box
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Task Name
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                task['Name'],
                                style: GoogleFonts.quicksand(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red, size: 18.0),
                                onPressed: () {
                                  _showConfirmationDeleteTask(
                                      context,
                                      task[
                                          'id']); // Call the delete confirmation method
                                },
                              ),
                            ),
                          ],
                        ),

                        // Task Notes
                        Text(
                          "Notes: ${task['Notes']}",
                          style: GoogleFonts.quicksand(
                            fontSize: 10.0,
                            color: const Color.fromARGB(255, 101, 99, 99),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(
                            height: 8.0), // Space between notes and date

                        // Task Date and Time
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16.0,
                              color: const Color.fromARGB(255, 92, 171, 95),
                            ), // Calendar icon
                            const SizedBox(width: 4.0),
                            task['date'] != null
                                ? Text('Date: $formattedDate')
                                : const Text('No date specified'),
                            // Clock icon
                            const SizedBox(width: 6.0),
                            Icon(
                              Icons.access_time,
                              size: 16.0,
                              color: const Color.fromARGB(255, 92, 171, 95),
                            ),
                            task['time'] != null
                                ? Text('Time: $formattedTime')
                                : const Text('No time specified'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Function to show a confirmation dialog before deleting a task
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

    return shouldDelete ??
        false; // Provide a default value if shouldDelete is null
  }
}
