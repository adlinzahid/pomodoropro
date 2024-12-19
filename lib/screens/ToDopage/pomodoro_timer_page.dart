// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PomodoroTimerPage extends StatefulWidget {
  final String taskName;
  final String taskDateTime;

  const PomodoroTimerPage({
    super.key,
    required this.taskName,
    required this.taskDateTime,
  });

  @override
  State<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends State<PomodoroTimerPage> {
  int selectedMinutes = 0;
  int selectedSeconds = 0;
  late int remainingTime;
  Timer? timer;
  bool isRunning = false;

  @override
  void initState() {
    super.initState();
    remainingTime = (selectedMinutes * 60) + selectedSeconds;
  }

  String formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void startTimer() {
    if (!isRunning) {
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (remainingTime > 0) {
          setState(() {
            remainingTime--;
          });
        } else {
          timer.cancel();
          setState(() {
            isRunning = false;
          });
          _showCompletionDialog();
        }
      });
      setState(() {
        isRunning = true;
      });
    }
  }

  void pauseTimer() {
    if (isRunning) {
      timer?.cancel();
      setState(() {
        isRunning = false;
      });
    }
  }

  void resetTimer() {
    setState(() {
      remainingTime = (selectedMinutes * 60) + selectedSeconds;
      isRunning = false;
      timer?.cancel();
    });
  }

  void _showCompletionDialog() async {
    final AudioPlayer audioPlayer = AudioPlayer();
    try {
      // Play the completion sound
      await audioPlayer.play(AssetSource('sounds/timer_done.mp3'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }

    // Show the completion dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pomodoro Completed!'),
        content:
            const Text('Great job! Take a short break or start a new task.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTimePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Set Timer',
                style: GoogleFonts.quicksand(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Minutes Picker
                    Expanded(
                      child: ListWheelScrollView.useDelegate(
                        controller: FixedExtentScrollController(
                          initialItem: selectedMinutes,
                        ),
                        itemExtent: 40,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (value) {
                          setState(() {
                            selectedMinutes = value;
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) => Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          childCount: 60, // 0-59 minutes
                        ),
                      ),
                    ),
                    const Text(
                      ' : ',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    // Seconds Picker
                    Expanded(
                      child: ListWheelScrollView.useDelegate(
                        controller: FixedExtentScrollController(
                          initialItem: selectedSeconds,
                        ),
                        itemExtent: 40,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (value) {
                          setState(() {
                            selectedSeconds = value;
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) => Center(
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          childCount: 60, // 0-59 seconds
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    remainingTime = (selectedMinutes * 60) + selectedSeconds;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Set Timer'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Task details in a box
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                    255, 211, 245, 212), //shade color of task details
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.green.shade800, width: 2.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8.0,
                    offset: const Offset(4, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Task: ${widget.taskName}',
                    style: GoogleFonts.quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scheduled: ${widget.taskDateTime}',
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Timer display
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: _showTimePicker, // Function to open the time picker
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Circle background
                    CircleAvatar(
                      radius: 120.0,
                      backgroundColor: const Color.fromARGB(255, 18, 77, 19),
                    ),
                    // Text displayed in the center
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ignore: unrelated_type_equality_checks
                        if (remainingTime ==
                            Duration
                                .zero) // Display "Set Timer" if no time is set
                          const Text(
                            'Set Timer',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        else // Display the countdown timer if time is set
                          Text(
                            formatTime(remainingTime),
                            style: const TextStyle(
                              fontSize: 48.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Timer controls
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: isRunning ? pauseTimer : startTimer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    backgroundColor: Colors.green,
                  ),
                  child: Text(
                    isRunning ? 'Pause' : 'Start',
                    style: GoogleFonts.quicksand(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: resetTimer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    backgroundColor: Colors.red,
                  ),
                  child: Text(
                    'Reset',
                    style: GoogleFonts.quicksand(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
