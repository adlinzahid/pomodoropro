import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarEventPage extends StatefulWidget {
  const CalendarEventPage({Key? key}) : super(key: key);

  @override
  _CalendarEventPageState createState() => _CalendarEventPageState();
}

class _CalendarEventPageState extends State<CalendarEventPage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;
  Map<DateTime, List<Map<String, dynamic>>> tasksMap = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
    _fetchAllTasks(); // Fetch tasks for all days on init
  }

  // Fetch tasks for multiple days from Firebase
  Future<void> _fetchAllTasks() async {
    final startOfDay =
        DateTime.now().subtract(const Duration(days: 30)); // Start date
    final endOfDay = DateTime.now().add(const Duration(days: 30)); // End date

    final snapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .get();

    final tasks = snapshot.docs
        .map((doc) => {
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            })
        .toList();

    // Group tasks by date
    tasksMap.clear();
    for (var task in tasks) {
      DateTime taskDate = (task['date'] as Timestamp).toDate();
      DateTime taskDay = DateTime(taskDate.year, taskDate.month, taskDate.day);

      if (!tasksMap.containsKey(taskDay)) {
        tasksMap[taskDay] = [];
      }
      tasksMap[taskDay]!.add(task);
    }

    setState(() {}); // Trigger a rebuild after fetching tasks
  }

  // Check if a specific day has tasks
  bool _hasTasksForDay(DateTime day) {
    DateTime normalizedDay = DateTime(day.year, day.month, day.day);
    return tasksMap.containsKey(normalizedDay) &&
        tasksMap[normalizedDay]!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("C A L E N D A R", style: TextStyle(fontSize: 26)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Calendar Widget
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.green.shade300,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: const Color.fromARGB(255, 98, 161, 102),
                shape: BoxShape.circle,
              ),
              selectedTextStyle: const TextStyle(color: Colors.white),
              cellMargin: const EdgeInsets.all(9),
            ),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, _) {
                // Display a dot under the date if tasks exist
                if (_hasTasksForDay(date)) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.orange, // Dot color
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),

          // Display tasks for the selected day
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _fetchTasksByDate(
                  _selectedDay), // Stream for selected day's tasks
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No tasks for this day'));
                }

                final tasks = snapshot.data!;

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(task['time'] ?? 'No time specified'),
                        ],
                      ),
                      title: Text(task['name'] ?? 'No task name'),
                      subtitle: Text(
                        task['notes'] ?? 'No notes available',
                        style: TextStyle(color: Colors.grey),
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

  // Function to fetch tasks for the selected day
  Stream<List<Map<String, dynamic>>> _fetchTasksByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return FirebaseFirestore.instance
        .collection('tasks')
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                })
            .toList());
  }
}
