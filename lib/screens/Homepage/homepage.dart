import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pomodoro_pro/screens/GroupCollab/groupscreen.dart';
import 'package:pomodoro_pro/screens/Homepage/calendar_event.dart';
import 'package:pomodoro_pro/screens/TargetMarkCalculator/target_mark.dart';
import 'package:pomodoro_pro/screens/ToDopage/todoscreen.dart';
import 'package:pomodoro_pro/screens/authentication/user_profile.dart';
import 'package:pomodoro_pro/services/tasksdata.dart';

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
    GroupCollaborationPage(), // Links to the GroupCollaborationPage in `groupscreen.dart`
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
            onTap: () {
              log('Box Clicked');
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '0 Days',
                    style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontSize: 45.0,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    'Current Streak',
                    style: GoogleFonts.quicksand(
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
        // display today's goals here
        Expanded(
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
              itemCount: tasks?.length,
              itemBuilder: (context, index) {
                final task = tasks?[index];
                return Card(
                  color: Colors.blue[50], // card colour
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 6.0),
                  child: ListTile(
                    title: Text(task?['Name'],
                        style: GoogleFonts.quicksand(
                            fontSize: 15.0, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      task?['Notes'],
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
        )),
      ],
    );
  }

// format to 12-hour time with AM/PM
  _formatTime(task) {
    try {
      final time = task.toDate();
      final hour = time.hour > 12 ? time.hour - 12 : time.hour;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.hour > 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    } catch (e) {
      return 'Invalid Time';
    }
  }
}
