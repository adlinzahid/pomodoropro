import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:developer';

import 'package:pomodororpo/services/tasksdata.dart';

class Displaystreak extends StatelessWidget {
  Displaystreak({super.key});
  final Tasksdata tasksdata = Tasksdata();

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                color: Colors.black.withAlpha(100),
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: FutureBuilder<int>(
              future: getUserStreak(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(), // Show a loading indicator
                      const SizedBox(height: 10.0),
                      Text(
                        'Loading streak...',
                        style: GoogleFonts.quicksand(
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 50.0),
                      const SizedBox(height: 10.0),
                      Text(
                        'Error loading streak',
                        style: GoogleFonts.quicksand(
                          color: Colors.white,
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  );
                } else if (snapshot.hasData) {
                  int streak = snapshot.data!; // Get the streak value
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$streak Days',
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
                  );
                } else {
                  return Column(
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
                        Text('Current Streak',
                            style: GoogleFonts.quicksand(
                              color: Colors.white,
                              fontSize: 30.0,
                            ))
                      ]);
                }
              }),
        ),
      ),
    );
  }

  Future<int> getUserStreak() async {
    return await tasksdata.getUserStreak();
  }
}
