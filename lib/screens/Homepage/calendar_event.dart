import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro_pro/services/tasksdata.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts


class CalendarEventPage extends StatefulWidget {
  const CalendarEventPage({super.key});

  @override
  State<CalendarEventPage> createState() => _CalendarEventPageState();
}

class _CalendarEventPageState extends State<CalendarEventPage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;
  final Tasksdata tasksdata = Tasksdata();
  Map<DateTime, List<Map<String, dynamic>>> _groupedTasks = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
    _loadAllTasks();
  }

  /// Groups tasks by their date
  Future<void> _loadAllTasks() async {
    final tasksStream = tasksdata.getTasksStream();
    tasksStream.listen((tasks) {
      final groupedTasks = <DateTime, List<Map<String, dynamic>>>{};

      for (var task in tasks) {
        final taskDate = (task['date'] as Timestamp).toDate();
        final dateOnly = DateTime(taskDate.year, taskDate.month, taskDate.day);

        if (!groupedTasks.containsKey(dateOnly)) {
          groupedTasks[dateOnly] = [];
        }
        groupedTasks[dateOnly]!.add(task);
      }

      setState(() {
        _groupedTasks = groupedTasks;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calendar", 
        style: GoogleFonts.quicksand(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        
        
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
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
              markersAlignment: Alignment.bottomCenter,
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
              markerBuilder: (context, day, events) {
                final dateOnly = DateTime(day.year, day.month, day.day);
                if (_groupedTasks.containsKey(dateOnly)) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      height: 5,
                      width: 5,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return null; // No marker if no tasks
              },
            ),
          ),
          Expanded(
            child: _groupedTasks[DateTime(_selectedDay.year, _selectedDay.month,
                            _selectedDay.day)]
                        ?.isEmpty ??
                    true
                ? const Center(
                    child: Text(
                      "No tasks for this day",
                      style: TextStyle(fontSize: 16.0, color: Colors.grey),
                    ),
                  )
                : buildTaskList(_groupedTasks[DateTime(
                    _selectedDay.year, _selectedDay.month, _selectedDay.day)]!),
          ),
        ],
      ),
    );
  }

  /// Builds the task list for a selected day
  Widget buildTaskList(List<Map<String, dynamic>> tasks) {
    // Sort tasks by time
    tasks.sort((a, b) {
      final timeA = (a['time'] as Timestamp).toDate();
      final timeB = (b['time'] as Timestamp).toDate();
      return timeA.compareTo(timeB); // Sort in ascending order
    });

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final taskTime = (task['time'] as Timestamp).toDate();

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.green.shade300, width: 2.0),
          ),
          child: ListTile(
            title: Text(
              task['Name'],
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "Notes: ${task['Notes']}",
              style: const TextStyle(fontSize: 14.0, color: Colors.grey),
            ),
            trailing: Text(
              TimeOfDay.fromDateTime(taskTime).format(context),
              style: const TextStyle(fontSize: 14.0, color: Colors.black),
            ),
          ),
        );
      },
    );
  }
}
