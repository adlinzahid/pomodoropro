import 'package:flutter/material.dart';
import 'pomodoro_timer_page.dart'; //Import the target_mark.dart file
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

final taskStreamProvider = StreamProvider.autoDispose((ref) {
  return FirebaseFirestore.instance.collection('tasks').snapshots();
});

class TodoListPage extends HookConsumerWidget {
  const TodoListPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = useState('');
    final nameController = useTextEditingController();
    final notesController = useTextEditingController();
    final selectedDate = useState<DateTime?>(null);
    final selectedTime = useState<TimeOfDay?>(null);

    final tasksAsyncValue = ref.watch(taskStreamProvider);

    void saveTask() async {
      if (nameController.text.isEmpty ||
          selectedDate.value == null ||
          selectedTime.value == null) {
        return;
      }

      final taskData = {
        'name': nameController.text,
        'notes': notesController.text,
        'date': selectedDate.value,
        'time': selectedTime.value?.format(context),
        'pomodoro': false,
        'completed': false,
      };

      try {
        await FirebaseFirestore.instance.collection('tasks').add(taskData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task saved successfully!')),
        );
        nameController.clear();
        notesController.clear();
        selectedDate.value = null;
        selectedTime.value = null;
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving task: $e')),
        );
      }
    }

    Future<void> pickDate() async {
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

    Future<void> pickTime() async {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        selectedTime.value = pickedTime;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'To-Do List',
          style: GoogleFonts.quicksand(
            fontSize: 25, // Set the font size
            fontWeight: FontWeight.bold, // Set the font weight
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: useTextEditingController(),
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
                searchQuery.value = value;
              },   
            ),  
            


          ),
          Expanded(
            child: tasksAsyncValue.when(
              data: (snapshot) {
                final tasks = snapshot.docs
                    .map((doc) => {
                          'id': doc.id,
                          ...doc.data() as Map<String, dynamic>,
                        })
                    .where((task) => (task['name'] as String)
                        .toLowerCase()
                        .contains(searchQuery.value.toLowerCase()))
                    .toList();

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final taskDate =
                        (task['date'] as Timestamp).toDate(); // Firebase date
                    final taskTime = task['time'];
                    final taskCompleted = task['completed'] ?? false;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFE8F5E9), // Soft green background
                          border: Border.all(color: Colors.green, width: 2.0),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
  leading: Checkbox(
    value: taskCompleted,
    onChanged: (value) async {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(task['id'])
          .update({'completed': value});
    },
  ),
  title: Text(
    task['name'],
    style: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: const Color.fromARGB(255, 0, 0, 0),
      decoration: taskCompleted ? TextDecoration.lineThrough : null,
    ),
  ),
  subtitle: Text(
    '${DateFormat.yMMMd().format(taskDate)} at $taskTime',
    style: TextStyle(color: const Color.fromARGB(255, 2, 56, 14)),
  ),
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      
      // Pomodoro Button
// Pomodoro Button
Container(
  decoration: BoxDecoration(
    color: Colors.green, // Green circular background
    shape: BoxShape.circle, // Ensures the background is circular
  ),
  child: IconButton(
    icon: Icon(
      Icons.play_arrow, // "Play" icon
      color: Colors.white, // Icon color is white
    ),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PomodoroTimerPage(
            taskName: task['name'],
            taskDateTime: '${DateFormat.yMMMd().format(taskDate)} at $taskTime',
          ),
        ),
      );
    },
  ),
),


      // Delete Button
      IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () async {
          // Show confirmation dialog before deletion
          final bool? confirmed = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Confirm Delete'),
                content: const Text('Are you sure you want to delete this task?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete task'),
                  ),
                ],
              );
            },
          );

          if (confirmed == true) {
            // User confirmed deletion
            try {
              await FirebaseFirestore.instance
                  .collection('tasks')
                  .doc(task['id'])
                  .delete();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task deleted successfully!')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error deleting task: $e')),
              );
            }
          }
        },
      ),
    ],
  ),
),

                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                    255, 215, 253, 179), // Green background
                foregroundColor: Colors.black, // Black text
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                ),
                minimumSize: Size(double.infinity, 50), // Full width button
              ),
              onPressed: () {
                //container for the tasks creation
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  backgroundColor: Colors.green,
                  builder: (context) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                        top: 20,
                        left: 16,
                        right: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Stack for Cancel, Save, and Details Text
                          Stack(
                            children: [
                              // Cancel Button (Top Left)
                              Align(
                                alignment: Alignment.topLeft,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Cancel
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                        255, 215, 253, 179), // Green background
                                    foregroundColor: Colors.black, // White text
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 20,
                                    ),
                                  ),
                                  child: const Text('Cancel'),
                                ),
                              ),
                              // Save Button (Top Right)
                              Align(
                                alignment: Alignment.topRight,
                                child: ElevatedButton(
                                  onPressed: saveTask,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(
                                        255, 215, 253, 179), // Green background
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 20,
                                    ),
                                  ),
                                  child: const Text('Save Task'),
                                ),
                              ),
                              // Details Text
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'Details',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 18,
                                    fontWeight: FontWeight
                                        .bold, // Bold version of Quicksand
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                              height:
                                  40), // Space between buttons and input fields

                          // Task Name Input Box
                          Container(
                            decoration: BoxDecoration(
                              color: Colors
                                  .white, // White background for input fields
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'Task Name',
                                border: InputBorder.none, // No border
                                contentPadding: EdgeInsets.all(16),
                              ),
                            ),
                          ),
                          const SizedBox(
                              height: 10), // Space between Task Name and Notes

                          // Notes Input Box
                          Container(
                            decoration: BoxDecoration(
                              color: Colors
                                  .white, // White background for input fields
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: notesController,
                              decoration: const InputDecoration(
                                labelText: 'Notes',
                                border: InputBorder.none, // No border
                                contentPadding: EdgeInsets.all(16),
                              ),
                            ),
                          ),
                          const SizedBox(
                              height:
                                  10), // Space between Notes and Date/Time buttons

                          // Row for Date and Time Buttons (Aligned Bottom)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Pick Date Button (Left)
                              ElevatedButton(
                                onPressed: pickDate,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                      255,
                                      47,
                                      122,
                                      60), // Change the background color here
                                  foregroundColor: const Color.fromARGB(
                                      255,
                                      255,
                                      255,
                                      255), // Change the text color here
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        12), // Optional: rounded corners
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today),
                                    const SizedBox(width: 7),
                                    const Text('Pick Date'),
                                  ],
                                ),
                              ),
                              // Pick Time Button (Right)
                              ElevatedButton(
                                onPressed: pickTime,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                      255,
                                      47,
                                      122,
                                      60), // Change the background color here
                                  foregroundColor:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        12), // Optional: rounded corners
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time),
                                    const SizedBox(width: 5),
                                    const Text('Pick Time'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Text(
                '+ Create a Task',
                style: GoogleFonts.quicksand(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
