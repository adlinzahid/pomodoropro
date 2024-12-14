// ignore_for_file: unused_element

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Tasksdata {
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController taskDescriptionController =
      TextEditingController();
  final ValueNotifier<DateTime> selectedDate =
      ValueNotifier<DateTime>(DateTime.now());
  final ValueNotifier<TimeOfDay> selectedTime =
      ValueNotifier<TimeOfDay>(TimeOfDay.now());
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //method to get the stream of tasks
  Stream<List<Map<String, dynamic>>> getTasksStream() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user is logged in');
    }

    //get the collection of tasks for the current user
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .orderBy('createdAt',
            descending: true) // order the tasks by creation time
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; //ensure the task ID is included in the data
        return data;
      }).toList();
    });
  }

  //method to add a task
  Future<void> addTask(
      String taskName, String taskDescription, DateTime selectedDate) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user is logged in');
    }

    final taskCollection = _firestore
        .collection('users') // Get collection of users
        .doc(user.uid) // Get document of the current user
        .collection('tasks'); // Get collection of tasks for the current user

    // Combine selectedDate and selectedTime into a DateTime
    final DateTime taskDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.value.hour, // Convert TimeOfDay to hour and minute
      selectedTime.value.minute,
    );

    await taskCollection.add({
      'Name': taskName,
      'Notes': taskDescription,
      'createdAt': FieldValue.serverTimestamp(),
      'date': selectedDate, // Save the date-only field
      'time': taskDateTime, // Save as a DateTime object
      'pomodoro': false,
      'completed': false,
    });
  }

  //methods to pick date and time
  Future<void> pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      selectedDate.value = pickedDate;
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      selectedTime.value = pickedTime;
      log("Selected Time: ${pickedTime.format(context)}");
    }
  }

  String formatTime(TimeOfDay time, BuildContext context) {
    // Format the time according to the current locale.
    return MaterialLocalizations.of(context).formatTimeOfDay(time);
  }

  Map<String, dynamic> toMap(BuildContext context) {
    return {
      'time': selectedTime.value
          .format(context), // Ensure context is passed correctly
      // other fields...
    };
  }

  // function to delete a task
  Future<void> deleteTask(String id) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('No user is logged in');
      }

      final taskCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks');
      await taskCollection.doc(id).delete();
    } catch (e) {
      if (kDebugMode) {
        print("Deleting task with ID: $id");
      }
      if (kDebugMode) {
        print("Task with ID $id deleted successfully.");
      } else {
        if (kDebugMode) {
          print("Error deleting task with ID $id: $e");
        }
      }
    }

    // Fetch tasks in a date range
    Future<List<Map<String, dynamic>>> fetchTasksInRange(
        DateTime start, DateTime end) async {
      final snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .where('date', isGreaterThanOrEqualTo: start)
          .where('date', isLessThanOrEqualTo: end)
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    }

    // Fetch tasks for a specific date
    Stream<List<Map<String, dynamic>>> fetchTasksForDate(DateTime date) {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('No user is logged in');
      }

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      return FirebaseFirestore.instance
          .collection('tasks')
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThanOrEqualTo: endOfDay)
          .snapshots()
          .map((snapshot) {
        final tasks = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            ...doc.data(),
          };
        }).toList();

        // Debug: Print raw Firestore tasks
        log('Fetched tasks from Firestore: $tasks');
        return tasks;
      });
    }

    //method to search for tasks
    Future<List<Map<String, dynamic>>> searchTasks(String query) async {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception('No user is logged in');
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .where('Name', isGreaterThanOrEqualTo: query)
          .where('Name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data(),
        };
      }).toList();
    }
  }
}
