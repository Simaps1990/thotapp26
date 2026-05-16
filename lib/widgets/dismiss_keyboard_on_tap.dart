import 'package:flutter/material.dart';

/// A widget that dismisses the keyboard when tapping outside of text fields
class DismissKeyboardOnTap extends StatelessWidget {
  final Widget child;

  const DismissKeyboardOnTap({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus && currentFocus.hasFocus) {
          currentFocus.unfocus();
        }
      },
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
