import 'package:flutter/material.dart';
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
              return ListTile(
                title: Text(task['Name']), // Show the task name
                subtitle: Text(task['Notes']), // Show the task notes
                trailing: IconButton(
                  icon: const Icon(Icons.delete), // Show a delete icon
                  onPressed: () {
                    tasksdata.deleteTask(task['id']); // Delete the task
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
