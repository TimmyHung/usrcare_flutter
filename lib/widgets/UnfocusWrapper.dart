import 'package:flutter/material.dart';

class UnfocusWrapper extends StatelessWidget {
  final Widget child;

  const UnfocusWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: child,
    );
  }
} 