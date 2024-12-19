// ignore_for_file: unused_element, use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // To hold the stream subscription to manage it later
  StreamSubscription<List<Map<String, dynamic>>>? _taskStreamSubscription;

  // Dispose method to dispose of controllers, notifiers, and subscription
  void dispose() {
    taskNameController.dispose();
    taskDescriptionController.dispose();
    selectedDate.dispose();
    selectedTime.dispose();
    _taskStreamSubscription
        ?.cancel(); // Cancel the subscription to avoid memory leak
  }

  // Constructor to initialize the controllers and value notifiers
  Tasksdata() {
    taskNameController.addListener(() {
      log('Task name: ${taskNameController.text}');
    });
    taskDescriptionController.addListener(() {
      log('Task description: ${taskDescriptionController.text}');
    });
    selectedDate.addListener(() {
      log('Selected date: ${selectedDate.value}');
    });
    selectedTime.addListener(() {
      log('Selected time: ${selectedTime.value}');
    });
  }

  Stream<List<Map<String, dynamic>>> getTasksStream() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user is logged in');
    }

    // Get the collection of tasks for the current user
    final tasksStream = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .orderBy('createdAt',
            descending: true) // Order the tasks by creation time
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Ensure the task ID is included in the data
        return data;
      }).toList();
    });

    // Assign stream to _taskStreamSubscription and add error handling
    _taskStreamSubscription = tasksStream.listen(
      (taskList) {
        // Handle task stream updates here
        log("Received tasks: $taskList");
      },
      onError: (error) {
        log("Error receiving tasks: $error");
      },
    );

    return tasksStream;
  }

  // Method to add a task
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

  // Method to pick a date
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

  // Method to pick a time
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

  // Method to format time
  String formatTime(TimeOfDay time, BuildContext context) {
    // Format the time according to the current locale.
    return MaterialLocalizations.of(context).formatTimeOfDay(time);
  }

  // Method to delete a task
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
      log("Task with ID: $id deleted successfully.");
    } catch (e) {
      log("Error deleting task with ID: $id - $e");
    }
  }

  // Method to mark a task as completed and update streaks
  Future<void> markTaskCompleted(String taskId) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user is logged in');
    }

    try {
      // Retrieve the task document to check if it exists
      final taskDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tasks')
          .doc(taskId)
          .get();

      if (taskDoc.exists) {
        final taskData = taskDoc.data();

        // Set the 'completed' field to true and move task to completedTask collection
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('completedTask')
            .doc(taskId)
            .set({
          ...taskData!,
          'completed':
              true, // Ensure the task is marked as completed in the new collection
        });

        await Future.delayed(const Duration(seconds: 2)); // Simulate a delay

        // Delete the task from the 'tasks' collection
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('tasks')
            .doc(taskId)
            .delete();

        log('Task marked as completed, moved to completedTasks and deleted from tasks.');

        // Update user points and streak after completing a task
        await updateUserPointsAndStreak();
      } else {
        log('Task with ID $taskId does not exist.');
      }
    } catch (e) {
      log('Error marking task as completed: $e');
    }
  }

  Future<void> updateUserPointsAndStreak() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user is logged in');
    }

    try {
      // Fetch completed tasks for the current user (tasks with 'completed' set to true)
      final completedTasks = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('completedTask')
          .where('completed', isEqualTo: true) // Only get completed tasks
          .get();

      int completedTasksCount = completedTasks.docs.length;
      log('Completed tasks count: $completedTasksCount');

      // Points calculation: 1 point for each completed task
      int points = completedTasksCount;

      // Streak calculation: 1 streak for every 5 completed tasks
      int streak = (completedTasksCount >= 5)
          ? (completedTasksCount ~/ 5) // Integer division for streaks
          : 0; // No streak if fewer than 5 tasks

      // Fetch the user's current streak
      int currentStreak = await getUserStreak();

      // Check if the user has completed 5 tasks today
      if (completedTasksCount % 5 == 0) {
        streak = currentStreak + 1; // Increment the streak
      } else {
        streak = currentStreak; // Keep the current streak
      }


      // Update the user points and streak in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'points': points,
        'streak': streak,
      });

      log('User points and streak updated successfully: Points: $points, Streak: $streak');
    } catch (e) {
      log('Error updating user points and streak: $e');
    }
  }

  // Fetch tasks for today
  Stream<List<Map<String, dynamic>>> getTodayTasks() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user is logged in');
    }

    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay
        .add(const Duration(days: 1))
        .subtract(const Duration(seconds: 1));

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tasks')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  //method to fetch completed tasks
  Stream<List<Map<String, dynamic>>> getCompletedTasks() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user is logged in');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('completedTask')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

//method to fetch user's current points
  Future<int> getUserPoints() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user is logged in');
    }

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();

      if (userData != null && userData.containsKey('points')) {
        final points = userData['points'];
        return points is int ? points : 0; // Safely cast to int
      } else {
        return 0;
      }
    } catch (e) {
      throw Exception('Error fetching user points: $e');
    }
  }

  //method to fetch user's current streak
  Future<int> getUserStreak() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No user is logged in');
    }

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();

    if (userData != null && userData['streak'] != null) {
      return userData['streak'];
    } else {
      return 0;
    }
  }
}
