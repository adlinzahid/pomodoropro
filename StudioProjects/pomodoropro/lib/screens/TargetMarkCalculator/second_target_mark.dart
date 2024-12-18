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
    super.key,
    this.currentCredits = 20, // Example data from the previous page
    this.currentGpa = 3.81, // Example data from the previous page
  });

  @override
  State<SecondTargetMarkCalculator> createState() =>
      _SecondTargetMarkCalculatorState();
}

class _SecondTargetMarkCalculatorState
    extends State<SecondTargetMarkCalculator> {
  // Initialize with three course input boxes
  final List<Map<String, dynamic>> _courses = [
    {'name': '', 'grade': null, 'credits': null},
    {'name': '', 'grade': null, 'credits': null},
    {'name': '', 'grade': null, 'credits': null},
  ]; // List to hold course info

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
                    color: Colors.grey.withValues(alpha: 50),
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
    if (_courses.isEmpty) {
      // Show a SnackBar to alert the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one course before calculating!'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Stop further execution
    }

    // Calculate the target GPA
    double targetGpa = GPACalculator.calculateGpa(
      courses: _courses,
    );

    // Calculate the cumulative GPA
    double cumulativeGpa = GPACalculator.calculateCumulativeGpa(
      currentGpa: widget.currentGpa,
      targetGpa: targetGpa,
    );

    // Navigate to the result page
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
    required List<Map<String, dynamic>> courses,
  }) {
    double totalGradePoints = 0;
    int totalCredits = 0;

    for (var course in courses) {
      if (course['grade'] != null && course['credits'] != null) {
        double gradePoint = getGradePoint(course['grade']);
        int credits = course['credits'];
        totalGradePoints += gradePoint * credits;
        totalCredits += credits;
      }
    }

    return totalCredits > 0 ? totalGradePoints / totalCredits : 0.0;
  }

  static double calculateCumulativeGpa({
    required double currentGpa,
    required double targetGpa,
  }) {
    // Assume equal credits for current GPA and target GPA
    return (currentGpa + targetGpa) / 2;
  }
}
