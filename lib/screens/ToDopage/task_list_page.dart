import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pomodoro_pro/screens/ToDopage/pomodoro_timer_page.dart';
import 'package:pomodoro_pro/services/tasksdata.dart';

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
      setState(() {
        allTasks = tasks;
        filteredTasks = allTasks;
      });
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
                          ? DateFormat.yMd().format(task['date']
                              .toDate()
                              .toLocal()) // Convert to local time
                          : 'No date specified';

                      final formattedTime = task['time'] != null
                          ? DateFormat.jm().format(task['time']
                              .toDate()
                              .toLocal()) // Convert to local time
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
                                // Task Name with Action Buttons
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
                                        Container(
                                          decoration: const BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle),
                                          margin: const EdgeInsets.all(2.0),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.play_arrow,
                                              color: Colors.white,
                                              size: 18.0,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PomodoroTimerPage(
                                                    taskName:
                                                        task['Name'] ?? '',
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
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 18.0,
                                          ),
                                          onPressed: () {
                                            _showConfirmationDeleteTask(
                                              context,
                                              task['id'],
                                            );
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
}
