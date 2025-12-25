import 'package:flutter/material.dart';

class ButtonComponent extends StatefulWidget {
  final double width;
  final double height;
  final String textValue;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;

  ButtonComponent(
    this.width,
    this.height,
    this.textValue, {
    this.onTap,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<ButtonComponent> createState() => _ButtonComponentState();
}

class _ButtonComponentState extends State<ButtonComponent> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final Color mainBlue =
        widget.backgroundColor ?? Color(0xFF1976D2); // Blue 700
    final Color txtColor = widget.textColor ?? Colors.white;

    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: Duration(milliseconds: 90),
      child: Material(
        color: Colors.transparent,
        elevation: 6,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onTap,
          onHighlightChanged: (pressed) {
            setState(() {
              _isPressed = pressed;
            });
          },
          splashColor: Colors.white.withOpacity(0.18),
          highlightColor: Colors.white.withOpacity(0.10),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: mainBlue,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: mainBlue.withOpacity(0.18),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.textValue,
                style: TextStyle(
                  color: txtColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
