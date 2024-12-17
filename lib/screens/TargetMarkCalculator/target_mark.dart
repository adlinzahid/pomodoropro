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
  padding: const EdgeInsets.all(30.0),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Spacer(), // Push the boxes down from the top
      _buildInputBox(
        'Enter current credits',
        'Enter credit hours',
        _creditsController,
        _isCreditsValid,
      ),
      const SizedBox(height: 40), // Spacing between the two blue boxes
      _buildInputBox(
        'Enter current Cumulative GPA',
        'Enter Cumulative GPA',
        _cumulativeGpaController,
        _isCumulativeGpaValid,
      ),
      Spacer(), // Pushes the buttons to the bottom of the page
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
      color: const Color.fromARGB(255, 167, 224, 250),
      borderRadius: BorderRadius.circular(12.0),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.8), 
          blurRadius: 6,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Center the title and input field
      children: [
        Text(
          title,
          textAlign: TextAlign.center, // Center the title text
       style: GoogleFonts.poppins( // Apply custom font here
            fontSize: 16,  // Set the font size
            fontWeight: FontWeight.w600,  // Set font weight
            color: Colors.black,  // Change font color (optional)
          ),
        ),
        const SizedBox(height: 20.0), // Adjust space between title and input field
        
        
        
        
        TextField(
          controller: controller,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: const Color.fromARGB(255, 167, 161, 161), // Faded gray color for hint text
              fontSize: 14, // Adjust font size of the placeholder text
            ),
            filled: true,
            fillColor: Colors.white,
            
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10.0, //blue box style
              vertical: 8.0,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: isValid ? Colors.transparent : Colors.red,
                width: 2.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Colors.blue,
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Colors.red,
                width: 2.0,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                color: Colors.red,
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
      child: Text(//button text 
        label,
       style: GoogleFonts.poppins(  // You can use any Google font here
        color: Colors.white,         // Set the text color
        fontSize: 14,                // Adjust the font size
        fontWeight: FontWeight.bold, // Set the font weight (e.g., bold)
      ),
      ),
    );
  }
}
