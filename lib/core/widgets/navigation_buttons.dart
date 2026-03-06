import 'package:flutter/material.dart';
import 'safety_button.dart';

class NavigationButtons extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;
  final String continueText;
  final bool showBack;

  const NavigationButtons({
    super.key,
    this.onBack,
    this.onContinue,
    this.continueText = 'Continue',
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBack && onBack != null) ...[
          Expanded(
            child: SafetyButton(
              text: 'Back',
              onPressed: onBack,
              variant: SafetyButtonVariant.outlined,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: SafetyButton(
            text: continueText,
            onPressed: onContinue,
          ),
        ),
      ],
    );
  }
}
