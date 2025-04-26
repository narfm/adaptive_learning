import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../utils/constants.dart';

/// A splash screen that displays for a few seconds before navigating to the main app.
class SplashScreen extends StatefulWidget {
  /// The widget to navigate to after the splash screen.
  final Widget nextScreen;

  /// Creates a splash screen.
  const SplashScreen({
    Key? key,
    required this.nextScreen,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  // Animation controllers
  late AnimationController _controller;
  late Animation<double> _backgroundFadeAnimation;
  late Animation<double> _mascotBounceAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _loadingPulseAnimation;

  // Timer for auto-navigation
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Background fade-in animation
    _backgroundFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeIn),
      ),
    );

    // Mascot bounce-in animation
    _mascotBounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.5, curve: Curves.elasticOut),
      ),
    );

    // Text slide-up animation
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.75, curve: Curves.easeOut),
      ),
    );

    // Loading pulse animation
    _loadingPulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeInOut),
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });

    // Start animations
    _controller.forward();

    // Set up auto-navigation timer
    _navigationTimer = Timer(SplashConstants.splashDuration, _navigateToNextScreen);
  }

  @override
  void dispose() {
    _controller.dispose();
    _navigationTimer?.cancel();
    super.dispose();
  }

  /// Navigate to the next screen.
  void _navigateToNextScreen() {
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
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToNextScreen, // Skip splash screen on tap
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _backgroundFadeAnimation,
              child: Container(
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated mascot
                      ScaleTransition(
                        scale: _mascotBounceAnimation,
                        child: Lottie.asset(
                          'assets/animations/mascot.json',
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // App name with slide-up animation
                      SlideTransition(
                        position: _textSlideAnimation,
                        child: Text(
                          SplashConstants.appName,
                          style: SplashConstants.appNameStyle,
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // Tagline with slide-up animation
                      SlideTransition(
                        position: _textSlideAnimation,
                        child: AnimatedTextKit(
                          animatedTexts: [
                            FadeAnimatedText(
                              SplashConstants.tagline,
                              textStyle: SplashConstants.taglineStyle,
                              duration: const Duration(milliseconds: 1500),
                            ),
                          ],
                          isRepeatingAnimation: false,
                        ),
                      ),
                      const SizedBox(height: 50),
                      
                      // Loading spinner with pulse animation
                      ScaleTransition(
                        scale: _loadingPulseAnimation,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: SplashConstants.primaryAccent.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                SplashConstants.primaryAccent,
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
