import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// A custom button widget for grade selection with animations and visual feedback
class GradeButton extends StatefulWidget {
  /// The grade value this button represents (e.g., "1st", "2nd")
  final String grade;
  
  /// The numeric value of the grade (e.g., 1, 2)
  final int gradeNumber;
  
  /// Whether this button is currently selected
  final bool isSelected;
  
  /// Callback function when the button is tapped
  final Function(String) onTap;
  
  /// Icon to display on the button
  final IconData icon;

  const GradeButton({
    Key? key,
    required this.grade,
    required this.gradeNumber,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  }) : super(key: key);

  @override
  State<GradeButton> createState() => _GradeButtonState();
}

class _GradeButtonState extends State<GradeButton> with SingleTickerProviderStateMixin {
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

  /// Determine the button color based on grade level and selection state
  Color _getButtonColor() {
    if (widget.isSelected) {
      return SplashConstants.primaryAccent;
    }
    
    if (widget.gradeNumber >= 1 && widget.gradeNumber <= 2) {
      return AgeGradeConstants.ageGroupColors['young']!;
    } else if (widget.gradeNumber >= 3 && widget.gradeNumber <= 5) {
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
        onTap: () => widget.onTap(widget.grade),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: AgeGradeConstants.buttonSelectDuration,
            width: AgeGradeConstants.buttonSize * 1.2, // Slightly wider for grade text
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
                  widget.grade,
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
