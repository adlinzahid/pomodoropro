import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pomodoro_pro/screens/GroupCollab/groupscreen.dart';
import 'package:pomodoro_pro/screens/Homepage/calendar_event.dart';
import 'package:pomodoro_pro/screens/TargetMarkCalculator/target_mark.dart';
import 'package:pomodoro_pro/screens/ToDopage/todo_page.dart';
import 'package:pomodoro_pro/screens/authentication/userProfile.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // List of pages to display based on the selected index
  static final List<Widget> _pages = <Widget>[
    HomePage(), // Updated HomePage widget
    TodoListPage(), // Links to the TodoListPage in `todo_page.dart`
    GroupCollaborationPage(), // Links to the GroupCollaborationPage in `groupscreen.dart`
    TargetMarkCalculator(), // Links to the TargetMarkPage in `target_mark.dart`
  ];

  void _onItemTapped(int index) {
    setState(() {
      log('Selected page: $index');
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              title: Padding(
                padding: EdgeInsets.only(left: 10.0, top: 20.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        log('Navigate to User Profile');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserProfile(),
                          ),
                        );
                      },
                      child: Icon(
                        Icons.account_circle,
                        size: 40.0,
                        color: const Color.fromARGB(
                            255, 150, 164, 151), // Adjust color as needed
                      ),
                    ),
                    SizedBox(
                        width: 10.0), // Space between the icon and the text
                    Text(
                      "Welcome", // Use the user's name here
                      style: GoogleFonts.quicksand(
                          fontSize: 25.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 20.0, left: 10.0),
                  child: IconButton(
                    icon:
                        Icon(Icons.military_tech_outlined, color: Colors.amber),
                    iconSize: 31.0,
                    onPressed: () {
                      log('Navigate to Rewards Page');
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.0, right: 18.0),
                  child: IconButton(
                    icon: Icon(Icons.calendar_month, color: Colors.green[900]),
                    iconSize: 31.0,
                    onPressed: () {
                      log('Navigate to Calendar Event Page');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CalendarEventPage(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            )
          : null, // No app bar for other pages
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'To-Do List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_sharp),
            label: 'Group',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey[600],
        onTap: _onItemTapped,
      ),
    );
  }
}

// Define the new HomePage widget with task fetching and display functionality
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Fetch tasks from Firebase Firestore
  Stream<QuerySnapshot> getTodayTasks() {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));

    // Query for tasks where 'date' is today
    return FirebaseFirestore.instance
        .collection('tasks')
        .where('date', isGreaterThanOrEqualTo: todayStart)
        .where('date', isLessThan: tomorrowStart)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
            onTap: () {
              print('Box Clicked');
            },
            child: Container(
              width: double.infinity,
              height: 200.0,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 101, 181, 103),
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '0 Days',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 45.0,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Current Streak',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 20.0),
          child: Row(
            children: [
              const Text(
                "Today's Goals",
                style: TextStyle(fontSize: 25.0),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outlined,
                    size: 35.0, color: Colors.lightGreen[300]),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => TodoListPage()));
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: getTodayTasks(), // Fetch tasks from Firebase
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final todayTasks = snapshot.data!.docs;
              if (todayTasks.isEmpty) {
                return const Center(child: Text('No tasks for today!'));
              }

              return ListView.builder(
                itemCount: todayTasks.length,
                itemBuilder: (context, index) {
                  final task = todayTasks[index];
                  final taskDate = (task['date'] as Timestamp).toDate();
                  final taskTime = task['time'];
                  final taskNotes = task['notes'] ??
                      'No notes available'; // Use 'No notes available' if no notes exist

                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .spaceBetween, // Align the text and icon on opposite ends
                      children: [
                        Text(task['name'], style: TextStyle(fontSize: 16.0)),
                        IconButton(
                          icon: Icon(Icons.info_outline),
                          onPressed: () {
                            // Show an AlertDialog with the task notes
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Task Notes'),
                                  content: Text(taskNotes),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                      child: Text(
                                        'Close',
                                        style: TextStyle(
                                            fontSize: 15,
                                            color: const Color.fromARGB(
                                                255, 134, 189, 71)),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${DateFormat.yMMMd().format(taskDate)} at $taskTime',
                        ),
                        SizedBox(
                            height:
                                4.0), // Add some space between date/time and notes
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
