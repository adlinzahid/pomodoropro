import 'package:flutter/material.dart';
import 'todo_page.dart'; // Import the todo_page.dart file
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'splashscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro Pro',
      theme: ThemeData(),
      home: SplashScreen(), //app will first show splash screen
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // List of pages to display based on the selected index
  static final List<Widget> _pages = <Widget>[
    HomePage(), // Updated HomePage widget
    Center(child: Text('To-Do List Page', style: TextStyle(fontSize: 24))),
    Center(
        child:
            Text('Group Collaboration Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Calculator Page', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.only(left: 16.0, top: 20.0),
          child: Text(
            "Welcome",
            style: TextStyle(fontSize: 35.0),
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 20.0, left: 10.0),
            child: IconButton(
              icon: Icon(Icons.military_tech_outlined, color: Colors.amber),
              iconSize: 31.0,
              onPressed: () {
                print('Reward Clicked');
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0, right: 18.0),
            child: IconButton(
              icon: Icon(Icons.calendar_month, color: Colors.green[900]),
              iconSize: 31.0,
              onPressed: () {
                print('Calendar Clicked');
              },
            ),
          ),
        ],
      ),
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

// Define the new HomePage widget with the clickable box and sign-up button
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align content to the left
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0), // Space from AppBar
          child: GestureDetector(
            onTap: () {
              // Define the action on tap here
              print('Box Clicked');
            },
            child: Container(
              width: 400.0, // Width of the box
              height: 200.0, // Height of the box
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                    255, 101, 181, 103), // Background color of the box
                borderRadius: BorderRadius.circular(8.0), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(0, 3), // Changes position of shadow
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
                  SizedBox(height: 10.0), // Space between texts
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
          padding: const EdgeInsets.only(
              left: 16.0, top: 20.0), // Align to the left like "Welcome"
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
      ],
    );
  }
}
