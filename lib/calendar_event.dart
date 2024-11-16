import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarEventPage extends StatefulWidget {
  const CalendarEventPage({Key? key}) : super(key: key);

  @override
  _CalendarEventPageState createState() => _CalendarEventPageState();
}

class _CalendarEventPageState extends State<CalendarEventPage> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
  }

  // function to get the events for a specific day

  List<String> _getEventsForDay(DateTime day) {
    return [];
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("C A L E N D A R", style: TextStyle(fontSize: 26)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format; // Update the format
              });
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay; // Update the selected day
                _focusedDay = focusedDay; // Update the focused day
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay, // Load events for a specific day
          ),
          //TableCalendar

          ..._getEventsForDay(_selectedDay)
              .map((event) => ListTile(title: Text(event)))
              .toList(), // Display the events for the selected day
        ],
      ),
    );
  }
}
