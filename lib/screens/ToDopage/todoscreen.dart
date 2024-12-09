import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pomodoro_pro/services/tasksdata.dart';
import 'TaskListPage.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final Tasksdata tasksData = Tasksdata();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'To-Do List',
          style: GoogleFonts.quicksand(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Tasklistpage(),
          ),
          // Your main content or task list

          // "Create Task" Button at the Bottom
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  log('Create Task button pressed');
                  createTask(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                      255, 215, 253, 179), // Green background
                  foregroundColor: Colors.black, // Black text
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.add, color: Colors.black),
                label: Text(
                  "Create Task",
                  style: GoogleFonts.quicksand(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // function to create a task
  void createTask(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.green,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Stack for Cancel, Save, and Details Text
              Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,

                    ///button to cancel task
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close bottom sheet
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 215, 253, 179),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    //button to save task
                    child: ElevatedButton(
                      onPressed: () => saveTaskData(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 215, 253, 179),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                      ),
                      child: const Text('Save Task'),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Task Name Input Box
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: tasksData.taskNameController,
                  decoration: const InputDecoration(
                    labelText: 'Task Name',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Notes Input Box
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: tasksData.taskDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Row for Date and Time Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await tasksData.pickDate(context);
                      log('Date Picker button pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 47, 122, 60),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.calendar_today),
                        SizedBox(width: 7),
                        Text('Pick Date'),
                      ],
                    ),
                  ),
                  ValueListenableBuilder<DateTime>(
                    valueListenable: tasksData.selectedDate,
                    builder: (context, date, child) {
                      return Text(
                        'Date: ${date.toLocal().toString().split(' ')[0]}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      await tasksData.pickTime(context);
                      log('Time picker is pressed');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 47, 122, 60),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.access_time),
                        SizedBox(width: 5),
                        Text('Pick Time'),
                      ],
                    ),
                  ),
                  ValueListenableBuilder<TimeOfDay>(
                    valueListenable: tasksData.selectedTime,
                    builder: (context, time, child) {
                      return Text(
                        'Time: ${time.format(context)}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
// End of createTask function

  //method to display time and date
  Widget buildDateTimePicker(Tasksdata tasksData, BuildContext context) {
    return Column(
      children: [
        // Date Picker Button and Display
        Row(
          children: [
            ElevatedButton(
              onPressed: () async {
                await tasksData.pickDate(context); // Open Date Picker
                log('Date Picker button pressed');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 47, 122, 60),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                children: const [
                  Icon(Icons.calendar_today),
                  SizedBox(width: 7),
                  Text('Pick Date'),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Display Selected Date
            ValueListenableBuilder<DateTime>(
              valueListenable: tasksData.selectedDate,
              builder: (context, date, child) {
                return Text(
                  'Selected Date: ${date.toLocal().toString().split(' ')[0]}',
                  style: const TextStyle(fontSize: 16),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Time Picker Button and Display
        Row(
          children: [
            ElevatedButton(
              onPressed: () async {
                await tasksData.pickTime(context); // Open Time Picker
                log('Time picker is pressed');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 47, 122, 60),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                children: const [
                  Icon(Icons.access_time),
                  SizedBox(width: 5),
                  Text('Pick Time'),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Display Selected Time
            ValueListenableBuilder<TimeOfDay>(
              valueListenable: tasksData.selectedTime,
              builder: (context, time, child) {
                return Text(
                  'Selected Time: ${time.format(context)}',
                  style: const TextStyle(fontSize: 16),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  saveTaskData(BuildContext context) async {
    final taskName = tasksData.taskNameController.text.trim();
    final taskDescription = tasksData.taskDescriptionController.text.trim();

    if (taskName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all the fields'),
        ),
      );
      log('Task name or description is empty');
      return;
    }

    try {
      await tasksData.addTask(
          taskName, taskDescription, tasksData.selectedDate.value);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task saved successfully')));
      Navigator.pop(context); // Close the bottom sheet
    } catch (e) {
      log('Error saving task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
        ),
      );
    }
  }
}
