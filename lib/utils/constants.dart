import 'package:flutter/material.dart';

/// Constants for the home screen
class HomeConstants {
  // Text styles
  static const TextStyle greetingStyle = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: SplashConstants.textColor,
    letterSpacing: 0.5,
  );
  
  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: SplashConstants.textColor,
    letterSpacing: 0.5,
  );
  
  static const TextStyle motivationalMessageStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    color: SplashConstants.textColor,
  );
  
  // Button dimensions
  static const double mainButtonHeight = 60.0;
  static const double mainButtonRadius = 15.0;
  static const double topicCardWidth = 100.0;
  static const double topicCardHeight = 120.0;
  static const double topicCardRadius = 15.0;
  
  // Animation durations
  static const Duration buttonHoverDuration = Duration(milliseconds: 150);
  static const Duration cardTapDuration = Duration(milliseconds: 200);
}

/// Constants for the splash screen
class SplashConstants {
  /// Color palette as specified in requirements
  static const Color backgroundColor = Color(0xFFC9E4FF); // light sky blue
  static const Color primaryAccent = Color(0xFFFFB703); // gold/yellow
  static const Color secondaryAccent = Color(0xFF219EBC); // medium blue
  static const Color textColor = Color(0xFF023047); // dark navy

  /// Animation durations
  static const Duration fadeInDuration = Duration(milliseconds: 500);
  static const Duration bounceInDuration = Duration(milliseconds: 800);
  static const Duration slideUpDuration = Duration(milliseconds: 600);
  static const Duration splashDuration = Duration(seconds: 3);

  /// Text styles
  static const TextStyle appNameStyle = TextStyle(
    fontSize: 36.0,
    fontWeight: FontWeight.bold,
    color: textColor,
    letterSpacing: 1.2,
  );

  static const TextStyle taglineStyle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
    color: textColor,
    letterSpacing: 0.5,
  );

  /// App name and tagline
  static const String appName = "BrightMind";
  static const String tagline = "Let's Learn & Play!";
}

/// Constants for the Age/Grade Selection screen
class AgeGradeConstants {
  // Color palette for different age groups
  static const Map<String, Color> ageGroupColors = {
    'young': Color(0xFFB5EAD7),  // Light green for ages 5-7
    'middle': Color(0xFFC7CEEA),  // Light blue for ages 8-10
    'older': Color(0xFFFFDFD3),   // Light orange for ages 11-14+
  };
  
  // Text styles
  static const TextStyle headerStyle = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    color: SplashConstants.textColor,
    letterSpacing: 0.8,
  );
  
  static const TextStyle subheaderStyle = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    color: SplashConstants.textColor,
    letterSpacing: 0.5,
  );
  
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: SplashConstants.textColor,
  );
  
  static const TextStyle parentTeacherStyle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    color: SplashConstants.secondaryAccent,
    decoration: TextDecoration.underline,
  );
  
  // Button dimensions
  static const double buttonSize = 80.0;
  static const double buttonRadius = 20.0;
  static const double buttonPadding = 12.0;
  
  // Animation durations
  static const Duration buttonHoverDuration = Duration(milliseconds: 150);
  static const Duration buttonSelectDuration = Duration(milliseconds: 300);
  static const Duration screenTransitionDuration = Duration(milliseconds: 400);
}
