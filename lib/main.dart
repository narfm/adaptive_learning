import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/age_grade_selection_screen.dart';
import 'screens/teacher_introduction_screen.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: SplashConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: SplashConstants.primaryAccent,
          primary: SplashConstants.primaryAccent,
          secondary: SplashConstants.secondaryAccent,
        ),
        useMaterial3: true,
      ),
      home: SplashScreen(
        nextScreen: AgeGradeSelectionScreen(
          nextScreen: const HomeScreen(),
        ),
      ),
    );
  }
}
