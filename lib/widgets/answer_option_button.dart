import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// A button widget for displaying answer options in the math lesson screen
class AnswerOptionButton extends StatelessWidget {
  /// The numeric value to display on the button
  final int value;
  
  /// Whether this button is currently selected
  final bool isSelected;
  
  /// Whether this button represents the correct answer (and should be highlighted)
  final bool isCorrect;
  
  /// Callback function when the button is tapped
  final VoidCallback? onTap;

  const AnswerOptionButton({
    Key? key,
    required this.value,
    this.isSelected = false,
    this.isCorrect = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the button's appearance based on its state
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    
    if (isCorrect) {
      // Correct answer appearance
      backgroundColor = Colors.green[100]!;
      borderColor = Colors.green;
      textColor = Colors.green[800]!;
    } else if (isSelected) {
      // Selected but incorrect answer appearance
      backgroundColor = Colors.red[100]!;
      borderColor = Colors.red;
      textColor = Colors.red[800]!;
    } else {
      // Default appearance
      backgroundColor = Colors.white;
      borderColor = SplashConstants.secondaryAccent;
      textColor = SplashConstants.textColor;
    }
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: 3,
          ),
          boxShadow: [
            if (isSelected || isCorrect)
              BoxShadow(
                color: borderColor.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Center(
          child: Text(
            value.toString(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
