import 'package:flutter/material.dart';
import 'setting_targetmark.dart'; // Import target mark settings page
import 'gpa_calculator.dart'; // Import GPA calculator page

void main() {
  runApp(const MaterialApp(
    home: SecondTargetMarkCalculator(),
    debugShowCheckedModeBanner: false,
  ));
}

class SecondTargetMarkCalculator extends StatefulWidget {
  final int currentCredits;
  final double currentGpa;

  const SecondTargetMarkCalculator({
    Key? key,
    this.currentCredits = 20, // Example data from the previous page
    this.currentGpa = 3.81, // Example data from the previous page
  }) : super(key: key);

  @override
  State<SecondTargetMarkCalculator> createState() =>
      _SecondTargetMarkCalculatorState();
}

class _SecondTargetMarkCalculatorState
    extends State<SecondTargetMarkCalculator> {
  final List<Map<String, dynamic>> _courses = []; // List to hold course info

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Target Mark Calculator',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GradeSettingsPage()),
              );
            },
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Current Credits and GPA Box
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCurrentStat(
                      'CREDITS', widget.currentCredits.toString()),
                  _buildCurrentStat(
                      'CGPA', widget.currentGpa.toStringAsFixed(2)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Dynamic Course Rows
            Expanded(
              child: ListView.builder(
                itemCount: _courses.length,
                itemBuilder: (context, index) {
                  return _buildCourseRow(index);
                },
              ),
            ),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildIconButton(
                  icon: Icons.add,
                  label: 'ADD',
                  color: Colors.green,
                  onPressed: _addCourseRow,
                ),
                _buildIconButton(
                  icon: Icons.calculate,
                  label: 'CALCULATE',
                  color: Colors.black,
                  onPressed: _calculateTargetGpa,
                ),
                _buildIconButton(
                  icon: Icons.delete,
                  label: 'DELETE',
                  color: Colors.red,
                  onPressed: _showDeleteConfirmation,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildCourseRow(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          // Course Name
          Expanded(
            flex: 3,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter course name',
                filled: true,
                fillColor: Colors.blue[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                _courses[index]['name'] = value;
              },
            ),
          ),
          const SizedBox(width: 8),
          // Grade Dropdown
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: _courses[index]['grade'],
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.blue[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              hint: const Text('Grade'),
              items: [
                'A+',
                'A',
                'A-',
                'B+',
                'B',
                'B-',
                'C+',
                'C',
                'C-',
                'D+',
                'D',
                'D-',
                'F'
              ]
                  .map((grade) => DropdownMenuItem(
                        value: grade,
                        child: Text(grade),
                      ))
                  .toList(),
              onChanged: (value) {
                _courses[index]['grade'] = value;
              },
            ),
          ),
          const SizedBox(width: 8),
          // Credits
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Credits',
                filled: true,
                fillColor: Colors.blue[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _courses[index]['credits'] = int.tryParse(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  void _addCourseRow() {
    setState(() {
      _courses.add({'name': '', 'grade': null, 'credits': null});
    });
  }

  void _showDeleteConfirmation() {
    if (_courses.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content:
              const Text('Are you sure you want to delete the last course?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (_courses.isNotEmpty) _courses.removeLast();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Course deleted!')),
                );
              },
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );
  }

  void _calculateTargetGpa() {
    double targetGpa = GPACalculator.calculateGpa(
      currentCredits: widget.currentCredits,
      currentGpa: widget.currentGpa,
      courses: _courses,
    );

    double cumulativeGpa = GPACalculator.calculateCumulativeGpa(
      currentCredits: widget.currentCredits,
      currentGpa: widget.currentGpa,
      targetGpa: targetGpa,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TargetGpaResultPage(
          courses: _courses,
          targetGpa: targetGpa,
          currentGpa: widget.currentGpa,
          cumulativeGpa: cumulativeGpa,
        ),
      ),
    );
  }
}

class GPACalculator {
  static double getGradePoint(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return 4.0;
      case 'A-':
        return 3.7;
      case 'B+':
        return 3.3;
      case 'B':
        return 3.0;
      case 'B-':
        return 2.7;
      case 'C+':
        return 2.3;
      case 'C':
        return 2.0;
      case 'C-':
        return 1.7;
      case 'D+':
        return 1.3;
      case 'D':
        return 1.0;
      case 'F':
        return 0.0;
      default:
        return 0.0;
    }
  }

  static double calculateGpa({
    required int currentCredits,
    required double currentGpa,
    required List<Map<String, dynamic>> courses,
  }) {
    double currentGradePoints = currentCredits * currentGpa;
    double totalGradePoints = currentGradePoints;
    int totalCredits = currentCredits;

    for (var course in courses) {
      if (course['grade'] != null && course['credits'] != null) {
        double gradePoint = getGradePoint(course['grade']);
        int credits = course['credits'];
        totalGradePoints += gradePoint * credits;
        totalCredits += credits;
      }
    }
    return totalGradePoints / totalCredits;
  }

  static double calculateCumulativeGpa({
    required int currentCredits,
    required double currentGpa,
    required double targetGpa,
  }) {
    double currentGradePoints = currentCredits * currentGpa;
    double targetGradePoints = targetGpa * currentCredits;

    return (currentGradePoints + targetGradePoints) /
        (currentCredits * 2); // Modify weight logic as needed
  }
}
