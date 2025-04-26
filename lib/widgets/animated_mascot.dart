import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// A widget that displays an animated mascot with different states
class AnimatedMascot extends StatefulWidget {
  /// The current state of the mascot animation
  final String state;
  
  /// The controller for the Lottie animation
  final AnimationController controller;
  
  /// Optional callback when the animation completes
  final Function? onComplete;

  /// Available mascot states
  static const String idle = 'idle';
  static const String waving = 'waving';
  static const String happy = 'happy';
  static const String thinking = 'thinking';

  const AnimatedMascot({
    Key? key,
    required this.state,
    required this.controller,
    this.onComplete,
  }) : super(key: key);

  @override
  State<AnimatedMascot> createState() => _AnimatedMascotState();
}

class _AnimatedMascotState extends State<AnimatedMascot> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Main mascot animation
        Lottie.asset(
          'assets/animations/mascot.json',
          controller: widget.controller,
          width: 150,
          height: 150,
          fit: BoxFit.contain,
          onLoaded: (composition) {
            // Configure the animation controller
            widget.controller.duration = composition.duration;
            
            // Start the animation
            if (!widget.controller.isAnimating) {
              widget.controller.forward();
            }
            
            // Set up completion callback
            if (widget.onComplete != null) {
              widget.controller.addStatusListener((status) {
                if (status == AnimationStatus.completed) {
                  widget.onComplete!();
                }
              });
            }
          },
        ),
        
        // Speech bubble (only shown in certain states)
        if (widget.state == AnimatedMascot.waving || widget.state == AnimatedMascot.thinking)
          Positioned(
            top: 20,
            right: 0,
            child: _buildSpeechBubble(),
          ),
      ],
    );
  }

  /// Build a speech bubble with text based on the current state
  Widget _buildSpeechBubble() {
    String message = '';
    
    switch (widget.state) {
      case AnimatedMascot.waving:
        message = 'How old are you?';
        break;
      case AnimatedMascot.thinking:
        message = 'Hmm...';
        break;
      default:
        return const SizedBox.shrink(); // No speech bubble for other states
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
