import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pomodororpo/screens/Homepage/streak.dart';

import '../../services/tasksdata.dart';
import '../GroupCollab/groupscreen.dart';
import '../TargetMarkCalculator/target_mark.dart';
import '../ToDopage/todoscreen.dart';
import '../authentication/user_profile.dart';
import 'calendar_event.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Tasksdata tasksdata = Tasksdata();
  int _selectedIndex = 0;

  // List of pages to display based on the selected index
  static final List<Widget> _pages = <Widget>[
    HomePage(), // Updated HomePage widget
    TodoList(), // Links to the TodoListPage in `todo_page.dart`
    GroupCollaborationApp(), // Links to the GroupCollaborationPage in `groupscreen.dart`
    TargetMarkCalculator(), // Links to the TargetMarkPage in `target_mark.dart`
  ];

  void _onItemTapped(int index) {
    setState(() {
      log('Selected page: $index');
      _selectedIndex = index;
    });
  }

  // Dispose of the controller when the widget is removed from the tree
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              automaticallyImplyLeading: false,
              title: Padding(
                padding: EdgeInsets.only(left: 10.0, top: 20.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.account_circle),
                      iconSize: 40.0,
                      color: const Color.fromARGB(255, 150, 164, 151),
                      onPressed: () {
                        log('Navigate to User Profile');
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserProfile()));
                      }, // Adjust color as needed
                    ),
                    SizedBox(
                        width: 10.0), // Space between the icon and the text
                    // display current logged in user user name here
                    Text(
                      "Welcome",
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
  HomePage({super.key});

  final Tasksdata tasksdata = Tasksdata();
  final int currentPoints = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Makes the page scrollable
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Section: Display Streak
          Displaystreak(),
          // Second Section: Today's Goals
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 20.0),
            child: Row(
              children: [
                Text(
                  "Today's Goals",
                  style: GoogleFonts.quicksand(
                      fontSize: 25.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.amber[700]),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outlined,
                      size: 35.0, color: Colors.lightGreen[300]),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TodoList(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // Display Today's Goals
          SizedBox(
            // Set a height constraint for the list
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: tasksdata.getTodayTasks(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final tasks = snapshot.data;

                return ListView.builder(
                  shrinkWrap: true,
                  physics:
                      NeverScrollableScrollPhysics(), // Disable nested scrolling
                  itemCount: tasks?.length,
                  itemBuilder: (context, index) {
                    final task = tasks?[index];
                    return Card(
                      color: Colors.blue[50],
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6.0),
                      child: ListTile(
                        title: Text(task?['Name'] ?? '',
                            style: GoogleFonts.quicksand(
                                fontSize: 15.0, fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          task?['Notes'] ?? '',
                          style: GoogleFonts.quicksand(
                              fontSize: 12.0, fontWeight: FontWeight.w500),
                        ),
                        trailing: Text(
                          "Due: ${_formatTime(task?['time'])}",
                          style: GoogleFonts.quicksand(
                              color: Colors.indigo[900],
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Third Section: Your Progress
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 20.0, right: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Progress",
                      style: GoogleFonts.quicksand(
                        fontSize: 25.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.amber[700],
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      "Yesterday",
                      style: GoogleFonts.quicksand(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),

                // Fetching and displaying current points using FutureBuilder
                FutureBuilder<int>(
                  future: tasksdata.getUserPoints(), // Fetch current points
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Loading spinner
                    }

                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    final currentPoints = snapshot.data ?? 0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "$currentPoints Points", // Display points dynamically
                          style: GoogleFonts.quicksand(
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          _getYesterdayDate(),
                          style: GoogleFonts.quicksand(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          // Display Yesterday's Completed Tasks
          SizedBox(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: tasksdata.getYesterdayCompletedTasks(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final tasks = snapshot.data;

                return ListView.builder(
                  shrinkWrap: true,
                  physics:
                      NeverScrollableScrollPhysics(), // Disable nested scrolling
                  itemCount: tasks?.length,
                  itemBuilder: (context, index) {
                    final task = tasks?[index];
                    return Card(
                      color: Colors.blue[50],
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6.0),
                      child: ListTile(
                        title: Text(task?['Name'] ?? '',
                            style: GoogleFonts.quicksand(
                                fontSize: 15.0, fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          task?['Notes'] ?? '',
                          style: GoogleFonts.quicksand(
                              fontSize: 12.0, fontWeight: FontWeight.w500),
                        ),
                        // Display the time the task was completed
                        trailing: Text(
                          "Completed: at ${_formatTime(DateTime.now())}",
                          style: GoogleFonts.quicksand(
                              color: Colors.indigo[900],
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Format time utility
  String _formatTime(task) {
    try {
      final time = task.toDate();
      final hour = time.hour > 12 ? time.hour - 12 : time.hour;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } catch (e) {
      return 'Invalid Time';
    }
  }

  //function to get yesterday's date
  String _getYesterdayDate() {
    final DateTime now = DateTime.now();
    final DateTime yesterday = now.subtract(const Duration(days: 1));
    return "${yesterday.day} ${_getMonthName(yesterday.month)} ${yesterday.year}";
  }

  //helper function to get month name
  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return 'Invalid Month';
    }
  }
}
