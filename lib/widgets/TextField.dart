import 'package:flutter/material.dart';

enum InputType { text, password, email }

class CustomTextField extends StatelessWidget {
  final String label;
  final InputType inputType;
  final bool obscureText;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final ValueChanged<String>? onChanged;
  final Color? suffixIconColor;
  final TextEditingController? controller;
  final String? errorText;

  const CustomTextField({
    super.key,
    required this.label,
    this.inputType = InputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.onChanged,
    this.suffixIconColor,
    this.controller,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    TextInputType keyboardType;

    switch (inputType) {
      case InputType.email:
        keyboardType = TextInputType.emailAddress;
        break;
      case InputType.password:
        keyboardType = TextInputType.visiblePassword;
        break;
      default:
        keyboardType = TextInputType.text;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 22, color: Colors.black),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: Theme.of(context).textTheme.bodySmall,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            errorText: errorText,
            errorStyle: const TextStyle(color: Colors.red, fontSize: 20),
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon, color: suffixIconColor ?? Colors.grey[700]),
                    onPressed: onSuffixIconPressed,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
