import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// A custom button widget for age selection with animations and visual feedback
class AgeButton extends StatefulWidget {
  /// The age value this button represents
  final int age;
  
  /// Whether this button is currently selected
  final bool isSelected;
  
  /// Callback function when the button is tapped
  final Function(int) onTap;
  
  /// Icon to display on the button
  final IconData icon;

  const AgeButton({
    Key? key,
    required this.age,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  }) : super(key: key);

  @override
  State<AgeButton> createState() => _AgeButtonState();
}

class _AgeButtonState extends State<AgeButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AgeGradeConstants.buttonHoverDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Determine the button color based on age group and selection state
  Color _getButtonColor() {
    if (widget.isSelected) {
      return SplashConstants.primaryAccent;
    }
    
    if (widget.age >= 5 && widget.age <= 7) {
      return AgeGradeConstants.ageGroupColors['young']!;
    } else if (widget.age >= 8 && widget.age <= 10) {
      return AgeGradeConstants.ageGroupColors['middle']!;
    } else {
      return AgeGradeConstants.ageGroupColors['older']!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
          _controller.forward();
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
          _controller.reverse();
        });
      },
      child: GestureDetector(
        onTap: () => widget.onTap(widget.age),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: AgeGradeConstants.buttonSelectDuration,
            width: AgeGradeConstants.buttonSize,
            height: AgeGradeConstants.buttonSize,
            decoration: BoxDecoration(
              color: _getButtonColor(),
              borderRadius: BorderRadius.circular(AgeGradeConstants.buttonRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(widget.isSelected || _isHovered ? 0.2 : 0.1),
                  blurRadius: widget.isSelected || _isHovered ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
              border: widget.isSelected
                  ? Border.all(color: SplashConstants.secondaryAccent, width: 3)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 24,
                  color: SplashConstants.textColor,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.age == 14 ? '14+' : widget.age.toString(),
                  style: AgeGradeConstants.buttonTextStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
