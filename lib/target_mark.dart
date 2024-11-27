import 'package:flutter/material.dart';
import 'second_target_mark.dart'; // Import the second_target_mark.dart file

void main() {
  runApp(const MaterialApp(
    home: TargetMarkCalculator(),
  ));
}

class TargetMarkCalculator extends StatefulWidget {
  const TargetMarkCalculator({Key? key}) : super(key: key);

  @override
  State<TargetMarkCalculator> createState() => _TargetMarkCalculatorState();
}

class _TargetMarkCalculatorState extends State<TargetMarkCalculator> {
  final TextEditingController _creditsController = TextEditingController();
  final TextEditingController _gpaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        centerTitle: true, // Center the app bar title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildInputBox(
              'Enter current credits',
              'Enter credit hours',
              _creditsController,
            ),
            const SizedBox(height: 20),
            _buildInputBox(
              'Enter current GPA',
              'Enter GPA',
              _gpaController,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildButton(
                  'CLEAR',
                  Colors.black,
                  onPressed: () {
                    _creditsController.clear();
                    _gpaController.clear();
                  },
                ),
                _buildButton(
                  'NEXT',
                  Colors.black,
                  onPressed: () {
                    // Retrieve inputs from the text fields
                    final int currentCredits = int.tryParse(_creditsController.text) ?? 0;
                    final double currentGpa = double.tryParse(_gpaController.text) ?? 0.0;

                    // Navigate to SecondTargetMarkCalculator with user inputs
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SecondTargetMarkCalculator(
                          currentCredits: currentCredits,
                          currentGpa: currentGpa,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBox(
      String title, String hint, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Center-align text
        children: [
          Text(
            title,
            textAlign: TextAlign.center, // Center-align title
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: controller,
            textAlign: TextAlign.center, // Center-align input text
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0, vertical: 8.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, Color color, {required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
