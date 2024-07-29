import 'package:flutter/material.dart';
import 'package:usrcare/utils/ColorUtil.dart';

enum ButtonType {
  primary,
  secondary,
  circular,
}

class CustomButton extends StatelessWidget {
  final dynamic text;
  final ButtonType type;
  final VoidCallback onPressed;
  final int? maxFontSize;
  final int? CircularBtnSize;
  final Icon? icon;
  final bool? disabled;

  const CustomButton({
    required this.text,
    required this.type,
    required this.onPressed,
    this.CircularBtnSize,
    this.maxFontSize,
    this.icon,
    this.disabled,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
        Color backgroundColor;
        Color foregroundColor;

        if (type == ButtonType.primary) {
          backgroundColor = ColorUtil.primary;
          foregroundColor = ColorUtil.secondary;
        } else {
          backgroundColor = ColorUtil.secondary;
          foregroundColor = ColorUtil.primary;
        }

        return SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: disabled ?? false ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              textStyle: TextStyle(fontSize: maxFontSize?.toDouble() ?? 28.0, fontWeight: FontWeight.bold),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: text is String ? Text(text) : text,
            ),
          ),
        );

      case ButtonType.circular:
        final double buttonSize = CircularBtnSize?.toDouble() ?? 50.0;
        return Container(
          height: buttonSize,
          width: buttonSize,
          decoration: BoxDecoration(
            border: Border.all(color: ColorUtil.grey),
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: IconButton(
            icon: icon ?? const Icon(Icons.arrow_back, color: Colors.black),
            iconSize: buttonSize * 0.6,
            onPressed: onPressed,
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
