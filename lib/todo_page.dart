import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async'; // For the countdown timer

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Timer? _pomodoroTimer; // Timer object for Pomodoro
  int _timeRemaining = 0; // Time remaining for the Pomodoro in seconds
  final int _pomodoroDuration =
      25 * 60; // Pomodoro duration in seconds (25 minutes)
  int _currentTaskIndex = -1; // Index of the task with active Pomodoro

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _saveTask() {
    if (_nameController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      return; // Input validation
    }
    setState(() {
      _tasks.add({
        'name': _nameController.text,
        'notes': _notesController.text,
        'date': _selectedDate,
        'time': _selectedTime,
        'pomodoro': false, // Indicates if Pomodoro is running
      });
    });
    _nameController.clear();
    _notesController.clear();
    _selectedDate = null;
    _selectedTime = null;
    Navigator.pop(context); // Close the task creation bottom sheet
  }

  void _startPomodoro(int index) {
    setState(() {
      _currentTaskIndex = index;
      _tasks[index]['pomodoro'] = true;
      _timeRemaining =
          _pomodoroDuration; // Set remaining time to full duration (25 minutes)
    });
    _pomodoroTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeRemaining > 0) {
          _timeRemaining--;
        } else {
          _stopPomodoro(index);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Pomodoro for ${_tasks[index]['name']} finished!'),
          ));
        }
      });
    });
    _showPomodoroDialog(index); // Show the countdown in a dialog
  }

  void _stopPomodoro(int index) {
    if (_pomodoroTimer != null) {
      _pomodoroTimer?.cancel();
      setState(() {
        _tasks[index]['pomodoro'] = false;
        _pomodoroTimer = null;
        _timeRemaining = 0;
      });
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _showPomodoroDialog(int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Pomodoro Timer for ${_tasks[index]['name']}'),
              content: Text(
                'Time Remaining: ${_formatTime(_timeRemaining)}',
                style: const TextStyle(fontSize: 24),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _stopPomodoro(index);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Stop'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListTile(
                  title: Text(
                    task['name'],
                    // Highlight the task if it's the current Pomodoro task
                    style: TextStyle(
                      fontWeight: index == _currentTaskIndex
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    '${DateFormat.yMMMd().format(task['date'])} at ${task['time'].format(context)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.timer),
                    onPressed: () {
                      if (!task['pomodoro']) {
                        _startPomodoro(index);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Pomodoro started for ${task['name']}'),
                        ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              'Pomodoro already running for ${task['name']}'),
                        ));
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                _showTaskCreationSheet();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(
                    double.infinity, 50), // Full width rectangular button
              ),
              child: const Text('+ Create a Task'),
            ),
          ),
        ],
      ),
    );
  }

  void _showTaskCreationSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Colors.green, // Green background for the box
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Details title in the center
              const Text(
                'Details',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickDate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                      ),
                      child: const Text('Pick Date'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _pickTime,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                      ),
                      child: const Text('Pick Time'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the sheet on cancel
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: _saveTask,
                    child: const Text(
                      'Done',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
