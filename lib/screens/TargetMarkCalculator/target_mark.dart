import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'second_target_mark.dart'; // Import the second_target_mark.dart file

void main() {
  runApp(const MaterialApp(
    home: TargetMarkCalculator(),
  ));
}

class TargetMarkCalculator extends StatefulWidget {
  const TargetMarkCalculator({super.key});

  @override
  State<TargetMarkCalculator> createState() => _TargetMarkCalculatorState();
}

class _TargetMarkCalculatorState extends State<TargetMarkCalculator> {
  final TextEditingController _creditsController = TextEditingController();
  final TextEditingController _cumulativeGpaController = TextEditingController();

  bool _isCreditsValid = true;
  bool _isCumulativeGpaValid = true;

  void _validateInputs() {
    setState(() {
      _isCreditsValid = int.tryParse(_creditsController.text) != null &&
          _creditsController.text.isNotEmpty;
      _isCumulativeGpaValid = double.tryParse(_cumulativeGpaController.text) != null &&
          _cumulativeGpaController.text.isNotEmpty &&
          double.parse(_cumulativeGpaController.text) >= 0 &&
          double.parse(_cumulativeGpaController.text) <= 4.0;
    });

    if (_isCreditsValid && _isCumulativeGpaValid) {
      // Navigate to SecondTargetMarkCalculator if inputs are valid
      final int currentCredits = int.parse(_creditsController.text);
      final double currentCumulativeGpa = double.parse(_cumulativeGpaController.text);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SecondTargetMarkCalculator(
            currentCredits: currentCredits,
            currentGpa: currentCumulativeGpa,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Target Mark Calculator',
          style: GoogleFonts.quicksand(
            fontSize: 25, // Set the font size
            fontWeight: FontWeight.bold, // Set the font weight
          ),
        ),
        centerTitle: true,
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
              _isCreditsValid,
            ),
            const SizedBox(height: 20),
            _buildInputBox(
              'Enter current Cumulative GPA',
              'Enter current Cumulative GPA',
              _cumulativeGpaController,
              _isCumulativeGpaValid,
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
                    _cumulativeGpaController.clear();
                    setState(() {
                      _isCreditsValid = true;
                      _isCumulativeGpaValid = true;
                    });
                  },
                ),
                _buildButton(
                  'NEXT',
                  Colors.black,
                  onPressed: _validateInputs,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBox(
    String title,
    String hint,
    TextEditingController controller,
    bool isValid,
  ) {
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: controller,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: isValid ? Colors.transparent : Colors.red,
                  width: 2.0,
                ),
              ),
              errorText: !isValid ? 'Invalid input' : null,
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, Color color,
      {required VoidCallback onPressed}) {
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
