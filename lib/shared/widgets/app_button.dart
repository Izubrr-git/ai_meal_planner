import 'package:flutter/material.dart';

enum ButtonVariant { filled, outlined }

class AppButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon;
  final ButtonVariant variant;
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.variant = ButtonVariant.filled,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = variant == ButtonVariant.filled
        ? ElevatedButton.styleFrom(
      minimumSize: fullWidth ? const Size(double.infinity, 48) : null,
    )
        : OutlinedButton.styleFrom(
      minimumSize: fullWidth ? const Size(double.infinity, 48) : null,
    );

    final child = isLoading
        ? const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    )
        : Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Text(text),
      ],
    );

    if (variant == ButtonVariant.filled) {
      return ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: child,
      );
    } else {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: child,
      );
    }
  }
}