import 'package:flutter/material.dart';

class CalculatorButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isOperation;
  final bool isClear;
  final bool isEquals;
  final bool isBackspace;
  final Animation<double>? animation;

  const CalculatorButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOperation = false,
    this.isClear = false,
    this.isEquals = false,
    this.isBackspace = false,
    this.animation,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    if (isClear) {
      backgroundColor = Colors.red;
    } else if (isEquals) {
      backgroundColor = Colors.green;
    } else if (isOperation) {
      backgroundColor = Theme.of(context).primaryColor;
    } else if (isBackspace) {
      backgroundColor = Colors.orange;
    } else {
      backgroundColor = Colors.grey;
    }

    Widget buttonContent = isBackspace
        ? const Icon(Icons.backspace, color: Colors.white, size: 24)
        : Text(
            text,
            style: TextStyle(
              fontSize: 24,
              color: isOperation || isClear || isEquals || isBackspace
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          );

    Widget button = Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Center(child: buttonContent),
        ),
      ),
    );

    if (animation != null) {
      return AnimatedBuilder(
        animation: animation!,
        builder: (context, child) {
          return Transform.scale(
            scale: animation!.value,
            child: button,
          );
        },
      );
    }

    return button;
  }
}