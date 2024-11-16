import 'package:flutter/material.dart';
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
        title: const Text('TO-DO LIST', style: TextStyle(fontSize: 26)),
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

                    return ListTile(
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
                          decoration:
                              taskCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Text(
                          '${DateFormat.yMMMd().format(taskDate)} at $taskTime'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('tasks')
                              .doc(task['id'])
                              .delete();
                        },
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
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
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
                          TextField(
                            controller: nameController,
                            decoration:
                                const InputDecoration(labelText: 'Task Name'),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: notesController,
                            decoration:
                                const InputDecoration(labelText: 'Notes'),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: pickDate,
                                child: const Text('Pick Date'),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: pickTime,
                                child: const Text('Pick Time'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: saveTask,
                            child: const Text('Save Task'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: const Text('+ Create Task'),
            ),
          ),
        ],
      ),
    );
  }
}
