import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../utils/audio_service.dart';
import '../utils/constants.dart';
import '../widgets/animated_mascot.dart';
import '../widgets/answer_option_button.dart';
import '../widgets/example_animation_display.dart';
import '../widgets/interactive_counting_area.dart';
import '../widgets/math_problem_display.dart';
import 'home_screen.dart';

/// A screen that presents basic math problems to young children (ages 4-7)
class BasicMathLessonScreen extends StatefulWidget {
  /// The type of math operation (addition, subtraction, etc.)
  final String operationType;
  
  /// The difficulty level (based on user profile)
  final String difficultyLevel;

  const BasicMathLessonScreen({
    Key? key,
    required this.operationType,
    required this.difficultyLevel,
  }) : super(key: key);

  @override
  State<BasicMathLessonScreen> createState() => _BasicMathLessonScreenState();
}

class _BasicMathLessonScreenState extends State<BasicMathLessonScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _mascotController;
  late AnimationController _problemAnimationController;
  late AnimationController _feedbackAnimationController;
  late AnimationController _idleTimeoutController;
  late AnimationController _exampleAnimationController;
  
  // Animations
  late Animation<double> _problemEntryAnimation;
  late Animation<double> _answerOptionsAnimation;
  late Animation<double> _exampleEntryAnimation;
  
  // Mascot state
  String _mascotState = AnimatedMascot.idle;
  
  // Problem state
  int _firstNumber = 1;
  int _secondNumber = 1;
  String _operation = '+';
  int _correctAnswer = 2;
  List<int> _answerOptions = [1, 2, 3, 4];
  int? _selectedAnswer;
  bool _isAnswerCorrect = false;
  bool _showFeedback = false;
  int _attemptCount = 0;
  bool _showHint = false;
  bool _problemCompleted = false;
  
  // Example mode state
  bool _isExampleMode = true; // Start with example mode
  int _exampleStep = 0; // Current step in the example animation
  bool _exampleCompleted = false;
  
  // Object visualization
  String _objectType = 'apple'; // Default object
  final List<String> _availableObjects = ['apple', 'banana', 'ball', 'star'];
  
  // User profile
  UserProfile? _userProfile;
  bool _isLoading = true;
  
  // Idle timeout
  Timer? _idleTimer;
  bool _isIdle = false;
  
  // Audio state
  bool _isAudioEnabled = true;
  
  // Audio service
  final AudioService _audioService = AudioService();
  
  @override
  void initState() {
    super.initState();
    
    // Initialize audio service
    _audioService.initialize();
    
    // Initialize animation controllers
    _mascotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _problemAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _feedbackAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _idleTimeoutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _exampleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    // Set up animations
    _problemEntryAnimation = CurvedAnimation(
      parent: _problemAnimationController,
      curve: Curves.easeInOut,
    );
    
    _answerOptionsAnimation = CurvedAnimation(
      parent: _problemAnimationController,
      curve: Interval(0.3, 1.0, curve: Curves.easeInOut),
    );
    
    _exampleEntryAnimation = CurvedAnimation(
      parent: _exampleAnimationController,
      curve: Curves.easeInOut,
    );
    
    // Load user profile
    _loadUserProfile();
    
    // Generate first problem
    _generateProblem();
    
    // Start in example mode
    _startExampleMode();
    
    // Set up idle timeout
    _resetIdleTimer();
  }

  @override
  void dispose() {
    _mascotController.dispose();
    _problemAnimationController.dispose();
    _feedbackAnimationController.dispose();
    _idleTimeoutController.dispose();
    _exampleAnimationController.dispose();
    _idleTimer?.cancel();
    _audioService.dispose();
    super.dispose();
  }
  
  /// Start the example mode animation sequence
  void _startExampleMode() {
    setState(() {
      _isExampleMode = true;
      _exampleStep = 0;
      _exampleCompleted = false;
      _mascotState = AnimatedMascot.thinking;
    });
    
    // Reset animation controllers
    _exampleAnimationController.reset();
    
    // Start the example animation sequence
    _playExampleAnimation();
  }
  
  /// Play the example animation sequence
  void _playExampleAnimation() {
    // Play different animations based on the operation type
    switch (_operation) {
      case '+':
        _playAdditionExample();
        break;
      case '-':
        _playSubtractionExample();
        break;
      case '×':
        _playMultiplicationExample();
        break;
      case '÷':
        _playDivisionExample();
        break;
      default:
        _playAdditionExample(); // Default to addition
    }
  }
  
  /// Play the addition example animation
  void _playAdditionExample() {
    // Step 1: Show first number
    setState(() {
      _exampleStep = 0;
      _mascotState = AnimatedMascot.thinking;
    });
    
    if (_isAudioEnabled) {
      _audioService.playSound('count');
    }
    
    _exampleAnimationController.forward().then((_) {
      // Step 2: Show second number
      setState(() {
        _exampleStep = 1;
      });
      
      if (_isAudioEnabled) {
        _audioService.playSound('count');
      }
      
      Future.delayed(const Duration(milliseconds: 1500), () {
        // Step 3: Show them combining
         setState(() {
          _exampleStep = 2;
        });
        
        if (_isAudioEnabled) {
          _audioService.playSound('combine');
        }
        
        Future.delayed(const Duration(milliseconds: 1500), () {
          // Step 4: Show result
          setState(() {
            _exampleStep = 3;
          });
          
          if (_isAudioEnabled) {
            _audioService.playSound('correct');
          }
          
          Future.delayed(const Duration(milliseconds: 2000), () {
            // Transition to problem mode
            setState(() {
              _isExampleMode = false;
              _exampleCompleted = true;
              _mascotState = AnimatedMascot.idle;
            });
            
            // Start problem animation
            _problemAnimationController.forward();
          });
        });
      });
    });
  }
  
  /// Play the subtraction example animation
  void _playSubtractionExample() {
    // Step 1: Show first number
    setState(() {
      _exampleStep = 0;
      _mascotState = AnimatedMascot.thinking;
    });
    
    if (_isAudioEnabled) {
      _audioService.playSound('count');
    }
    
    _exampleAnimationController.forward().then((_) {
      // Step 2: Show second number
      setState(() {
        _exampleStep = 1;
      });
      
      if (_isAudioEnabled) {
        _audioService.playSound('count');
      }
      
      Future.delayed(const Duration(milliseconds: 1500), () {
        // Step 3: Show them subtracting
        setState(() {
          _exampleStep = 2;
        });
        
        if (_isAudioEnabled) {
          _audioService.playSound('subtract');
        }
        
        Future.delayed(const Duration(milliseconds: 1500), () {
          // Step 4: Show result
          setState(() {
            _exampleStep = 3;
          });
          
          if (_isAudioEnabled) {
            _audioService.playSound('correct');
          }
          
          Future.delayed(const Duration(milliseconds: 2000), () {
            // Transition to problem mode
            setState(() {
              _isExampleMode = false;
              _exampleCompleted = true;
              _mascotState = AnimatedMascot.idle;
            });
            
            // Start problem animation
            _problemAnimationController.forward();
          });
        });
      });
    });
  }
  
  /// Play the multiplication example animation
  void _playMultiplicationExample() {
    // Step 1: Show first number
    setState(() {
      _exampleStep = 0;
      _mascotState = AnimatedMascot.thinking;
    });
    
    if (_isAudioEnabled) {
      _audioService.playSound('count');
    }
    
    _exampleAnimationController.forward().then((_) {
      // Step 2: Show second number
      setState(() {
        _exampleStep = 1;
      });
      
      if (_isAudioEnabled) {
        _audioService.playSound('count');
      }
      
      Future.delayed(const Duration(milliseconds: 1500), () {
        // Step 3: Show them multiplying
        setState(() {
          _exampleStep = 2;
        });
        
        if (_isAudioEnabled) {
          _audioService.playSound('multiply');
        }
        
        Future.delayed(const Duration(milliseconds: 1500), () {
          // Step 4: Show result
          setState(() {
            _exampleStep = 3;
          });
          
          if (_isAudioEnabled) {
            _audioService.playSound('correct');
          }
          
          Future.delayed(const Duration(milliseconds: 2000), () {
            // Transition to problem mode
            setState(() {
              _isExampleMode = false;
              _exampleCompleted = true;
              _mascotState = AnimatedMascot.idle;
            });
            
            // Start problem animation
            _problemAnimationController.forward();
          });
        });
      });
    });
  }
  
  /// Play the division example animation
  void _playDivisionExample() {
    // Step 1: Show first number
    setState(() {
      _exampleStep = 0;
      _mascotState = AnimatedMascot.thinking;
    });
    
    if (_isAudioEnabled) {
      _audioService.playSound('count');
    }
    
    _exampleAnimationController.forward().then((_) {
      // Step 2: Show second number
      setState(() {
        _exampleStep = 1;
      });
      
      if (_isAudioEnabled) {
        _audioService.playSound('count');
      }
      
      Future.delayed(const Duration(milliseconds: 1500), () {
        // Step 3: Show them dividing
        setState(() {
          _exampleStep = 2;
        });
        
        if (_isAudioEnabled) {
          _audioService.playSound('divide');
        }
        
        Future.delayed(const Duration(milliseconds: 1500), () {
          // Step 4: Show result
          setState(() {
            _exampleStep = 3;
          });
          
          if (_isAudioEnabled) {
            _audioService.playSound('correct');
          }
          
          Future.delayed(const Duration(milliseconds: 2000), () {
            // Transition to problem mode
            setState(() {
              _isExampleMode = false;
              _exampleCompleted = true;
              _mascotState = AnimatedMascot.idle;
            });
            
            // Start problem animation
            _problemAnimationController.forward();
          });
        });
      });
    });
  }
  
  /// Handle when an example animation step completes
  void _handleExampleStepComplete(int step) {
    // This is called by the ExampleAnimationDisplay widget
    // when each animation step completes
    if (step == _exampleStep) {
      // Move to the next step
      setState(() {
        _exampleStep = step + 1;
      });
    }
  }

  /// Load the user profile from shared preferences
  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userProfileString = prefs.getString('user_profile');
      
      if (userProfileString != null) {
        // The stored string is in format: {userAge: 5, userGrade: null, ...}
        // We need to parse it manually since it's not valid JSON
        if (userProfileString.startsWith('{') && userProfileString.endsWith('}')) {
          // Extract the content between { and }
          final content = userProfileString.substring(1, userProfileString.length - 1);
          
          // Split by commas to get key-value pairs
          final pairs = content.split(',');
          
          // Create a map from the pairs
          final Map<String, dynamic> userProfileMap = {};
          
          for (final pair in pairs) {
            final keyValue = pair.trim().split(':');
            if (keyValue.length == 2) {
              final key = keyValue[0].trim();
              final valueStr = keyValue[1].trim();
              
              // Parse the value based on its type
              dynamic value;
              if (valueStr == 'null') {
                value = null;
              } else if (valueStr == 'true') {
                value = true;
              } else if (valueStr == 'false') {
                value = false;
              } else if (int.tryParse(valueStr) != null) {
                value = int.parse(valueStr);
              } else {
                value = valueStr; // Treat as string
              }
              
              userProfileMap[key] = value;
            }
          }
          
          setState(() {
            _userProfile = UserProfile.fromJson(userProfileMap);
            _isLoading = false;
          });
        } else {
          // Try standard JSON parsing as fallback
          try {
            final userProfileJson = jsonDecode(userProfileString) as Map<String, dynamic>;
            setState(() {
              _userProfile = UserProfile.fromJson(userProfileJson);
              _isLoading = false;
            });
          } catch (jsonError) {
            debugPrint('Error parsing JSON: $jsonError');
            setState(() {
              _userProfile = UserProfile.fromAge(6); // Default to age 6 as fallback
              _isLoading = false;
            });
          }
        }
      } else {
        // No saved profile, create a default one
        setState(() {
          _userProfile = UserProfile.fromAge(6); // Default to age 6 only if no profile exists
          _isLoading = false;
        });
      }
      
      // Adjust difficulty based on user profile
      _adjustDifficultyBasedOnProfile();
      
      // Randomly select an object type for visualization
      _selectRandomObjectType();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      setState(() {
        _userProfile = UserProfile.fromAge(6); // Default to age 6 as fallback
        _isLoading = false;
      });
    }
  }

  /// Adjust the problem difficulty based on the user profile
  void _adjustDifficultyBasedOnProfile() {
    if (_userProfile == null) return;
    
    // Adjust number range based on difficulty level
    switch (widget.difficultyLevel) {
      case 'early-elementary':
        // For very young children (ages 4-5)
        _generateProblemInRange(1, 5);
        break;
      case 'elementary':
        // For young children (ages 6-7)
        _generateProblemInRange(1, 10);
        break;
      default:
        // Default range
        _generateProblemInRange(1, 5);
    }
  }

  /// Generate a problem with numbers in the specified range
  void _generateProblemInRange(int min, int maxValue) {
    final random = math.Random();
    
    // Generate random numbers within the range
    _firstNumber = min + random.nextInt(maxValue - min + 1);
    _secondNumber = min + random.nextInt(maxValue - min + 1);
    
    // Set operation based on the operation type
    switch (widget.operationType.toLowerCase()) {
      case 'addition':
        _operation = '+';
        _correctAnswer = _firstNumber + _secondNumber;
        break;
      case 'subtraction':
        // Ensure first number is larger for young children
        if (_firstNumber < _secondNumber) {
          final temp = _firstNumber;
          _firstNumber = _secondNumber;
          _secondNumber = temp;
        }
        _operation = '-';
        _correctAnswer = _firstNumber - _secondNumber;
        break;
      case 'multiplication':
        _operation = '×';
        _correctAnswer = _firstNumber * _secondNumber;
        break;
      case 'division':
        // Ensure division results in a whole number for young children
        _secondNumber = 1 + random.nextInt(math.min(3, maxValue));
        _correctAnswer = 1 + random.nextInt(maxValue);
        _firstNumber = _correctAnswer * _secondNumber;
        _operation = '÷';
        break;
      default:
        // Default to addition
        _operation = '+';
        _correctAnswer = _firstNumber + _secondNumber;
    }
    
    // Generate answer options
    _generateAnswerOptions();
  }

  /// Generate a new math problem
  void _generateProblem() {
    _adjustDifficultyBasedOnProfile();
    
    // Reset problem state
    setState(() {
      _selectedAnswer = null;
      _isAnswerCorrect = false;
      _showFeedback = false;
      _attemptCount = 0;
      _showHint = false;
      _problemCompleted = false;
      
      // Select a new random object type
      _selectRandomObjectType();
    });
  }

  /// Generate answer options including the correct answer
  void _generateAnswerOptions() {
    final random = math.Random();
    final Set<int> options = {_correctAnswer};
    
    // Determine the range for wrong answers
    int minValue = math.max(1, _correctAnswer - 3);
    int maxValue = _correctAnswer + 3;
    
    // Generate 3 wrong answers
    while (options.length < 4) {
      int wrongAnswer = minValue + random.nextInt(maxValue - minValue + 1);
      if (wrongAnswer != _correctAnswer) {
        options.add(wrongAnswer);
      }
    }
    
    // Convert to list and shuffle
    _answerOptions = options.toList()..shuffle();
  }

  /// Select a random object type for visualization
  void _selectRandomObjectType() {
    final random = math.Random();
    _objectType = _availableObjects[random.nextInt(_availableObjects.length)];
  }

  /// Handle when the user selects an answer
  void _handleAnswerSelected(int answer) {
    // Reset idle timer on interaction
    _resetIdleTimer();
    
    setState(() {
      _selectedAnswer = answer;
      _isAnswerCorrect = answer == _correctAnswer;
      _showFeedback = true;
      _attemptCount++;
      
      if (_isAnswerCorrect) {
        // Correct answer
        _mascotState = AnimatedMascot.happy;
        _problemCompleted = true;
        
        // Play correct sound
        if (_isAudioEnabled) {
          _audioService.playSound('correct');
        }
      } else {
        // Incorrect answer
        _mascotState = AnimatedMascot.thinking;
        
        // Play incorrect sound
        if (_isAudioEnabled) {
          _audioService.playSound('incorrect');
        }
        
        // Show hint after first wrong attempt
        if (_attemptCount >= 1) {
          _showHint = true;
        }
      }
    });
    
    // Play feedback animation
    _feedbackAnimationController.reset();
    _feedbackAnimationController.forward();
  }

  /// Move to the next problem
  void _nextProblem() {
    // Reset idle timer
    _resetIdleTimer();
    
    // Play sound
    if (_isAudioEnabled) {
      _audioService.playSound('slide');
    }
    
    // Reset animations
    _problemAnimationController.reset();
    
    // Generate new problem
    _generateProblem();
    
    // Start new problem animation
    _problemAnimationController.forward();
  }

  /// Navigate back to the home screen
  void _navigateToHome() {
    // Play sound
    if (_isAudioEnabled) {
      _audioService.playSound('click');
    }
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var fadeAnimation = animation.drive(tween);
          return FadeTransition(opacity: fadeAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  /// Reset the idle timer
  void _resetIdleTimer() {
    _idleTimer?.cancel();
    
    // If currently showing idle prompt, hide it
    if (_isIdle) {
      setState(() {
        _isIdle = false;
      });
      _idleTimeoutController.reverse();
    }
    
    // Set new timer
    _idleTimer = Timer(const Duration(seconds: 30), _onIdleTimeout);
  }

  /// Handle idle timeout
  void _onIdleTimeout() {
    setState(() {
      _isIdle = true;
      _mascotState = AnimatedMascot.waving;
    });
    
    // Show idle animation
    _idleTimeoutController.forward();
  }

  /// Get the appropriate feedback message based on answer correctness
  String _getFeedbackMessage() {
    if (_isAnswerCorrect) {
      // Correct answer messages
      final correctMessages = [
        "Great job!",
        "You got it!",
        "That's right!",
        "Awesome work!",
        "Perfect!",
      ];
      return correctMessages[math.Random().nextInt(correctMessages.length)];
    } else {
      // Incorrect answer messages
      final incorrectMessages = [
        "Let's try again!",
        "Not quite, try once more!",
        "You can do it!",
        "Almost there!",
      ];
      return incorrectMessages[math.Random().nextInt(incorrectMessages.length)];
    }
  }

  /// Get the problem instruction based on operation type
  String _getProblemInstruction() {
    switch (_operation) {
      case '+':
        return "Let's add $_firstNumber $_objectType and $_secondNumber $_objectType!";
      case '-':
        return "Let's take away $_secondNumber $_objectType from $_firstNumber $_objectType!";
      case '×':
        return "Let's count $_firstNumber groups of $_secondNumber $_objectType!";
      case '÷':
        return "Let's share $_firstNumber $_objectType into $_secondNumber equal groups!";
      default:
        return "Let's solve this problem!";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.lightBlue[100]!,
              Colors.lightBlue[50]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background decorations
              _buildBackgroundDecorations(),
              
              // Main content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top navigation bar
                    _buildTopNavigationBar(),
                    
                    const SizedBox(height: 10),
                    
                    // AI Teacher with speech bubble
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Animated mascot
                        AnimatedMascot(
                          state: _mascotState,
                          controller: _mascotController,
                          customMessage: _isIdle 
                              ? "Are you still there? Let's try together!"
                              : _getProblemInstruction(),
                        ),
                        
                        const Spacer(),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Example mode or problem mode content
                    _isExampleMode
                        ? _buildExampleModeContent()
                        : _buildProblemModeContent(),
                    
                    const SizedBox(height: 20),
                    
                    // Feedback area
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _showFeedback ? 60 : 0,
                      child: _showFeedback
                          ? _buildFeedbackArea()
                          : const SizedBox.shrink(),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Next problem button (only shown after correct answer)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _problemCompleted ? 60 : 0,
                      child: _problemCompleted
                          ? _buildNextProblemButton()
                          : const SizedBox.shrink(),
                    ),
                    
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              
              // Idle timeout prompt
              ScaleTransition(
                scale: _idleTimeoutController,
                child: _isIdle
                    ? _buildIdlePrompt()
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the top navigation bar
  Widget _buildTopNavigationBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Home button
        IconButton(
          icon: const Icon(
            Icons.home,
            color: SplashConstants.secondaryAccent,
            size: 30,
          ),
          onPressed: _navigateToHome,
        ),
        
        // Operation type title
        Text(
          widget.operationType,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: SplashConstants.textColor,
          ),
        ),
        
        // Audio toggle
        IconButton(
          icon: Icon(
            _isAudioEnabled ? Icons.volume_up : Icons.volume_off,
            color: SplashConstants.secondaryAccent,
            size: 30,
          ),
          onPressed: () {
            setState(() {
              _isAudioEnabled = !_isAudioEnabled;
              // Update audio service state
              _audioService.isAudioEnabled = _isAudioEnabled;
              
              // Play a click sound if enabling audio
              if (_isAudioEnabled) {
                _audioService.playSound('click');
              }
            });
            _resetIdleTimer();
          },
        ),
      ],
    );
  }

  /// Build the answer options buttons
  Widget _buildAnswerOptions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _answerOptions.map((option) {
        // Determine the onTap callback based on the current state
        VoidCallback? onTapCallback;
        
        if (_showFeedback) {
          // If showing feedback and answer was incorrect
          if (!_isAnswerCorrect && option == _correctAnswer) {
            // Allow tapping the correct answer after an incorrect attempt
            onTapCallback = () => _handleAnswerSelected(option);
          } else {
            // Disable tapping other options when showing feedback
            onTapCallback = null;
          }
        } else {
          // Normal state - allow tapping any option
          onTapCallback = () => _handleAnswerSelected(option);
        }
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: AnswerOptionButton(
            value: option,
            isSelected: _selectedAnswer == option,
            isCorrect: option == _correctAnswer && _showFeedback,
            onTap: onTapCallback,
          ),
        );
      }).toList(),
    );
  }

  /// Build the feedback area
  Widget _buildFeedbackArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: _isAnswerCorrect ? Colors.green[100] : Colors.orange[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _isAnswerCorrect ? Colors.green : Colors.orange,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isAnswerCorrect ? Icons.check_circle : Icons.info,
            color: _isAnswerCorrect ? Colors.green : Colors.orange,
            size: 24,
          ),
          const SizedBox(width: 10),
          Text(
            _getFeedbackMessage(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _isAnswerCorrect ? Colors.green[800] : Colors.orange[800],
            ),
          ),
        ],
      ),
    );
  }

  /// Build the next problem button
  Widget _buildNextProblemButton() {
    return ElevatedButton(
      onPressed: _nextProblem,
      style: ElevatedButton.styleFrom(
        backgroundColor: SplashConstants.primaryAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Next Problem',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward),
        ],
      ),
    );
  }

  /// Build the idle timeout prompt
  Widget _buildIdlePrompt() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Are you still there?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: SplashConstants.textColor,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Let's continue learning!",
              style: TextStyle(
                fontSize: 18,
                color: SplashConstants.textColor,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetIdleTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: SplashConstants.primaryAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "I'm here!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the background decorations
  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        // Floating stars or shapes
        Positioned(
          top: 50,
          left: 20,
          child: _buildAnimatedDecoration(Icons.star, Colors.amber, 30),
        ),
        Positioned(
          top: 120,
          right: 40,
          child: _buildAnimatedDecoration(Icons.cloud, Colors.white, 40),
        ),
        Positioned(
          bottom: 200,
          left: 30,
          child: _buildAnimatedDecoration(Icons.star, Colors.amber, 20),
        ),
        Positioned(
          bottom: 100,
          right: 50,
          child: _buildAnimatedDecoration(Icons.cloud, Colors.white, 30),
        ),
      ],
    );
  }

  /// Build an animated decoration element
  Widget _buildAnimatedDecoration(IconData icon, Color color, double size) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 4000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 10 * math.sin(value * 2 * 3.14159)),
          child: Opacity(
            opacity: 0.3,
            child: Icon(
              icon,
              color: color,
              size: size,
            ),
          ),
        );
      },
    );
  }
  
  /// Build the content for example mode
  Widget _buildExampleModeContent() {
    return Column(
      children: [
        // Example animation display
        FadeTransition(
          opacity: _exampleEntryAnimation,
          child: ExampleAnimationDisplay(
            firstNumber: _firstNumber,
            secondNumber: _secondNumber,
            operation: _operation,
            objectType: _objectType,
            animationStep: _exampleStep,
            onStepComplete: _handleExampleStepComplete,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Mode indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: SplashConstants.primaryAccent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: SplashConstants.primaryAccent,
              width: 2,
            ),
          ),
          child: const Text(
            "Watch the Example",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: SplashConstants.textColor,
            ),
          ),
        ),
      ],
    );
  }
  
  /// Build the content for problem mode
  Widget _buildProblemModeContent() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5, // Set a bounded height
      child: Column(
        children: [
          // Problem display area
          FadeTransition(
            opacity: _problemEntryAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.2),
                end: Offset.zero,
              ).animate(_problemEntryAnimation),
              child: MathProblemDisplay(
                firstNumber: _firstNumber,
                secondNumber: _secondNumber,
                operation: _operation,
                objectType: _objectType,
                showHint: _showHint,
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Interactive counting area
          Expanded(
            child: FadeTransition(
              opacity: _problemEntryAnimation,
              child: InteractiveCountingArea(
                firstNumber: _firstNumber,
                secondNumber: _secondNumber,
                operation: _operation,
                objectType: _objectType,
                showHint: _showHint,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Answer options
          FadeTransition(
            opacity: _answerOptionsAnimation,
            child: _buildAnswerOptions(),
          ),
        ],
      ),
    );
  }
}
