import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  // underscore meaning its a private class
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Timer? _pomodoroTimer;
  int _timeRemaining = 0;
  final int _pomodoroDuration = 25 * 60;
  int _currentTaskIndex = -1;
  String _searchQuery = '';
  int _completedTaskCount = 0;
  int _streakPoints = 0;

  // Initialize _tasks as an empty list
  List<Map<String, dynamic>> _tasks = [];
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
    if (_nameController.text.isEmpty || _selectedDate == null || _selectedTime == null) {
      return;
    }
    setState(() {
      _tasks.add({
        'name': _nameController.text,
        'notes': _notesController.text,
        'date': _selectedDate,
        'time': _selectedTime,
        'pomodoro': false,
        'completed': false,
      });
    });
    _nameController.clear();
    _notesController.clear();
    _selectedDate = null;
    _selectedTime = null;
    Navigator.pop(context);
  }

  void _startPomodoro(int index) {
    setState(() {
      _currentTaskIndex = index;
      _tasks[index]['pomodoro'] = true;
      _timeRemaining = _pomodoroDuration;
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
    _showPomodoroDialog(index);
  }

  void _stopPomodoro(int index) {
    _pomodoroTimer?.cancel();
    setState(() {
      _tasks[index]['pomodoro'] = false;
      _pomodoroTimer = null;
      _timeRemaining = 0;
    });
  }

void _toggleTaskCompletion(int index) {
  setState(() {
    _tasks[index]['completed'] = !_tasks[index]['completed'];
    
    // Increase or decrease count, ensuring it never goes below zero
    if (_tasks[index]['completed']) {
      _completedTaskCount++;
    } else if (_completedTaskCount > 0) {
      _completedTaskCount--;
    }

    // Award streak point for every 5 tasks completed
    if (_completedTaskCount == 5) {
      _streakPoints++;
      _completedTaskCount = 0; // Reset the count after awarding a streak point
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Congratulations! You earned a streak point! Total Streaks: $_streakPoints'),
      ));
    }
  });
}

void _deleteTask(int index) {
  setState(() {
    if (_tasks[index]['completed'] && _completedTaskCount > 0) {
      _completedTaskCount--; // Decrease completed count if completed task is deleted
    }
    _tasks.removeAt(index);
  });
}


  List<Map<String, dynamic>> _filteredTasks() {
    return _tasks.where((task) => task['name'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
  padding: const EdgeInsets.all(16.0),
  child: TextField(
    controller: _searchController,
    decoration: InputDecoration(
      hintText: 'Search tasks...',
      prefixIcon: const Icon(Icons.search),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.green, width: 2.0),
      ),
    ),
    onChanged: (value) {
      setState(() {
        _searchQuery = value;
      });
    },
  ),
),

   // Task completion rate display with dynamic color
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            'Tasks (Completed: $_completedTaskCount / 5)',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _completedTaskCount > 0 ? Colors.green : Colors.red, // Dynamic color based on the count
            ),
          ),
        ),
Expanded(
  child: ListView.builder(
    itemCount: _filteredTasks().length,
    itemBuilder: (context, index) {
      final task = _filteredTasks()[index];
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), // Add margin between items
        decoration: BoxDecoration(
          color: Colors.green.shade50, // Light green background color
          borderRadius: BorderRadius.circular(12), // Rounded corners
          border: Border.all(
            color: Colors.green, // Green border color
            width: 2, // Border width
          ),
        ),
        child: ListTile(
          leading: Checkbox(
            value: task['completed'],
            onChanged: (value) {
              _toggleTaskCompletion(index);
            },
          ),
          title: Text(
            task['name'],
            style: TextStyle(
              fontWeight: index == _currentTaskIndex ? FontWeight.bold : FontWeight.normal,
              decoration: task['completed'] ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(
            '${DateFormat.yMMMd().format(task['date'])} at ${task['time'].format(context)}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.timer),
                onPressed: () {
                  if (!task['pomodoro']) {
                    _startPomodoro(index);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Pomodoro started for ${task['name']}'),
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Pomodoro already running for ${task['name']}'),
                    ));
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                color: Colors.red, // Red color for the delete button
                onPressed: () {
                  _deleteTask(index);
                },
              ),
            ],
          ),
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
                backgroundColor: const Color.fromARGB(255, 222, 255, 183),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size(double.infinity, 50),
                elevation: 5,
                shadowColor: Colors.grey.withOpacity(0.5),
              ),
              child: const Text(
                '+ Create a Task',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ),
            ),
        ]
    ));
  }

  void _showTaskCreationSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                      decoration: InputDecoration(
                        labelText: 'Task Name',
                        labelStyle: const TextStyle(color: Color.fromRGBO(45, 94, 62, 1)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        labelText: 'Notes',
                        labelStyle: const TextStyle(color: Color.fromRGBO(45, 94, 62, 1)),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _pickDate,
                            child: Text(_selectedDate != null
                                ? DateFormat.yMMMd().format(_selectedDate!)
                                : 'Pick Date'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _pickTime,
                            child: Text(
                                _selectedTime != null ? _selectedTime!.format(context) : 'Pick Time'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom
                            (backgroundColor: const Color.fromARGB(255, 222, 255, 183),
                            foregroundColor: Colors.black,),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: _saveTask,
                          style: ElevatedButton.styleFrom
                           (backgroundColor: const Color.fromARGB(255, 222, 255, 183),
                            foregroundColor: Colors.black,),
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPomodoroDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pomodoro Timer'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Time remaining: ${(_timeRemaining ~/ 60).toString().padLeft(2, '0')}:${(_timeRemaining % 60).toString().padLeft(2, '0')}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _stopPomodoro(index);
                      Navigator.pop(context);
                    },
                    child: const Text('Stop Timer'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
