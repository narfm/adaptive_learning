import 'package:flutter/material.dart';
import 'dart:math';

/// A widget that displays interactive objects for counting in math problems
class InteractiveCountingArea extends StatefulWidget {
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

  const InteractiveCountingArea({
    Key? key,
    required this.firstNumber,
    required this.secondNumber,
    required this.operation,
    required this.objectType,
    this.showHint = false,
  }) : super(key: key);

  @override
  State<InteractiveCountingArea> createState() => _InteractiveCountingAreaState();
}

class _InteractiveCountingAreaState extends State<InteractiveCountingArea>
    with TickerProviderStateMixin {
  // List to track which objects have been tapped
  List<bool> _tappedObjects = [];
  
  // Animation controllers for each object
  List<AnimationController> _objectControllers = [];
  
  // Animations for each object
  List<Animation<double>> _objectAnimations = [];
  
  // Positions for each object
  List<Offset> _objectPositions = [];
  
  // Total number of objects to display
  int _totalObjects = 0;
  
  // Number of objects in the first group
  int _firstGroupCount = 0;
  
  // Number of objects in the second group (for addition/multiplication)
  int _secondGroupCount = 0;
  
  // Current hint index
  int _hintIndex = -1;
  
  // Timer for hint animation
  late AnimationController _hintController;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize hint controller
    _hintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    // Initialize the object counts based on the operation
    _setupObjectCounts();
    
    // Initialize tapped state for all objects
    _tappedObjects = List.generate(_totalObjects, (index) => false);
    
    // Create animation controllers for each object
    _objectControllers = List.generate(
      _totalObjects,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );
    
    // Create animations for each object
    _objectAnimations = List.generate(
      _totalObjects,
      (index) => CurvedAnimation(
        parent: _objectControllers[index],
        curve: Curves.elasticOut,
      ),
    );
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Generate positions for objects after dependencies are available
    if (_objectPositions.isEmpty && _totalObjects > 0) {
      _generateObjectPositions();
      
      // Start entry animations with staggered delay
      for (int i = 0; i < _totalObjects; i++) {
        Future.delayed(
          Duration(milliseconds: 100 * i),
          () {
            if (mounted) {
              _objectControllers[i].forward();
            }
          },
        );
      }
    }
  }
  
  @override
  void didUpdateWidget(InteractiveCountingArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If the problem changed, reset the objects
    if (oldWidget.firstNumber != widget.firstNumber ||
        oldWidget.secondNumber != widget.secondNumber ||
        oldWidget.operation != widget.operation ||
        oldWidget.objectType != widget.objectType) {
      
      // Dispose old controllers
      for (var controller in _objectControllers) {
        controller.dispose();
      }
      
      // Reset state
      _objectControllers = [];
      _objectAnimations = [];
      _tappedObjects = [];
      
      // Set up new objects
      _setupObjects();
    }
    
    // If hint state changed, update hint animation
    if (oldWidget.showHint != widget.showHint) {
      if (widget.showHint) {
        _startHintAnimation();
      } else {
        _hintIndex = -1;
        _hintController.reset();
      }
    }
  }
  
  @override
  void dispose() {
    // Dispose all animation controllers
    for (var controller in _objectControllers) {
      controller.dispose();
    }
    _hintController.dispose();
    super.dispose();
  }
  
  /// Set up the object counts based on the operation (without accessing context)
  void _setupObjectCounts() {
    switch (widget.operation) {
      case '+':
        _setupAdditionObjects();
        break;
      case '-':
        _setupSubtractionObjects();
        break;
      case '×':
        _setupMultiplicationObjects();
        break;
      case '÷':
        _setupDivisionObjects();
        break;
      default:
        _setupAdditionObjects(); // Default to addition
    }
  }
  
  /// Set up the objects based on the operation
  void _setupObjects() {
    // Set up object counts
    _setupObjectCounts();
    
    // Initialize tapped state for all objects
    _tappedObjects = List.generate(_totalObjects, (index) => false);
    
    // Create animation controllers for each object
    _objectControllers = List.generate(
      _totalObjects,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
      ),
    );
    
    // Create animations for each object
    _objectAnimations = List.generate(
      _totalObjects,
      (index) => CurvedAnimation(
        parent: _objectControllers[index],
        curve: Curves.elasticOut,
      ),
    );
    
    // Generate random positions for each object
    _generateObjectPositions();
    
    // Start entry animations with staggered delay
    for (int i = 0; i < _totalObjects; i++) {
      Future.delayed(
        Duration(milliseconds: 100 * i),
        () {
          if (mounted) {
            _objectControllers[i].forward();
          }
        },
      );
    }
  }
  
  /// Set up objects for addition
  void _setupAdditionObjects() {
    _firstGroupCount = widget.firstNumber;
    _secondGroupCount = widget.secondNumber;
    _totalObjects = _firstGroupCount + _secondGroupCount;
  }
  
  /// Set up objects for subtraction
  void _setupSubtractionObjects() {
    _firstGroupCount = widget.firstNumber;
    _secondGroupCount = 0; // No second group for subtraction
    _totalObjects = _firstGroupCount;
  }
  
  /// Set up objects for multiplication
  void _setupMultiplicationObjects() {
    _firstGroupCount = widget.firstNumber * widget.secondNumber;
    _secondGroupCount = 0; // No separate second group for multiplication
    _totalObjects = _firstGroupCount;
  }
  
  /// Set up objects for division
  void _setupDivisionObjects() {
    _firstGroupCount = widget.firstNumber;
    _secondGroupCount = 0; // No second group for division
    _totalObjects = _firstGroupCount;
  }
  
  /// Generate random positions for each object
  void _generateObjectPositions() {
    final random = Random();
    _objectPositions = [];
    
    // Calculate available space
    final double areaWidth = MediaQuery.of(context).size.width - 80; // Padding
    final double areaHeight = 200; // Fixed height for the area
    
    // Object size (approximate)
    const double objectSize = 50;
    
    // Calculate grid dimensions
    final int cols = max(2, min(6, (_totalObjects / 2).ceil()));
    final int rows = (_totalObjects / cols).ceil();
    
    // Calculate cell size
    final double cellWidth = areaWidth / cols;
    final double cellHeight = areaHeight / rows;
    
    // Generate positions
    for (int i = 0; i < _totalObjects; i++) {
      // Calculate grid position
      final int row = i ~/ cols;
      final int col = i % cols;
      
      // Calculate base position
      double x = col * cellWidth + cellWidth / 2 - objectSize / 2;
      double y = row * cellHeight + cellHeight / 2 - objectSize / 2;
      
      // Add small random offset for natural look
      x += random.nextDouble() * 10 - 5;
      y += random.nextDouble() * 10 - 5;
      
      // Add position
      _objectPositions.add(Offset(x, y));
    }
  }
  
  /// Handle when an object is tapped
  void _handleObjectTap(int index) {
    setState(() {
      _tappedObjects[index] = !_tappedObjects[index];
    });
    
    // Play tap animation
    _objectControllers[index].reset();
    _objectControllers[index].forward();
  }
  
  /// Start the hint animation
  void _startHintAnimation() {
    if (!widget.showHint) return;
    
    _hintIndex = 0;
    _hintController.reset();
    _hintController.forward();
    
    // Set up repeating hint animation
    _hintController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _hintController.reset();
        
        setState(() {
          _hintIndex = (_hintIndex + 1) % _totalObjects;
        });
        
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && widget.showHint) {
            _hintController.forward();
          }
        });
      }
    });
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
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue[200]!,
          width: 2,
        ),
      ),
      child: Stack(
        children: _buildObjectWidgets(),
      ),
    );
  }
  
  /// Build the list of object widgets
  List<Widget> _buildObjectWidgets() {
    List<Widget> widgets = [];
    
    for (int i = 0; i < _totalObjects; i++) {
      // Determine if this object is in the first or second group
      final bool isInFirstGroup = i < _firstGroupCount;
      
      // For subtraction, mark objects that should be removed
      bool shouldBeRemoved = false;
      if (widget.operation == '-') {
        if (i >= (_firstGroupCount - widget.secondNumber)) {
          shouldBeRemoved = true;
        }
      }
      
      widgets.add(
        Positioned(
          left: _objectPositions[i].dx,
          top: _objectPositions[i].dy,
          child: ScaleTransition(
            scale: _objectAnimations[i],
            child: GestureDetector(
              onTap: () => _handleObjectTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                transform: _tappedObjects[i]
                    ? (Matrix4.identity()..scale(1.2))
                    : Matrix4.identity(),
                child: Stack(
                  children: [
                    // Object emoji
                    Text(
                      _getObjectEmoji(),
                      style: TextStyle(
                        fontSize: 40,
                        color: shouldBeRemoved
                            ? Colors.red.withOpacity(0.7)
                            : null,
                      ),
                    ),
                    
                    // Hint indicator
                    if (widget.showHint && i == _hintIndex)
                      Positioned.fill(
                        child: FadeTransition(
                          opacity: _hintController,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.yellow,
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                      ),
                    
                    // Tap indicator
                    if (_tappedObjects[i])
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return widgets;
  }
}
