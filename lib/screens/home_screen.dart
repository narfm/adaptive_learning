import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import '../models/user_profile.dart';
import '../utils/constants.dart';
import '../widgets/animated_mascot.dart';
import 'teacher_introduction_screen.dart';

/// The home screen of the application, providing quick access to lessons, games, and other features.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _mascotController;
  String _mascotState = AnimatedMascot.waving;
  UserProfile? _userProfile;
  bool _isLoading = true;
  String _greeting = "Hi there!";
  
  // Sample topics for the carousel
  final List<Map<String, dynamic>> _youngTopics = [
    {'name': 'Addition', 'icon': Icons.add_circle, 'color': Colors.blue},
    {'name': 'Animals', 'icon': Icons.pets, 'color': Colors.green},
    {'name': 'Colors', 'icon': Icons.color_lens, 'color': Colors.purple},
    {'name': 'Shapes', 'icon': Icons.category, 'color': Colors.orange},
    {'name': 'Letters', 'icon': Icons.text_fields, 'color': Colors.red},
  ];
  
  final List<Map<String, dynamic>> _middleTopics = [
    {'name': 'Multiplication', 'icon': Icons.calculate, 'color': Colors.blue},
    {'name': 'Plants', 'icon': Icons.eco, 'color': Colors.green},
    {'name': 'Fractions', 'icon': Icons.pie_chart, 'color': Colors.purple},
    {'name': 'Geography', 'icon': Icons.public, 'color': Colors.orange},
    {'name': 'Reading', 'icon': Icons.menu_book, 'color': Colors.red},
  ];
  
  final List<Map<String, dynamic>> _olderTopics = [
    {'name': 'Algebra', 'icon': Icons.functions, 'color': Colors.blue},
    {'name': 'Photosynthesis', 'icon': Icons.biotech, 'color': Colors.green},
    {'name': 'Physics', 'icon': Icons.science, 'color': Colors.purple},
    {'name': 'History', 'icon': Icons.history_edu, 'color': Colors.orange},
    {'name': 'Programming', 'icon': Icons.code, 'color': Colors.red},
  ];
  
  // Motivational messages
  final List<String> _motivationalMessages = [
    "You're doing great! Keep it up! 🌟",
    "Learning is an adventure! 🚀",
    "Every day is a chance to learn something new! 🌈",
    "Believe in yourself! You can do it! ✨",
    "Small steps lead to big achievements! 🏆",
  ];
  
  String _currentMotivationalMessage = "";

  @override
  void initState() {
    super.initState();
    _mascotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _loadUserProfile();
    _updateGreeting();
    _selectRandomMotivationalMessage();
  }

  @override
  void dispose() {
    _mascotController.dispose();
    super.dispose();
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
              _userProfile = UserProfile.fromAge(8); // Default to age 8 as fallback
              _isLoading = false;
            });
          }
        }
      } else {
        // No saved profile, create a default one
        setState(() {
          _userProfile = UserProfile.fromAge(8); // Default to age 8 only if no profile exists
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      setState(() {
        _userProfile = UserProfile.fromAge(8); // Default to age 8 as fallback
        _isLoading = false;
      });
    }
  }

  /// Update the greeting based on the time of day
  void _updateGreeting() {
    final hour = DateTime.now().hour;
    String timeGreeting;
    
    if (hour < 12) {
      timeGreeting = "Good morning";
    } else if (hour < 17) {
      timeGreeting = "Good afternoon";
    } else {
      timeGreeting = "Good evening";
    }
    
    setState(() {
      _greeting = "$timeGreeting, Lily!"; // Hardcoded name for now
    });
  }

  /// Select a random motivational message
  void _selectRandomMotivationalMessage() {
    final random = DateTime.now().millisecond % _motivationalMessages.length;
    setState(() {
      _currentMotivationalMessage = _motivationalMessages[random];
    });
  }

  /// Navigate to the learning screen
  void _navigateToLearning() {
    // To be implemented - navigate to learning screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Learning screen will be implemented in a future update'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Navigate to the games screen
  void _navigateToGames() {
    // To be implemented - navigate to games screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Games screen will be implemented in a future update'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Navigate to the progress screen
  void _navigateToProgress() {
    // To be implemented - navigate to progress screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Progress screen will be implemented in a future update'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Navigate to a specific topic
  void _navigateToTopic(String topicName) {
    // Navigate to the TeacherIntroductionScreen with the selected topic
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          TeacherIntroductionScreen(
            topicName: topicName,
            // For now, we'll navigate back to home screen after introduction
            // In a real implementation, this would be the actual lesson screen
            nextScreen: const HomeScreen(),
          ),
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

  /// Open settings
  void _openSettings() {
    // To be implemented - open settings drawer or modal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings will be implemented in a future update'),
        duration: Duration(seconds: 2),
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
    
    // Determine which topics to show based on user profile
    List<Map<String, dynamic>> topicsToShow;
    switch (_userProfile!.uiLevel) {
      case 'young':
        topicsToShow = _youngTopics;
        break;
      case 'middle':
        topicsToShow = _middleTopics;
        break;
      case 'older':
        topicsToShow = _olderTopics;
        break;
      default:
        topicsToShow = _middleTopics;
    }
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              SplashConstants.backgroundColor,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting and settings row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Greeting text
                    Text(
                      _greeting,
                      style: HomeConstants.greetingStyle,
                    ),
                    
                    // Settings icon
                    IconButton(
                      icon: const Icon(
                        Icons.settings,
                        color: SplashConstants.secondaryAccent,
                        size: 30,
                      ),
                      onPressed: _openSettings,
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Animated mascot
                Row(
                  children: [
                    AnimatedMascot(
                      state: _mascotState,
                      controller: _mascotController,
                      customMessage: "What would you like to learn today?",
                    ),
                    const Spacer(),
                  ],
                ),
                
                const SizedBox(height: 30),
                
                // Main action buttons
                _buildMainActionButtons(),
                
                const SizedBox(height: 30),
                
                // Topic carousel
                _buildTopicCarousel(topicsToShow),
                
                const SizedBox(height: 30),
                
                // Motivational message
                _buildMotivationalMessage(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build the main action buttons section
  Widget _buildMainActionButtons() {
    // Adjust button size based on user age
    double buttonHeight = _userProfile!.uiLevel == 'young' ? 70 : 60;
    double fontSize = _userProfile!.uiLevel == 'young' ? 20 : 18;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Start Learning button
        ElevatedButton(
          onPressed: _navigateToLearning,
          style: ElevatedButton.styleFrom(
            backgroundColor: SplashConstants.primaryAccent,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: buttonHeight / 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            'Start Learning',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const SizedBox(height: 10),
        
        // Play a Game button
        ElevatedButton(
          onPressed: _navigateToGames,
          style: ElevatedButton.styleFrom(
            backgroundColor: SplashConstants.secondaryAccent,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: buttonHeight / 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            'Play a Game',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const SizedBox(height: 10),
        
        // My Progress button
        ElevatedButton(
          onPressed: _navigateToProgress,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: SplashConstants.textColor,
            padding: EdgeInsets.symmetric(vertical: buttonHeight / 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(color: SplashConstants.secondaryAccent),
            ),
          ),
          child: Text(
            'My Progress',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  /// Build the topic carousel section
  Widget _buildTopicCarousel(List<Map<String, dynamic>> topics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Text(
          'Explore Topics',
          style: HomeConstants.sectionTitleStyle,
        ),
        
        const SizedBox(height: 10),
        
        // Scrollable topic cards
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return _buildTopicCard(
                name: topic['name'],
                icon: topic['icon'],
                color: topic['color'],
              );
            },
          ),
        ),
      ],
    );
  }

  /// Build a single topic card
  Widget _buildTopicCard({
    required String name,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => _navigateToTopic(name),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: SplashConstants.textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build the motivational message section
  Widget _buildMotivationalMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.star,
            color: SplashConstants.primaryAccent,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _currentMotivationalMessage,
              style: HomeConstants.motivationalMessageStyle,
            ),
          ),
        ],
      ),
    );
  }
}
