import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/constants.dart';

/// A widget that displays animated examples of math operations
class ExampleAnimationDisplay extends StatefulWidget {
  /// The first number in the math example
  final int firstNumber;
  
  /// The second number in the math example
  final int secondNumber;
  
  /// The operation symbol ('+', '-', '×', '÷')
  final String operation;
  
  /// The type of object to display (e.g., 'apple', 'banana')
  final String objectType;
  
  /// The current step in the animation sequence
  final int animationStep;
  
  /// Callback when an animation step completes
  final Function(int)? onStepComplete;

  const ExampleAnimationDisplay({
    Key? key,
    required this.firstNumber,
    required this.secondNumber,
    required this.operation,
    required this.objectType,
    required this.animationStep,
    this.onStepComplete,
  }) : super(key: key);

  @override
  State<ExampleAnimationDisplay> createState() => _ExampleAnimationDisplayState();
}

class _ExampleAnimationDisplayState extends State<ExampleAnimationDisplay>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _firstGroupController;
  late AnimationController _secondGroupController;
  late AnimationController _operationController;
  late AnimationController _resultController;
  
  // Animations
  late Animation<double> _firstGroupAnimation;
  late Animation<double> _secondGroupAnimation;
  late Animation<double> _operationAnimation;
  late Animation<double> _resultAnimation;
  
  // Object positions
  List<Offset> _firstGroupPositions = [];
  List<Offset> _secondGroupPositions = [];
  List<Offset> _resultPositions = [];
  
  // Result value
  int _result = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Calculate result based on operation
    _calculateResult();
    
    // Initialize animation controllers
    _firstGroupController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _secondGroupController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _operationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _resultController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Set up animations
    _firstGroupAnimation = CurvedAnimation(
      parent: _firstGroupController,
      curve: Curves.easeInOut,
    );
    
    _secondGroupAnimation = CurvedAnimation(
      parent: _secondGroupController,
      curve: Curves.easeInOut,
    );
    
    _operationAnimation = CurvedAnimation(
      parent: _operationController,
      curve: Curves.easeInOut,
    );
    
    _resultAnimation = CurvedAnimation(
      parent: _resultController,
      curve: Curves.elasticOut,
    );
    
    // Set up animation listeners
    _firstGroupController.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.animationStep == 0) {
        widget.onStepComplete?.call(0);
      }
    });
    
    _secondGroupController.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.animationStep == 1) {
        widget.onStepComplete?.call(1);
      }
    });
    
    _operationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.animationStep == 2) {
        widget.onStepComplete?.call(2);
      }
    });
    
    _resultController.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.animationStep == 3) {
        widget.onStepComplete?.call(3);
      }
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Generate object positions after layout is available
    _generateObjectPositions();
  }
  
  @override
  void didUpdateWidget(ExampleAnimationDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If the numbers or operation changed, recalculate the result
    if (oldWidget.firstNumber != widget.firstNumber ||
        oldWidget.secondNumber != widget.secondNumber ||
        oldWidget.operation != widget.operation) {
      _calculateResult();
      _generateObjectPositions();
    }
    
    // If the animation step changed, play the appropriate animation
    if (oldWidget.animationStep != widget.animationStep) {
      _playAnimationForStep(widget.animationStep);
    }
  }
  
  @override
  void dispose() {
    _firstGroupController.dispose();
    _secondGroupController.dispose();
    _operationController.dispose();
    _resultController.dispose();
    super.dispose();
  }
  
  /// Calculate the result based on the operation
  void _calculateResult() {
    switch (widget.operation) {
      case '+':
        _result = widget.firstNumber + widget.secondNumber;
        break;
      case '-':
        _result = widget.firstNumber - widget.secondNumber;
        break;
      case '×':
        _result = widget.firstNumber * widget.secondNumber;
        break;
      case '÷':
        _result = widget.firstNumber ~/ widget.secondNumber;
        break;
      default:
        _result = 0;
    }
  }
  
  /// Generate positions for the objects
  void _generateObjectPositions() {
    final random = math.Random();
    
    // Clear previous positions
    _firstGroupPositions = [];
    _secondGroupPositions = [];
    _resultPositions = [];
    
    // Calculate available space
    final double areaWidth = MediaQuery.of(context).size.width - 80;
    final double areaHeight = 200;
    
    // Object size
    const double objectSize = 50;
    
    // Generate positions for first group
    for (int i = 0; i < widget.firstNumber; i++) {
      double x = 20 + (i % 5) * (objectSize + 10);
      double y = 20 + (i ~/ 5) * (objectSize + 10);
      
      // Add small random offset
      x += random.nextDouble() * 5 - 2.5;
      y += random.nextDouble() * 5 - 2.5;
      
      _firstGroupPositions.add(Offset(x, y));
    }
    
    // Generate positions for second group
    for (int i = 0; i < widget.secondNumber; i++) {
      double x = areaWidth / 2 + 20 + (i % 5) * (objectSize + 10);
      double y = 20 + (i ~/ 5) * (objectSize + 10);
      
      // Add small random offset
      x += random.nextDouble() * 5 - 2.5;
      y += random.nextDouble() * 5 - 2.5;
      
      _secondGroupPositions.add(Offset(x, y));
    }
    
    // Generate positions for result group
    int resultCount = 0;
    
    switch (widget.operation) {
      case '+':
        resultCount = _result;
        break;
      case '-':
        resultCount = _result;
        break;
      case '×':
        resultCount = _result;
        break;
      case '÷':
        resultCount = _result * widget.secondNumber; // Show the original count for division
        break;
      default:
        resultCount = 0;
    }
    
    for (int i = 0; i < resultCount; i++) {
      double x = 20 + (i % 10) * (objectSize + 5);
      double y = areaHeight / 2 + 20 + (i ~/ 10) * (objectSize + 5);
      
      // Add small random offset
      x += random.nextDouble() * 5 - 2.5;
      y += random.nextDouble() * 5 - 2.5;
      
      _resultPositions.add(Offset(x, y));
    }
  }
  
  /// Play the animation for the current step
  void _playAnimationForStep(int step) {
    switch (step) {
      case 0:
        // First group animation
        _firstGroupController.forward(from: 0);
        break;
      case 1:
        // Second group animation
        _secondGroupController.forward(from: 0);
        break;
      case 2:
        // Operation animation
        _operationController.forward(from: 0);
        break;
      case 3:
        // Result animation
        _resultController.forward(from: 0);
        break;
      default:
        break;
    }
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
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue[200]!,
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Equation display
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: _buildEquationDisplay(),
          ),
          
          // Objects display
          ..._buildFirstGroupObjects(),
          ..._buildSecondGroupObjects(),
          ..._buildResultObjects(),
          
          // Operation visualization
          if (widget.animationStep >= 2)
            _buildOperationVisualization(),
        ],
      ),
    );
  }
  
  /// Build the equation display
  Widget _buildEquationDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // First number
        FadeTransition(
          opacity: _firstGroupAnimation,
          child: Text(
            widget.firstNumber.toString(),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: SplashConstants.textColor,
            ),
          ),
        ),
        
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
        FadeTransition(
          opacity: _secondGroupAnimation,
          child: Text(
            widget.secondNumber.toString(),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: SplashConstants.textColor,
            ),
          ),
        ),
        
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
        
        // Result
        FadeTransition(
          opacity: _resultAnimation,
          child: ScaleTransition(
            scale: _resultAnimation,
            child: Text(
              widget.animationStep >= 3 ? _result.toString() : '?',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: widget.animationStep >= 3
                    ? Colors.green[700]
                    : SplashConstants.textColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  /// Build the first group of objects
  List<Widget> _buildFirstGroupObjects() {
    List<Widget> objects = [];
    
    for (int i = 0; i < widget.firstNumber; i++) {
      if (i < _firstGroupPositions.length) {
        objects.add(
          Positioned(
            left: _firstGroupPositions[i].dx,
            top: _firstGroupPositions[i].dy,
            child: FadeTransition(
              opacity: _firstGroupAnimation,
              child: ScaleTransition(
                scale: _firstGroupAnimation,
                child: Text(
                  _getObjectEmoji(),
                  style: const TextStyle(
                    fontSize: 40,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    
    return objects;
  }
  
  /// Build the second group of objects
  List<Widget> _buildSecondGroupObjects() {
    List<Widget> objects = [];
    
    if (widget.animationStep < 1) {
      return objects; // Don't show second group until step 1
    }
    
    for (int i = 0; i < widget.secondNumber; i++) {
      if (i < _secondGroupPositions.length) {
        objects.add(
          Positioned(
            left: _secondGroupPositions[i].dx,
            top: _secondGroupPositions[i].dy,
            child: FadeTransition(
              opacity: _secondGroupAnimation,
              child: ScaleTransition(
                scale: _secondGroupAnimation,
                child: Text(
                  _getObjectEmoji(),
                  style: const TextStyle(
                    fontSize: 40,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    
    return objects;
  }
  
  /// Build the result objects
  List<Widget> _buildResultObjects() {
    List<Widget> objects = [];
    
    if (widget.animationStep < 3) {
      return objects; // Don't show result until step 3
    }
    
    int resultCount = 0;
    
    switch (widget.operation) {
      case '+':
        resultCount = _result;
        break;
      case '-':
        resultCount = _result;
        break;
      case '×':
        resultCount = _result;
        break;
      case '÷':
        resultCount = _result;
        break;
      default:
        resultCount = 0;
    }
    
    for (int i = 0; i < resultCount; i++) {
      if (i < _resultPositions.length) {
        objects.add(
          Positioned(
            left: _resultPositions[i].dx,
            top: _resultPositions[i].dy,
            child: FadeTransition(
              opacity: _resultAnimation,
              child: ScaleTransition(
                scale: _resultAnimation,
                child: Text(
                  _getObjectEmoji(),
                  style: const TextStyle(
                    fontSize: 40,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    
    return objects;
  }
  
  /// Build the operation visualization
  Widget _buildOperationVisualization() {
    switch (widget.operation) {
      case '+':
        return _buildAdditionVisualization();
      case '-':
        return _buildSubtractionVisualization();
      case '×':
        return _buildMultiplicationVisualization();
      case '÷':
        return _buildDivisionVisualization();
      default:
        return const SizedBox.shrink();
    }
  }
  
  /// Build the addition visualization
  Widget _buildAdditionVisualization() {
    return FadeTransition(
      opacity: _operationAnimation,
      child: Center(
        child: Icon(
          Icons.add_circle,
          color: Colors.green.withOpacity(0.7),
          size: 80,
        ),
      ),
    );
  }
  
  /// Build the subtraction visualization
  Widget _buildSubtractionVisualization() {
    return FadeTransition(
      opacity: _operationAnimation,
      child: Center(
        child: Icon(
          Icons.remove_circle,
          color: Colors.red.withOpacity(0.7),
          size: 80,
        ),
      ),
    );
  }
  
  /// Build the multiplication visualization
  Widget _buildMultiplicationVisualization() {
    return FadeTransition(
      opacity: _operationAnimation,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            '×',
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
        ),
      ),
    );
  }
  
  /// Build the division visualization
  Widget _buildDivisionVisualization() {
    return FadeTransition(
      opacity: _operationAnimation,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            '÷',
            style: TextStyle(
              fontSize: 60,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }
}
