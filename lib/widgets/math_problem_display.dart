import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// A widget that displays a math problem with visual representation
class MathProblemDisplay extends StatefulWidget {
  /// The first number in the math problem
  final int firstNumber;
  
  /// The second number in the math problem
  final int secondNumber;
  
  /// The operation symbol ('+', '-', '×', '÷')
  final String operation;
  
  /// The type of object to display (e.g., 'apple', 'banana')
  final String objectType;
  
  /// Whether to show counting hints
  final bool showHint;

  const MathProblemDisplay({
    Key? key,
    required this.firstNumber,
    required this.secondNumber,
    required this.operation,
    required this.objectType,
    this.showHint = false,
  }) : super(key: key);

  @override
  State<MathProblemDisplay> createState() => _MathProblemDisplayState();
}

class _MathProblemDisplayState extends State<MathProblemDisplay>
    with SingleTickerProviderStateMixin {
  // Animation controller for hint effect
  late AnimationController _hintController;
  late Animation<double> _hintAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize hint animation controller
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _hintAnimation = CurvedAnimation(
      parent: _hintController,
      curve: Curves.easeInOut,
    );
    
    // Start hint animation if hint is enabled
    if (widget.showHint) {
      _hintController.repeat(reverse: true);
    }
  }
  
  @override
  void didUpdateWidget(MathProblemDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update hint animation when hint state changes
    if (oldWidget.showHint != widget.showHint) {
      if (widget.showHint) {
        _hintController.repeat(reverse: true);
      } else {
        _hintController.stop();
        _hintController.reset();
      }
    }
  }
  
  @override
  void dispose() {
    _hintController.dispose();
    super.dispose();
  }
  
  /// Get the appropriate emoji for the object type
  String _getObjectEmoji() {
    switch (widget.objectType.toLowerCase()) {
      case 'apple':
        return '🍎';
      case 'banana':
        return '🍌';
      case 'ball':
        return '⚽';
      case 'star':
        return '⭐';
      default:
        return '🍎'; // Default to apple
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Equation display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // First number
              _buildNumberWithObjects(widget.firstNumber),
              
              // Operation symbol
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.operation,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: SplashConstants.textColor,
                  ),
                ),
              ),
              
              // Second number
              _buildNumberWithObjects(widget.secondNumber),
              
              // Equals sign
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '=',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: SplashConstants.textColor,
                  ),
                ),
              ),
              
              // Question mark (for the answer)
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: widget.showHint
                      ? SplashConstants.primaryAccent.withOpacity(0.3)
                      : SplashConstants.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: SplashConstants.primaryAccent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: AnimatedBuilder(
                    animation: _hintAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: widget.showHint
                            ? 1.0 + (_hintAnimation.value * 0.2)
                            : 1.0,
                        child: child,
                      );
                    },
                    child: const Text(
                      '?',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: SplashConstants.textColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build a number with object emojis next to it
  Widget _buildNumberWithObjects(int number) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Number
        Text(
          number.toString(),
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: SplashConstants.textColor,
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Object emoji
        Text(
          _getObjectEmoji(),
          style: const TextStyle(
            fontSize: 30,
          ),
        ),
      ],
    );
  }
}
