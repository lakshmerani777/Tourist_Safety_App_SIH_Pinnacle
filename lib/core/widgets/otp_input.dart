import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class OTPInput extends StatelessWidget {
  final TextEditingController? controller;
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;

  const OTPInput({
    super.key,
    this.controller,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PinCodeTextField(
      appContext: context,
      length: length,
      controller: controller,
      onCompleted: onCompleted,
      onChanged: onChanged ?? (_) {},
      keyboardType: TextInputType.number,
      animationType: AnimationType.fade,
      textStyle: AppTypography.h2,
      cursorColor: AppColors.accentBlue,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(12),
        fieldHeight: 56,
        fieldWidth: 48,
        activeFillColor: AppColors.card,
        inactiveFillColor: AppColors.card,
        selectedFillColor: AppColors.card,
        activeColor: AppColors.accentBlue,
        inactiveColor: AppColors.border,
        selectedColor: AppColors.accentBlue,
        borderWidth: 1.5,
      ),
      enableActiveFill: true,
      autoFocus: true,
    );
  }
}
