import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math';
import '../models/user_profile.dart';
import '../utils/constants.dart';
import '../widgets/animated_mascot.dart';

/// A screen that introduces the AI teacher character to the user
class TeacherIntroductionScreen extends StatefulWidget {
  /// The widget to navigate to after the introduction
  final Widget nextScreen;
  
  /// The name of the topic that was selected
  final String topicName;

  const TeacherIntroductionScreen({
    Key? key,
    required this.nextScreen,
    required this.topicName,
  }) : super(key: key);

  @override
  State<TeacherIntroductionScreen> createState() => _TeacherIntroductionScreenState();
}

class _TeacherIntroductionScreenState extends State<TeacherIntroductionScreen>
    with TickerProviderStateMixin {
  late AnimationController _mascotController;
  String _mascotState = AnimatedMascot.waving;
  UserProfile? _userProfile;
  bool _isLoading = true;
  String _userName = '';
  bool _showStartButton = false;
  Timer? _autoTimer;

  // Animation controllers
  late AnimationController _textAnimationController;
  late Animation<double> _textAnimation;
  late Animation<double> _buttonAnimation;

  @override
  void initState() {
    super.initState();
    _mascotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _textAnimationController = AnimationController(
      vsync: this,
      duration: TeacherIntroConstants.textTypingDuration,
    );

    _textAnimation = CurvedAnimation(
      parent: _textAnimationController,
      curve: Curves.easeInOut,
    );

    _buttonAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: const Interval(0.5, 1.0),
      ),
    );

    _loadUserProfile();

    // Start text animation after a short delay
    Future.delayed(TeacherIntroConstants.fadeInDuration, () {
      _textAnimationController.forward();
    });

    // Show start button after a delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showStartButton = true;
      });
      
      // Start auto-continue timer
      _startAutoTimer();
    });
  }

  @override
  void dispose() {
    _mascotController.dispose();
    _textAnimationController.dispose();
    _autoTimer?.cancel();
    super.dispose();
  }

  /// Load the user profile from shared preferences
  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userProfileString = prefs.getString('user_profile');
      
      if (userProfileString != null) {
        // This is a simplified approach - in a real app, we'd parse the JSON properly
        // For now, we'll create a default profile
        setState(() {
          _userProfile = UserProfile.fromAge(8); // Default to age 8 for testing
          _isLoading = false;
        });
      } else {
        setState(() {
          _userProfile = UserProfile.fromAge(8); // Default to age 8 for testing
          _isLoading = false;
        });
      }
      
      // For demo purposes, we'll use a hardcoded name
      // In a real app, this would come from the user profile
      setState(() {
        _userName = 'Alex';
      });
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      setState(() {
        _userProfile = UserProfile.fromAge(8); // Default to age 8 for testing
        _isLoading = false;
      });
    }
  }

  /// Start the auto-continue timer
  void _startAutoTimer() {
    _autoTimer = Timer(TeacherIntroConstants.autoTimerDuration, () {
      // Pulse the button to remind the user to tap it
      _textAnimationController.repeat();
    });
  }

  /// Navigate to the next screen
  void _navigateToNextScreen() {
    _autoTimer?.cancel();
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => widget.nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var fadeAnimation = animation.drive(tween);

          return FadeTransition(
            opacity: fadeAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  /// Get the welcome message based on the user's age/grade and selected topic
  String _getWelcomeMessage() {
    if (_userProfile == null) return "Hi there! Let's learn together!";
    
    String greeting = _userName.isNotEmpty ? "Hi $_userName!" : "Hi there!";
    
    // Include the topic name in the welcome message
    return "$greeting Let's learn about ${widget.topicName}!";
  }

  /// Get the background decoration based on the user's age/grade
  BoxDecoration _getBackgroundDecoration() {
    if (_userProfile == null) return _getDefaultBackgroundDecoration();
    
    switch (_userProfile!.uiLevel) {
      case 'young':
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.lightBlue[100]!,
              Colors.lightBlue[50]!,
            ],
          ),
        );
      case 'middle':
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[100]!,
              Colors.blue[50]!,
            ],
          ),
        );
      case 'older':
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.indigo[100]!,
              Colors.indigo[50]!,
            ],
          ),
        );
      default:
        return _getDefaultBackgroundDecoration();
    }
  }

  /// Get the default background decoration
  BoxDecoration _getDefaultBackgroundDecoration() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          SplashConstants.backgroundColor,
          Colors.white,
        ],
      ),
    );
  }

  /// Get the button style based on the user's age/grade
  ButtonStyle _getButtonStyle() {
    if (_userProfile == null) return _getDefaultButtonStyle();
    
    switch (_userProfile!.uiLevel) {
      case 'young':
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.pink[400],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TeacherIntroConstants.youngButtonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        );
      case 'middle':
        return ElevatedButton.styleFrom(
          backgroundColor: SplashConstants.primaryAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TeacherIntroConstants.middleButtonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        );
      case 'older':
        return ElevatedButton.styleFrom(
          backgroundColor: SplashConstants.secondaryAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TeacherIntroConstants.olderButtonRadius),
          ),
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        );
      default:
        return _getDefaultButtonStyle();
    }
  }

  /// Get the default button style
  ButtonStyle _getDefaultButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: SplashConstants.primaryAccent,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TeacherIntroConstants.middleButtonRadius),
      ),
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
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
        decoration: _getBackgroundDecoration(),
        child: SafeArea(
          child: Stack(
            children: [
              // Background animations
              _buildBackgroundAnimations(),
              
              // Main content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 1),
                    
                    // Animated mascot
                    AnimatedMascot(
                      state: _mascotState,
                      controller: _mascotController,
                      customMessage: "Hi there! I'm Alex, your learning buddy! Let's learn about ${widget.topicName}!",
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Welcome text bubble
                    FadeTransition(
                      opacity: _textAnimation,
                      child: _buildWelcomeTextBubble(),
                    ),
                    
                    const Spacer(flex: 1),
                    
                    // Let's Start button
                    if (_showStartButton)
                      ScaleTransition(
                        scale: _buttonAnimation,
                        child: ElevatedButton(
                          onPressed: _navigateToNextScreen,
                          style: _getButtonStyle(),
                          child: const Text("Let's Start!"),
                        ),
                      ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the welcome text bubble
  Widget _buildWelcomeTextBubble() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            _getWelcomeMessage(),
            style: TeacherIntroConstants.welcomeTextStyle,
            textAlign: TextAlign.center,
          ),
          
          // Optional: Voice playback controls
          // Uncomment if implementing audio playback
          /*
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay, color: SplashConstants.secondaryAccent),
                onPressed: () {
                  // Replay audio
                },
              ),
              IconButton(
                icon: const Icon(Icons.volume_up, color: SplashConstants.secondaryAccent),
                onPressed: () {
                  // Toggle volume
                },
              ),
            ],
          ),
          */
        ],
      ),
    );
  }

  /// Build the background animations based on user age and selected topic
  Widget _buildBackgroundAnimations() {
    if (_userProfile == null) return const SizedBox.shrink();
    
    // First, check if we should show a topic-specific animation
    Widget? topicAnimation = _buildTopicSpecificAnimation();
    if (topicAnimation != null) {
      return topicAnimation;
    }
    
    // If no topic-specific animation, fall back to age-based animations
    switch (_userProfile!.uiLevel) {
      case 'young':
        return _buildYoungBackgroundAnimation();
      case 'middle':
        return _buildMiddleBackgroundAnimation();
      case 'older':
        return _buildOlderBackgroundAnimation();
      default:
        return const SizedBox.shrink();
    }
  }
  
  /// Build a topic-specific animation based on the selected topic
  Widget? _buildTopicSpecificAnimation() {
    String topic = widget.topicName.toLowerCase();
    
    // Math-related topics
    if (topic.contains('addition') || 
        topic.contains('multiplication') || 
        topic.contains('algebra') || 
        topic.contains('fractions')) {
      return _buildMathAnimation();
    }
    
    // Science-related topics
    else if (topic.contains('photosynthesis') || 
             topic.contains('plants') || 
             topic.contains('science') || 
             topic.contains('biology')) {
      return _buildScienceAnimation();
    }
    
    // Animal-related topics
    else if (topic.contains('animals')) {
      return _buildAnimalsAnimation();
    }
    
    // Return null if no specific animation for this topic
    return null;
  }
  
  /// Build an animation for math-related topics
  Widget _buildMathAnimation() {
    return Stack(
      children: [
        // Falling numbers and math symbols
        Positioned(
          top: 40,
          left: 30,
          child: _buildAnimatedMathElement('+', 30, 3000, 0),
        ),
        Positioned(
          top: 100,
          right: 40,
          child: _buildAnimatedMathElement('=', 25, 3500, 500),
        ),
        Positioned(
          bottom: 200,
          left: 50,
          child: _buildAnimatedMathElement('7', 28, 4000, 1000),
        ),
        Positioned(
          bottom: 150,
          right: 60,
          child: _buildAnimatedMathElement('×', 32, 3500, 1500),
        ),
        Positioned(
          top: 180,
          left: 100,
          child: _buildAnimatedMathElement('3', 26, 4500, 2000),
        ),
      ],
    );
  }
  
  /// Build an animation for science/photosynthesis-related topics
  Widget _buildScienceAnimation() {
    return Stack(
      children: [
        // Sun, plants, and science elements
        Positioned(
          top: 40,
          right: 40,
          child: _buildAnimatedSun(50, 5000),
        ),
        Positioned(
          bottom: 100,
          left: 30,
          child: _buildAnimatedPlant(40, 4000),
        ),
        Positioned(
          top: 150,
          left: 50,
          child: _buildAnimatedClassroomElement(Icons.eco, 30, 3500, 500),
        ),
        Positioned(
          bottom: 200,
          right: 70,
          child: _buildAnimatedClassroomElement(Icons.water_drop, 25, 4500, 1000),
        ),
      ],
    );
  }
  
  /// Build an animation for animal-related topics
  Widget _buildAnimalsAnimation() {
    return Stack(
      children: [
        // Animal silhouettes
        Positioned(
          top: 50,
          left: 30,
          child: _buildAnimatedClassroomElement(Icons.pets, 35, 4000, 0),
        ),
        Positioned(
          top: 120,
          right: 40,
          child: _buildAnimatedClassroomElement(Icons.cruelty_free, 30, 3500, 500),
        ),
        Positioned(
          bottom: 180,
          left: 50,
          child: _buildAnimatedClassroomElement(Icons.emoji_nature, 32, 4500, 1000),
        ),
        Positioned(
          bottom: 120,
          right: 60,
          child: _buildAnimatedClassroomElement(Icons.spa, 28, 3000, 1500),
        ),
      ],
    );
  }
  
  /// Build an animated math element
  Widget _buildAnimatedMathElement(String text, double size, int duration, int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: duration),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 10 * sin(value * 2 * 3.14159)),
          child: Opacity(
            opacity: TeacherIntroConstants.backgroundElementOpacity,
            child: Text(
              text,
              style: TextStyle(
                color: SplashConstants.secondaryAccent,
                fontSize: size,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// Build an animated sun for photosynthesis
  Widget _buildAnimatedSun(double size, int duration) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: duration),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.rotate(
          angle: 0.1 * sin(value * 2 * 3.14159),
          child: Opacity(
            opacity: TeacherIntroConstants.backgroundElementOpacity,
            child: Icon(
              Icons.wb_sunny,
              color: Colors.amber,
              size: size,
            ),
          ),
        );
      },
    );
  }
  
  /// Build an animated plant for photosynthesis
  Widget _buildAnimatedPlant(double size, int duration) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: Duration(milliseconds: duration),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: TeacherIntroConstants.backgroundElementOpacity,
            child: Icon(
              Icons.local_florist,
              color: Colors.green,
              size: size,
            ),
          ),
        );
      },
    );
  }

  /// Build the background animation for young users (5-7 years)
  Widget _buildYoungBackgroundAnimation() {
    return Stack(
      children: [
        // Floating stars or bubbles
        Positioned(
          top: 50,
          left: 20,
          child: _buildAnimatedStar(30, 3000, 0),
        ),
        Positioned(
          top: 120,
          right: 40,
          child: _buildAnimatedStar(20, 4000, 500),
        ),
        Positioned(
          bottom: 200,
          left: 60,
          child: _buildAnimatedStar(25, 3500, 1000),
        ),
        Positioned(
          bottom: 100,
          right: 80,
          child: _buildAnimatedStar(35, 4500, 1500),
        ),
      ],
    );
  }

  /// Build the background animation for middle users (8-11 years)
  Widget _buildMiddleBackgroundAnimation() {
    return Stack(
      children: [
        // Classroom elements
        Positioned(
          top: 40,
          left: 20,
          child: _buildAnimatedClassroomElement(Icons.menu_book, 30, 4000, 0),
        ),
        Positioned(
          top: 100,
          right: 30,
          child: _buildAnimatedClassroomElement(Icons.science, 25, 3500, 500),
        ),
        Positioned(
          bottom: 180,
          left: 40,
          child: _buildAnimatedClassroomElement(Icons.calculate, 28, 4500, 1000),
        ),
        Positioned(
          bottom: 120,
          right: 50,
          child: _buildAnimatedClassroomElement(Icons.public, 32, 3000, 1500),
        ),
      ],
    );
  }

  /// Build the background animation for older users (12-14 years)
  Widget _buildOlderBackgroundAnimation() {
    return Stack(
      children: [
        // Tech/science elements
        Positioned(
          top: 60,
          left: 30,
          child: _buildAnimatedTechElement(Icons.code, 28, 4000, 0),
        ),
        Positioned(
          top: 130,
          right: 40,
          child: _buildAnimatedTechElement(Icons.biotech, 25, 3500, 500),
        ),
        Positioned(
          bottom: 200,
          left: 50,
          child: _buildAnimatedTechElement(Icons.psychology, 30, 4500, 1000),
        ),
        Positioned(
          bottom: 140,
          right: 60,
          child: _buildAnimatedTechElement(Icons.smart_toy, 32, 3000, 1500),
        ),
      ],
    );
  }

  /// Build an animated star for young users
  Widget _buildAnimatedStar(double size, int duration, int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: duration),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, TeacherIntroConstants.animationAmplitude * sin(value * 2 * 3.14159)),
          child: Opacity(
            opacity: TeacherIntroConstants.backgroundElementOpacity,
            child: Icon(
              Icons.star,
              color: Colors.amber,
              size: size,
            ),
          ),
        );
      },
    );
  }

  /// Build an animated classroom element for middle users
  Widget _buildAnimatedClassroomElement(IconData icon, double size, int duration, int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: duration),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(5 * sin(value * 2 * 3.14159), 5 * cos(value * 2 * 3.14159)),
          child: Opacity(
            opacity: TeacherIntroConstants.backgroundElementOpacity,
            child: Icon(
              icon,
              color: SplashConstants.secondaryAccent,
              size: size,
            ),
          ),
        );
      },
    );
  }

  /// Build an animated tech element for older users
  Widget _buildAnimatedTechElement(IconData icon, double size, int duration, int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: duration),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.rotate(
          angle: 0.1 * sin(value * 2 * 3.14159),
          child: Opacity(
            opacity: TeacherIntroConstants.backgroundElementOpacity,
            child: Icon(
              icon,
              color: SplashConstants.secondaryAccent,
              size: size,
            ),
          ),
        );
      },
    );
  }
}
