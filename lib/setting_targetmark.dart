import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: GradeSettingsPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class GradeSettingsPage extends StatefulWidget {
  const GradeSettingsPage({super.key});

  @override
  State<GradeSettingsPage> createState() => _GradeSettingsPageState();
}

class _GradeSettingsPageState extends State<GradeSettingsPage> {
  final Map<String, double> gradePoints = {
    'A+': 4.0,
    'A': 4.0,
    'A-': 3.67,
    'B+': 3.3,
    'B': 3.0,
    'B-': 2.67,
    'C+': 2.3,
    'C': 2.0,
    'C-': 1.67,
    'D+': 1.3,
    'D': 1.0,
    'D-': 0.67,
    'F': 0.0,
  };

  final Map<String, TextEditingController> controllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize controllers with default values
    gradePoints.forEach((key, value) {
      controllers[key] = TextEditingController(text: value.toString());
    });
  }

  @override
  void dispose() {
    // Dispose controllers
    controllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Create a list of grade keys excluding 'F'
    final List<String> gradeList = List.from(gradePoints.keys)..remove('F');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.lightBlue[100],
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Points',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Grid for all grades except 'F'
              GridView.builder(
                shrinkWrap: true,
                itemCount: gradeList.length,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 80,
                ),
                itemBuilder: (context, index) {
                  final grade = gradeList[index];
                  return Column(
                    children: [
                      Container(
                        width: 70,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: grade == 'F'
                                ? Colors.red
                                : (grade == 'A+' || grade == 'A' || grade == 'A-')
                                    ? Colors.green
                                    : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          grade,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: grade == 'F'
                                ? Colors.red
                                : (grade == 'A+' || grade == 'A' || grade == 'A-')
                                    ? Colors.green
                                    : Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: 70,
                        child: TextField(
                          controller: controllers[grade],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                            border: UnderlineInputBorder(),
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          onSubmitted: (value) {
                            setState(() {
                              final newValue = double.tryParse(value);
                              if (newValue != null) {
                                gradePoints[grade] = newValue;
                              } else {
                                controllers[grade]!.text =
                                    gradePoints[grade]!.toString();
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              // Add the 'F' grade, aligning it in the center of the last row
              GridView.builder(
                shrinkWrap: true,
                itemCount: 1,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  mainAxisExtent: 80,
                ),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      // The 'F' grade is placed in the center
                      Container(
                        width: 70,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                        child: const Text(
                          'F',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: 70,
                        child: TextField(
                          controller: controllers['F'],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                            border: UnderlineInputBorder(),
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          onSubmitted: (value) {
                            setState(() {
                              final newValue = double.tryParse(value);
                              if (newValue != null) {
                                gradePoints['F'] = newValue;
                              } else {
                                controllers['F']!.text = gradePoints['F']!.toString();
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
