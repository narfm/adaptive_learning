import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../utils/constants.dart';
import '../widgets/age_button.dart';
import '../widgets/grade_button.dart';
import '../widgets/animated_mascot.dart';

/// A screen for selecting age or grade level
class AgeGradeSelectionScreen extends StatefulWidget {
  /// The widget to navigate to after selection
  final Widget nextScreen;

  const AgeGradeSelectionScreen({
    Key? key,
    required this.nextScreen,
  }) : super(key: key);

  @override
  State<AgeGradeSelectionScreen> createState() => _AgeGradeSelectionScreenState();
}

class _AgeGradeSelectionScreenState extends State<AgeGradeSelectionScreen> with SingleTickerProviderStateMixin {
  int? _selectedAge;
  String? _selectedGrade;
  bool _showGradeSelection = false;
  late AnimationController _mascotController;
  String _mascotState = AnimatedMascot.waving;

  // Define age icons
  final List<IconData> _ageIcons = [
    Icons.toys, // 5
    Icons.color_lens, // 6
    Icons.menu_book, // 7
    Icons.calculate, // 8
    Icons.science, // 9
    Icons.public, // 10
    Icons.psychology, // 11
    Icons.biotech, // 12
    Icons.computer, // 13
    Icons.smart_toy, // 14+
  ];

  // Define grade icons
  final List<IconData> _gradeIcons = [
    Icons.edit, // 1st
    Icons.create, // 2nd
    Icons.functions, // 3rd
    Icons.bar_chart, // 4th
    Icons.biotech, // 5th
    Icons.language, // 6th
    Icons.devices, // 7th
    Icons.smart_toy, // 8th
  ];

  @override
  void initState() {
    super.initState();
    _mascotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _mascotController.dispose();
    super.dispose();
  }

  /// Handle age selection
  void _selectAge(int age) {
    setState(() {
      _selectedAge = age;
      _selectedGrade = null;
      _mascotState = AnimatedMascot.happy;
    });
    
    // Save selection and navigate after a short delay
    Future.delayed(AgeGradeConstants.buttonSelectDuration, () {
      _saveSelectionAndNavigate();
    });
  }

  /// Handle grade selection
  void _selectGrade(String grade) {
    setState(() {
      _selectedGrade = grade;
      _selectedAge = null;
      _mascotState = AnimatedMascot.happy;
    });
    
    // Save selection and navigate after a short delay
    Future.delayed(AgeGradeConstants.buttonSelectDuration, () {
      _saveSelectionAndNavigate();
    });
  }

  /// Toggle between age and grade selection
  void _toggleSelectionMode() {
    setState(() {
      _showGradeSelection = !_showGradeSelection;
      _mascotState = AnimatedMascot.thinking;
    });
  }

  /// Navigate to parent/teacher setup mode
  void _navigateToParentTeacherMode() {
    // To be implemented - navigate to parent/teacher setup
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Parent/Teacher mode will be implemented in a future update'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Save the user's selection and navigate to the next screen
  Future<void> _saveSelectionAndNavigate() async {
    UserProfile profile;
    
    if (_selectedAge != null) {
      profile = UserProfile.fromAge(_selectedAge!);
    } else if (_selectedGrade != null) {
      profile = UserProfile.fromGrade(_selectedGrade!);
    } else {
      return; // No selection made
    }
    
    // Save to shared preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile', profile.toJson().toString());
    } catch (e) {
      debugPrint('Error saving user profile: $e');
    }
    
    // Navigate to next screen
    if (!mounted) return;
    
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
        transitionDuration: AgeGradeConstants.screenTransitionDuration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // App logo and settings row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // App logo placeholder
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: SplashConstants.primaryAccent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'BM',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        
                        // Settings icon
                        IconButton(
                          icon: const Icon(
                            Icons.settings,
                            color: SplashConstants.secondaryAccent,
                            size: 30,
                          ),
                          onPressed: () {
                            // Open settings drawer
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Settings will be implemented in a future update'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Animated mascot
                    AnimatedMascot(
                      state: _mascotState,
                      controller: _mascotController,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Header text
                    Text(
                      _showGradeSelection ? 'Select your grade' : 'How old are you?',
                      style: AgeGradeConstants.headerStyle,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Age or Grade selection grid
                    Expanded(
                      child: _showGradeSelection
                          ? _buildGradeGrid()
                          : _buildAgeGrid(),
                    ),
                    
                    // Toggle between age and grade
                    TextButton(
                      onPressed: _toggleSelectionMode,
                      child: Text(
                        _showGradeSelection ? 'Select by age instead' : 'Select by grade instead',
                        style: const TextStyle(
                          color: SplashConstants.secondaryAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Parent/Teacher mode link
                    GestureDetector(
                      onTap: _navigateToParentTeacherMode,
                      child: Text(
                        'I am a Parent/Teacher',
                        style: AgeGradeConstants.parentTeacherStyle,
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the grid of age buttons
  Widget _buildAgeGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 10, // Ages 5-14+
      itemBuilder: (context, index) {
        final age = index + 5; // Start from age 5
        return AgeButton(
          age: age,
          isSelected: _selectedAge == age,
          onTap: _selectAge,
          icon: _ageIcons[index],
        );
      },
    );
  }

  /// Build the grid of grade buttons
  Widget _buildGradeGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 8, // Grades 1-8
      itemBuilder: (context, index) {
        final gradeNumber = index + 1;
        final grade = _getGradeSuffix(gradeNumber);
        return GradeButton(
          grade: grade,
          gradeNumber: gradeNumber,
          isSelected: _selectedGrade == grade,
          onTap: _selectGrade,
          icon: _gradeIcons[index],
        );
      },
    );
  }

  /// Get the grade with the appropriate suffix (1st, 2nd, 3rd, etc.)
  String _getGradeSuffix(int grade) {
    if (grade == 1) {
      return '1st';
    } else if (grade == 2) {
      return '2nd';
    } else if (grade == 3) {
      return '3rd';
    } else {
      return '${grade}th';
    }
  }
}
